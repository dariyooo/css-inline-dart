use std::ffi::{CStr, CString};
use libc::c_char;

#[no_mangle]
pub extern "C" fn inline_css(html: *const c_char) -> *mut c_char {
    _inline_css(html)
}

#[no_mangle]
pub extern "C" fn inline_css_sync(html: *const c_char) -> *mut c_char {
    _inline_css(html)
}

#[no_mangle]
pub extern "C" fn inline_fragment(html: *const c_char, css: *const c_char) -> *mut c_char {
    _inline_fragment(html, css)
}

#[no_mangle]
pub extern "C" fn inline_fragment_sync(html: *const c_char, css: *const c_char) -> *mut c_char {
    _inline_fragment(html, css)
}

fn _inline_css(html: *const c_char) -> *mut c_char {
    if html.is_null() {
        return std::ptr::null_mut();
    }

    let c_str = unsafe { CStr::from_ptr(html) };
    let html_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    match css_inline::inline(html_str) {
        Ok(result) => {
            match CString::new(result) {
                Ok(c_string) => c_string.into_raw(),
                Err(_) => std::ptr::null_mut(),
            }
        }
        Err(_) => std::ptr::null_mut(),
    }
}

fn _inline_fragment(html: *const c_char, css: *const c_char) -> *mut c_char {
    if html.is_null() || css.is_null() {
        return std::ptr::null_mut();
    }

    let html_c_str = unsafe { CStr::from_ptr(html) };
    let css_c_str = unsafe { CStr::from_ptr(css) };

    let html_str = match html_c_str.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let css_str = match css_c_str.to_str() {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };

    match css_inline::inline_fragment(html_str, css_str) {
        Ok(result) => {
            match CString::new(result) {
                Ok(c_string) => c_string.into_raw(),
                Err(_) => std::ptr::null_mut(),
            }
        }
        Err(_) => std::ptr::null_mut(),
    }
}

/// Frees a string allocated by Rust.
#[no_mangle]
pub extern "C" fn free_string(ptr: *mut c_char) {
    if ptr.is_null() {
        return;
    }
    unsafe {
        drop(CString::from_raw(ptr));
    }
}
