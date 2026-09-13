# css_inline_dart

Inlines CSS into HTML `style` attributes.

Email clients, and anything else that ignores stylesheets, need every rule on
the element it applies to. This moves them there, through the Rust
[css-inline](https://github.com/Stranger6667/css-inline) crate.

```dart
import 'package:css_inline_dart/css_inline_dart.dart';

inlineDocument(
  '<html><head><style>p { color: red }</style></head>'
  '<body><p>text</p></body></html>',
);
// <html><head></head><body><p style="color: red;">text</p></body></html>

inlineFragment('<p>text</p>', 'p { color: blue }');
// <p style="color: blue;">text</p>
```

Both throw `CssInlineException` when the HTML or the options are rejected.

## Options

`InlineOptions` covers everything the crate exposes. The defaults match it,
except that remote stylesheets are left alone — see below.

| option | default | effect |
| --- | --- | --- |
| `inlineStyleTags` | `true` | Inline the CSS in the document's own `style` tags. |
| `keepStyleTags` | `false` | Leave those tags in place afterwards. |
| `keepLinkTags` | `false` | Leave `link` tags in place afterwards. |
| `keepAtRules` | `false` | Keep `@media` and friends, which no style attribute can express. |
| `minifyCss` | `false` | Drop trailing semicolons and the spaces around values. |
| `loadRemoteStylesheets` | `false` | Fetch what `link` tags point at. Needs the opt-in below. |
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

Fetching a stylesheet blocks the calling thread and costs an HTTP stack in every
binary — 2.6 MB per architecture — so it is left out unless you ask for it. A
build without it throws rather than silently ignoring
`loadRemoteStylesheets: true`, and `supportsRemoteStylesheets` says which build
you have.

Prefer fetching the stylesheet yourself and passing it as `extraCss`: the result
is identical, the request is cancellable, and it uses whatever HTTP client,
caching and offline policy the rest of your app already has.

If you do want it in the native library, say so in your own `pubspec.yaml`:

```yaml
hooks:
  user_defines:
    css_inline_dart:
      remote_stylesheets: true
```

## Building

The Rust crate is compiled by a native-assets build hook, so a Rust toolchain
has to be installed. Nothing else is needed — no manual build step, and no
prebuilt binaries to download.
