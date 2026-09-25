//! `NSData`.

const std = @import("std");
const objc = @import("../objc/objc.zig");
const generated = @import("generated.zig");
const cf = @import("../cf.zig");
const errors = @import("../errors.zig");
const error_object = @import("error_object.zig");
const String = @import("string.zig").String;

const Error = errors.Error;
const Object = objc.Object;
const ErrorObject = error_object.ErrorObject;

/// An immutable byte buffer.
pub const Data = extern struct {
    object: Object,

    pub fn class() objc.Class {
        return objc.getClass("NSData").?;
    }

    /// A copy of `contents`. Yours.
    pub fn init(contents: []const u8) Data {
        return class().msgSend(Object, "alloc", .{}).msgSend(Data, "initWithBytes:length:", .{
            contents.ptr,
            @as(objc.UInteger, contents.len),
        });
    }

    /// The contents of the file at `path`. Yours.
    pub fn initContentsOfFile(path: []const u8, details: ?*ErrorObject) Error!Data {
        const path_string = try String.init(path);
        defer path_string.deinit();

        var slot: error_object.Slot = .{};
        const data = class().msgSend(Object, "alloc", .{}).msgSend(?Data, "initWithContentsOfFile:options:error:", .{
            path_string,
            @as(objc.UInteger, 0),
            &slot.id,
        });
        try slot.finish(data != null, details);
        return data.?;
    }

    /// Writes the bytes to `path`, replacing what is there, atomically.
    pub fn writeToFile(self: Data, path: []const u8, details: ?*ErrorObject) Error!void {
        const path_string = try String.init(path);
        defer path_string.deinit();

        var slot: error_object.Slot = .{};
        // NSDataWritingAtomic
        const ok = self.object.msgSend(bool, "writeToFile:options:error:", .{ path_string, @as(objc.UInteger, 1), &slot.id });
        try slot.finish(ok, details);
    }

    /// Every method `NSData` has -- this is the everyday part -- as the
    /// generated wrapper for the same object.
    pub fn all(self: Data) generated.Data {
        return .from(self.object);
    }

    pub fn deinit(self: Data) void {
        self.object.release();
    }

    pub fn retain(self: Data) Data {
        return .{ .object = self.object.retain() };
    }

    pub fn autorelease(self: Data) Data {
        return .{ .object = self.object.autorelease() };
    }

    /// The bytes, borrowed: valid while this `Data` is.
    pub fn bytes(self: Data) []const u8 {
        const len = self.object.msgSend(objc.UInteger, "length", .{});
        if (len == 0) return &.{};
        const base = self.object.msgSend([*]const u8, "bytes", .{});
        return base[0..len];
    }

    pub fn asCf(self: Data) cf.Data {
        return self.object.asCf(cf.Data).?;
    }

    pub fn fromCf(data: cf.Data) Data {
        return .{ .object = Object.fromCf(data) };
    }
};

test "data holds a copy" {
    var source = "bytes".*;
    const data = Data.init(&source);
    defer data.deinit();
    source[0] = 'X';
    try std.testing.expectEqualStrings("bytes", data.bytes());
}

test "data through a file" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    const path = try std.fmt.allocPrint(std.testing.allocator, ".zig-cache/tmp/{s}/data.bin", .{tmp.sub_path});
    defer std.testing.allocator.free(path);

    const written = Data.init("\x00\x01\x02");
    defer written.deinit();
    try written.writeToFile(path, null);

    const read = try Data.initContentsOfFile(path, null);
    defer read.deinit();
    try std.testing.expectEqualSlices(u8, "\x00\x01\x02", read.bytes());
}
