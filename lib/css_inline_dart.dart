library;

import 'dart:ffi';

import 'package:css_inline_dart/src/rust_bindings.g.dart' as bindings;
import 'package:ffi/ffi.dart';

/// Inlines CSS from style/link tags into style attributes.
/// Returns the resulting HTML as a String.
/// Throws an exception if inlining fails.
Future<String> inlineCss({required String html}) async {
  return inlineCssSync(html: html);
}

/// Synchronous version of [inlineCss].
String inlineCssSync({required String html}) {
  final htmlPtr = html.toNativeUtf8();
  try {
    final resultPtr = bindings.inline_css(htmlPtr.cast<Char>());
    if (resultPtr == nullptr) {
      throw Exception('CSS Inlining failed');
    }
    final result = resultPtr.cast<Utf8>().toDartString();
    bindings.free_string(resultPtr);
    return result;
  } finally {
    malloc.free(htmlPtr);
  }
}

/// Inlines a specific CSS string into an HTML fragment.
/// Useful for partial templates where you provide the CSS separately.
Future<String> inlineFragment({required String html, required String css}) async {
  return inlineFragmentSync(html: html, css: css);
}

/// Synchronous version of [inlineFragment].
String inlineFragmentSync({required String html, required String css}) {
  final htmlPtr = html.toNativeUtf8();
  final cssPtr = css.toNativeUtf8();
  try {
    final resultPtr = bindings.inline_fragment(
      htmlPtr.cast<Char>(),
      cssPtr.cast<Char>(),
    );
    if (resultPtr == nullptr) {
      throw Exception('Fragment Inlining failed');
    }
    final result = resultPtr.cast<Utf8>().toDartString();
    bindings.free_string(resultPtr);
    return result;
  } finally {
    malloc.free(htmlPtr);
    malloc.free(cssPtr);
  }
}
