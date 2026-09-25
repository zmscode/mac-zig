//! [ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit):
//! capturing displays, windows and apps -- reached as
//! `mac.screencapturekit`, under `-Dscreencapturekit`.
//!
//! ```zig
//! if (!screencapturekit.hasPermission()) return error.NoScreenRecordingPermission;
//!
//! const content = try screencapturekit.shareableContent(gpa, io, .{}, null);
//! defer content.release();
//! const display = content.displays().first().?;
//!
//! const filter = screencapturekit.ContentFilter.alloc()
//!     .initWithDisplayExcludingWindows(display, .init(&.{}));
//! defer filter.release();
//! const config = screencapturekit.StreamConfiguration.new();
//! defer config.release();
//! config.setWidth(@intCast(display.width() * 2));    // pixels: points x 2 on Retina
//! config.setHeight(@intCast(display.height() * 2));
//!
//! const stream = try screencapturekit.Stream.init(filter, config, &recorder, Recorder, null);
//! defer stream.deinit();
//! try stream.start(gpa, io, null);
//! ```
//!
//! where `Recorder.frame(&recorder, frame)` is called for each new frame on
//! a queue of the stream's own. A frame is a `corevideo.PixelBuffer` on an
//! IOSurface: hand it to a `corevideo.MetalTextureCache` and the GPU reads
//! the capture where it lies.
//!
//! ## Permission
//!
//! Capturing needs Screen Recording permission, which macOS grants to an
//! app -- a signed bundle, `addAppBundle` in `build.zig` -- or to the
//! terminal a command-line program runs in. `hasPermission` asks without
//! prompting; `requestPermission` prompts, once. Without it, content comes
//! back empty or with an error, and a stream fails to start.
//!
//! Everything in the framework is in `all`, generated from the SDK.

const std = @import("std");
const Io = std.Io;
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");
const cg = @import("../cg/cg.zig");
const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const dispatch = @import("../dispatch/dispatch.zig");
const iosurface = @import("../iosurface/iosurface.zig");
const corevideo = @import("../corevideo/corevideo.zig");
const coremedia = @import("../coremedia/coremedia.zig");
const generated = @import("generated.zig");

const Error = errors.Error;
const ErrorObject = foundation.ErrorObject;

/// True when the package was built with `-Dscreencapturekit` (the default).
pub const enabled = true;

/// Every class, protocol, enum and constant generated from the SDK.
pub const all = generated;

pub const ShareableContent = generated.ShareableContent;
pub const Display = generated.Display;
pub const Window = generated.Window;
pub const RunningApplication = generated.RunningApplication;
pub const ContentFilter = generated.ContentFilter;
pub const StreamConfiguration = generated.StreamConfiguration;
pub const ScreenshotManager = generated.ScreenshotManager;
pub const StreamOutputType = generated.StreamOutputType;
pub const FrameStatus = generated.FrameStatus;

/// What the asynchronous calls here can fail with: the call itself
/// (`error.Failed`, with the `NSError` in `details`), the wait being
/// canceled, or no memory for the wait.
pub const AsyncError = Error || Io.Cancelable || std.mem.Allocator.Error;

/// Whether this process may capture the screen. Does not prompt.
pub fn hasPermission() bool {
    return cg.window.hasScreenCaptureAccess();
}

/// Prompts for Screen Recording permission, the first time only, and
/// answers whether it is granted. A grant usually takes effect only once
/// the app is relaunched.
pub fn requestPermission() bool {
    return cg.window.requestScreenCaptureAccess();
}

pub const ContentOptions = struct {
    /// Leave out the desktop's own windows: the wallpaper and icons.
    exclude_desktop_windows: bool = false,
    /// Only windows that are on screen now, rather than every window
    /// including minimized ones and those on other Spaces.
    on_screen_windows_only: bool = true,
};

/// The displays, windows and apps there are to capture. Yours to
/// `release`.
///
/// `allocator` holds the wait, and must be thread-safe; see
/// `objc.Completion`.
pub fn shareableContent(
    allocator: std.mem.Allocator,
    io: Io,
    options: ContentOptions,
    details: ?*ErrorObject,
) AsyncError!ShareableContent {
    var done = try objc.Completion(fn (?ShareableContent, ?ErrorObject) void).init(allocator, io);
    defer done.deinit();
    ShareableContent.getShareableContentExcludingDesktopWindowsOnScreenWindowsOnlyCompletionHandler(
        options.exclude_desktop_windows,
        options.on_screen_windows_only,
        done.handler(),
    );
    const content = try foundation.valueOrError(try done.wait(), details);
    return .{ .object = content.object.retain() };
}

