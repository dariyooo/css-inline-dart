use css_inline::{CSSInliner, InlineOptions, Url};
use serde::Deserialize;

/// Every knob `css-inline` exposes, as a consumer sends it over the boundary.
///
/// Mirrors `InlineOptions` field for field, with two exceptions: the stylesheet
/// resolver is a Rust trait object and has no representation here, and the
/// external-stylesheet cache is only reachable when the crate can fetch them.
/// A caller that needs either resolves the stylesheet itself and passes the CSS
/// through [`extra_css`].
#[derive(Deserialize)]
#[serde(default, deny_unknown_fields, rename_all = "camelCase")]
pub struct Options {
    pub inline_style_tags: bool,
    pub keep_style_tags: bool,
    pub keep_link_tags: bool,
    pub keep_at_rules: bool,
    pub minify_css: bool,
    pub load_remote_stylesheets: bool,
    pub remove_inlined_selectors: bool,
    pub preallocate_node_capacity: usize,
    /// Resolves relative stylesheet URLs. Rejected if it does not parse.
    pub base_url: Option<String>,
    pub extra_css: Option<String>,
}

impl Default for Options {
    /// What `css-inline` itself defaults to, except that stylesheets are not
    /// fetched unless asked for.
    fn default() -> Self {
        Self {
            inline_style_tags: true,
            keep_style_tags: false,
            keep_link_tags: false,
            keep_at_rules: false,
            minify_css: false,
            load_remote_stylesheets: false,
            remove_inlined_selectors: false,
            preallocate_node_capacity: 32,
            base_url: None,
            extra_css: None,
        }
    }
}

impl Options {
    /// Reads the options from JSON. A null pointer means the defaults.
    pub fn parse(json: *const std::os::raw::c_char) -> Result<Self, String> {
        if json.is_null() {
            return Ok(Self::default());
        }
        let text = crate::borrow_str(json)?;
        if text.trim().is_empty() {
            return Ok(Self::default());
        }
        serde_json::from_str(text).map_err(|e| format!("options: {e}"))
    }

    /// The inliner these options describe.
    pub fn inliner(&self) -> Result<CSSInliner<'_>, String> {
        if self.load_remote_stylesheets && !cfg!(feature = "http") {
            return Err(
                "this build cannot load remote stylesheets. Enable the \
                 `remote_stylesheets` user define, or resolve the stylesheet \
                 yourself and pass it as extraCss."
                    .to_owned(),
            );
        }

        let base_url = match &self.base_url {
            Some(url) => Some(Url::parse(url).map_err(|e| format!("baseUrl: {e}"))?),
            None => None,
        };

        Ok(CSSInliner::new(InlineOptions {
            inline_style_tags: self.inline_style_tags,
            keep_style_tags: self.keep_style_tags,
            keep_link_tags: self.keep_link_tags,
            keep_at_rules: self.keep_at_rules,
            minify_css: self.minify_css,
            base_url,
            load_remote_stylesheets: self.load_remote_stylesheets,
            extra_css: self.extra_css.as_deref().map(Into::into),
            preallocate_node_capacity: self.preallocate_node_capacity,
            remove_inlined_selectors: self.remove_inlined_selectors,
            ..InlineOptions::default()
        }))
    }
}
