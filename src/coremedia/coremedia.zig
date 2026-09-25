//! The corner of [CoreMedia](https://developer.apple.com/documentation/coremedia)
//! that video frames arrive in -- reached as `mac.coremedia`, under
//! `-Dcorevideo`.
//!
//! A `CMSampleBuffer` is the envelope: a frame of video (a
//! `corevideo.PixelBuffer`) or a run of audio, with its timing and
//! whatever the source attached. ScreenCaptureKit, AVFoundation's capture
//! outputs and VideoToolbox's decoder all hand these out.
//!
//! ```zig
//! fn frame(sample: coremedia.SampleBuffer) void {
//!     const pixels = sample.imageBuffer() orelse return;     // borrowed
//!     const at = sample.presentationTime().seconds();
//!     ...
//! }
//! ```

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");
const corevideo = @import("../corevideo/corevideo.zig");

const Error = errors.Error;

/// True when the package was built with `-Dcorevideo` (the default).
pub const enabled = true;

/// A rational time: `value / timescale` seconds. `CMTime`.
pub const Time = extern struct {
    value: i64,
    timescale: i32,
    flags: u32,
    epoch: i64,

    pub const invalid: Time = .{ .value = 0, .timescale = 0, .flags = 0, .epoch = 0 };
    pub const zero: Time = .{ .value = 0, .timescale = 1, .flags = raw.kCMTimeFlags_Valid, .epoch = 0 };

    /// `value / timescale` seconds, exactly.
    pub fn init(value: i64, timescale: i32) Time {
        return fromRaw(raw.CMTimeMake(value, timescale));
    }

    /// `seconds`, as nearly as `timescale` allows.
    pub fn initSeconds(seconds_: f64, timescale: i32) Time {
        return fromRaw(raw.CMTimeMakeWithSeconds(seconds_, timescale));
    }

    pub fn fromRaw(value: raw.CMTime) Time {
        return .{ .value = value.value, .timescale = value.timescale, .flags = value.flags, .epoch = value.epoch };
    }

    pub fn toRaw(self: Time) raw.CMTime {
        return .{ .value = self.value, .timescale = self.timescale, .flags = self.flags, .epoch = self.epoch };
    }

    /// False for `invalid`, which is what a sample without that time
    /// answers.
    pub fn isValid(self: Time) bool {
        return self.flags & raw.kCMTimeFlags_Valid != 0;
    }

    /// In seconds; NaN when invalid.
    pub fn seconds(self: Time) f64 {
        return raw.CMTimeGetSeconds(self.toRaw());
    }
};

/// A sample buffer. One handed to a callback is borrowed -- `retain` it to
/// keep it past the callback, and `deinit` what you retained.
pub const SampleBuffer = struct {
    handle: *raw.struct_opaqueCMSampleBuffer,

    pub fn typeId() raw.CFTypeID {
        return raw.CMSampleBufferGetTypeID();
    }

    /// A sample holding one video frame, shown at `presentation` for
    /// `length`: what a capture source produces, for feeding to an
    /// encoder or a test. Yours.
    pub fn initWithImageBuffer(buffer: corevideo.PixelBuffer, presentation: Time, length: Time) Error!SampleBuffer {
        var format: raw.CMVideoFormatDescriptionRef = null;
        if (raw.CMVideoFormatDescriptionCreateForImageBuffer(null, buffer.handle, &format) != 0) return Error.Failed;
        defer raw.CFRelease(format);
        const timing: raw.CMSampleTimingInfo = .{
            .duration = length.toRaw(),
            .presentationTimeStamp = presentation.toRaw(),
            .decodeTimeStamp = Time.invalid.toRaw(),
        };
        var out: raw.CMSampleBufferRef = null;
        if (raw.CMSampleBufferCreateReadyWithImageBuffer(null, buffer.handle, format, &timing, &out) != 0) return Error.Failed;
        return .{ .handle = out orelse return Error.Failed };
    }

    pub fn fromRaw(value: raw.CMSampleBufferRef) ?SampleBuffer {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: SampleBuffer) raw.CMSampleBufferRef {
        return self.handle;
    }

    pub fn retain(self: SampleBuffer) SampleBuffer {
        return .{ .handle = @ptrCast(@constCast(raw.CFRetain(self.handle).?)) };
    }

    pub fn deinit(self: SampleBuffer) void {
        raw.CFRelease(self.handle);
    }

    pub fn asType(self: SampleBuffer) cf.Type {
        return .{ .handle = self.handle };
    }

    /// False once invalidated -- a source that has stopped may do so.
    pub fn isValid(self: SampleBuffer) bool {
        return raw.CMSampleBufferIsValid(self.handle) != 0;
    }

    pub fn isDataReady(self: SampleBuffer) bool {
        return raw.CMSampleBufferDataIsReady(self.handle) != 0;
    }

    /// The frame, for a video sample. Null for audio, and for a video
    /// sample that carries no new frame -- ScreenCaptureKit sends those
    /// when nothing on screen changed. Borrowed from the sample.
    pub fn imageBuffer(self: SampleBuffer) ?corevideo.PixelBuffer {
        return corevideo.PixelBuffer.fromRaw(raw.CMSampleBufferGetImageBuffer(self.handle));
    }

    pub fn presentationTime(self: SampleBuffer) Time {
        return .fromRaw(raw.CMSampleBufferGetPresentationTimeStamp(self.handle));
    }

    pub fn duration(self: SampleBuffer) Time {
        return .fromRaw(raw.CMSampleBufferGetDuration(self.handle));
    }

    pub fn sampleCount(self: SampleBuffer) usize {
        return @intCast(raw.CMSampleBufferGetNumSamples(self.handle));
    }

    /// The value under `key` in the first sample's attachments, or null.
    /// Borrowed. This is where ScreenCaptureKit puts a frame's status,
    /// dirty rectangles and scale -- the `SCStreamFrameInfo` keys.
    pub fn sampleAttachment(self: SampleBuffer, key: raw.CFStringRef) ?cf.Type {
        const array = raw.CMSampleBufferGetSampleAttachmentsArray(self.handle, 0) orelse return null;
        if (raw.CFArrayGetCount(array) == 0) return null;
        const first: raw.CFDictionaryRef = @ptrCast(raw.CFArrayGetValueAtIndex(array, 0));
        return cf.Type.fromRaw(raw.CFDictionaryGetValue(first, key));
    }
};

test "a sample buffer around a pixel buffer" {
    const pixels = try corevideo.PixelBuffer.init(.{ .width = 8, .height = 4 });
    defer pixels.deinit();

    const sample = try SampleBuffer.initWithImageBuffer(pixels, .init(3, 60), .init(1, 60));
    defer sample.deinit();

    try std.testing.expect(sample.isValid());
    try std.testing.expect(sample.isDataReady());
    try std.testing.expectEqual(@as(usize, 1), sample.sampleCount());
    try std.testing.expectEqual(pixels.handle, sample.imageBuffer().?.handle);
    try std.testing.expectApproxEqAbs(@as(f64, 0.05), sample.presentationTime().seconds(), 1e-9);
    try std.testing.expectEqual(@as(i32, 60), sample.duration().timescale);
    try std.testing.expect(!Time.invalid.isValid());
    try std.testing.expect(Time.zero.isValid());

    const kept = sample.retain();
    kept.deinit();
    try std.testing.expect(sample.sampleAttachment(raw.kCMSampleAttachmentKey_DisplayImmediately) == null);
}
