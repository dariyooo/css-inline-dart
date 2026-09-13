// Turns the upstream `css-inline` Rust test files into Dart test cases.
//
// Run after bumping the vendored crate:
//
//     dart run tool/generate_upstream_tests.dart
//
// It reads `css-inline/tests/test_inlining.rs` and `test_selectors.rs` from
// GitHub at the tag the crate was vendored from, matches the shapes it knows,
// and writes `test/upstream_test_cases.dart`. Every test function it cannot
// match is listed with a reason in the generated file's header, so what is not
// covered stays visible.
import 'dart:convert';
import 'dart:io';

const _defaultRevision = 'd60b8a3';

const _sourceFiles = ['test_inlining.rs', 'test_selectors.rs'];

const _outputPath = 'test/upstream_test_cases.dart';

/// Rust builder setters and struct fields that map onto an [InlineOptions]
/// field of the same meaning. Anything outside this map makes a test
/// unparseable rather than being silently dropped.
const _optionNames = <String, String>{
  'inline_style_tags': 'inlineStyleTags',
  'keep_style_tags': 'keepStyleTags',
  'keep_link_tags': 'keepLinkTags',
  'keep_at_rules': 'keepAtRules',
  'minify_css': 'minifyCss',
  'load_remote_stylesheets': 'loadRemoteStylesheets',
  'remove_inlined_selectors': 'removeInlinedSelectors',
  'preallocate_node_capacity': 'preallocateNodeCapacity',
  'extra_css': 'extraCss',
};

Future<void> main(List<String> arguments) async {
  final revision = _argument(arguments, '--revision') ?? _defaultRevision;
  final localDirectory = _argument(arguments, '--source-dir');

  final extracted = <_Extracted>[];
  final rejected = <_Rejected>[];

  for (final file in _sourceFiles) {
    final source = localDirectory == null
        ? await _download(revision, file)
        : File('$localDirectory/$file').readAsStringSync();
    final result = _parseFile(file, source);
    extracted.addAll(result.extracted);
    rejected.addAll(result.rejected);
  }

  File(_outputPath).writeAsStringSync(_render(revision, extracted, rejected));

  stdout.writeln('${extracted.length} cases -> $_outputPath');
  stdout.writeln('${rejected.length} test functions rejected');
}

