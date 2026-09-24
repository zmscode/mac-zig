//! What `zig build generate` wraps from AppKit. Add a class, an enum, a
//! struct or a protocol here and regenerate; `src/appkit/generated.zig` is
//! the result.
//!
//! A class listed here gets a wrapper struct, and every other listed class
//! that mentions it gets that type instead of a bare `objc.Object`. An enum
//! listed here gets a Zig `enum` -- or, for an option set, a
//! `packed struct` of flags -- and a method using an enum that is *not*
//! listed is left out, since its size is unknown. The comment at the end
//! of each generated struct names what was left out and why.

pub const framework = "AppKit";
pub const umbrella = "AppKit/AppKit.h";
pub const prefix = "NS";

pub const classes = [_][]const u8{
    "NSResponder",
    "NSApplication",
    "NSRunningApplication",
    "NSWindow",
    "NSView",
    "NSScreen",
    "NSColor",
    "NSEvent",
    "NSMenu",
    "NSMenuItem",
    "NSImage",
    "NSCursor",
    "NSGraphicsContext",
    "NSImageRep",
    "NSBitmapImageRep",
};

pub const enums = [_][]const u8{
    "NSWindowStyleMask",
    "NSBackingStoreType",
    "NSWindowOrderingMode",
    "NSWindowCollectionBehavior",
    "NSWindowTitleVisibility",
    "NSWindowButton",
    "NSWindowTabbingMode",
    "NSWindowToolbarStyle",
    "NSWindowAnimationBehavior",
    "NSWindowOcclusionState",
    "NSWindowSharingType",
    "NSTitlebarSeparatorStyle",
    "NSApplicationActivationPolicy",
    "NSApplicationActivationOptions",
    "NSApplicationPresentationOptions",
    "NSApplicationTerminateReply",
    "NSApplicationOcclusionState",
    "NSRequestUserAttentionType",
    "NSEventType",
    "NSEventMask",
    "NSEventModifierFlags",
    "NSEventPhase",
    "NSEventSubtype",
    "NSEventButtonMask",
    "NSPointingDeviceType",
    "NSPressureBehavior",
    "NSAutoresizingMaskOptions",
    "NSFocusRingType",
    "NSUserInterfaceLayoutDirection",
    "NSViewLayerContentsRedrawPolicy",
    "NSViewLayerContentsPlacement",
    "NSImageScaling",
    "NSCompositingOperation",
    "NSMenuPresentationStyle",
    "NSMenuSelectionMode",
    "NSMenuProperties",
    "NSMenuItemImageVisibility",
    "NSRectEdge",
    "NSWindowDepth",
    "NSAlignmentOptions",
    "NSWindowUserTabbingPreference",
    "NSWindowListOptions",
    "NSWindowNumberListOptions",
    "NSSelectionDirection",
    "NSApplicationDelegateReply",
    "NSColorType",
    "NSColorSystemEffect",
    "NSControlTint",
    "NSImageResizingMode",
    "NSImageCacheMode",
    "NSTIFFCompression",
    "NSDisplayGamut",
    "NSEventGestureAxis",
    "NSEventSwipeTrackingOptions",
    "NSTouchPhase",
    "NSHorizontalDirections",
    "NSVerticalDirections",
    "NSCursorFrameResizePosition",
    "NSCursorFrameResizeDirections",
    "NSScreenTouchCapabilities",
    "NSBitmapFormat",
    "NSBitmapImageFileType",
    "NSImageRepLoadStatus",
    "NSImageLayoutDirection",
    "NSColorRenderingIntent",
};

/// C structs that methods take or return, emitted as `extern struct`s.
pub const structs = [_][]const u8{
    "NSEdgeInsets",
};

/// Delegate protocols, emitted with their method signatures so that an
/// `objc.Subclass` adopting one has its methods checked against them.
pub const protocols = [_][]const u8{
    "NSApplicationDelegate",
    "NSWindowDelegate",
    "NSMenuDelegate",
};