/// One still image of what `filter` selects, at the size and in the format
/// `configuration` asks for. Yours to `deinit`. macOS 14 and later.
pub fn screenshot(
    allocator: std.mem.Allocator,
    io: Io,
    filter: ContentFilter,
    configuration: StreamConfiguration,
    details: ?*ErrorObject,
) AsyncError!cg.Image {
    var done = try objc.Completion(fn (?cg.Image, ?ErrorObject) void).init(allocator, io);
    defer done.deinit();
    ScreenshotManager.captureImageWithFilterConfigurationCompletionHandler(filter, configuration, done.handler());
    const image = try foundation.valueOrError(try done.wait(), details);
    return image.retain();
}

/// A frame from a stream: a sample buffer that holds a new image. Borrowed
/// for the length of the `frame` handler; `retain` what is wanted longer.
pub const Frame = struct {
    sample: coremedia.SampleBuffer,

    /// The image. Borrowed.
    pub fn pixelBuffer(self: Frame) corevideo.PixelBuffer {
        return self.sample.imageBuffer().?;
    }

    /// The IOSurface under the image -- for a `CALayer`'s contents, or for
    /// another process. Borrowed.
    pub fn surface(self: Frame) ?iosurface.Surface {
        return self.pixelBuffer().surface();
    }

    /// When the frame was on screen.
    pub fn time(self: Frame) coremedia.Time {
        return self.sample.presentationTime();
    }

    /// Points to pixels, for the captured content: 2 on a Retina display.
    pub fn scaleFactor(self: Frame) ?f64 {
        const value = self.attachment(generated.streamFrameInfoScaleFactor()) orelse return null;
        return (cf.Number{ .handle = @ptrCast(value.handle) }).toFloat();
    }

    /// The part of the frame, in pixels, that holds the content -- the
    /// rest is letterboxing when the aspect ratios differ.
    pub fn contentRect(self: Frame) ?cg.Rect {
        const value = self.attachment(generated.streamFrameInfoContentRect()) orelse return null;
        var rect: raw.CGRect = undefined;
        if (!raw.CGRectMakeWithDictionaryRepresentation(@ptrCast(value.handle), &rect)) return null;
        return @bitCast(rect);
    }

    fn attachment(self: Frame, key: foundation.String) ?cf.Type {
        return self.sample.sampleAttachment(@ptrCast(key.object.value));
    }

    fn status(sample: coremedia.SampleBuffer) FrameStatus {
        const value = sample.sampleAttachment(@ptrCast(generated.streamFrameInfoStatus().object.value)) orelse
            return .complete;
        return @fromBackingInt(@intCast((cf.Number{ .handle = @ptrCast(value.handle) }).toInt()));
    }
};

