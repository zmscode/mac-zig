//! Catching Objective-C exceptions, so that a message the receiver does not
//! understand is an error rather than the end of the process.
//!
//! An exception thrown with no `@try` around it terminates the program.
//! Zig has no `@try`, so `vendor/mac_objc_exception.m` provides one:
//! `tryCall` runs a Zig function inside it, and `Object.tryMsgSend` sends a
//! message inside it. Either answers `error.ObjcException`, and hands the
//! exception itself to the caller if asked:
//!
//! ```zig
//! var caught: objc.Exception = undefined;
//! const item = array.tryMsgSend(objc.Object, "objectAtIndex:", .{@as(objc.UInteger, 9)}, &caught) catch {
//!     defer caught.deinit();
//!     std.log.err("{f}", .{caught});
//!     return;
//! };
//! ```
//!
//! ## What unwinding skips
//!
//! The exception unwinds through every frame between the throw and the
//! catch, Zig frames included, and a Zig frame's `defer`s do **not** run
//! on the way. `tryMsgSend` has none in between. With `tryCall`, keep the
//! function free of `defer` and `errdefer` that must run -- the natural
//! shape is a few messages and nothing else. A method implemented in Zig
//! that an exception passes through is skipped the same way.
//!
//! ## Cost
//!
//! Nothing when nothing is thrown: on 64-bit, `@try` is a table entry, not
//! code on the fast path. The call is no longer inlined, which is all.

const std = @import("std");
const abi = @import("abi.zig");
const message = @import("message.zig");
const sel = @import("sel.zig");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");

const Object = @import("object.zig").Object;

extern fn mac_zig_objc_try(
    body: *const fn (context: ?*anyopaque) callconv(.c) void,
    context: ?*anyopaque,
) abi.Id;

/// A caught exception, usually an `NSException`. Yours: `deinit` it.
pub const Exception = struct {
    object: Object,

    pub fn deinit(self: Exception) void {
        self.object.release();
    }

    /// The exception's name -- `NSRangeException`,
    /// `NSInvalidArgumentException` -- in memory the caller owns. Empty if
    /// what was thrown is not an `NSException`.
    pub fn name(self: Exception, allocator: std.mem.Allocator) ![]u8 {
        return self.stringProperty(allocator, "name");
    }

    /// Why it was thrown, in memory the caller owns. Empty if there is no
    /// reason, or if what was thrown is not an `NSException`.
    pub fn reason(self: Exception, allocator: std.mem.Allocator) ![]u8 {
        return self.stringProperty(allocator, "reason");
    }

    fn stringProperty(self: Exception, allocator: std.mem.Allocator, comptime property: [:0]const u8) ![]u8 {
        if (!self.object.respondsTo(property)) return allocator.alloc(u8, 0);
        const text = self.object.msgSend(?Object, property, .{}) orelse return allocator.alloc(u8, 0);
        const string = text.asCf(cf.String) orelse return allocator.alloc(u8, 0);
        return string.toOwnedSlice(allocator);
    }

    /// `name: reason`, for `{f}`. Written without allocating, through a
    /// fixed buffer, so a very long reason is cut short.
    pub fn format(self: Exception, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        var buffer: [1024]u8 = undefined;
        var fixed = std.heap.FixedBufferAllocator.init(&buffer);
        const allocator = fixed.allocator();
        const n = self.name(allocator) catch "";
        const r = self.reason(allocator) catch "";
        try writer.print("{s}: {s}", .{ n, r });
    }
};

/// Runs `f(args...)` inside `@try`. If an Objective-C exception is thrown,
/// answers `error.ObjcException` and, when `caught` is not null, stores the
/// exception there for the caller to `deinit`; with `caught` null it is
/// released here. See the note on `defer` at the top of this file.
pub fn tryCall(
    comptime f: anytype,
    args: std.meta.ArgsTuple(@TypeOf(f)),
    caught: ?*Exception,
) errors.Error!abi.ReturnOf(@TypeOf(f)) {
    const R = abi.ReturnOf(@TypeOf(f));
    const Context = struct {
        args: std.meta.ArgsTuple(@TypeOf(f)),
        result: R = undefined,

        fn body(pointer: ?*anyopaque) callconv(.c) void {
            const context: *@This() = @ptrCast(@alignCast(pointer));
            context.result = @call(.auto, f, context.args);
        }
    };
    var context: Context = .{ .args = args };
    try run(&Context.body, &context, caught);
    return context.result;
}

/// `Object.msgSend`, inside `@try`. See `tryCall`.
pub fn trySend(
    receiver: abi.Id,
    comptime Return: type,
    selector: sel.Sel,
    args: anytype,
    caught: ?*Exception,
) errors.Error!Return {
    const Context = struct {
        receiver: abi.Id,
        selector: sel.Sel,
        args: @TypeOf(args),
        result: Return = undefined,

        fn body(pointer: ?*anyopaque) callconv(.c) void {
            const context: *@This() = @ptrCast(@alignCast(pointer));
            context.result = message.send(context.receiver, Return, context.selector, context.args);
        }
    };
    var context: Context = .{ .receiver = receiver, .selector = selector, .args = args };
    try run(&Context.body, &context, caught);
    return context.result;
}

fn run(
    body: *const fn (?*anyopaque) callconv(.c) void,
    context: ?*anyopaque,
    caught: ?*Exception,
) errors.Error!void {
    const thrown = mac_zig_objc_try(body, context) orelse return;
    const exception: Exception = .{ .object = .{ .value = thrown } };
    if (caught) |slot| slot.* = exception else exception.deinit();
    return errors.Error.ObjcException;
}
