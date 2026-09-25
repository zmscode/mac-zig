//! Screen capture from Zig: list what there is to capture, stream the
//! main display for a moment, and hand each frame to the GPU without a
//! copy.
//!
//!     zig build run-capture
//!     zig build run-capture -- --seconds 5
//!     zig build run-capture -- --screenshot screen.png   # one still, to a PNG
//!
//! Needs Screen Recording permission for the terminal it runs in (System
//! Settings > Privacy & Security > Screen & System Audio Recording). The
//! first run asks.

const std = @import("std");
const mac = @import("mac");
const objc = mac.objc;
const sck = mac.screencapturekit;
const corevideo = mac.corevideo;
const metal = mac.metal;
const cg = mac.cg;

const print = std.debug.print;

/// What the stream's handler sees. It runs on the stream's own queue, so
/// the counters are atomic.
const Recorder = struct {
    frames: std.atomic.Value(u32) = .init(0),
    textures: std.atomic.Value(u32) = .init(0),
    width: std.atomic.Value(usize) = .init(0),
    height: std.atomic.Value(usize) = .init(0),
    cache: ?Cache,

    const Cache = if (mac.features.metal) corevideo.MetalTextureCache else void;

    pub fn frame(self: *Recorder, f: sck.Frame) void {
        const pixels = f.pixelBuffer();
        self.width.store(pixels.width(), .monotonic);
        self.height.store(pixels.height(), .monotonic);
        _ = self.frames.fetchAdd(1, .monotonic);

        // The capture as a Metal texture: the same IOSurface, no upload.
        // A renderer would encode a pass sampling `texture.texture()` here.
        if (comptime mac.features.metal) if (self.cache) |cache| {
            const texture = cache.texture(pixels, .{}) catch return;
            defer texture.deinit();
            _ = self.textures.fetchAdd(1, .monotonic);
            cache.flush();
        };
    }

    pub fn stopped(_: *Recorder, failure: mac.foundation.ErrorObject) void {
        print("stream stopped: {f}\n", .{failure});
    }
};

pub fn main(init: std.process.Init) !void {
    if (!mac.features.screencapturekit) {
        print("built without -Dscreencapturekit\n", .{});
        return;
    }
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();
    const io = init.io;
    // The waits here finish on ScreenCaptureKit's threads, so their memory
    // comes from an allocator that is safe to free from any thread.
    const gpa = std.heap.smp_allocator;

    var seconds: f64 = 2;
    var screenshot_path: ?[]const u8 = null;
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    var i: usize = 1;
    while (i + 1 < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--seconds")) {
            i += 1;
            seconds = try std.fmt.parseFloat(f64, args[i]);
        } else if (std.mem.eql(u8, args[i], "--screenshot")) {
            i += 1;
            screenshot_path = args[i];
        }
    }

    if (!sck.hasPermission()) {
        print(
            \\No Screen Recording permission. Grant it to this terminal in System Settings >
            \\Privacy & Security > Screen & System Audio Recording, then run this again.
            \\
        , .{});
        _ = sck.requestPermission();
        return;
    }

    var details: mac.foundation.ErrorObject = undefined;
    const content = sck.shareableContent(gpa, io, .{}, &details) catch |err| {
        if (err == error.Failed) {
            defer details.deinit();
            print("could not list shareable content: {f}\n", .{details});
            return;
        }
        return err;
    };
    defer content.release();

    const displays = content.displays();
    print("{d} display(s), {d} window(s) on screen, {d} app(s)\n", .{
        displays.count(), content.windows().count(), content.applications().count(),
    });
    const display = displays.first() orelse return;
    print("capturing display {d}: {d}x{d} points\n", .{ display.displayID(), display.width(), display.height() });

    const filter = sck.ContentFilter.alloc().initWithDisplayExcludingWindows(display, .init(&.{}));
    defer filter.release();
    const config = sck.StreamConfiguration.new();
    defer config.release();
    // Pixels rather than points: twice as many on a Retina display.
    const scale: usize = @intFromFloat(@max(1, filter.pointPixelScale()));
    config.setWidth(@as(usize, @intCast(display.width())) * scale);
    config.setHeight(@as(usize, @intCast(display.height())) * scale);
    config.setPixelFormat(@backingInt(corevideo.PixelFormat.bgra));
    config.setShowsCursor(true);

    if (screenshot_path) |path| {
        const image = sck.screenshot(gpa, io, filter, config, &details) catch |err| {
            if (err == error.Failed) {
                defer details.deinit();
                print("screenshot failed: {f}\n", .{details});
                return;
            }
            return err;
        };
        defer image.deinit();
        if (!mac.features.imageio) return std.debug.print("built without -Dimageio: not writing {s}\n", .{path});
        try cg.imageio.writeImage(image, path, .png, .{});
        print("wrote {s}: {d}x{d}\n", .{ path, image.width(), image.height() });
        return;
    }

    const device = if (comptime mac.features.metal) metal.createSystemDefaultDevice() else null;
    defer if (comptime mac.features.metal) if (device) |d| d.release();
    const cache: ?Recorder.Cache = if (comptime mac.features.metal) (if (device) |d| try corevideo.MetalTextureCache.init(d) else null) else null;
    defer if (comptime mac.features.metal) if (cache) |c| c.deinit();

    var recorder: Recorder = .{ .cache = cache };
    const stream = sck.Stream.init(filter, config, &recorder, Recorder, &details) catch |err| {
        if (err == error.Failed) {
            defer details.deinit();
            print("could not make the stream: {f}\n", .{details});
            return;
        }
        return err;
    };
    defer stream.deinit();

    const started = std.Io.Clock.awake.now(io);
    try stream.start(gpa, io, null);
    try io.sleep(.fromNanoseconds(@intFromFloat(seconds * std.time.ns_per_s)), .awake);
    try stream.stop(gpa, io, null);
    const elapsed = @as(f64, @floatFromInt(started.durationTo(std.Io.Clock.awake.now(io)).nanoseconds)) / std.time.ns_per_s;

    const frames = recorder.frames.load(.monotonic);
    print("{d} frames of {d}x{d} in {d:.2}s: {d:.1} fps, {d} as Metal textures\n", .{
        frames,
        recorder.width.load(.monotonic),
        recorder.height.load(.monotonic),
        elapsed,
        @as(f64, @floatFromInt(frames)) / elapsed,
        recorder.textures.load(.monotonic),
    });
    print("(ScreenCaptureKit sends a frame only when something on screen changes.)\n", .{});
}
