//! What `zig build generate` wraps from ScreenCaptureKit. The result is
//! `src/screencapturekit/generated.zig`.
//!
//! Capturing the screen, a window or an app: `SCShareableContent` lists
//! what there is, an `SCContentFilter` picks from it, an
//! `SCStreamConfiguration` says how, and an `SCStream` delivers frames --
//! `CMSampleBuffer`s holding IOSurface-backed `CVPixelBuffer`s -- to an
//! `SCStreamOutput`. `SCScreenshotManager` takes a single frame.

pub const framework = "ScreenCaptureKit";
pub const imports = [_][]const u8{"ScreenCaptureKit/ScreenCaptureKit.h"};
pub const prefixes = [_][]const u8{"SC"};
/// The frameworks whose `extern` constants and C functions are generated.
pub const frameworks = [_][]const u8{"ScreenCaptureKit"};

pub const classes = [_][]const u8{
    // What there is to capture.
    "SCShareableContent",
    "SCShareableContentInfo",
    "SCDisplay",
    "SCWindow",
    "SCRunningApplication",
    // What to capture, and how.
    "SCContentFilter",
    "SCStreamConfiguration",
    // Capturing.
    "SCStream",
    "SCScreenshotManager",
    "SCScreenshotConfiguration",
    "SCScreenshotOutput",
    "SCRecordingOutput",
    "SCRecordingOutputConfiguration",
    // The system's own picker.
    "SCContentSharingPicker",
    "SCContentSharingPickerConfiguration",
};

pub const protocols = [_][]const u8{
    "SCStreamOutput",
    "SCStreamDelegate",
    "SCRecordingOutputDelegate",
    "SCContentSharingPickerObserver",
};

pub const enums = [_][]const u8{
    "SCStreamOutputType",
    "SCFrameStatus",
    "SCPresenterOverlayAlertSetting",
    "SCStreamType",
    "SCCaptureResolutionType",
    "SCCaptureDynamicRange",
    "SCStreamConfigurationPreset",
    "SCShareableContentStyle",
    "SCContentSharingPickerMode",
    "SCScreenshotDisplayIntent",
    "SCScreenshotDynamicRange",
    "SCStreamErrorCode",
};

pub const structs = [_][]const u8{};
