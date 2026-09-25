const std = @import("std");
const objc = @import("../objc/objc.zig");
const foundation = @import("foundation.zig");
const generated = @import("generated.zig");

test "every generated method, constant and function compiles" {
    // Taking each one's address makes the compiler analyse its body,
    // checking each selector against its arguments.
    @setEvalBranchQuota(2_000_000);
    inline for (@typeInfo(generated).@"struct".decl_names) |name| {
        const member = @field(generated, name);
        const info = @typeInfo(@TypeOf(member));
        if (info == .@"fn" and !info.@"fn".is_generic) std.mem.doNotOptimizeAway(&member);
        if (@TypeOf(member) == type and @typeInfo(member) == .@"struct" and
            (@hasDecl(member, "class_name") or @hasDecl(member, "protocol_name")))
        {
            inline for (@typeInfo(member).@"struct".decl_names) |decl| {
                const method = @field(member, decl);
                const method_info = @typeInfo(@TypeOf(method));
                if (method_info == .@"fn" and !method_info.@"fn".is_generic) std.mem.doNotOptimizeAway(&method);
            }
            inline for (@typeInfo(member.signatures).@"struct".decl_names) |decl| {
                std.debug.assert(@typeInfo(@field(member.signatures, decl)) == .@"fn");
            }
        }
    }
}

test "Foundation's constants and functions, called" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    try std.testing.expect(foundation.all.runLoopCommonModes().eql(.literal("kCFRunLoopCommonModes")));
    try std.testing.expect(foundation.all.homeDirectory().hasPrefix(.literal("/")));
    try std.testing.expect(foundation.all.stringFromSelector(objc.sel("initWithFrame:")).eql(.literal("initWithFrame:")));
    try std.testing.expect(foundation.all.selectorFromString(.literal("count")).eql(objc.sel("count")));
    try std.testing.expect(foundation.all.cocoaErrorDomain().eql(.literal("NSCocoaErrorDomain")));
}

// -- the long tail, used ---------------------------------------------------

const String = foundation.String;

test "a hand-written type reaches its full method list with all()" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const text = String.literal("Mac, Zig, Objective-C");
    try std.testing.expect(text.all().lowercaseString().eql(.literal("mac, zig, objective-c")));
    const parts = text.all().componentsSeparatedByString(.literal(", "));
    try std.testing.expectEqual(@as(usize, 3), parts.count());
    try std.testing.expect(parts.at(1).?.eql(.literal("Zig")));
}

test "the file manager, through a temporary directory" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const files = foundation.all.FileManager.defaultManager();
    const base = files.temporaryDirectory().appendingPathComponent(.literal("mac-zig-test")).path().?;
    var failure: objc.abi.Id = null;
    try std.testing.expect(files.createDirectoryAtPathWithIntermediateDirectoriesAttributesError(base, true, null, &failure));
    defer _ = files.removeItemAtPathError(base, null);

    try String.literal("hello").writeToFile(base.appending(.literal("/a.txt")).utf8(), null);
    try std.testing.expect(files.fileExistsAtPath(base.appending(.literal("/a.txt"))));
    const listing = files.contentsOfDirectoryAtPathError(base, null).?;
    try std.testing.expectEqual(@as(usize, 1), listing.count());
    try std.testing.expect(listing.at(0).?.eql(.literal("a.txt")));
}

test "process info, the bundle and a UUID" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const info = foundation.all.ProcessInfo.processInfo();
    try std.testing.expect(info.processorCount() >= 1);
    try std.testing.expect(info.operatingSystemVersion().major_version >= 13);
    try std.testing.expect(foundation.all.Bundle.mainBundle().bundlePath().length() > 0);
    try std.testing.expectEqual(@as(usize, 36), foundation.all.UUID.uuid().uuidString().length());
}

test "user defaults, in a suite of their own" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const defaults = foundation.all.UserDefaults.alloc().initWithSuiteName(.literal("io.github.zmscode.mac-zig.test")).?;
    defer defaults.release();
    defaults.setIntegerForKey(42, .literal("answer"));
    try std.testing.expectEqual(@as(objc.Integer, 42), defaults.integerForKey(.literal("answer")));
    defaults.removeObjectForKey(.literal("answer"));
    try std.testing.expectEqual(@as(objc.Integer, 0), defaults.integerForKey(.literal("answer")));
}

test "notifications, observed by a typed block" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const Seen = objc.Block(struct { count: *u32 }, fn (foundation.all.Notification) void);
    var count: u32 = 0;
    var block = Seen.init(.{ .count = &count }, struct {
        fn body(captures: *const Seen.Captures, note: foundation.all.Notification) void {
            if (note.name().eql(.literal("MacZigTestNotification"))) captures.count.* += 1;
        }
    }.body);

    const center = foundation.all.NotificationCenter.defaultCenter();
    const token = center.addObserverForNameObjectQueueUsingBlock(.literal("MacZigTestNotification"), null, null, block.ref());
    center.postNotificationNameObject(.literal("MacZigTestNotification"), null);
    center.postNotificationNameObject(.literal("MacZigTestNotification"), null);
    center.removeObserver(token);
    center.postNotificationNameObject(.literal("MacZigTestNotification"), null);
    try std.testing.expectEqual(@as(u32, 2), count);
}

test "JSON, both ways" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const JSON = foundation.all.JSONSerialization;
    const source = foundation.Data.init("{\"name\":\"zig\",\"stars\":42}");
    defer source.deinit();
    const parsed = foundation.Dictionary(String, objc.Object).from(JSON.jsonObjectWithDataOptionsError(source, .{}, null).?);
    try std.testing.expect(parsed.get(.literal("name")).?.eql(String.literal("zig").object));
    try std.testing.expect(JSON.isValidJSONObject(parsed.object));
    const encoded = JSON.dataWithJSONObjectOptionsError(parsed.object, .{ .sorted_keys = true }, null).?;
    try std.testing.expectEqualStrings("{\"name\":\"zig\",\"stars\":42}", encoded.bytes());
}
