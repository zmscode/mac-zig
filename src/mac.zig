//! Zig bindings for the macOS system frameworks.
//!
//! One package, one translated C layer, one `Error` set, and a namespace
//! per framework:
//!
//! ```zig
//! const mac = @import("mac");
//!
//! const ctx = try mac.cg.Context.initBitmap(.{ .width = 400, .height = 300 });
//! defer ctx.deinit();
//! ```
//!
//! A program that only wants one framework can pull the namespace out and
//! forget the umbrella is there:
//!
//! ```zig
//! const cg = @import("mac").cg;
//! ```
//!
//! ## Why one package
//!
//! These frameworks share CoreFoundation's types. A `CFStringRef` produced
//! by CoreGraphics has to be the *same Zig type* as one consumed by IOKit,
//! or the two cannot be passed between. Separate packages, each running
//! `translate-c` over its own headers, would each emit their own
//! incompatible `CFStringRef`. So there is one translation unit here,
//! covering every framework that is switched on, and one `cf` namespace
//! that all of them share.
//!
//! ## What is here
//!
//! - `cg` -- CoreGraphics: 2D drawing, images, PDF, displays, the window
//!   list and synthetic input. Optionally ImageIO and a CoreText bridge.
//! - `iokit` -- power sources: battery charge and time remaining.
//! - `objc` -- the Objective-C runtime: messages, classes defined from
//!   Zig, blocks. The bridge to Foundation, AppKit, Metal and the rest.
//! - `foundation` -- Foundation's everyday classes as Zig types.
//! - `appkit` -- AppKit, from wrappers generated out of the SDK.
//! - `metal` -- Metal, generated, and QuartzCore's Metal layer.
//! - `iosurface` -- pixel buffers shared across processes and the GPU.
//! - `dispatch` -- Grand Central Dispatch: queues and the main thread.
//! - `cf` -- just enough CoreFoundation to work the rest.

const build_options = @import("mac_build_options");

/// The complete, mechanically translated C API of every framework that is
/// switched on, for the corners the wrappers do not cover.
pub const raw = @import("mac_raw");

/// The `Error` set, shared by every framework in the package.
pub const errors = @import("errors.zig");

/// Just enough CoreFoundation to work the frameworks above it: strings,
/// data, numbers, arrays, dictionaries and URLs.
pub const cf = @import("cf.zig");

/// CoreGraphics: contexts, paths, colours, images, gradients, PDF,
/// displays, the window list and synthetic input.
pub const cg = @import("cg/cg.zig");

/// IOKit's power sources: battery charge, mains or battery, time
/// remaining. Under `-Diokit` (on by default); without it this namespace
/// holds only `enabled = false`.
pub const iokit = if (build_options.iokit) @import("iokit/iokit.zig") else struct {
    pub const enabled = false;
};

/// The Objective-C runtime: sending messages, defining classes and
/// making blocks from Zig. Under `-Dobjc` (on by default), which also
/// links Foundation; without it this namespace holds only
/// `enabled = false`.
pub const objc = if (build_options.objc) @import("objc/objc.zig") else struct {
    pub const enabled = false;
};

/// Foundation's everyday classes -- strings, numbers, data, URLs, arrays,
/// dictionaries, errors -- as Zig types. Under `-Dobjc`.
pub const foundation = if (build_options.objc) @import("foundation/foundation.zig") else struct {
    pub const enabled = false;
};

/// AppKit, from wrappers generated out of the SDK: windows, views, the
/// application, events, menus. Under `-Dappkit` (on by default with
/// `-Dobjc`).
pub const appkit = if (build_options.appkit) @import("appkit/appkit.zig") else struct {
    pub const enabled = false;
};

/// IOSurface: pixel buffers shared between processes, and between the
/// CPU and the GPU. Under `-Diosurface` (on by default).
pub const iosurface = if (build_options.iosurface) @import("iosurface/iosurface.zig") else struct {
    pub const enabled = false;
};

/// Metal, from wrappers generated out of the SDK, and the part of
/// QuartzCore that shows it on screen. Under `-Dmetal` (on by default with
/// `-Dobjc`).
pub const metal = if (build_options.metal) @import("metal/metal.zig") else struct {
    pub const enabled = false;
};

/// Grand Central Dispatch: queues, semaphores, and the main thread.
/// Part of libSystem, so always here.
pub const dispatch = @import("dispatch/dispatch.zig");

pub const Error = errors.Error;

/// Which optional pieces this build has. Check these rather than assuming,
/// since a dependent can switch them off.
pub const features: Features = .{
    .imageio = build_options.imageio,
    .coretext = build_options.coretext,
    .iokit = build_options.iokit,
    .iosurface = build_options.iosurface,
    .objc = build_options.objc,
    .appkit = build_options.appkit,
    .metal = build_options.metal,
};

pub const Features = struct {
    /// `mac.cg.imageio`: reading and writing image files.
    imageio: bool,
    /// `mac.cg.text`: drawing a string.
    coretext: bool,
    /// `mac.iokit`: power sources.
    iokit: bool,
    /// `mac.iosurface`: shared pixel buffers.
    iosurface: bool,
    /// `mac.objc` and `mac.foundation`: the Objective-C runtime, and
    /// Foundation.
    objc: bool,
    /// `mac.appkit`: AppKit.
    appkit: bool,
    /// `mac.metal`: Metal and QuartzCore.
    metal: bool,
};

test {
    // Listed rather than `refAllDecls`, which would also walk `raw` and
    // force the Mach message headers' size assertions -- those cover
    // bitfield structs that translate-c can only render as `opaque`.
    _ = errors;
    _ = cf;
    _ = cg;
    _ = iokit;
    _ = objc;
    _ = foundation;
    _ = appkit;
    _ = dispatch;
    _ = metal;
    _ = iosurface;
}