/// The upstream test source for [file] at [revision].
Future<String> _download(String revision, String file) async {
  final uri = Uri.parse(
    'https://raw.githubusercontent.com/Stranger6667/css-inline/'
    '$revision/css-inline/tests/$file',
  );
  final client = HttpClient();
  try {
    final response = await (await client.getUrl(uri)).close();
    if (response.statusCode != 200) {
      throw StateError('GET $uri returned ${response.statusCode}');
    }
    return response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

String? _argument(List<String> arguments, String name) {
  final prefix = '$name=';
  for (final argument in arguments) {
    if (argument.startsWith(prefix)) return argument.substring(prefix.length);
  }
  return null;
}

/// One test function's worth of source, split off from the file around it.
class _Function {
  _Function(this.name, this.body, this.attributes);

  final String name;
  final String body;
  final List<String> attributes;
}

/// A case the generator produced.
class _Extracted {
  _Extracted({
    required this.name,
    required this.file,
    required this.html,
    required this.expected,
    required this.options,
    this.fragmentCss,
  });

  final String name;
  final String file;
  final String html;
  final String expected;

  /// The non-default options, already spelled with Dart field names.
  final Map<String, String> options;

  /// Set when the case calls `inlineFragment` rather than `inlineDocument`.
  final String? fragmentCss;
}

/// A test function the generator refused, and why.
class _Rejected {
  _Rejected(this.name, this.file, this.reason);

  final String name;
  final String file;
  final String reason;
}

class _FileResult {
  _FileResult(this.extracted, this.rejected);

  final List<_Extracted> extracted;
  final List<_Rejected> rejected;
}

_FileResult _parseFile(String file, String source) {
  final constants = _parseConstants(source);
  final extracted = <_Extracted>[];
  final rejected = <_Rejected>[];

  for (final function in _splitFunctions(source)) {
    if (!function.attributes.any((a) => a.startsWith('#[test'))) continue;

    final skip = _skipReason(function);
    if (skip != null) {
      rejected.add(_Rejected(function.name, file, skip));
      continue;
    }

    final macroCases = _parseAssertInlined(function, file);
    if (macroCases.isNotEmpty) {
      extracted.addAll(macroCases);
      continue;
    }

    final optionCase = _parseOptionDriven(function, file, constants);
    if (optionCase != null) {
      extracted.add(optionCase);
      continue;
    }

    rejected.add(
      _Rejected(function.name, file, 'no recognised assertion shape'),
    );
  }

  return _FileResult(extracted, rejected);
}

/// Why this function can never become a case, or null if it might.
String? _skipReason(_Function function) {
  final body = function.body;
  if (function.attributes.any((a) => a.startsWith('#[test_case'))) {
    return 'parameterised by #[test_case], asserts on error strings';
  }
  if (function.attributes.any((a) => a.contains('feature ='))) {
    return 'gated behind a cargo feature this build does not enable';
  }
  if (function.name.endsWith('_large_document')) {
    return 'performance test over a generated document';
  }
  if (body.contains('assert_http(')) {
    return 'needs the http feature and a local server';
  }
  if (body.contains('assert_file(') || body.contains('assert_file_error(')) {
    return 'needs the file feature and an on-disk stylesheet';
  }
  if (body.contains('expect_err')) {
    return 'asserts on an error string, which the binding rewords';
  }
  if (body.contains('StylesheetResolver')) {
    return 'installs a custom Rust resolver, which the binding does not expose';
  }
  if (body.contains('inline_to(') || body.contains('inline_fragment_to(')) {
    return 'writes into a Rust sink, which the binding does not expose';
  }
  if (body.contains('assert!(') && !body.contains('assert_eq!(')) {
    return 'asserts a predicate rather than an expected document';
  }
  return null;
}

/// A Rust string literal and where it ended.
class _Literal {
  _Literal(this.value, this.end);

  final String value;
  final int end;
}

/// The Rust string literal starting at [start], or null if that is not where
/// one starts.
///
/// Handles `"..."` with escapes, `r"..."`, and `r#"..."#` at any hash depth.
_Literal? _readLiteral(String source, int start) {
  var index = start;
  while (index < source.length && _isSpace(source[index])) {
    index++;
  }
  if (index >= source.length) return null;

  if (source[index] == 'r') {
    var hashes = 0;
    var cursor = index + 1;
    while (cursor < source.length && source[cursor] == '#') {
      hashes++;
      cursor++;
    }
    if (cursor >= source.length || source[cursor] != '"') return null;
    final terminator = '"${'#' * hashes}';
    final close = source.indexOf(terminator, cursor + 1);
    if (close < 0) return null;
    return _Literal(
      source.substring(cursor + 1, close),
      close + terminator.length,
    );
  }

  if (source[index] != '"') return null;
  final buffer = StringBuffer();
  var cursor = index + 1;
  while (cursor < source.length) {
    final character = source[cursor];
    if (character == r'\') {
      cursor++;
      if (cursor >= source.length) return null;
      buffer.write(_unescape(source[cursor]));
      cursor++;
      continue;
    }
    if (character == '"') return _Literal(buffer.toString(), cursor + 1);
    buffer.write(character);
    cursor++;
  }
  return null;
}

String _unescape(String character) => switch (character) {
  'n' => '\n',
  't' => '\t',
  'r' => '\r',
  _ => character,
};

bool _isSpace(String character) =>
    character == ' ' ||
    character == '\n' ||
    character == '\t' ||
    character == '\r';

/// The `const NAME: &str = <literal>;` bindings in [source], which the
/// fragment tests refer to by name.
Map<String, String> _parseConstants(String source) {
  final constants = <String, String>{};
  final pattern = RegExp(r'const\s+([A-Z_][A-Z0-9_]*)\s*:\s*&str\s*=');
  for (final match in pattern.allMatches(source)) {
    final literal = _readLiteral(source, match.end);
    if (literal != null) constants[match.group(1)!] = literal.value;
  }
  return constants;
}

/// Splits [source] into top-level `fn` items with the attributes above them.
List<_Function> _splitFunctions(String source) {
  final functions = <_Function>[];
  final pattern = RegExp(r'^fn\s+([A-Za-z0-9_]+)\s*\(', multiLine: true);

  for (final match in pattern.allMatches(source)) {
    final open = source.indexOf('{', match.end);
    if (open < 0) continue;
    final body = source.substring(open, _matchBrace(source, open) + 1);
    functions.add(
      _Function(match.group(1)!, body, _attributesAbove(source, match.start)),
    );
  }
  return functions;
}

/// The `#[...]` attribute lines directly above the item starting at [start].
List<String> _attributesAbove(String source, int start) {
  final attributes = <String>[];
  final before = source.substring(0, start).split('\n');
  for (var index = before.length - 2; index >= 0; index--) {
    final line = before[index].trim();
    if (line.startsWith('#[')) {
      attributes.insert(0, line);
      continue;
    }
    if (line.isEmpty || line.startsWith('//')) continue;
    break;
  }
  return attributes;
}

/// The index of the `}` closing the `{` at [open], ignoring braces inside
/// string literals.
int _matchBrace(String source, int open) {
  var depth = 0;
  var index = open;
  while (index < source.length) {
    final character = source[index];
    if (character == '"' || character == 'r') {
      final literal = _readLiteral(source, index);
      if (literal != null && literal.end > index + 1) {
        index = literal.end;
        continue;
      }
    }
    if (character == '{') depth++;
    if (character == '}') {
      depth--;
      if (depth == 0) return index;
    }
    index++;
  }
  return source.length - 1;
}

/// The document the `html!` macro builds from a style and a body.
String _html(String style, String body) =>
    '<html><head><style>$style</style></head><body>$body</body></html>';

/// The document the `html!` macro builds from a body alone, which is what an
/// `assert_inlined!` expectation is measured against.
String _htmlBody(String body) => '<html><head></head><body>$body</body></html>';

/// Every `assert_inlined!(style = .., body = .., expected = ..)` in [function].
///
/// A function with more than one gets a numbered suffix per case so the
/// descriptions stay unique.
List<_Extracted> _parseAssertInlined(_Function function, String file) {
  final cases = <_Extracted>[];
  var index = function.body.indexOf('assert_inlined!');

  while (index >= 0) {
    final style = _labelled(function.body, index, 'style');
    final body = style == null
        ? null
        : _labelled(function.body, style.end, 'body');
    final expected = body == null
        ? null
        : _labelled(function.body, body.end, 'expected');
    if (expected == null) return const [];

    cases.add(
      _Extracted(
        name: function.name,
        file: file,
        html: _html(style!.value, body!.value),
        expected: _htmlBody(expected.value),
        options: const {},
      ),
    );
    index = function.body.indexOf('assert_inlined!', expected.end);
  }

  if (cases.length < 2) return cases;
  return [
    for (var position = 0; position < cases.length; position++)
      _Extracted(
        name: '${cases[position].name} #${position + 1}',
        file: file,
        html: cases[position].html,
        expected: cases[position].expected,
        options: const {},
      ),
  ];
}

/// The literal after `<label> =`, searching from [from].
_Literal? _labelled(String source, int from, String label) {
  final match = RegExp('$label\\s*=').firstMatch(source.substring(from));
  if (match == null) return null;
  final literal = _readLiteral(source, from + match.end);
  if (literal == null) return null;
  return literal;
}

/// A test that builds options, inlines one literal document and compares the
/// result against one literal expectation.
///
/// Covers both ways upstream spells the options: the `CSSInliner::options()`
/// builder chain and the `InlineOptions { .. }` struct literal.
_Extracted? _parseOptionDriven(
  _Function function,
  String file,
  Map<String, String> constants,
) {
  final expected = _parseExpected(function.body, constants);
  if (expected == null) return null;

  final fragment = _parseFragmentInput(function.body, constants);
  if (fragment != null) {
    return _Extracted(
      name: function.name,
      file: file,
      html: fragment.$1,
      expected: expected,
      options: const {},
      fragmentCss: fragment.$2,
    );
  }

  final options = _parseOptions(function.body);
  if (options == null) return null;

  final html = _parseHtmlInput(function.body, constants);
  if (html == null) return null;

  return _Extracted(
    name: function.name,
    file: file,
    html: html,
    expected: expected,
    options: options,
  );
}

/// The non-default options the test sets, or null when it sets one the binding
/// has no equivalent for.
Map<String, String>? _parseOptions(String body) {
  final options = <String, String>{};

  final builder = RegExp(r'CSSInliner::options\(\)').firstMatch(body);
  if (builder != null) {
    final chain = body.substring(
      builder.end,
      body.indexOf('.build()', builder.end),
    );
    for (final call in RegExp(r'\.([a-z_]+)\(([^()]*)\)').allMatches(chain)) {
      final field = _optionNames[call.group(1)!];
      if (field == null) return null;
      final value = _optionValue(call.group(2)!, body);
      if (value == null) return null;
      options[field] = value;
    }
    return options;
  }

  final struct = RegExp(r'InlineOptions\s*\{').firstMatch(body);
  if (struct != null) {
    final close = _matchBrace(body, struct.end - 1);
    final fields = body.substring(struct.end, close);
    for (final entry in RegExp(
      r'([a-z_]+)\s*:\s*([^,]+),',
    ).allMatches(fields)) {
      final field = _optionNames[entry.group(1)!];
      if (field == null) return null;
      final value = _optionValue(entry.group(2)!, body);
      if (value == null) return null;
      options[field] = value;
    }
    return options;
  }

  // `inline(..)` with no options at all still produces a default-options case.
  return RegExp(r'\binline\((&?html|html)\)|inline\(&html\)').hasMatch(body)
      ? options
      : null;
}

/// One option argument as Dart source, or null when it is not a literal the
/// binding can express.
String? _optionValue(String raw, String body) {
  final trimmed = raw.trim();
  if (trimmed == 'true' || trimmed == 'false') return trimmed;
  if (RegExp(r'^\d+$').hasMatch(trimmed)) return trimmed;

  final some = RegExp(r'^Some\((.*)\)$', dotAll: true).firstMatch(trimmed);
  if (some != null) {
    final inner = some.group(1)!.replaceAll(RegExp(r'\.into\(\)\s*$'), '');
    final literal = _readLiteral(inner, 0);
    if (literal == null) return null;
    return _dartString(literal.value);
  }
  return null;
}

/// The document the test inlines.
String? _parseHtmlInput(String body, Map<String, String> constants) {
  final macro = RegExp(r'let\s+html\s*=\s*html!\(').firstMatch(body);
  if (macro != null) {
    final style = _readLiteral(body, macro.end);
    if (style == null) return null;
    final comma = body.indexOf(',', style.end);
    if (comma < 0) return null;
    final content = _readLiteral(body, comma + 1);
    if (content == null) return null;
    return _html(style.value, content.value);
  }

  final binding = RegExp(r'let\s+html\s*=').firstMatch(body);
  if (binding == null) return null;
  final literal = _readLiteral(body, binding.end);
  if (literal != null) return literal.value;

  final name = RegExp(r'let\s+html\s*=\s*([A-Z_]+)\s*;').firstMatch(body);
  return name == null ? null : constants[name.group(1)!];
}

/// The fragment and its CSS, when the test calls `inline_fragment`.
(String, String)? _parseFragmentInput(
  String body,
  Map<String, String> constants,
) {
  final call = RegExp(
    r'inline_fragment\(\s*([^,]+),\s*([^)]+)\)',
  ).firstMatch(body);
  if (call == null) return null;
  final fragment = _argumentValue(call.group(1)!, constants);
  final css = _argumentValue(call.group(2)!, constants);
  if (fragment == null || css == null) return null;
  return (fragment, css);
}

/// A call argument that is either a string literal or a `const` by name.
String? _argumentValue(String raw, Map<String, String> constants) {
  final trimmed = raw.trim();
  final literal = _readLiteral(trimmed, 0);
  if (literal != null) return literal.value;
  return constants[trimmed];
}

/// The literal the test compares the result against.
String? _parseExpected(String body, Map<String, String> constants) {
  final binding = RegExp(r'let\s+expected\s*=').firstMatch(body);
  if (binding != null) {
    final literal = _readLiteral(body, binding.end);
    if (literal != null) return literal.value;
  }

  final direct = RegExp(
    r'assert_eq!\(\s*(?:result|inlined)\s*,',
  ).firstMatch(body);
  if (direct == null) return null;

  final literal = _readLiteral(body, direct.end);
  if (literal != null) return literal.value;

  final name = RegExp(
    r'assert_eq!\(\s*(?:result|inlined)\s*,\s*([A-Z_]+)\s*\)',
  ).firstMatch(body);
  return name == null ? null : constants[name.group(1)!];
}

/// [value] as a Dart string literal, single-quoted, escapes spelled out.
String _dartString(String value) {
  final buffer = StringBuffer("'");
  for (final rune in value.runes) {
    final character = String.fromCharCode(rune);
    buffer.write(switch (character) {
      "'" => r"\'",
      r'\' => r'\\',
      '\n' => r'\n',
      '\r' => r'\r',
      '\t' => r'\t',
      r'$' => r'\$',
      _ => character,
    });
  }
  return (buffer..write("'")).toString();
}

String _render(
  String revision,
  List<_Extracted> extracted,
  List<_Rejected> rejected,
) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE — DO NOT EDIT.')
    ..writeln('//')
    ..writeln('// Produced by tool/generate_upstream_tests.dart from the')
    ..writeln('// css-inline Rust test suite at revision $revision:')
    ..writeln('// css-inline/tests/test_inlining.rs, test_selectors.rs.')
    ..writeln('//')
    ..writeln('// Regenerate after bumping the crate:')
    ..writeln('//   dart run tool/generate_upstream_tests.dart')
    ..writeln('//')
    ..writeln(
      '// ${extracted.length} cases from ${_functionCount(extracted)} '
      'upstream test functions.',
    )
    ..writeln('//')
    ..writeln('// Not ported (${rejected.length} test functions):');

  for (final entry in rejected) {
    buffer.writeln('//   ${entry.file}::${entry.name} — ${entry.reason}');
  }

  buffer
    ..writeln('//')
    ..writeln('// Upstream is MIT licensed — see LICENSE-THIRD-PARTY.')
    ..writeln("import 'package:css_inline_dart/css_inline_dart.dart';")
    ..writeln()
    ..writeln("import 'inline_test_cases.dart';")
    ..writeln()
    ..writeln('/// Documents upstream inlines, and what it expects back.')
    ..writeln('const upstreamDocumentCases = <DocumentCase>[');

  for (final entry in extracted.where((e) => e.fragmentCss == null)) {
    buffer
      ..writeln('  DocumentCase(')
      ..writeln('    description: ${_dartString(entry.name)},')
      ..writeln('    html: ${_dartString(entry.html)},')
      ..writeln('    expected: ${_dartString(entry.expected)},');
    if (entry.options.isNotEmpty) {
      buffer.writeln('    options: ${_options(entry.options)},');
    }
    buffer.writeln('  ),');
  }

  buffer
    ..writeln('];')
    ..writeln()
    ..writeln('/// Fragments upstream inlines, and what it expects back.')
    ..writeln('const upstreamFragmentCases = <FragmentCase>[');

  for (final entry in extracted.where((e) => e.fragmentCss != null)) {
    buffer
      ..writeln('  FragmentCase(')
      ..writeln('    description: ${_dartString(entry.name)},')
      ..writeln('    html: ${_dartString(entry.html)},')
      ..writeln('    css: ${_dartString(entry.fragmentCss!)},')
      ..writeln('    expected: ${_dartString(entry.expected)},');
    if (entry.options.isNotEmpty) {
      buffer.writeln('    options: ${_options(entry.options)},');
    }
    buffer.writeln('  ),');
  }

  return (buffer..writeln('];')).toString();
}

String _options(Map<String, String> options) {
  final fields = options.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  return 'InlineOptions($fields)';
}

int _functionCount(List<_Extracted> extracted) =>
    extracted.map((e) => e.name.split(' #').first).toSet().length;
