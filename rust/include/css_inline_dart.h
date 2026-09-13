/**
 * Inlines the CSS a document carries in its own style and link tags.
 * `options_json` may be NULL for the defaults.
 * Returns NULL on failure; call `css_inline_last_error` for the reason.
 * The caller must free the result with `css_inline_free_string`.
 */
char *css_inline_document(const char *html, const char *options_json);

/**
 * Inlines `css` into `html`, treating it as a fragment rather than a document.
 * Returns NULL on failure; call `css_inline_last_error` for the reason.
 * The caller must free the result with `css_inline_free_string`.
 */
char *css_inline_fragment(const char *html, const char *css,
                          const char *options_json);

/**
 * Why the last call on this thread returned NULL, or NULL if it succeeded.
 * Owned by the library; valid until the next call on the same thread.
 */
const char *css_inline_last_error(void);

/** Frees a string this library returned. */
void css_inline_free_string(char *ptr);

/** Whether this build can fetch stylesheets over the network. */
int css_inline_supports_remote_stylesheets(void);
