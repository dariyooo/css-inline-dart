/// Inlines CSS into HTML `style` attributes.
///
/// Email clients and other readers that ignore stylesheets need every rule on
/// the element it applies to. This moves them there, through the Rust
/// [css-inline](https://github.com/Stranger6667/css-inline) crate.
library;

import 'dart:ffi';

import 'package:css_inline_dart/src/rust_bindings.g.dart' as bindings;
import 'package:ffi/ffi.dart';

export 'package:css_inline_dart/src/inline_options.dart'
    show CssInlineException, InlineOptions;

import 'package:css_inline_dart/src/inline_options.dart';

/// Inlines the CSS a document carries in its own `style` and `link` tags.
///
/// Throws [CssInlineException] if the HTML or the options are rejected.
String inlineDocument(String html, {InlineOptions options = const InlineOptions()}) {
  return using((arena) {
    final result = bindings.css_inline_document(
      html.toNativeUtf8(allocator: arena).cast<Char>(),
      options.toJson().toNativeUtf8(allocator: arena).cast<Char>(),
    );
    return _take(result);
  });
}

/// Inlines [css] into [html], which is treated as a fragment rather than a
/// whole document.
///
/// Throws [CssInlineException] if the HTML, the CSS or the options are
/// rejected.
String inlineFragment(
  String html,
  String css, {
  InlineOptions options = const InlineOptions(),
}) {
  return using((arena) {
    final result = bindings.css_inline_fragment(
      html.toNativeUtf8(allocator: arena).cast<Char>(),
      css.toNativeUtf8(allocator: arena).cast<Char>(),
      options.toJson().toNativeUtf8(allocator: arena).cast<Char>(),
    );
    return _take(result);
  });
}

/// Whether this build can fetch stylesheets that `link` tags point at.
///
/// False unless the consuming package opted in, because the HTTP stack it needs
/// costs every binary that ships without using it.
bool get supportsRemoteStylesheets =>
    bindings.css_inline_supports_remote_stylesheets() != 0;

/// The string behind [result], freeing it, or the reason there is none.
String _take(Pointer<Char> result) {
  if (result == nullptr) {
    final error = bindings.css_inline_last_error();
    throw CssInlineException(
      error == nullptr ? 'inlining failed' : error.cast<Utf8>().toDartString(),
    );
  }
  try {
    return result.cast<Utf8>().toDartString();
  } finally {
    bindings.css_inline_free_string(result);
  }
}
