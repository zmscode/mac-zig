//! Objective-C from Zig, at every level: Foundation's types, a class
//! defined as a Zig struct, an exception caught as an error, and AppKit
//! through the generated wrappers.
//!
//!     zig build run-objc

const std = @import("std");
const mac = @import("mac");
const objc = mac.objc;
const foundation = mac.foundation;
const appkit = mac.appkit;

const print = std.debug.print;
const String = foundation.String;

/// A class of our own, as a Zig struct: fields are the instance's state,
/// `pub fn`s are its methods.
const Tally = objc.Subclass(.{ .name = "MacZigExampleTally" }, struct {
    words: usize = 0,
    characters: usize = 0,

    pub fn @"count:"(self: *@This(), word: String) void {
        self.words += 1;
        self.characters += word.length();
    }

    /// An override that calls `super`, and that Foundation calls.
    pub fn description(self: Tally) String {
        const inherited = self.object.msgSendSuper(objc.getClass("NSObject").?, String, "description", .{});
        return inherited.appending(.literal(" (counted in Zig)"));
    }
});

pub fn main() !void {
    if (!mac.features.objc) {
        print("built with -Dobjc=false; there is no runtime to talk to\n", .{});
        return;
    }

    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    // -- Foundation -----------------------------------------------------

    const words = foundation.Array(String).init(&.{
        .literal("message"), .literal("zig"), .literal("objective"), .literal("send"),
    });
    defer words.deinit();

    const by_length = words.sorted(struct {
        fn order(a: String, b: String) std.math.Order {
            return std.math.order(a.length(), b.length());
        }
    }.order);

    print("sorted by length:", .{});
    var it = by_length.iterator();
    while (it.next()) |word| print(" {f}", .{word});
    print("\n", .{});

    var details: foundation.ErrorObject = undefined;
    if (String.initContentsOfFile("/no/such/file", &details)) |text| {
        text.deinit();
    } else |_| {
        defer details.deinit();
        print("reading a missing file: {f}\n", .{details});
    }

    // -- a class of our own ---------------------------------------------

    const tally = Tally.new();
    defer tally.release();

    var words_it = words.iterator();
    while (words_it.next()) |word| tally.msgSend(void, "count:", .{word});
    print("\ntally saw {d} words, {d} characters\n", .{ tally.state().words, tally.state().characters });

    // An array describes itself by asking each element -- our override.
    const boxed = foundation.Array(Tally).init(&.{tally});
    defer boxed.deinit();
    print("in an array it reads {f}\n", .{boxed.object.msgSend(String, "description", .{})});

    // -- an exception, caught -------------------------------------------

    var caught: objc.Exception = undefined;
    _ = words.object.tryMsgSend(objc.Object, "objectAtIndex:", .{@as(objc.UInteger, 99)}, &caught) catch {
        defer caught.deinit();
        print("\nindexing past the end: {f}\n", .{caught});
    };

    // -- AppKit ---------------------------------------------------------

    if (!mac.features.appkit) return;
    print("\nscreens:\n", .{});
    var screens = appkit.Screen.screens().iterator();
    while (screens.next()) |screen| {
        print("  {f}  {f} at {d}x\n", .{ screen.localizedName(), screen.frame(), screen.backingScaleFactor() });
    }
}
