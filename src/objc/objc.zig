//! The [Objective-C runtime](https://developer.apple.com/documentation/objectivec/objective-c-runtime),
//! which is what reaches every Objective-C framework -- Foundation,
//! AppKit, Metal, AVFoundation -- from Zig. Reached as `mac.objc`, under
//! `-Dobjc`.
//!
//! Nothing here is specific to one framework. It is the message-sending
//! bridge the frameworks are built on:
//!
//! ```zig
//! const objc = @import("mac").objc;
//!
//! const pool = objc.AutoreleasePool.init();
//! defer pool.deinit();
//!
//! const info = objc.getClass("NSProcessInfo").?.msgSend(objc.Object, "processInfo", .{});
//! const cores = info.msgSend(objc.UInteger, "activeProcessorCount", .{});
//!
//! const range = objc.getClass("NSValue").?.msgSend(objc.Object, "valueWithRange:", .{
//!     objc.Range{ .location = 2, .length = 3 },
//! });
//! ```
//!
//! ## What the wrapper changes
//!
//! - `objc_msgSend` is called through a function type built at compile
//!   time from the arguments and the requested return type, which is the
//!   only correct way to call it; a string selector is checked against
//!   the argument count before the program runs.
//! - `bool`, `Object`, `Class` and `Sel` convert themselves to `BOOL`,
//!   `id`, `Class` and `SEL`, and back, so neither side of a call sees
//!   the other's spelling.
//! - A method implementation or a block body is an ordinary Zig function;
//!   the C trampoline and the type encoding are generated from its type.
//! - A struct whose only field is an `Object` is an object, which is how a
//!   program gives `NSWindow` a Zig type of its own.
//! - `Subclass` defines a class as a Zig struct: fields are instance
//!   state, with defaults and a `deinit`; `pub fn`s are methods.
//! - `tryMsgSend` and `tryCall` turn an Objective-C exception into
//!   `error.ObjcException`.
//!
//! Typed wrappers for Foundation are in `mac.foundation`, and for AppKit
//! in `mac.appkit`.
//!
//! ## Linking
//!
//! `-Dobjc` links libobjc and Foundation. Every other framework is found
//! by name at run time and so has to be linked by the program that uses
//! it -- `exe.root_module.linkFramework("AppKit", .{})` -- or
//! `getClass("NSWindow")` answers null.
//!
//! ## Exceptions
//!
//! An Objective-C exception that nothing catches ends the process: a
//! message that is not understood, an index past the end of an `NSArray`.
//! `Object.tryMsgSend` and `tryCall` catch it and answer
//! `error.ObjcException` instead. See `exception.zig`.

const std = @import("std");

/// True when the package was built with `-Dobjc` (the default).
pub const enabled = true;

pub const abi = @import("abi.zig");
pub const encoding = @import("encoding.zig");

const object = @import("object.zig");
const class = @import("class.zig");
const sel_ = @import("sel.zig");
const protocol = @import("protocol.zig");
const block = @import("block.zig");
const autorelease = @import("autorelease.zig");
const exception = @import("exception.zig");
const subclass = @import("subclass.zig");
const completion = @import("completion.zig");

pub const Object = object.Object;
pub const Class = class.Class;
pub const Sel = sel_.Sel;
pub const Protocol = protocol.Protocol;
pub const AutoreleasePool = autorelease.AutoreleasePool;
pub const Block = block.Block;
pub const BlockRef = block.BlockRef;
pub const Exception = exception.Exception;
pub const Subclass = subclass.Subclass;
pub const Completion = completion.Completion;

pub const sel = sel_.sel;
pub const tryCall = exception.tryCall;
pub const getClass = class.getClass;
pub const getProtocol = protocol.getProtocol;
pub const allocateClassPair = class.allocateClassPair;
pub const registerClassPair = class.registerClassPair;
pub const disposeClassPair = class.disposeClassPair;

/// An element of a C array of objects that may hold nil, such as the
/// textures in `setFragmentTextures:withRange:` -- `id<MTLTexture>
/// _Nullable const *`. It is exactly the size of the pointer it holds,
/// which `?T` is not, so a slice of these is the C array itself.
///
/// ```zig
/// encoder.setFragmentTexturesWithRange(&.{ .of(albedo), .none, .of(normals) }, .{ .location = 0, .length = 3 });
/// ```
pub fn Nullable(comptime T: type) type {
    if (!abi.isObject(T)) @compileError("objc.Nullable holds an object wrapper; found " ++ @typeName(T));
    return extern struct {
        value: ?*anyopaque,

        const Self = @This();

        pub const none: Self = .{ .value = null };

        pub fn of(item: ?T) Self {
            return .{ .value = if (item) |present| abi.unwrap(present).value else null };
        }

        pub fn get(self: Self) ?T {
            return abi.wrap(T, .{ .value = self.value orelse return null });
        }
    };
}

test "Nullable is the size of a pointer" {
    const N = Nullable(Object);
    try std.testing.expectEqual(@sizeOf(*anyopaque), @sizeOf(N));
    try std.testing.expect(N.none.get() == null);
    var byte: u8 = 0;
    const item: Object = .{ .value = &byte };
    try std.testing.expect(N.of(item).get().?.value == item.value);
}

/// `NSInteger`: the signed integer Foundation counts in.
pub const Integer = c_long;
/// `NSUInteger`: counts, indices, option sets.
pub const UInteger = c_ulong;

/// `NSRange`: a span of a string or an array, in the units the receiver
/// counts in (UTF-16 code units, for a string).
pub const Range = extern struct {
    location: UInteger,
    length: UInteger,

    pub const objc_encoding = "{_NSRange=QQ}";

    /// `NSNotFound`, the location of a range that found nothing.
    pub const not_found: UInteger = std.math.maxInt(Integer);

    pub fn found(self: Range) bool {
        return self.location != not_found;
    }
};

test {
    _ = abi;
    _ = encoding;
    _ = object;
    _ = class;
    _ = sel_;
    _ = protocol;
    _ = block;
    _ = autorelease;
    _ = exception;
    _ = subclass;
    _ = completion;
    _ = @import("tests.zig");
}
