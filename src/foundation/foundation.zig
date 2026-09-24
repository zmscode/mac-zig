//! [Foundation](https://developer.apple.com/documentation/foundation),
//! wrapped by hand -- reached as `mac.foundation`, under `-Dobjc`.
//!
//! The classes nearly every Objective-C API passes around, as Zig types:
//!
//! | Foundation                            | here                                  |
//! | ------------------------------------- | ------------------------------------- |
//! | `NSString`                            | `String`                              |
//! | `NSNumber`                            | `Number`                              |
//! | `NSData`                              | `Data`                                |
//! | `NSURL`                               | `Url`                                 |
//! | `NSArray` / `NSMutableArray`          | `Array(T)` / `MutableArray(T)`        |
//! | `NSDictionary` / `NSMutableDictionary`| `Dictionary(K, V)` / `MutableDictionary(K, V)` |
//! | `NSError`                             | `ErrorObject`                         |
//!
//! Each is an `extern struct` over one `objc.Object`, so it goes to and
//! from `msgSend` as itself, and the rest of Foundation stays reachable
//! through `.object`.
//!
//! ## What is Zig-shaped here
//!
//! - Slices in, slices out: `String.init("text")`, `Data.bytes()`,
//!   `Array(T).init(&items)`, `toOwnedSlice(allocator)`.
//! - Collections are typed by what they hold, and bounds-checked, so an
//!   index past the end is `null` or an assertion rather than an
//!   Objective-C exception.
//! - An `error:` out-parameter is `error.Failed`, with the `NSError`
//!   handed over through an optional `details` pointer when you want it.
//! - `{f}` prints a `String` or an `ErrorObject`.
//!
//! ## Ownership
//!
//! The rule is the one `cf` uses: **anything from an `init...` is yours
//! to `deinit`**. Everything else a method returns is borrowed or
//! autoreleased, and lives until the enclosing `objc.AutoreleasePool`
//! drains -- `retain` it to keep it longer. `String.literal("...")` is the
//! exception: made once, never freed, like `@"..."`.

pub const String = @import("string.zig").String;
pub const Number = @import("number.zig").Number;
pub const Data = @import("data.zig").Data;
pub const Url = @import("url.zig").Url;
pub const ErrorObject = @import("error_object.zig").ErrorObject;

const collections = @import("collections.zig");
pub const Array = collections.Array;
pub const MutableArray = collections.MutableArray;
pub const Dictionary = collections.Dictionary;
pub const MutableDictionary = collections.MutableDictionary;

/// True when the package was built with `-Dobjc` (the default).
pub const enabled = true;

test {
    _ = @import("string.zig");
    _ = @import("number.zig");
    _ = @import("data.zig");
    _ = @import("url.zig");
    _ = @import("error_object.zig");
    _ = collections;
}
