//! `NSString`.

const std = @import("std");
const objc = @import("../objc/objc.zig");
const cf = @import("../cf.zig");
const errors = @import("../errors.zig");
const error_object = @import("error_object.zig");

const Error = errors.Error;
const Object = objc.Object;
const ErrorObject = error_object.ErrorObject;

/// An immutable string, stored as UTF-16 -- which is what `length` counts
/// and what an `objc.Range` indexes.
///
/// ## Ownership
///
/// As everywhere in this package, `init...` hands you a string that is
/// yours to `deinit`. Every other method that returns a string hands back
/// one that is autoreleased, and valid until the enclosing
/// `objc.AutoreleasePool` drains. `literal` is neither: it is made once and
/// never freed, like an `@"..."` constant.
pub const String = extern struct {
    object: Object,

    pub fn class() objc.Class {
        return objc.getClass("NSString").?;
    }

    /// A copy of `text`, which must be valid UTF-8. Yours.
    pub fn init(text: []const u8) Error!String {
        const string = class().msgSend(Object, "alloc", .{}).msgSend(?String, "initWithBytes:length:encoding:", .{
            text.ptr,
            @as(objc.UInteger, text.len),
            utf8_encoding,
        });
        return string orelse Error.Failed;
    }

    /// The string `text`, made the first time it is asked for and kept for
    /// the life of the process -- the `@"..."` of Objective-C. Needs no
    /// pool and no `deinit`.
    pub fn literal(comptime text: [:0]const u8) String {
        const Cache = struct {
            const key = text;
            var value: objc.abi.Id = null;
        };
        if (@atomicLoad(objc.abi.Id, &Cache.value, .acquire)) |value| return .{ .object = .{ .value = value } };
        if (comptime !std.unicode.utf8ValidateSlice(text)) @compileError("not UTF-8: " ++ text);
        // Valid UTF-8 cannot fail, short of running out of memory.
        const made = init(Cache.key) catch @panic("out of memory");
        // Two threads may both get here; the loser's copy is released.
        if (@cmpxchgStrong(objc.abi.Id, &Cache.value, null, made.object.value, .acq_rel, .acquire)) |winner| {
            made.deinit();
            return .{ .object = .{ .value = winner.? } };
        }
        return made;
    }

    /// The contents of the file at `path`, which must be UTF-8. Yours.
    pub fn initContentsOfFile(path: []const u8, details: ?*ErrorObject) Error!String {
        const path_string = try init(path);
        defer path_string.deinit();

        var slot: error_object.Slot = .{};
        const string = class().msgSend(Object, "alloc", .{}).msgSend(?String, "initWithContentsOfFile:encoding:error:", .{
            path_string,
            utf8_encoding,
            &slot.id,
        });
        try slot.finish(string != null, details);
        return string.?;
    }

    /// Writes this string to `path` as UTF-8, replacing what is there.
    pub fn writeToFile(self: String, path: []const u8, details: ?*ErrorObject) Error!void {
        const path_string = try init(path);
        defer path_string.deinit();

        var slot: error_object.Slot = .{};
        const ok = self.object.msgSend(bool, "writeToFile:atomically:encoding:error:", .{
            path_string,
            true,
            utf8_encoding,
            &slot.id,
        });
        try slot.finish(ok, details);
    }

    pub fn deinit(self: String) void {
        self.object.release();
    }

    pub fn retain(self: String) String {
        return .{ .object = self.object.retain() };
    }

    pub fn autorelease(self: String) String {
        return .{ .object = self.object.autorelease() };
    }

    /// The same string as a `cf.String`. Same reference, not a copy.
    pub fn asCf(self: String) cf.String {
        return self.object.asCf(cf.String).?;
    }

    pub fn fromCf(string: cf.String) String {
        return .{ .object = Object.fromCf(string) };
    }

    /// The length in UTF-16 code units -- *not* the number of bytes the
    /// UTF-8 form takes, and not the number of characters a person sees.
    pub fn length(self: String) usize {
        return self.object.msgSend(objc.UInteger, "length", .{});
    }

    /// The UTF-8 form, borrowed. It lives in an autoreleased buffer, so it
    /// is valid until the pool drains or the string is freed, whichever is
    /// first. `toOwnedSlice` for anything longer.
    pub fn utf8(self: String) [:0]const u8 {
        return std.mem.span(self.object.msgSend([*:0]const u8, "UTF8String", .{}));
    }

    /// A UTF-8 copy in memory the caller owns.
    pub fn toOwnedSlice(self: String, allocator: std.mem.Allocator) ![]u8 {
        return self.asCf().toOwnedSlice(allocator);
    }

    pub fn eql(self: String, other: String) bool {
        return self.object.msgSend(bool, "isEqualToString:", .{other});
    }

    pub fn hasPrefix(self: String, prefix: String) bool {
        return self.object.msgSend(bool, "hasPrefix:", .{prefix});
    }

    pub fn hasSuffix(self: String, suffix: String) bool {
        return self.object.msgSend(bool, "hasSuffix:", .{suffix});
    }

    /// Where `needle` first occurs, in UTF-16 units, or null.
    pub fn find(self: String, needle: String) ?objc.Range {
        const found = self.object.msgSend(objc.Range, "rangeOfString:", .{needle});
        return if (found.found()) found else null;
    }

    /// This string followed by `other`. Autoreleased.
    pub fn appending(self: String, other: String) String {
        return self.object.msgSend(String, "stringByAppendingString:", .{other});
    }

    /// The UTF-8 form, for `{f}`.
    pub fn format(self: String, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        const pool = objc.AutoreleasePool.init();
        defer pool.deinit();
        try writer.writeAll(self.utf8());
    }
};

/// `NSUTF8StringEncoding`.
const utf8_encoding: objc.UInteger = 4;

test "a string round trip" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const text = try String.init("hello, τ");
    defer text.deinit();

    try std.testing.expectEqualStrings("hello, τ", text.utf8());
    try std.testing.expectEqual(@as(usize, 8), text.length());

    const copy = try text.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(copy);
    try std.testing.expectEqualStrings("hello, τ", copy);
}

test "invalid UTF-8 is an error" {
    try std.testing.expectError(Error.Failed, String.init("\xff\xfe"));
}

test "a literal is made once" {
    const a = String.literal("constant");
    const b = String.literal("constant");
    try std.testing.expect(a.object.value == b.object.value);
    try std.testing.expect(!String.literal("other").eql(a));
}

test "searching and joining" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const text = String.literal("objective zig");
    try std.testing.expect(text.hasPrefix(.literal("obj")));
    try std.testing.expect(text.hasSuffix(.literal("zig")));
    try std.testing.expectEqual(objc.Range{ .location = 10, .length = 3 }, text.find(.literal("zig")).?);
    try std.testing.expect(text.find(.literal("swift")) == null);

    var buffer: [64]u8 = undefined;
    const printed = try std.fmt.bufPrint(&buffer, "{f}", .{text.appending(.literal("!"))});
    try std.testing.expectEqualStrings("objective zig!", printed);
}

test "a missing file is an error with details" {
    var details: ErrorObject = undefined;
    try std.testing.expectError(Error.Failed, String.initContentsOfFile("/no/such/file", &details));
    defer details.deinit();
    try std.testing.expect(details.code() != 0);
    try std.testing.expect(details.domain().eql(.literal("NSCocoaErrorDomain")));
}