/// A running capture, delivering frames to Zig handlers. Yours to `deinit`.
pub const Stream = struct {
    stream: generated.Stream,
    receiver: Receiver,
    queue: dispatch.Queue,

    /// A stream of what `filter` selects, as `configuration` says, calling
    /// `Handlers` with `context` -- a pointer that must outlive the stream:
    ///
    /// - `frame(context, Frame)` -- required: each new frame. Frames with
    ///   nothing new in them (the screen did not change) are not passed on.
    /// - `audio(context, coremedia.SampleBuffer)` -- optional: audio, when
    ///   `configuration.setCapturesAudio(true)`.
    /// - `stopped(context, foundation.ErrorObject)` -- optional: the
    ///   stream stopped by itself -- the display went away, or permission
    ///   was withdrawn. The error is borrowed.
    ///
    /// Handlers run on a serial queue of the stream's own, one at a time.
    /// Nothing is captured until `start`.
    pub fn init(
        filter: ContentFilter,
        configuration: StreamConfiguration,
        context: anytype,
        comptime Handlers: type,
        details: ?*ErrorObject,
    ) Error!Stream {
        const C = @TypeOf(context);
        if (@typeInfo(C) != .pointer) @compileError("the context for a Stream must be a pointer");
        if (!@hasDecl(Handlers, "frame")) @compileError(@typeName(Handlers) ++ " needs a frame(context, Frame) function");

        const Erased = struct {
            fn frame(pointer: ?*anyopaque, f: Frame) void {
                Handlers.frame(@as(C, @ptrCast(@alignCast(pointer))), f);
            }
            fn audio(pointer: ?*anyopaque, sample: coremedia.SampleBuffer) void {
                if (@hasDecl(Handlers, "audio")) Handlers.audio(@as(C, @ptrCast(@alignCast(pointer))), sample);
            }
            fn stopped(pointer: ?*anyopaque, failure: ErrorObject) void {
                if (@hasDecl(Handlers, "stopped")) Handlers.stopped(@as(C, @ptrCast(@alignCast(pointer))), failure);
            }
        };

        const receiver = Receiver.new();
        errdefer receiver.release();
        receiver.state().* = .{
            .context = @ptrCast(@constCast(context)),
            .frame = Erased.frame,
            .audio = Erased.audio,
            .stopped = Erased.stopped,
        };

        const stream = generated.Stream.alloc().initWithFilterConfigurationDelegate(
            filter,
            configuration,
            receiver.into(generated.StreamDelegate),
        );
        errdefer stream.release();
        const queue = dispatch.Queue.initSerial("io.github.zmscode.mac-zig.screencapturekit");
        errdefer queue.deinit();

        const output = receiver.into(generated.StreamOutput);
        const queue_object: objc.Object = .{ .value = queue.handle };
        var slot: foundation.ErrorSlot = .{};
        try slot.finish(stream.addStreamOutputTypeSampleHandlerQueueError(output, .screen, queue_object, &slot.id), details);
        if (@hasDecl(Handlers, "audio")) {
            try slot.finish(stream.addStreamOutputTypeSampleHandlerQueueError(output, .audio, queue_object, &slot.id), details);
        }
        return .{ .stream = stream, .receiver = receiver, .queue = queue };
    }

    /// Starts capturing, and waits until capture has started. Fails --
    /// with the reason in `details` -- without Screen Recording permission.
    pub fn start(self: Stream, allocator: std.mem.Allocator, io: Io, details: ?*ErrorObject) AsyncError!void {
        var done = try objc.Completion(fn (?ErrorObject) void).init(allocator, io);
        defer done.deinit();
        self.stream.startCaptureWithCompletionHandler(done.handler());
        try failed(try done.wait(), details);
    }

    /// Stops capturing, and waits until it has stopped.
    pub fn stop(self: Stream, allocator: std.mem.Allocator, io: Io, details: ?*ErrorObject) AsyncError!void {
        var done = try objc.Completion(fn (?ErrorObject) void).init(allocator, io);
        defer done.deinit();
        self.stream.stopCaptureWithCompletionHandler(done.handler());
        try failed(try done.wait(), details);
    }

    /// Captures `filter`'s content from now on, without stopping.
    pub fn updateFilter(self: Stream, allocator: std.mem.Allocator, io: Io, filter: ContentFilter, details: ?*ErrorObject) AsyncError!void {
        var done = try objc.Completion(fn (?ErrorObject) void).init(allocator, io);
        defer done.deinit();
        self.stream.updateContentFilterCompletionHandler(filter, done.handler());
        try failed(try done.wait(), details);
    }

    /// Captures as `configuration` says from now on, without stopping.
    pub fn updateConfiguration(self: Stream, allocator: std.mem.Allocator, io: Io, configuration: StreamConfiguration, details: ?*ErrorObject) AsyncError!void {
        var done = try objc.Completion(fn (?ErrorObject) void).init(allocator, io);
        defer done.deinit();
        self.stream.updateConfigurationCompletionHandler(configuration, done.handler());
        try failed(try done.wait(), details);
    }

    /// Releases the stream. `stop` it first if it was started; once this
    /// returns, no handler is running or will run.
    pub fn deinit(self: Stream) void {
        self.receiver.state().detached.store(true, .release);
        // Wait out a handler already running on the queue.
        self.queue.sync(&self, struct {
            fn drained(_: *const Stream) void {}
        }.drained);
        self.stream.release();
        self.receiver.release();
        self.queue.deinit();
    }

    fn failed(failure: ?ErrorObject, details: ?*ErrorObject) Error!void {
        const reported = failure orelse return;
        if (details) |out| out.* = .{ .object = reported.object.retain() };
        return Error.Failed;
    }
};

