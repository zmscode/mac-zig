//! `NSURL`.

const std = @import("std");
const objc = @import("../objc/objc.zig");
const generated = @import("generated.zig");
const cf = @import("../cf.zig");
const errors = @import("../errors.zig");
const String = @import("string.zig").String;

const Error = errors.Error;
const Object = objc.Object;

/// A URL, which is how most of Foundation and AppKit name a file.
pub const Url = extern struct {
    object: Object,

    pub fn class() objc.Class {
        return objc.getClass("NSURL").?;
    }

    /// A `file://` URL for `file_path`, which may be relative. Yours.
    pub fn initFilePath(file_path: []const u8) Error!Url {
        const path_string = try String.init(file_path);
        defer path_string.deinit();
        return class().msgSend(Object, "alloc", .{}).msgSend(Url, "initFileURLWithPath:", .{path_string});
    }

    /// A URL parsed from `text`; `error.Failed` when it is not one. Yours.
    pub fn init(text: []const u8) Error!Url {
        const string = try String.init(text);
        defer string.deinit();
        return class().msgSend(Object, "alloc", .{}).msgSend(?Url, "initWithString:", .{string}) orelse Error.Failed;
    }

    /// Every method `NSURL` has -- this is the everyday part -- as the
    /// generated wrapper for the same object.
    pub fn all(self: Url) generated.URL {
        return .from(self.object);
    }

    pub fn deinit(self: Url) void {
        self.object.release();
    }

    pub fn retain(self: Url) Url {
        return .{ .object = self.object.retain() };
    }

    pub fn isFile(self: Url) bool {
        return self.object.msgSend(bool, "isFileURL", .{});
    }

    /// The whole URL. Autoreleased.
    pub fn absoluteString(self: Url) String {
        return self.object.msgSend(String, "absoluteString", .{});
    }

    /// The path, or null for a URL that has none. Autoreleased.
    pub fn path(self: Url) ?String {
        return self.object.msgSend(?String, "path", .{});
    }

    /// The scheme -- `https`, `file` -- or null. Autoreleased.
    pub fn scheme(self: Url) ?String {
        return self.object.msgSend(?String, "scheme", .{});
    }

    /// The host, or null. Autoreleased.
    pub fn host(self: Url) ?String {
        return self.object.msgSend(?String, "host", .{});
    }

    pub fn lastPathComponent(self: Url) ?String {
        return self.object.msgSend(?String, "lastPathComponent", .{});
    }

    /// `path` appended as a component. Autoreleased.
    pub fn appendingPathComponent(self: Url, component: String) Url {
        return self.object.msgSend(Url, "URLByAppendingPathComponent:", .{component});
    }

    pub fn asCf(self: Url) cf.Url {
        return .{ .handle = @ptrCast(self.object.value) };
    }
};

test "urls" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const web = try Url.init("https://ziglang.org/learn/");
    defer web.deinit();
    try std.testing.expect(!web.isFile());
    try std.testing.expect(web.scheme().?.eql(.literal("https")));
    try std.testing.expect(web.host().?.eql(.literal("ziglang.org")));
    try std.testing.expect(web.lastPathComponent().?.eql(.literal("learn")));

    const file = try Url.initFilePath("/tmp");
    defer file.deinit();
    try std.testing.expect(file.isFile());
    try std.testing.expect(file.appendingPathComponent(.literal("x.txt")).path().?.eql(.literal("/tmp/x.txt")));
}
