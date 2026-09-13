## 0.1.0

Initial release.

* `inlineDocument` and `inlineFragment`, covering every option the `css-inline`
  crate exposes through `InlineOptions`.
* Failures raise `CssInlineException` with the reason, rather than returning
  null.
* Remote stylesheet fetching is opt-in through a `remote_stylesheets` user
  define, which keeps an HTTP stack out of builds that never fetch one.
