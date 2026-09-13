import 'package:hooks/hooks.dart';
import 'package:native_toolchain_rust/native_toolchain_rust.dart';

/// Builds the native library, fetching support included only when asked for.
///
/// Reaching the network costs an HTTP stack in every binary — 2.6 MB per
/// architecture — and a rendering call that downloads something without being
/// asked to is a surprise. A consumer that wants it says so in their pubspec:
///
/// ```yaml
/// hooks:
///   user_defines:
///     css_inline_dart:
///       remote_stylesheets: true
/// ```
void main(List<String> args) async {
  await build(args, (input, output) async {
    final remoteStylesheets = input.userDefines['remote_stylesheets'] == true;

    await RustBuilder(
      assetName: 'src/rust_bindings.g.dart',
      cratePath: 'rust',
      enableDefaultFeatures: false,
      features: [if (remoteStylesheets) 'http'],
    ).run(input: input, output: output);
  });
}
