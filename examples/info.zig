//! What this machine has: displays, modes, and the windows on screen.
//!
//!     zig build run-info

const std = @import("std");
const cg = @import("cg");

const print = std.debug.print;

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();
    const allocator = debug_allocator.allocator();

    print("cg-zig features: imageio={}, coretext={}\n\n", .{
        cg.features.imageio,
        cg.features.coretext,
    });

    // -- displays -----------------------------------------------------

    var display_buffer: [64]cg.Display = undefined;
    const displays = try cg.Display.active(&display_buffer);
    print("{d} active display(s)\n", .{displays.len});

    for (displays) |screen| {
        print("  display {d}{s}{s}\n", .{
            screen.id,
            if (screen.isMain()) " [main]" else "",
            if (screen.isBuiltin()) " [built-in]" else "",
        });
        print("    bounds   {f}\n", .{screen.bounds()});
        print("    pixels   {f}\n", .{screen.pixelSize()});

        const mode = try screen.currentMode();
        defer mode.deinit();
        print("    mode     {f} at {d}Hz{s}\n", .{
            mode.size(),
            mode.refreshRate(),
            if (mode.isRetina()) " (Retina)" else "",
        });

        // The current mode is usually absent from the unscaled list, which
        // is why this asks for the scaled ones too.
        const modes = try screen.modes(.{ .include_scaled = true });
        defer modes.deinit();
        print("    modes    {d} available\n", .{modes.count()});
    }

    // -- windows ------------------------------------------------------

    const windows = try cg.window.list(allocator, .visible, 0);
    defer windows.deinit(allocator);

    print("\n{d} window(s) on screen\n", .{windows.windows.len});

    var shown: usize = 0;
    var titled: usize = 0;
    for (windows.windows) |w| {
        if (w.title != null) titled += 1;
        if (w.layer != 0) continue; // skip the menu bar, dock and friends
        if (shown >= 10) continue;
        shown += 1;

        print("  {s: <24} {f}", .{ w.owner_name orelse "(unknown)", w.bounds });
        if (w.title) |title| print("  \"{s}\"", .{title});
        print("\n", .{});
    }

    if (titled == 0 and windows.windows.len > 0) {
        print(
            \\
            \\No window titles were readable, which means this binary has not
            \\been granted Screen Recording permission. Every other field
            \\above is still correct -- titles are the only part that needs
            \\it.
            \\
        , .{});
    }
}
