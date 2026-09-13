//! C bindings for the `css-inline` crate.
//!
//! Each entry point takes UTF-8 C strings and returns one the caller frees with
//! [`css_inline_free_string`]. A null return means the call failed and
//! [`css_inline_last_error`] says why.

use std::cell::RefCell;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};

mod options;
use options::Options;

thread_local! {
    /// The last failure on this thread, so a null return can be explained
    /// without every function carrying an out-parameter.
    static LAST_ERROR: RefCell<Option<CString>> = const { RefCell::new(None) };
}

/// Inlines the CSS a document carries in its own `style` and `link` tags.
///
/// `options_json` may be null for the defaults.
#[no_mangle]
pub extern "C" fn css_inline_document(
    html: *const c_char,
    options_json: *const c_char,
) -> *mut c_char {
    guarded(|| {
        let html = borrow_str(html)?;
        let options = Options::parse(options_json)?;
        options
            .inliner()?
            .inline(html)
            .map_err(|error| error.to_string())
    })
}

/// Inlines `css` into `html`, which is treated as a fragment rather than a
/// whole document.
#[no_mangle]
pub extern "C" fn css_inline_fragment(
    html: *const c_char,
    css: *const c_char,
    options_json: *const c_char,
) -> *mut c_char {
    guarded(|| {
        let html = borrow_str(html)?;
        let css = borrow_str(css)?;
        let options = Options::parse(options_json)?;
        options
            .inliner()?
            .inline_fragment(html, css)
            .map_err(|error| error.to_string())
    })
}

/// Why the last call on this thread returned null, or null if it succeeded.
///
/// Owned by the library and valid until the next call on the same thread.
#[no_mangle]
pub extern "C" fn css_inline_last_error() -> *const c_char {
    LAST_ERROR.with(|slot| {
        slot.borrow()
            .as_ref()
            .map_or(std::ptr::null(), |message| message.as_ptr())
    })
}

/// Frees a string this library returned.
#[no_mangle]
pub extern "C" fn css_inline_free_string(ptr: *mut c_char) {
    if ptr.is_null() {
        return;
    }
    unsafe {
        drop(CString::from_raw(ptr));
    }
}

/// Whether this build can fetch stylesheets over the network.
///
/// Fetching costs an HTTP stack in every binary, so it is compiled in only when
/// a consumer asks for it.
#[no_mangle]
pub extern "C" fn css_inline_supports_remote_stylesheets() -> c_int {
    c_int::from(cfg!(feature = "http"))
}

/// Runs `body`, turning its result into an owned C string and any failure —
/// including a panic — into a null with the reason recorded.
///
/// Unwinding into C is undefined behaviour, and `css-inline` panics when the
/// stylesheet cache lock is poisoned, so the catch is not optional.
fn guarded<F>(body: F) -> *mut c_char
where
    F: FnOnce() -> Result<String, String> + std::panic::UnwindSafe,
{
    let outcome = std::panic::catch_unwind(body)
        .unwrap_or_else(|payload| Err(panic_message(&payload)));

    match outcome {
        Ok(value) => match CString::new(value) {
            Ok(owned) => {
                set_error(None);
                owned.into_raw()
            }
            Err(_) => fail("the result contains a null byte"),
        },
        Err(message) => fail(&message),
    }
}

fn panic_message(payload: &Box<dyn std::any::Any + Send>) -> String {
    payload
        .downcast_ref::<&str>()
        .map(|text| (*text).to_owned())
        .or_else(|| payload.downcast_ref::<String>().cloned())
        .unwrap_or_else(|| "panicked".to_owned())
}

fn fail(message: &str) -> *mut c_char {
    set_error(Some(message));
    std::ptr::null_mut()
}

fn set_error(message: Option<&str>) {
    LAST_ERROR.with(|slot| {
        *slot.borrow_mut() = message.and_then(|text| CString::new(text).ok());
    });
}

/// The string behind `ptr`, or an error when it is null or not UTF-8.
pub(crate) fn borrow_str<'a>(ptr: *const c_char) -> Result<&'a str, String> {
    if ptr.is_null() {
        return Err("a required argument was null".to_owned());
    }
    unsafe { CStr::from_ptr(ptr) }
        .to_str()
        .map_err(|_| "an argument was not valid UTF-8".to_owned())
}
