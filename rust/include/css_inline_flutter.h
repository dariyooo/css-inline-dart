#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

/**
 * Inlines CSS from style/link tags into style attributes.
 * Returns the resulting HTML as a String (C pointer).
 * Caller MUST call `free_string` to avoid memory leak.
 * Returns null pointer if inlining fails or if input is invalid.
 */
char *inline_css(const char *html);

/**
 * Synchronous version of inline_css
 */
char *inline_css_sync(const char *html);

/**
 * Inlines a specific CSS string into an HTML fragment.
 * Returns the resulting HTML as a String (C pointer).
 * Caller MUST call `free_string` to avoid memory leak.
 * Returns null pointer if inlining fails or if input is invalid.
 */
char *inline_fragment(const char *html, const char *css);

/**
 * Synchronous version of inline_fragment
 */
char *inline_fragment_sync(const char *html, const char *css);

/**
 * Frees a string allocated by Rust.
 */
void free_string(char *ptr);
