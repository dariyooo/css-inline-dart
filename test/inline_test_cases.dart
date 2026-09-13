import 'package:css_inline_dart/css_inline_dart.dart';

/// One document, inlined under one set of options.
class DocumentCase {
  const DocumentCase({
    required this.description,
    required this.html,
    required this.expected,
    this.options = const InlineOptions(),
  });

  final String description;
  final String html;
  final InlineOptions options;
  final String expected;
}

/// One fragment and the CSS applied to it.
class FragmentCase {
  const FragmentCase({
    required this.description,
    required this.html,
    required this.css,
    required this.expected,
    this.options = const InlineOptions(),
  });

  final String description;
  final String html;
  final String css;
  final InlineOptions options;
  final String expected;
}

/// One rule in a style tag. Most document cases vary only the options.
const _styled = '<html><head><style>p { color: red }</style></head>'
    '<body><p>text</p></body></html>';

/// A rule that cannot be written into a style attribute, beside one that can.
const _atRules = '<html><head><style>@media screen { p { color: red } } '
    'p { font-size: 1em }</style></head><body><p>text</p></body></html>';

const _linked = '<html><head><link rel="stylesheet" href="x.css"></head>'
    '<body><p>text</p></body></html>';

const documentCases = <DocumentCase>[
  DocumentCase(
    description: 'a rule reaches the element it selects, and its tag goes',
    html: _styled,
    expected: '<html><head></head>'
        '<body><p style="color: red;">text</p></body></html>',
  ),
  DocumentCase(
    description: 'keepStyleTags leaves the tag behind',
    html: _styled,
    options: InlineOptions(keepStyleTags: true),
    expected: '<html><head><style>p { color: red }</style></head>'
        '<body><p style="color: red;">text</p></body></html>',
  ),
  DocumentCase(
    description: 'inlineStyleTags off ignores what the document carries',
    html: _styled,
    options: InlineOptions(inlineStyleTags: false),
    expected: '<html><head></head><body><p>text</p></body></html>',
  ),
  DocumentCase(
    description: 'extraCss applies after the document, so it wins ties',
    html: _styled,
    options: InlineOptions(extraCss: 'p { font-weight: bold }'),
    expected: '<html><head></head>'
        '<body><p style="color: red;font-weight: bold;">text</p></body></html>',
  ),
  DocumentCase(
    description: 'removeInlinedSelectors empties a kept style tag',
    html: _styled,
    options: InlineOptions(keepStyleTags: true, removeInlinedSelectors: true),
    expected: '<html><head><style></style></head>'
        '<body><p style="color: red;">text</p></body></html>',
  ),
  // An at-rule has no style-attribute equivalent, so keeping it means keeping
  // the tag it lives in while everything inlinable still moves.
  DocumentCase(
    description: 'keepAtRules keeps what cannot become an attribute',
    html: _atRules,
    options: InlineOptions(keepAtRules: true),
    expected: '<html><head><style>@media screen { p { color: red } } </style></head>'
        '<body><p style="font-size: 1em;">text</p></body></html>',
  ),
  DocumentCase(
    description: 'minifyCss drops the spaces and the trailing semicolon',
    html: _styled,
    options: InlineOptions(
      extraCss: 'p { margin : 0 ; padding : 0 }',
      minifyCss: true,
    ),
    expected: '<html><head></head>'
        '<body><p style="color:red;margin:0;padding:0">text</p></body></html>',
  ),
  // Nothing is fetched, so the rules the link points at never arrive — the tag
  // staying is all this option does.
  DocumentCase(
    description: 'keepLinkTags leaves an unfetched link in place',
    html: _linked,
    options: InlineOptions(keepLinkTags: true),
    expected: '<html><head><link rel="stylesheet" href="x.css"></head>'
        '<body><p>text</p></body></html>',
  ),
];

const fragmentCases = <FragmentCase>[
  FragmentCase(
    description: 'css applies without a document around it',
    html: '<p>text</p>',
    css: 'p { color: blue }',
    expected: '<p style="color: blue;">text</p>',
  ),
  FragmentCase(
    description: 'extraCss applies alongside the css passed in',
    html: '<p>text</p>',
    css: 'p { color: blue }',
    options: InlineOptions(extraCss: 'p { margin: 0 }'),
    expected: '<p style="margin: 0;color: blue;">text</p>',
  ),
];
