import 'dart:convert';

/// How CSS is inlined.
///
/// The defaults match the `css-inline` crate, except that remote stylesheets
/// are left alone: fetching one blocks the calling thread, and a rendering call
/// that reaches the network without being asked to is a surprise.
class InlineOptions {
  const InlineOptions({
    this.inlineStyleTags = true,
    this.keepStyleTags = false,
    this.keepLinkTags = false,
    this.keepAtRules = false,
    this.minifyCss = false,
    this.loadRemoteStylesheets = false,
    this.removeInlinedSelectors = false,
    this.preallocateNodeCapacity = 32,
    this.baseUrl,
    this.extraCss,
  });

  /// Inline the CSS in the document's own `style` tags.
  ///
  /// Off, a document is styled only by [extraCss] — useful where boilerplate
  /// styles apply to the page but not to what is being extracted from it.
  final bool inlineStyleTags;

  /// Leave the `style` tags in place afterwards.
  final bool keepStyleTags;

  /// Leave the `link` tags in place afterwards.
  final bool keepLinkTags;

  /// Keep at-rules such as `@media`, which cannot be expressed in a `style`
  /// attribute and are otherwise dropped.
  final bool keepAtRules;

  /// Drop trailing semicolons and the spaces around values.
  final bool minifyCss;

  /// Fetch stylesheets that `link` tags point at.
  ///
  /// Throws unless the consumer opted in — see the README. The request blocks
  /// the calling thread, so prefer fetching the stylesheet yourself and passing
  /// it as [extraCss].
  final bool loadRemoteStylesheets;

  /// Remove selectors from `style` blocks once they have been inlined.
  final bool removeInlinedSelectors;

  /// How many nodes to allocate room for up front. Worth setting only when the
  /// size of the document is known.
  final int preallocateNodeCapacity;

  /// Resolves relative stylesheet URLs. Rejected if it does not parse.
  final String? baseUrl;

  /// CSS applied after everything the document carries, so it wins at equal
  /// specificity.
  final String? extraCss;

  InlineOptions copyWith({
    bool? inlineStyleTags,
    bool? keepStyleTags,
    bool? keepLinkTags,
    bool? keepAtRules,
    bool? minifyCss,
    bool? loadRemoteStylesheets,
    bool? removeInlinedSelectors,
    int? preallocateNodeCapacity,
    String? baseUrl,
    String? extraCss,
  }) => InlineOptions(
    inlineStyleTags: inlineStyleTags ?? this.inlineStyleTags,
    keepStyleTags: keepStyleTags ?? this.keepStyleTags,
    keepLinkTags: keepLinkTags ?? this.keepLinkTags,
    keepAtRules: keepAtRules ?? this.keepAtRules,
    minifyCss: minifyCss ?? this.minifyCss,
    loadRemoteStylesheets: loadRemoteStylesheets ?? this.loadRemoteStylesheets,
    removeInlinedSelectors: removeInlinedSelectors ?? this.removeInlinedSelectors,
    preallocateNodeCapacity: preallocateNodeCapacity ?? this.preallocateNodeCapacity,
    baseUrl: baseUrl ?? this.baseUrl,
    extraCss: extraCss ?? this.extraCss,
  );

  /// How these options reach the native library.
  String toJson() => jsonEncode({
    'inlineStyleTags': inlineStyleTags,
    'keepStyleTags': keepStyleTags,
    'keepLinkTags': keepLinkTags,
    'keepAtRules': keepAtRules,
    'minifyCss': minifyCss,
    'loadRemoteStylesheets': loadRemoteStylesheets,
    'removeInlinedSelectors': removeInlinedSelectors,
    'preallocateNodeCapacity': preallocateNodeCapacity,
    if (baseUrl case final url?) 'baseUrl': url,
    if (extraCss case final css?) 'extraCss': css,
  });
}

/// Thrown when inlining fails.
class CssInlineException implements Exception {
  const CssInlineException(this.message);

  final String message;

  @override
  String toString() => 'CssInlineException: $message';
}
