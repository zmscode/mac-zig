//! [AppKit](https://developer.apple.com/documentation/appkit), from
//! wrappers generated out of the SDK's headers -- reached as `mac.appkit`,
//! under `-Dappkit`.
//!
//! Each class is a struct over one `objc.Object`, with a method per
//! Objective-C method and the types mapped for you:
//!
//! ```zig
//! const appkit = mac.appkit;
//!
//! const app = appkit.Application.sharedApplication();
//! _ = app.setActivationPolicy(.regular);
//!
//! const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(
//!     .init(0, 0, 480, 320),
//!     .{ .titled = true, .closable = true, .resizable = true },
//!     .buffered,
//!     false,
//! );
//! window.setTitle(.literal("mac-zig"));
//! window.makeKeyAndOrderFront(null);
//! ```
//!
//! ## How the names come out
//!
//! - A class loses its `NS`: `NSWindow` is `Window`.
//! - A method is its selector with the colons taken out and each piece
//!   after the first capitalised: `initWithContentRect:styleMask:backing:defer:`
//!   is `initWithContentRectStyleMaskBackingDefer`. Long, but never
//!   ambiguous, and searchable from Apple's documentation.
//! - An enum loses its `NS` and its constants lose the enum's name and go
//!   to snake case: `NSBackingStoreBuffered` is `BackingStoreType.buffered`.
//!   An option set is a `packed struct` of flags:
//!   `.{ .titled = true, .closable = true }`.
//! - A parameter that would shadow a method keeps its name with a trailing
//!   underscore: `setTitle(title_: foundation.String)`.
//!
//! ## How the types come out
//!
//! `NSString *` is `foundation.String`, `NSArray<NSWindow *> *` is
//! `foundation.Array(Window)`, `NSRect` is `cg.Rect`, `BOOL` is `bool`, a
//! `_Nullable` object is an optional. A class not generated here is
//! `objc.Object`, and a block parameter is `anytype` -- pass a pointer to
//! an `objc.Block`.
//!
//! Inherited methods live on the superclass's wrapper: `into` converts,
//! and refuses at compile time to convert to something that is not an
//! ancestor. `window.into(appkit.Responder)`.
//!
//! ## Threads
//!
//! AppKit is main-thread only. Nothing here checks.
//!
//! ## Regenerating
//!
//! `zig build generate` rewrites `generated.zig` from
//! `tools/objc_gen/appkit.zig`, the list of classes and enums to wrap.

const generated = @import("generated.zig");

/// Running an application: the event loop, the menu bar, a delegate
/// written in Zig, and getting back to the main thread.
pub const app = @import("app.zig");

/// A view that shows Metal, redrawn at the display's refresh rate by a Zig
/// `draw` function. Needs `-Dmetal`.
pub const MetalView = if (@import("mac_build_options").metal) @import("metal_view.zig").MetalView else struct {
    pub const enabled = false;
};

/// True when the package was built with `-Dappkit` (the default).
pub const enabled = true;

pub const Responder = generated.Responder;
pub const Application = generated.Application;
pub const RunningApplication = generated.RunningApplication;
pub const Window = generated.Window;
pub const View = generated.View;
pub const Screen = generated.Screen;
pub const Color = generated.Color;
pub const Event = generated.Event;
pub const Menu = generated.Menu;
pub const MenuItem = generated.MenuItem;
pub const Image = generated.Image;
pub const Cursor = generated.Cursor;
pub const GraphicsContext = generated.GraphicsContext;
pub const ImageRep = generated.ImageRep;
pub const BitmapImageRep = generated.BitmapImageRep;

pub const EdgeInsets = generated.EdgeInsets;

// Delegate protocols, for an `objc.Subclass`'s `.protocols`: adopted, and
// each method checked against the SDK's signature.
pub const ApplicationDelegate = generated.ApplicationDelegate;
pub const WindowDelegate = generated.WindowDelegate;
pub const MenuDelegate = generated.MenuDelegate;

/// Every generated enum and option set, by its name without `NS`.
pub const enums = generated;

pub const WindowStyleMask = generated.WindowStyleMask;
pub const BackingStoreType = generated.BackingStoreType;
pub const ApplicationActivationPolicy = generated.ApplicationActivationPolicy;
pub const EventType = generated.EventType;
pub const EventMask = generated.EventMask;
pub const EventModifierFlags = generated.EventModifierFlags;

test {
    _ = @import("tests.zig");
    _ = app;
}
