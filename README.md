# css_inline_dart

Move CSS rules onto the elements they apply to, as `style` attributes.

Bindings to the Rust crate
[css-inline](https://github.com/Stranger6667/css-inline). Every option the crate
exposes is available here. Calls are synchronous — no isolate hop, no `Future`.

Email clients are the usual reason: most strip `<style>` blocks and ignore
external stylesheets, so a rule only survives if it sits on the element itself.
The same applies to anything that renders a fragment out of its original page.

## Contents

- [Quick start](#quick-start)
- [Options](#options)
- [Remote stylesheets](#remote-stylesheets): why they are opt-in
- [Errors](#errors)
- [Building](#building)

## Quick start

```sh
dart pub add css_inline_dart
```

```dart
import 'package:css_inline_dart/css_inline_dart.dart';

void main() {
  print(inlineDocument(
    '<html><head><style>p { color: red }</style></head>'
    '<body><p>text</p></body></html>',
  ));
  // <html><head></head><body><p style="color: red;">text</p></body></html>
}
```

`inlineFragment` takes the CSS separately, for markup that is not a whole
document:

```dart
inlineFragment('<p>text</p>', 'p { color: blue }');
// <p style="color: blue;">text</p>
```

## Options

`InlineOptions` covers the crate's full configuration. The defaults match it,
with one exception: remote stylesheets are left alone.

| Option | Default | Effect |
| --- | --- | --- |
| `inlineStyleTags` | `true` | Inline the CSS in the document's own `style` tags. |
| `keepStyleTags` | `false` | Leave those tags in place afterwards. |
| `keepLinkTags` | `false` | Leave `link` tags in place afterwards. |
| `keepAtRules` | `false` | Keep `@media` and friends, which no style attribute can express. |
| `minifyCss` | `false` | Drop trailing semicolons and the spaces around values. |
| `loadRemoteStylesheets` | `false` | Fetch what `link` tags point at. See below. |
| `removeInlinedSelectors` | `false` | Remove selectors from `style` blocks once inlined. |
| `preallocateNodeCapacity` | `32` | Room reserved for nodes up front. |
| `baseUrl` | `null` | Resolves relative stylesheet URLs. Rejected if it does not parse. |
| `extraCss` | `null` | CSS applied last, so it wins at equal specificity. |

```dart
inlineDocument(html, options: const InlineOptions(
  keepStyleTags: true,
  extraCss: 'p { font-weight: bold }',
));
```

## Remote stylesheets

Fetching one blocks the calling thread and puts an HTTP stack in the binary —
1.8 MB becomes 4.4 MB per architecture. Neither is worth paying for by default,
so the capability is compiled in only when asked for.

Fetch the stylesheet yourself and pass it as `extraCss`. The output is
identical, the request is cancellable, and it goes through whatever HTTP client,
caching and offline policy the rest of the application already has.

If you want it in the native library instead, ask for it in your own
`pubspec.yaml`:

```yaml
hooks:
  user_defines:
    css_inline_dart:
      remote_stylesheets: true
```

`supportsRemoteStylesheets` reports which build you have. Setting
`loadRemoteStylesheets: true` on a build without it throws rather than quietly
doing nothing.

## Errors

Both functions throw `CssInlineException` when the HTML, the CSS or the options
are rejected — an unparseable `baseUrl`, a stylesheet that could not be fetched,
a selector the parser refuses. The message says which.

## Building

The crate is compiled by a native-assets build hook, so a Rust toolchain has to
be present. There is no separate build step and no prebuilt binary to download:
`dart pub get` and `dart test` are enough.

Anywhere Rust and native assets both work is a target. Built and tested on
macOS arm64; the others follow from the toolchain rather than from anything in
this package, but they are untested here.
