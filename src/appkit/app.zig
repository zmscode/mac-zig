//! Running an AppKit application from Zig -- the part a nib and
//! `NSApplicationMain` would do, written out.
//!
//! ```zig
//! pub fn main() !void {
//!     var state: State = .{};
//!     defer state.deinit();                 // runs: `run` returns on Quit
//!
//!     appkit.app.run(.{ .name = "Demo" }, &state, struct {
//!         pub fn launched(s: *State) void {
//!             s.window = makeWindow();
//!         }
//!     });
//! }
//! ```
//!
//! `run` makes the shared `NSApplication`, gives it a menu bar with the
//! standard application and window menus, installs a delegate, and runs
//! the event loop on the calling thread -- which must be the main thread.
//!
//! ## Quitting returns
//!
//! In Objective-C, quitting calls `exit()` from inside `-[NSApp terminate:]`,
//! so nothing after the event loop runs. Here the delegate turns every
//! route to quitting -- the Quit menu item, the Dock, logging out, the last
//! window closing -- into a stop of the event loop instead, and `run`
//! returns. Your `defer`s run.
//!
//! ## Handlers
//!
//! The third argument is a struct of optional functions, each taking the
//! context pointer:
//!
//! | Function                           | When                                        |
//! | ---------------------------------- | ------------------------------------------- |
//! | `launched(context) void`           | launching finished: make the first windows  |
//! | `shouldQuit(context) bool`         | asked to quit; false refuses                |
//! | `willQuit(context) void`           | about to stop, after `shouldQuit` agreed    |
//! | `reopened(context, visible) bool`  | the Dock icon was clicked                   |

const std = @import("std");
const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const dispatch = @import("../dispatch/dispatch.zig");
const cg = @import("../cg/cg.zig");
const generated = @import("generated.zig");

const Application = generated.Application;
const Menu = generated.Menu;
const MenuItem = generated.MenuItem;
const Event = generated.Event;
const String = foundation.String;

pub const Options = struct {
    /// The name in the menu bar's application menu: "About Name", "Quit
    /// Name". A bundled app gets its name from Info.plist; a bare
    /// executable has only this.
    name: [:0]const u8,
    /// `.regular` has a Dock icon and a menu bar; `.accessory` has neither
    /// but can show windows; `.prohibited` has no UI at all.
    activation_policy: generated.ApplicationActivationPolicy = .regular,
    /// Quit when the last window closes, as a single-window app should.
    quit_after_last_window_closes: bool = true,
    /// Build the standard menu bar. Off for an app that makes its own.
    standard_menu: bool = true,
    /// Bring the app to the front once launched. An app started from a
    /// terminal otherwise opens behind it.
    activate: bool = true,
};

/// Runs the application until it quits. See the top of this file.
/// `context` is a pointer handed to every handler; `Handlers` is a struct
/// of the optional functions listed there.
pub fn run(options: Options, context: anytype, comptime Handlers: type) void {
    const C = @TypeOf(context);
    if (@typeInfo(C) != .pointer) @compileError("the context for appkit.app.run must be a pointer");
    if (!dispatch.isMainThread()) @panic("appkit.app.run must be called on the main thread");

    const Erased = struct {
        fn cast(pointer: ?*anyopaque) C {
            return @ptrCast(@alignCast(pointer));
        }
        fn launched(pointer: ?*anyopaque) void {
            if (@hasDecl(Handlers, "launched")) Handlers.launched(cast(pointer));
        }
        fn shouldQuit(pointer: ?*anyopaque) bool {
            return if (@hasDecl(Handlers, "shouldQuit")) Handlers.shouldQuit(cast(pointer)) else true;
        }
        fn willQuit(pointer: ?*anyopaque) void {
            if (@hasDecl(Handlers, "willQuit")) Handlers.willQuit(cast(pointer));
        }
        fn reopened(pointer: ?*anyopaque, visible: bool) bool {
            return if (@hasDecl(Handlers, "reopened")) Handlers.reopened(cast(pointer), visible) else true;
        }
    };

    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const app = Application.sharedApplication();
    _ = app.setActivationPolicy(options.activation_policy);
    if (options.standard_menu) app.setMainMenu(standardMenu(options.name));

    const delegate = Delegate.new();
    defer delegate.release();
    delegate.state().* = .{
        .context = @ptrCast(@constCast(context)),
        .launched = Erased.launched,
        .should_quit = Erased.shouldQuit,
        .will_quit = Erased.willQuit,
        .reopened = Erased.reopened,
        .quit_after_last_window_closes = options.quit_after_last_window_closes,
        .activate = options.activate,
    };
    // The application keeps only a weak reference to its delegate, which is
    // why `delegate` is held here until the loop ends.
    app.setDelegate(delegate.object);
    defer app.setDelegate(null);

    app.run();
}

/// Stops the event loop, so that `run` returns -- the quiet way out,
/// which asks nobody. `requestQuit` asks `shouldQuit` first.
pub fn stop() void {
    const app = Application.sharedApplication();
    app.stop(null);
    // The loop only notices once it has an event to finish, and a stop
    // from a timer or a dispatched block may have none; this is one.
    const wake = Event.otherEventWithTypeLocationModifierFlagsTimestampWindowNumberContextSubtypeData1Data2(
        .application_defined,
        .zero,
        .{},
        0,
        0,
        null,
        0,
        0,
        0,
    ).?;
    app.postEventAtStart(wake, true);
}

