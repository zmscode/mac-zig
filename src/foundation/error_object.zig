//! `NSError`, and the out-parameter convention that produces it.

const std = @import("std");
const objc = @import("../objc/objc.zig");
const generated = @import("generated.zig");
const errors = @import("../errors.zig");
const String = @import("string.zig").String;

const Object = objc.Object;

/// An `NSError`: what went wrong with a call that takes `error:`.
///
/// Such calls are wrapped as returning `error.Failed`, with the details
/// handed to the caller when asked for:
///
/// ```zig
/// var details: foundation.ErrorObject = undefined;
/// const text = foundation.String.initContentsOfFile(path, &details) catch {
///     defer details.deinit();
///     std.log.err("{f}", .{details});
///     return;
/// };
/// ```
///
/// Named `ErrorObject` rather than `Error`, which is the error set.
pub const ErrorObject = extern struct {
    object: Object,

    /// Yours, when it came through a `details` parameter.
    /// Every method `NSError` has -- this is the everyday part -- as the
    /// generated wrapper for the same object.
    pub fn all(self: ErrorObject) generated.Error {
        return .from(self.object);
    }

    pub fn deinit(self: ErrorObject) void {
        self.object.release();
    }

    /// `NSCocoaErrorDomain`, `NSPOSIXErrorDomain`, `NSURLErrorDomain`...
    /// Borrowed from the error.
    pub fn domain(self: ErrorObject) String {
        return self.object.msgSend(String, "domain", .{});
    }

    /// The code within `domain`: an `errno` value for the POSIX domain.
    pub fn code(self: ErrorObject) objc.Integer {
        return self.object.msgSend(objc.Integer, "code", .{});
    }

    /// A sentence for a person to read. Autoreleased.
    pub fn localizedDescription(self: ErrorObject) String {
        return self.object.msgSend(String, "localizedDescription", .{});
    }

    /// `domain code: description`, for `{f}`.
    pub fn format(self: ErrorObject, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        const pool = objc.AutoreleasePool.init();
        defer pool.deinit();
        try writer.print("{f} {d}: {f}", .{ self.domain(), self.code(), self.localizedDescription() });
    }
};

/// The value from a completion handler's `(value, NSError)` pair -- the
/// shape of most of them -- as a Zig error union: the value, or
/// `error.Failed` with the `NSError` in `details` (retained, yours to
/// `deinit`) when given.
///
/// ```zig
/// var done = try objc.Completion(fn (?metal.Library, ?foundation.ErrorObject) void).init(gpa, io);
/// defer done.deinit();
/// device.newLibraryWithSourceOptionsCompletionHandler(source, null, done.handler());
/// const library = try foundation.valueOrError(try done.wait(), &details);
/// ```
///
/// The value is the completion's, and lives until its `deinit`.
pub fn valueOrError(result: anytype, details: ?*ErrorObject) errors.Error!@typeInfo(@TypeOf(result[0])).optional.child {
    if (result[0]) |value| return value;
    if (details) |out| {
        out.* = if (result[1]) |failure|
            .{ .object = failure.object.retain() }
        else
            .{ .object = Slot.makeUnknown() };
    }
    return errors.Error.Failed;
}

/// Where a wrapped call puts an `NSError *` out-parameter. Pass `&slot.id`
/// as the `error:` argument, then `finish` with whether the call worked.
pub const Slot = struct {
    id: objc.abi.Id = null,

    /// Turns the call's answer into `error.Failed`, storing the `NSError`
    /// in `details` when the caller asked for it.
    pub fn finish(self: Slot, ok: bool, details: ?*ErrorObject) errors.Error!void {
        if (ok) return;
        if (details) |out| {
            if (self.id) |id| {
                // The out-parameter is autoreleased; the caller gets one of
                // their own.
                out.* = .{ .object = (Object{ .value = id }).retain() };
            } else {
                out.* = .{ .object = makeUnknown() };
            }
        }
        return errors.Error.Failed;
    }

    /// A stand-in for a failure that reported no `NSError`, so a caller
    /// who asked for details always gets something to `deinit`.
    pub fn makeUnknown() Object {
        const domain = String.literal("MacZigUnknownError");
        return objc.getClass("NSError").?.msgSend(Object, "alloc", .{})
            .msgSend(Object, "initWithDomain:code:userInfo:", .{ domain, @as(objc.Integer, 0), @as(?Object, null) });
    }
};
