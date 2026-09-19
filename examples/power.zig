//! Battery and mains state.
//!
//!     zig build run-power

const std = @import("std");
const mac = @import("mac");

const print = std.debug.print;

pub fn main() !void {
    if (!mac.features.iokit) {
        print("built with -Diokit=false; nothing to read\n", .{});
        return;
    }

    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();
    const allocator = debug_allocator.allocator();

    const state = try mac.iokit.power.snapshot(allocator);
    defer state.deinit(allocator);

    print("powered by: {t}\n", .{state.providing});
    print("warning level: {t}\n", .{mac.iokit.power.warningLevel()});

    if (mac.iokit.power.timeRemaining()) |minutes| {
        print("time remaining: {d}h {d}m\n", .{ minutes / 60, minutes % 60 });
    } else {
        print("time remaining: not estimating (on mains, or still working it out)\n", .{});
    }

    if (state.sources.len == 0) {
        print("\nno power sources -- this is a desktop\n", .{});
        return;
    }

    for (state.sources) |source| {
        print("\n{s}\n", .{source.name});
        print("  kind      {t}\n", .{source.kind});
        print("  state     {t}\n", .{source.state});
        print("  charge    {d}%  ({d}/{d})\n", .{
            source.percent,
            source.current_capacity,
            source.max_capacity,
        });
        print("  charging  {}\n", .{source.is_charging});
        if (source.health) |health| print("  health    {s}\n", .{health});
        if (source.time_to_empty) |m| print("  to empty  {d}m\n", .{m});
        if (source.time_to_full) |m| print("  to full   {d}m\n", .{m});
    }
}