/// Quits the way the Quit menu item does: `shouldQuit` is asked, and if
/// it agrees, `willQuit` runs and `run` returns.
pub fn requestQuit() void {
    Application.sharedApplication().terminate(null);
}

/// Runs `f(context)` on the main thread, soon. The way back to AppKit
/// from another thread.
pub fn onMain(context: anytype, comptime f: fn (@TypeOf(context)) void) void {
    dispatch.Queue.main().async(context, f);
}

/// The Core Graphics context AppKit is drawing into right now -- in a
/// view's `drawRect:`. Borrowed: do not `deinit` it. Null outside of
/// drawing.
pub fn currentContext() ?cg.Context {
    const graphics = generated.GraphicsContext.currentContext() orelse return null;
    return cg.Context.fromRaw(@ptrCast(graphics.CGContext() orelse return null));
}

// -- the delegate -----------------------------------------------------------

const Delegate = objc.Subclass(.{
    .name = "MacZigApplicationDelegate",
    .protocols = &.{"NSApplicationDelegate"},
}, struct {
    context: ?*anyopaque = null,
    launched: *const fn (?*anyopaque) void = noLaunch,
    should_quit: *const fn (?*anyopaque) bool = alwaysQuit,
    will_quit: *const fn (?*anyopaque) void = noLaunch,
    reopened: *const fn (?*anyopaque, bool) bool = alwaysReopen,
    quit_after_last_window_closes: bool = true,
    activate: bool = true,

    fn noLaunch(_: ?*anyopaque) void {}
    fn alwaysQuit(_: ?*anyopaque) bool {
        return true;
    }
    fn alwaysReopen(_: ?*anyopaque, _: bool) bool {
        return true;
    }

    pub fn @"applicationDidFinishLaunching:"(self: *@This(), _: objc.Object) void {
        self.launched(self.context);
        if (self.activate) {
            const app = Application.sharedApplication();
            // -activate is macOS 14; before that, the older spelling.
            if (app.object.respondsTo("activate")) app.activate() else app.activateIgnoringOtherApps(true);
        }
    }

    /// Every route to quitting comes through here. Instead of letting
    /// AppKit call exit(), stop the loop so that `run` returns.
    pub fn @"applicationShouldTerminate:"(self: *@This(), _: objc.Object) generated.ApplicationTerminateReply {
        if (self.should_quit(self.context)) {
            self.will_quit(self.context);
            stop();
        }
        return .cancel;
    }

    pub fn @"applicationShouldTerminateAfterLastWindowClosed:"(self: *@This(), _: objc.Object) bool {
        return self.quit_after_last_window_closes;
    }

    pub fn @"applicationShouldHandleReopen:hasVisibleWindows:"(self: *@This(), _: objc.Object, visible: bool) bool {
        return self.reopened(self.context, visible);
    }
});

// -- the menu bar ---------------------------------------------------------

/// The menus every Mac app has: the application menu (About, Hide, Quit)
/// and a Window menu (Minimize, Zoom, Close). Without them a bare
/// executable does not even quit on Command-Q.
fn standardMenu(name: [:0]const u8) Menu {
    const bar = Menu.alloc().initWithTitle(.literal("")).autorelease();

    const app_menu = Menu.alloc().initWithTitle(.literal("")).autorelease();
    addItem(app_menu, "About ", name, "orderFrontStandardAboutPanel:", "", .{});
    app_menu.addItem(MenuItem.separatorItem());
    addItem(app_menu, "Hide ", name, "hide:", "h", .{ .command = true });
    addItem(app_menu, "Hide Others", "", "hideOtherApplications:", "h", .{ .command = true, .option = true });
    addItem(app_menu, "Show All", "", "unhideAllApplications:", "", .{});
    app_menu.addItem(MenuItem.separatorItem());
    addItem(app_menu, "Quit ", name, "terminate:", "q", .{ .command = true });
    submenu(bar, app_menu, "");

    const window_menu = Menu.alloc().initWithTitle(.literal("Window")).autorelease();
    addItem(window_menu, "Minimize", "", "performMiniaturize:", "m", .{ .command = true });
    addItem(window_menu, "Zoom", "", "performZoom:", "", .{});
    window_menu.addItem(MenuItem.separatorItem());
    addItem(window_menu, "Close", "", "performClose:", "w", .{ .command = true });
    submenu(bar, window_menu, "Window");
    Application.sharedApplication().setWindowsMenu(window_menu);

    return bar;
}

fn addItem(
    menu: Menu,
    comptime title: [:0]const u8,
    suffix: [:0]const u8,
    comptime action: [:0]const u8,
    comptime key: [:0]const u8,
    modifiers: generated.EventModifierFlags,
) void {
    const tail = (String.init(suffix) catch String.literal("")).autorelease();
    const full = String.literal(title).appending(tail);
    const item = MenuItem.alloc().initWithTitleActionKeyEquivalent(full, objc.Sel.cached(action), .literal(key));
    item.setKeyEquivalentModifierMask(modifiers);
    menu.addItem(item);
    item.release();
}

fn submenu(bar: Menu, menu: Menu, comptime title: [:0]const u8) void {
    const holder = MenuItem.alloc().initWithTitleActionKeyEquivalent(.literal(title), null, .literal(""));
    holder.setSubmenu(menu);
    bar.addItem(holder);
    holder.release();
}