/// The stream's output and delegate: forwards to the Zig handlers.
const Receiver = objc.Subclass(.{
    .name = "MacZigStreamReceiver",
    // As types, so each method below is checked against the SDK's.
    .protocols = .{ generated.StreamOutput, generated.StreamDelegate },
}, struct {
    context: ?*anyopaque = null,
    frame: *const fn (?*anyopaque, Frame) void = noFrame,
    audio: *const fn (?*anyopaque, coremedia.SampleBuffer) void = noAudio,
    stopped: *const fn (?*anyopaque, ErrorObject) void = noStop,
    /// Set by `Stream.deinit`: SCStream may deliver a last sample after
    /// the Zig side has gone.
    detached: std.atomic.Value(bool) = .init(false),

    fn noFrame(_: ?*anyopaque, _: Frame) void {}
    fn noAudio(_: ?*anyopaque, _: coremedia.SampleBuffer) void {}
    fn noStop(_: ?*anyopaque, _: ErrorObject) void {}

    pub fn @"stream:didOutputSampleBuffer:ofType:"(
        self: *@This(),
        _: generated.Stream,
        sample: coremedia.SampleBuffer,
        kind: StreamOutputType,
    ) void {
        if (self.detached.load(.acquire) or !sample.isValid()) return;
        switch (kind) {
            .screen => {
                if (Frame.status(sample) != .complete or sample.imageBuffer() == null) return;
                self.frame(self.context, .{ .sample = sample });
            },
            .audio, .microphone => self.audio(self.context, sample),
            _ => {},
        }
    }

    pub fn @"stream:didStopWithError:"(self: *@This(), _: generated.Stream, failure: ErrorObject) void {
        if (self.detached.load(.acquire)) return;
        self.stopped(self.context, failure);
    }
});

test "the generated wrappers and the receiver class compile and register" {
    std.testing.refAllDecls(generated);
    const receiver = Receiver.new();
    defer receiver.release();
    try std.testing.expect(receiver.object.msgSend(bool, "respondsToSelector:", .{objc.sel("stream:didOutputSampleBuffer:ofType:")}));
    try std.testing.expect(receiver.object.msgSend(bool, "conformsToProtocol:", .{objc.getProtocol("SCStreamOutput").?}));
}

test "a frame's status comes from its attachments" {
    const pixels = try corevideo.PixelBuffer.init(.{ .width = 4, .height = 4 });
    defer pixels.deinit();
    const sample = try coremedia.SampleBuffer.initWithImageBuffer(pixels, .zero, .init(1, 60));
    defer sample.deinit();
    // No attachment: taken as complete, as a synthetic sample would be.
    try std.testing.expectEqual(FrameStatus.complete, Frame.status(sample));
    const frame: Frame = .{ .sample = sample };
    try std.testing.expectEqual(pixels.handle, frame.pixelBuffer().handle);
    try std.testing.expect(frame.scaleFactor() == null);
}

test "listing content and capturing a frame, given permission" {
    if (!hasPermission()) return error.SkipZigTest;
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();
    const gpa = std.heap.smp_allocator;
    const io = std.testing.io;

    const content = try shareableContent(gpa, io, .{}, null);
    defer content.release();
    const display = content.displays().first() orelse return error.SkipZigTest;
    try std.testing.expect(display.width() > 0);

    const filter = ContentFilter.alloc().initWithDisplayExcludingWindows(display, .init(&.{}));
    defer filter.release();
    const config = StreamConfiguration.new();
    defer config.release();
    config.setWidth(64);
    config.setHeight(64);
    config.setPixelFormat(@backingInt(corevideo.PixelFormat.bgra));

    const Recorder = struct {
        frames: std.atomic.Value(u32) = .init(0),
        width: std.atomic.Value(usize) = .init(0),
        got_one: Io.Event = .unset,

        pub fn frame(self: *@This(), f: Frame) void {
            self.width.store(f.pixelBuffer().width(), .release);
            _ = self.frames.fetchAdd(1, .acq_rel);
            self.got_one.set(std.testing.io);
        }
    };
    var recorder: Recorder = .{};
    const stream = try Stream.init(filter, config, &recorder, Recorder, null);
    defer stream.deinit();
    try stream.start(gpa, io, null);
    try recorder.got_one.waitTimeout(io, .{ .duration = .{ .raw = .fromSeconds(5), .clock = .awake } });
    try stream.stop(gpa, io, null);

    try std.testing.expect(recorder.frames.load(.acquire) >= 1);
    try std.testing.expectEqual(@as(usize, 64), recorder.width.load(.acquire));
}
