# mac-zig

Zig 0.17 bindings for the macOS system frameworks. One package, one translated C layer, one
`Error` set, and a namespace per framework.

Today that is:

| Namespace        | Framework         | Covers                                                                                                                            |
| ---------------- | ----------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `mac.cg`         | CoreGraphics      | contexts, paths, colours and colour spaces, images, gradients, layers, PDF in and out, displays, the window list, synthetic input |
| `mac.cg.imageio` | ImageIO           | reading and writing image files, under `-Dimageio`                                                                                |
| `mac.cg.text`    | CoreText          | drawing and measuring a line of text, under `-Dcoretext`                                                                          |
| `mac.iokit`      | IOKit             | power sources: battery charge, mains or battery, time remaining, under `-Diokit`                                                  |
| `mac.objc`       | libobjc           | the Objective-C runtime: messages, classes defined in Zig, blocks — the bridge to Foundation, AppKit, Metal, under `-Dobjc`       |
| `mac.foundation` | Foundation        | strings, numbers, data, URLs, typed arrays and dictionaries, errors — as Zig types, under `-Dobjc`                                |
| `mac.appkit`     | AppKit            | windows, views, the application, events, menus, screens — generated from the SDK, under `-Dappkit`                                |
| `mac.metal`      | Metal, QuartzCore | devices, queues, buffers, textures, shaders, pipelines, `CAMetalLayer` — generated from the SDK, under `-Dmetal`                  |
| `mac.iosurface`  | IOSurface         | pixel buffers shared between processes, the CPU, the GPU and Core Animation, under `-Diosurface`                                  |
| `mac.dispatch`   | libdispatch       | Grand Central Dispatch: the main queue, global and private queues, semaphores                                                     |
| `mac.cf`         | CoreFoundation    | just enough to work the frameworks above it                                                                                       |

Everything links what macOS already ships, so there is nothing to fetch and nothing to build.

AI coding agents can use the repository's installable [`mac-zig` skill](SKILL.md) for concise,
version-specific integration guidance.

macOS only, and the Xcode command line tools must be installed — the headers live in the SDK.

## Why one package

These frameworks share CoreFoundation's types. A `CFStringRef` that CoreGraphics produces has
to be the _same Zig type_ as one IOKit consumes, or the two cannot be passed between. Separate
packages, each running `translate-c` over its own headers, would each emit their own
incompatible `CFStringRef`.

So there is one translation unit covering every framework that is switched on, one `mac.cf`
namespace they all share, and one `mac.Error`. Adding a framework is a build option and a
namespace, not another dependency.

## What is not here

AppKit and Metal are wrapped for what their manifests in `tools/objc_gen/` list, not all of
them; adding a class or protocol is a line there and `zig build generate`. Other Objective-C
frameworks — AVFoundation, CoreImage, ScreenCaptureKit — have no manifest yet, and are reached
through `mac.objc` by sending messages by name. A new framework is a new manifest.

## Use as a dependency

```sh
zig fetch --save=mac git+https://github.com/zmscode/mac-zig.git
```

For local development the equivalent path dependency is:

```zig
.dependencies = .{
    .mac = .{ .path = "../mac-zig" },
},
```

Then expose the module to your executable in `build.zig`:

```zig
const mac_dependency = b.dependency("mac", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("mac", mac_dependency.module("mac"));
```

Nothing else is needed — the frameworks are linked for you.

## A drawing

```zig
const mac = @import("mac");

const ctx = try mac.cg.Context.initBitmap(.{ .width = 400, .height = 300 });
defer ctx.deinit();

ctx.setFillColor(.hex(0x1E2430));
ctx.fillRect(ctx.bitmapBounds());

ctx.setFillColor(.hex(0x2ECC71));
ctx.fillEllipseInRect(.init(150, 100, 100, 100));

try mac.cg.imageio.writeContext(ctx, "out.png", .png, .{});
```

A program that wants one framework can pull the namespace out and forget the umbrella is
there, which is how the rest of this file is written:

```zig
const cg = @import("mac").cg;
```

`Context`, `Image`, `Path` and the rest are one-pointer handles passed by value. Most of
them need no allocator, because CoreFoundation owns its own memory — the allocator-taking
calls in this package are the ones that copy data _out_ of CoreFoundation and into memory
you own, and they say so.

## What the wrapper changes

| CoreGraphics                                       | mac-zig                                          |
| -------------------------------------------------- | ------------------------------------------------ |
| `CGBitmapContextCreate` / `CGContextRelease`       | `Context.initBitmap` / `deinit`, with `defer`    |
| `NULL` returns with no error code                  | an `Error` set; `?T` where null is a real answer |
| `CGError` codes from the display calls             | the same `Error` set, with the codes named       |
| `CGBitmapInfo` as or-ed constants from three enums | a `packed struct` with four named fields         |
| `kCGBlendMode*`, `kCGLineCap*`, `kCGPathFill`      | `BlendMode`, `LineCap`, `DrawingMode` enums      |
| `CGPathApply` with an untyped points array         | `path.Element`, a `union(enum)`                  |
| `CGPathRef` and `CGMutablePathRef` by `const`      | `Path` and `MutablePath`, two types              |
| `ptr, count` argument pairs                        | slices                                           |
| `CFStringRef` everywhere                           | `[]const u8` in, `toOwnedSlice(allocator)` out   |
| `CFDictionary` of `CFNumber` for the window list   | `window.Window`, a plain struct                  |
| `CGRectDivide` with two out-parameters             | `Rect.divide` returning a `Division`             |

Anything not yet wrapped is reachable through `mac.raw`, the complete translated API.

## Two things to get right

**The y axis points up.** A context's origin is at the bottom left. Shapes, images and text
drawn into a fresh context all come out correct, including once written to a PNG — the
coordinates simply count from the bottom. `Context.flipVertically` switches to top-left,
y-down coordinates when that suits the numbers better, and the cost is that it flips
everything: use `drawImageUpright` for images and `setTextMatrix(.scaling(1, -1))` for text.

**Create means you own it.** A CoreFoundation call with `Create` or `Copy` in its name hands
over a reference that is yours to release; one with `Get` lends you a reference that you must
not. The wrapper keeps that visible: anything with a `deinit` is yours, and anything returned
without one is borrowed from something that is.

## The bitmap info word

`CGBitmapInfo` is one `uint32_t` holding four unrelated fields, built by or-ing constants
from three different enums:

```c
kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little
```

Get it wrong and `CGBitmapContextCreate` returns `NULL` with no explanation, or succeeds and
gives you an image with red and blue swapped. Here the fields are named and the working
combinations have names:

```zig
const info: cg.BitmapInfo = .bgra8888;   // the layout a Mac composites fastest
const other: cg.BitmapInfo = .rgba8888;  // R, G, B, A in memory order

// And a layout a bitmap context cannot accept is an error here rather
// than a silent null from CoreGraphics:
_ = cg.Context.initBitmap(.{
    .width = 4,
    .height = 4,
    .bitmap_info = .{ .alpha = .last },  // error.IllegalArgument
});
```

## Paths

`Path` is immutable and `MutablePath` is being built, so the two cannot be confused:

```zig
const star = try cg.MutablePath.init();
defer star.deinit();

star.moveTo(.init(0, 0));
star.lineTo(.init(10, 0));
star.curveTo(.init(10, 5), .init(5, 10), .init(0, 10));
star.closeSubpath();

ctx.addPath(star.asPath());
ctx.fillPath();
```

Walking one is a tagged union rather than an array whose length you infer from a tag:

```zig
const elements = try star.asPath().toOwnedElements(allocator);
defer allocator.free(elements);

for (elements) |element| switch (element) {
    .move_to => |p| moveTo(p),
    .line_to => |p| lineTo(p),
    .quad_curve_to => |c| quadTo(c.control, c.end),
    .curve_to => |c| cubicTo(c.control1, c.control2, c.end),
    .close_subpath => close(),
};
```

Boolean operations, stroking to an outline, dashing and flattening all produce new paths:

```zig
const carved = try square.subtracting(circle, false);
defer carved.deinit();

const outline = try line.stroked(.{ .line_width = 4, .cap = .round });
defer outline.deinit();
```

## Graphics state

`save` and `restore` pair exactly with `defer`, which is what makes clipping and transforms
safe to nest:

```zig
ctx.save();
defer ctx.restore();

ctx.addEllipseInRect(.init(0, 0, 120, 120));
ctx.clip();                      // clipping only ever shrinks
ctx.drawLinearGradient(ramp, .init(0, 120), .init(120, 0), .both);
```

The current path is the one thing _not_ in the graphics state, which is why every call that
draws it also clears it. Build a `Path` once and `addPath` it to draw the same shape twice.

## PDF

Out:

```zig
const ctx = try cg.Context.initPdfFile(allocator, "out.pdf", .{
    .media_box = .init(0, 0, 612, 792),
    .title = "report",
});
defer ctx.deinit();
defer ctx.closePdf();            // without this the file has no trailer

ctx.beginPdfPage();
ctx.setFillColor(.white);
ctx.fillRect(.init(0, 0, 612, 792));
ctx.endPdfPage();
```

And back in, which is how a page gets rasterised:

```zig
const document = try cg.pdf.Document.initFile("out.pdf");
defer document.deinit();

const page = document.page(1).?;     // pages count from 1
const box = page.box(.media);

ctx.concat(page.drawingTransform(.media, box, 0, true));
ctx.drawPdfPage(page);
```

## Power

```zig
const state = try mac.iokit.power.snapshot(allocator);
defer state.deinit(allocator);

if (state.battery()) |b| {
    std.debug.print("{d}%{s}\n", .{ b.percent, if (b.is_charging) " charging" else "" });
}
if (mac.iokit.power.timeRemaining()) |minutes| { ... }
```

In C this is an opaque blob, then a `CFArray` of opaque handles, then a `CFDictionary` per
handle whose keys are plain C strings and whose values are boxed `CFNumber`s. Here it is one
call returning plain structs. A desktop with no battery gives an empty source list rather than
an error, and nothing here needs a permission.

## Displays and windows

Finding the display something is on, which is what "go fullscreen where the cursor is" needs:

```zig
const now = try cg.event.Event.initCurrentState(null);
defer now.deinit();
const under_cursor = cg.Display.containing(now.location()) orelse .main();

// Or, for a window: the display it mostly sits on. SDL reports window
// positions in this same global space on macOS, so its rectangle goes
// straight in.
const window_screen = cg.Display.bestFor(window_rect) orelse .main();
```

```zig
var buffer: [64]cg.Display = undefined;
for (try cg.Display.active(&buffer)) |screen| {
    const mode = try screen.currentMode();
    defer mode.deinit();
    std.debug.print("{f} at {d}Hz\n", .{ mode.size(), mode.refreshRate() });
}
```

The window list arrives as plain structs rather than a `CFArray` of `CFDictionary`:

```zig
const windows = try cg.window.list(allocator, .visible, 0);
defer windows.deinit(allocator);

for (windows.windows) |w| {
    std.debug.print("{s} {f}\n", .{ w.owner_name orelse "?", w.bounds });
}
```

Window _titles_ need Screen Recording permission; everything else does not, and a `null`
title means the permission is missing rather than that the window is untitled.
`cg.window.hasScreenCaptureAccess()` answers that directly, and `requestScreenCaptureAccess()`
prompts — once only, since a process that has been refused is never re-prompted.

## Text

Under `-Dcoretext` (on by default). CoreGraphics cannot lay text out — the calls that took a
string were deprecated in macOS 10.9 — so this is a thin CoreText bridge covering one line in
one font, which is enough to label, caption and measure:

```zig
const font = try cg.text.Font.initSystem(24);
defer font.deinit();

const metrics = try cg.text.measure("mac-zig", font);   // for alignment
ctx.setFillColor(.white);
try cg.text.draw(ctx, "mac-zig", font, .init(40, 40), null);
```

## Objective-C

Under `-Dobjc` (on by default), which links libobjc and Foundation. This is the runtime, not a
binding of any one framework: it is how any Objective-C API is reached from Zig.

```zig
const objc = mac.objc;

const pool = objc.AutoreleasePool.init();
defer pool.deinit();

const NSString = objc.getClass("NSString").?;
const hello = NSString.msgSend(objc.Object, "stringWithUTF8String:", .{"hello".ptr});
const length = hello.msgSend(objc.UInteger, "length", .{});

// Structs go through as themselves -- NSRect is cg.Rect.
const boxed = objc.getClass("NSValue").?.msgSend(objc.Object, "valueWithRect:", .{rect});
const back = boxed.msgSend(cg.Rect, "rectValue", .{});
```

`msgSend(Return, selector, args)` builds the exact C function type of the call at compile time
and casts `objc_msgSend` to it, which is the only correct way to call it — on arm64 a varargs
call puts floats in the wrong registers. Along the way:

- a string selector is checked against the argument tuple: `"setFrame:display:"` with one
  argument does not compile;
- `bool`, `Object`, `Class` and `Sel` become `BOOL`, `id`, `Class` and `SEL` and back;
- an integer or float literal is a compile error naming the fix, since the method's parameter
  types are not known here — write `@as(objc.Integer, 3)`;
- `Object` is never nil; ask for `?Object` where nil is an answer.

A struct whose only field is an `objc.Object` is treated as one, which is how a class gets a Zig
type of its own:

```zig
const Window = struct {
    object: objc.Object,

    fn setTitle(self: Window, title: objc.Object) void {
        self.object.msgSend(void, "setTitle:", .{title});
    }
};

const window = app.msgSend(Window, "mainWindow", .{});
```

### Blocks

`objc.Block(Captures, fn (...) R)` lays a block out by hand, following the Block ABI, around
an ordinary Zig function. Its signature is a Zig function type:

```zig
const Visit = objc.Block(struct { total: *i64 }, fn (objc.Object, objc.UInteger, *bool) void);

var total: i64 = 0;
var block = Visit.init(.{ .total = &total }, struct {
    fn body(captures: *const Visit.Captures, item: objc.Object, _: objc.UInteger, _: *bool) void {
        captures.total.* += item.msgSend(i64, "longLongValue", .{});
    }
}.body);
array.msgSend(void, "enumerateObjectsUsingBlock:", .{&block});
```

A generated method that takes a block takes an `objc.BlockRef` of the SDK's signature, and
`block.ref()` passes one — so a block of any other signature does not compile:

```zig
const Done = objc.Block(struct { done: *dispatch.Semaphore }, fn (metal.CommandBuffer) void);
var handler = Done.init(.{ .done = &semaphore }, onCompleted);
commands.addCompletedHandler(handler.ref());   // takes ?objc.BlockRef(fn (CommandBuffer) void)
```

`init` makes a stack block that lives as long as the variable. An API that keeps the block —
a completion handler, an observer — copies it to the heap itself, and the copy retains any
`Object` among the captures, as a C compiler's would. `objc.BlockRef(fn (...) R)` is also the
other direction: a block handed *to* a method you implemented, which you call with `.call(.{...})`.

### Classes

A class is a Zig struct: its fields are every instance's state, and its `pub fn`s are methods.

```zig
const Counter = objc.Subclass(.{ .name = "MyCounter", .protocols = &.{"NSCopying"} }, struct {
    total: objc.Integer = 0,
    history: std.ArrayList(objc.Integer) = .empty,

    pub fn increment(self: *@This()) void {
        self.total += 1;
    }

    pub fn @"add:"(self: *@This(), amount: objc.Integer) objc.Integer {
        self.total += amount;
        return self.total;
    }

    pub fn deinit(self: *@This()) void {          // runs from -dealloc
        self.history.deinit(gpa);
    }
});

const counter = Counter.new();
defer counter.release();
_ = counter.msgSend(objc.Integer, "add:", .{@as(objc.Integer, 2)});
counter.state().total;   // 2
```

- The class is registered on first use, once, however many threads race to be first.
- Fields get their **default values** when an instance is allocated — every field needs one —
  and `deinit`, if there is one, runs when it is freed.
- A method's first parameter says what it is: `*State` or the `Counter` type for an instance
  method, `objc.Class` for a class method. There is no `_cmd`. A `pub fn` with no receiver is
  a helper, and is left alone.
- **Overrides are checked against the SDK** when the superclass or a protocol is given as a
  generated type rather than a name — see below.
- Zig does not let a field and a function share a name, so a getter is named apart from its
  field: a `count` method over a `total` field.

Given `.superclass = appkit.View` or `.protocols = .{appkit.WindowDelegate}`, every method the
struct defines whose selector the SDK declares — anywhere up the superclass chain, or in the
protocol — is compared with the SDK's signature when the program compiles:

```zig
const Canvas = objc.Subclass(.{ .name = "Canvas", .superclass = appkit.View }, struct {
    pub fn @"drawRect:"(self: *@This(), dirty: cg.Point) void { ... }
});
// error: Canvas.drawRect: overrides NSView's drawRect:, whose argument 1 is cg.geometry.Rect;
//        this takes cg.geometry.Point
```

The comparison is of what each type is at the C boundary, not of its name: an object may be
declared as any object wrapper, an enum as its integer, but an `f32` for a `CGFloat`, a `Point`
for a `Rect` or a `bool` for an `NSInteger` is an error — each of those would read garbage. Given
by name (`.superclass = "NSDocument"`), nothing is checked.

Underneath is the runtime's own API — `allocateClassPair`, `addMethod`, `addIvar`,
`registerClassPair` — for when the struct form does not fit. `msgSendSuper` is `[super ...]`.

### Exceptions

An Objective-C exception that nothing catches ends the process. `tryMsgSend` catches it:

```zig
var caught: objc.Exception = undefined;
const item = array.tryMsgSend(objc.Object, "objectAtIndex:", .{index}, &caught) catch {
    defer caught.deinit();
    std.log.err("{f}", .{caught});   // NSRangeException: *** index 99 beyond bounds [0 .. 3]
    return;
};
```

`objc.tryCall(f, args, &caught)` does the same around a whole Zig function. The `@try` lives in
`vendor/mac_objc_exception.m`, the package's one Objective-C file, and costs nothing unless
something is thrown. The exception unwinds through Zig frames to get there, and **their
`defer`s do not run** — keep a function run under `tryCall` free of cleanup that must happen.

### Ownership

The same rule as CoreFoundation's, in the method name: **alloc**, **new**, **copy** and
**mutableCopy** hand you an object to `release`; everything else is autoreleased and lives until
the innermost `AutoreleasePool` drains. A `cf` value *is* its Objective-C counterpart —
`Object.fromCf(string)` is an `NSString`, and `asCf(cf.String)` goes back — sharing one
reference rather than copying.

## Foundation

`mac.foundation` is Foundation's everyday classes, wrapped by hand to be Zig-shaped:

```zig
const foundation = mac.foundation;

const words = foundation.Array(foundation.String).init(&.{ .literal("b"), .literal("a") });
defer words.deinit();

var it = words.iterator();
while (it.next()) |word| std.debug.print("{f}\n", .{word});

var details: foundation.ErrorObject = undefined;
const text = foundation.String.initContentsOfFile(path, &details) catch {
    defer details.deinit();
    std.log.err("{f}", .{details});   // NSCocoaErrorDomain 260: The file ... couldn't be opened
    return;
};
defer text.deinit();
```

- `String`, `Number`, `Data`, `Url`, and `ErrorObject` for `NSError`.
- `Array(T)`, `MutableArray(T)`, `Dictionary(K, V)`, `MutableDictionary(K, V)`, typed by what
  they hold and bounds-checked: past the end is `null` or an assertion, not an exception.
- Slices in and out; `toOwnedSlice(allocator)` to copy; `{f}` to print.
- An `error:` out-parameter becomes `error.Failed`, with the `NSError` handed over through an
  optional `details` pointer.
- **Anything from an `init...` is yours to `deinit`**; everything else is autoreleased.
  `String.literal("...")` is made once and never freed, like `@"..."`.

## AppKit

`mac.appkit` is generated from the SDK's headers:

```zig
const appkit = mac.appkit;

const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(
    .init(0, 0, 480, 320),
    .{ .titled = true, .closable = true, .resizable = true },
    .buffered,
    false,
);
window.setTitle(.literal("mac-zig"));
window.makeKeyAndOrderFront(null);

var screens = appkit.Screen.screens().iterator();   // foundation.Array(appkit.Screen)
```

A class loses its `NS`; a method is its selector with the colons removed and each later piece
capitalised; an enum's constants go to snake case; an option set is a `packed struct` of flags.
The types map through: `NSString *` is `foundation.String`, `NSArray<NSScreen *> *` is
`foundation.Array(Screen)`, `NSRect` is `cg.Rect`, `CGImageRef` is `cg.Image`, `NSEdgeInsets` is a
generated `EdgeInsets`, and a `_Nullable` object is an optional. Inherited methods are on every
subclass too — `window.nextResponder()` — and `window.into(appkit.Responder)` converts where a
superclass's type is wanted, refusing at compile time to convert to anything but an ancestor.

Each class also carries `signatures`, the SDK's signature for each of its methods, and the
delegate protocols the manifest lists (`ApplicationDelegate`, `WindowDelegate`, `MenuDelegate`)
are generated as types holding theirs. Those are what `objc.Subclass` checks overrides against.

### An application

`appkit.app.run` is what a nib and `NSApplicationMain` would do: the shared application, a
standard menu bar (About, Hide, Quit ⌘Q; Minimize ⌘M, Close ⌘W), a delegate written in Zig, and the
event loop. Handlers are plain Zig functions on a context pointer:

```zig
const App = struct {
    window: ?appkit.Window = null,

    pub fn launched(self: *App) void {
        const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(
            .init(0, 0, 560, 360), .{ .titled = true, .closable = true }, .buffered, false);
        const canvas = Canvas.alloc().msgSend(Canvas, "initWithFrame:", .{cg.Rect.init(0, 0, 560, 360)});
        window.setContentView(appkit.View.from(canvas.object));
        window.makeKeyAndOrderFront(null);
        self.window = window;
    }

    pub fn shouldQuit(_: *App) bool { return true; }   // optional, like willQuit and reopened
};

pub fn main() void {
    var app: App = .{};
    defer app.deinit();                               // runs: see below
    appkit.app.run(.{ .name = "Demo" }, &app, App);
}
```

**Quitting returns.** In Objective-C, `-[NSApp terminate:]` ends in `exit()`, so nothing after the
event loop runs. Here the delegate turns every way of quitting — the menu, the Dock, logging
out, the last window closing — into a stop of the loop, and `run` returns with your `defer`s
still to come. `appkit.app.stop()` stops without asking; `requestQuit()` asks `shouldQuit` first.

A view is an `objc.Subclass` of `NSView`, and draws with `cg`:

```zig
const Canvas = objc.Subclass(.{ .name = "DemoCanvas", .superclass = "NSView" }, struct {
    clicks: usize = 0,

    pub fn @"drawRect:"(self: *@This(), _: cg.Rect) void {
        const ctx = appkit.app.currentContext() orelse return;   // borrowed
        ctx.setFillColor(.hex(0x2ECC71));
        ctx.fillEllipseInRect(.init(20, 20, 80, 80));
    }

    pub fn @"mouseDown:"(self: *@This(), event: appkit.Event) void { ... }
    pub fn acceptsFirstResponder(_: *@This()) bool { return true; }
});
```

### Threads and dispatch

AppKit belongs to the main thread. `mac.dispatch` is Grand Central Dispatch, and the way back
to it:

```zig
dispatch.Queue.global(.utility).async(state, struct {
    fn work(s: *State) void {
        s.result = compute();
        appkit.app.onMain(s, show);        // = dispatch.Queue.main().async
    }
}.work);
```

`Queue.main()`, `Queue.global(qos)`, `Queue.initSerial(label)` and `initConcurrent`, each with
`async`, `sync` and `after(seconds, ...)`; `asyncOwned` copies its context to the heap for work
that outlives the caller; `Semaphore` waits for it. The context is always a pointer — the work
runs later, and a value on the caller's stack would be gone.

### The generator

`zig build generate` runs `tools/objc_gen` once per manifest — `tools/objc_gen/appkit.zig` and
`tools/objc_gen/metal.zig` — and writes `src/<framework>/generated.zig`, which is checked in, so
building the package never needs it. It has clang dump every declaration whose name carries
one of the manifest's prefixes (`NS`; `MTL` and `CA`) as JSON, one parse per prefix, then skims
the dump — a couple of hundred megabytes for AppKit and Foundation — and parses only the
declarations the manifest lists. Both frameworks take about ten seconds.

Because the dump is by prefix and not by name, a class's categories are found whatever they are
called — `-[NSView displayLinkWithTarget:selector:]` is declared in `NSView (NSDisplayLink)`.

A protocol is generated like a class: `id<MTLDevice>` is a `Device`, with `MTLDevice`'s methods
and those of any protocol it extends. Much of Metal is nothing but protocols.

Hand-written or generated was the decision to make before AppKit, and the answer is both.
Foundation is hand-written: it is small, used everywhere, and worth shaping — slices,
iterators, `details` out-parameters. AppKit is generated: it is thousands of methods, and a
wrapper that is a straight transcription is what is wanted. Hand-made conveniences go beside
`generated.zig`, never in it.

Constants and C functions come through too, from the frameworks each manifest names, in lower
camel case under `all`: `foundation.all.runLoopCommonModes()`, `foundation.all.homeDirectory()`,
`appkit.all.windowWillCloseNotification()`, `metal.all.currentMediaTime()`,
`metal.all.createSystemDefaultDevice()` — about 900, 1,500 and 170 of them. A constant is a
function returning it. Each is linked *weakly*: built against a newer SDK than the macOS it runs
on, a program still starts, and only calling something that macOS lacks panics, by name.
`static inline` functions (`NSMakeRect`) have no symbol and are left out; so is anything marked
unavailable on macOS.

C types map through as far as they go: a C array of objects, `id<MTLTexture> const *`, is a
`[*]const Texture`, or `[*]const objc.Nullable(Texture)` where an element may be nil — a `?T` is
not pointer-sized, `Nullable` is; a `const T *` input is a `[*]const T`; a C function pointer is
a Zig one over the same mapped types; a block is `objc.BlockRef(fn (...) R)`. Anything the
generator still cannot type safely is left out
and listed in a comment at the end of the struct — at present nothing is, across about 2,000
AppKit and 1,500 Metal methods. A test takes the address of every generated method, so each
one is compiled, and each selector checked against its arguments, on every `zig build test`.

Nullability comes from clang, with one repair. Inside Apple's `NS_ASSUME_NONNULL` regions an
unannotated pointer is non-null, and clang says so — except for a property carrying an
availability macro, whose type spelling loses it. The property declaration still records
whether nullability was written out, so the generator reads it from there.

## Metal

`mac.metal` is Metal, generated from the SDK like AppKit, plus QuartzCore's `CAMetalLayer`:

```zig
const metal = mac.metal;

const device = metal.createSystemDefaultDevice() orelse return error.NoGpu;
defer device.release();

const library = try metal.newLibrary(device, shader_source, &details);   // compiled at run time
const pipeline_descriptor = metal.RenderPipelineDescriptor.new();
pipeline_descriptor.setVertexFunction(metal.function(library, "vertex_main").?);
pipeline_descriptor.colorAttachments().objectAtIndexedSubscript(0).setPixelFormat(.bgra8_unorm);
const pipeline = try metal.newRenderPipelineState(device, pipeline_descriptor, null);
```

Names lose `MTL` or `CA` — `CAMetalLayer` is `MetalLayer` — and `new...` methods hand back what
you own, as the naming rule says. The calls that take `error:` have wrappers returning
`error.Failed`, with the compiler's messages in `details`.

`appkit.MetalView` puts it on screen: a view backed by a `CAMetalLayer`, redrawn by a display
link at the screen's refresh rate, calling your `draw` with the frame's drawable, texture, size
in pixels and timing:

```zig
const Renderer = struct {
    pub fn draw(self: *Renderer, frame: appkit.MetalView.Frame) void {
        const commands = frame.queue.commandBuffer().?;
        const encoder = commands.renderCommandEncoderWithDescriptor(frame.renderPass(background)).?;
        // ... set the pipeline, draw ...
        encoder.endEncoding();
        frame.present(commands);
    }
    pub fn resized(self: *Renderer, pixels: cg.Size) void { ... }   // optional
};

const view = try appkit.MetalView.init(.{ .frame = rect }, &renderer, Renderer);
defer view.deinit();
window.setContentView(view.asView());
```

The loop starts when the view goes into a window and stops when it leaves one, skips frames
while the window is hidden, and gives each frame its own autorelease pool. Before macOS 14,
which has no display link for a view, a 60 Hz timer stands in.

```sh
zig build run-metal                              # a spinning triangle
zig build run-metal -- --snapshot metal.png      # one frame, offscreen, to a PNG
```

## IOSurface

`mac.iosurface` is memory the kernel shares on everyone's behalf: the CPU through a lock, the
GPU through a Metal texture over it, Core Animation as a layer's contents, and another process by
ID or Mach port. Nothing is copied between them — which is how a renderer hands frames to a
window, and how Ghostty's Metal renderer shows its output.

```zig
const surface = try iosurface.Surface.init(.{ .width = 640, .height = 480 });   // BGRA by default
defer surface.deinit();

{
    const locked = try surface.lock(.{});      // the only way to the bytes
    defer locked.unlock();
    const ctx = try locked.initContext();      // cg, drawing straight into the surface
    defer ctx.deinit();
    ctx.fillRect(.init(0, 0, 320, 480));
    _ = locked.row(0);                         // or the pixels themselves, row by row
}

const texture = device.newTextureWithDescriptorIosurfacePlane(descriptor, surface, 0).?;   // Metal
layer.setContents(objc.Object.fromCf(surface));                                           // a layer
```

A test runs the whole round trip on one surface: `cg` draws, a Metal texture over it reads the
drawing, the GPU renders into it, the CPU reads that back through a lock, and a `CALayer` takes it
as contents. Rows are padded for the GPU, so index by `bytesPerRow()`, or use `row(y)`.

## Application bundles

A bare executable runs, but a Mac app is a bundle: an `Info.plist` naming it, an identifier that
permissions, preferences and notifications are keyed to, an icon, and a signature over the lot.
`addAppBundle` makes one:

```zig
// build.zig, in a program that depends on mac-zig
const mac_build = @import("mac");

const bundle = mac_build.addAppBundle(b, exe, .{
    .name = "Demo",
    .identifier = "com.example.demo",
    .version = "1.2",
    .icon = b.path("assets/AppIcon.icns"),          // optional
    .info = &.{.{ .key = "NSCameraUsageDescription", .value = .{ .string = "To see you." } }},
});
b.getInstallStep().dependOn(bundle.step);           // zig-out/Demo.app
b.step("run-app", "Run the app").dependOn(&bundle.run.step);
```

It writes `Info.plist` and `PkgInfo`, lays out `Contents/MacOS` and `Contents/Resources`, and
signs the bundle — ad hoc by default, which is enough to run locally and to keep a granted
permission across rebuilds; pass a Developer ID as `.sign` to hand the app to anyone else.
`bundle.run` runs the executable inside the bundle, so the app has its bundle identity and its
output stays in the terminal. `appkit.app.run` takes its menu-bar name from the bundle when no
`.name` is given.

```sh
zig build window-app        # zig-out/mac-zig Window.app
zig build run-window-app    # runs it
```

## Traps

- **`clipToPath` replaces the current path.** CoreGraphics has no call that clips to a path
  directly, so it goes through the current one. Take a `copyPath` first if you still need it.
- **A PDF context is not finished when it is released.** Call `closePdf` or the file is
  truncated.
- **`Event.post` is a silent no-op without Accessibility permission.** No error, no code.
  If synthetic input appears to do nothing, that is almost always why.
- **A display's current mode is usually absent from `modes(.{})`.** On a Retina display the
  current mode is a scaled one, and CoreGraphics leaves those out unless you pass
  `.{ .include_scaled = true }`.
- **`intersection` returns a _null_ rectangle, not an empty one, when two rectangles miss.**
  Check it with `isNull`, not `isEmpty`.
- **`Image.cropped` measures from the top left**, unlike everything else in the framework.
- **`Display.pixelSize()` is not `CGDisplayPixelsWide`.** That call predates Retina and answers
  in _points_ — on a 6016x3384 panel it says 3008x1692, and a capture buffer sized from it holds
  a quarter of the pixels. `pixelSize()` reads the current mode instead; `legacyPixelSize()` is
  the old number if you need to match it.
- **ImageIO's default JPEG quality is not maximum.** A 6016x3384 screenshot came out at 2.0 MB
  with `.{}` and 5.3 MB with `.{ .quality = 1.0 }`. PNG is lossless regardless.
- **The screen-capture calls are obsoleted as of macOS 15**, not merely deprecated —
  `obsoleted=15.0`, which in C is a hard compile error. Zig ignores availability attributes, so
  they compile and link, and they still worked on macOS 26.6. There will be no warning on the
  day they stop, only a null return.
- **An uncaught Objective-C exception ends the process** — a message the receiver does not
  understand, an index out of range. Use `tryMsgSend` where one is possible, and remember that
  unwinding skips the `defer`s in the Zig frames it passes through.
- **`getClass("NSWindow")` is null unless AppKit is linked.** `-Dappkit` links it; any other
  framework has to be linked by the program that uses it, with `linkFramework`.
- **A raw `addIvar` instance variable starts zero-filled**, and a Zig struct's default values
  are never applied. `objc.Subclass` does apply them; with the low-level API, make zero the
  starting state.
- **AppKit is main-thread only.** `appkit.app.run` checks; the wrappers do not.
- **A click on an inactive window only activates it.** Override `acceptsFirstMouse:` to take the
  click too.
- **A window that is not on screen drops mouse events** sent to it with `sendEvent:`. The tests
  order theirs in at zero alpha.
- **`launched` runs on the first `run` only** — AppKit finishes launching once per process.
- **Pass the defining class's superclass to `msgSendSuper`**, spelled out — not
  `self.getClass().superclass()`, which recurses forever once your class is subclassed.
- **IOKit reports a time-to-empty of 0 while on mains**, which is not an estimate that the
  machine is about to die. `Source.time_to_empty` is null unless the source is actually
  discharging, and `time_to_full` unless it is actually charging.

## Examples

```sh
zig build run-info        # displays, modes and the windows on screen
zig build run-power       # battery, mains, time remaining
zig build run-shapes      # paths, dashes, clipping, shadows, boolean ops
zig build run-gradient    # gradients, transforms and layers
zig build run-text        # measuring, aligning, the flipped-context fix
zig build run-pdf         # a PDF written, read back and rasterised
zig build run-objc        # Foundation, a class defined in Zig, exceptions, AppKit
zig build run-window      # a window: a view drawing with cg, mouse, keys, menus, dispatch
zig build run-metal       # Metal: a shader, a pipeline, a triangle at the display's rate
```

## Build options

| Option              | Default | Effect                                                                                    |
| ------------------- | ------- | ----------------------------------------------------------------------------------------- |
| `-Dimageio=false`   | on      | Drops `mac.cg.imageio`; no reading or writing of image files                              |
| `-Dcoretext=false`  | on      | Drops `mac.cg.text`; no string drawing                                                    |
| `-Diokit=false`     | on      | Drops `mac.iokit`; no power-source reading                                                |
| `-Dobjc=false`      | on      | Drops `mac.objc` and `mac.foundation`, and their links                                    |
| `-Dappkit=false`    | on      | Drops `mac.appkit` and the AppKit link; needs `-Dobjc`                                    |
| `-Dmetal=false`     | on      | Drops `mac.metal`, `appkit.MetalView`, and the Metal and QuartzCore links; needs `-Dobjc` |
| `-Diosurface=false` | on      | Drops `mac.iosurface` and the IOSurface link; `-Dmetal` needs it                          |

Every namespace still exists when switched off, holding only `enabled = false`, so a
dependent can check `mac.features.imageio` rather than failing to compile.

## Steps

| Step                   | Effect                                                 |
| ---------------------- | ------------------------------------------------------ |
| `zig build`            | Builds every example into `zig-out/bin`                |
| `zig build test`       | Runs the inline tests and the integration tests        |
| `zig build bindings`   | Writes the translated C bindings to `zig-out/bindings` |
| `zig build generate`   | Regenerates `src/appkit/generated.zig` from the SDK    |
| `zig build window-app` | Builds the window example as a signed `.app` bundle    |

## Layout

| Path                          | What is in it                                             |
| ----------------------------- | --------------------------------------------------------- |
| `src/mac.zig`                 | Umbrella root: the framework namespaces and feature flags |
| `src/errors.zig`              | The `Error` set, shared by every framework                |
| `src/cf.zig`                  | Just enough CoreFoundation to work the rest               |
| `src/cg/cg.zig`               | CoreGraphics namespace root and re-exports                |
| `src/cg/geometry.zig`         | `Point`, `Size`, `Rect`, `AffineTransform`                |
| `src/cg/color.zig`            | `ColorSpace`, `Color`, `Rgba`                             |
| `src/cg/image.zig`            | `Image`, `BitmapInfo`, `DataProvider`                     |
| `src/cg/path.zig`             | `Path`, `MutablePath`, `Element`                          |
| `src/cg/context.zig`          | `Context`, `Gradient`, `Layer` — the drawing surface      |
| `src/cg/pdf.zig`              | Reading PDFs                                              |
| `src/cg/display.zig`          | Displays and display modes                                |
| `src/cg/window.zig`           | The window list                                           |
| `src/cg/event.zig`            | Synthetic input and event taps                            |
| `src/cg/imageio.zig`          | Image files, under `-Dimageio`                            |
| `src/cg/text.zig`             | The CoreText bridge, under `-Dcoretext`                   |
| `src/iokit/iokit.zig`         | IOKit namespace root                                      |
| `src/iokit/power.zig`         | Power sources, under `-Diokit`                            |
| `src/objc/objc.zig`           | Objective-C runtime namespace root, `Range`, `Integer`    |
| `src/objc/object.zig`         | `Object`: messages, properties, ivars, bridging to `cf`   |
| `src/objc/class.zig`          | `Class`, and defining classes from Zig                    |
| `src/objc/message.zig`        | The `objc_msgSend` call, typed at compile time            |
| `src/objc/block.zig`          | `Block` and `BlockRef`, laid out by the Block ABI         |
| `src/objc/abi.zig`            | Zig types to C types and back; method trampolines         |
| `src/objc/encoding.zig`       | Type encodings, computed from Zig types                   |
| `src/objc/sel.zig`            | `Sel`, cached per call site                               |
| `src/objc/protocol.zig`       | `Protocol`                                                |
| `src/objc/autorelease.zig`    | `AutoreleasePool`                                         |
| `src/objc/subclass.zig`       | `Subclass`: a class defined as a Zig struct               |
| `src/objc/exception.zig`      | `Exception`, `tryCall`, and `tryMsgSend` underneath       |
| `src/foundation/`             | `String`, `Number`, `Data`, `Url`, collections, errors    |
| `src/appkit/appkit.zig`       | AppKit namespace root                                     |
| `src/appkit/generated.zig`    | The generated wrappers — do not edit                      |
| `src/appkit/app.zig`          | `run`, the delegate and menu bar, `currentContext`        |
| `src/dispatch/dispatch.zig`   | Grand Central Dispatch                                    |
| `tools/objc_gen/main.zig`     | The generator behind `zig build generate`                 |
| `tools/objc_gen/appkit.zig`   | What the generator wraps from AppKit                      |
| `tools/objc_gen/metal.zig`    | What the generator wraps from Metal and QuartzCore        |
| `src/metal/metal.zig`         | Metal namespace root, and the calls that are not methods  |
| `src/iosurface/iosurface.zig` | `Surface` and `Locked`: shared pixel buffers              |
| `src/metal/generated.zig`     | The generated Metal wrappers — do not edit                |
| `src/appkit/metal_view.zig`   | `MetalView`: a Metal layer and a display-link render loop |
| `vendor/mac_objc_exception.m` | The `@try` that `tryMsgSend` runs under                   |
| `vendor/mac_translate.h`      | The umbrella header, and the header workarounds           |

## Where the frameworks come from

They are already on the machine. The package links `CoreGraphics`, `CoreFoundation`, and
optionally `ImageIO`, `CoreText`, `IOKit`, `IOSurface`, `libobjc`, `Foundation`, `AppKit`,
`Metal` and `QuartzCore`, from the macOS SDK that `xcode-select` points at. One small Objective-C file is compiled, for `@try`.

The one piece worth knowing about is `vendor/mac_translate.h`. Five of Apple's spellings do
not survive Zig 0.17's C translator, and all five are handled there rather than in
`build.zig`, so the workaround sits next to the thing it works around:

1. **Nullability on bounded array parameters** — `const CGFloat wp[_Nonnull 3]` in
   `CGColorSpace.h`. The translator reports the feature as supported and then rejects the
   syntax, so the spellings are blanked.
2. **Blocks** — the translator has no blocks support. The few C headers carrying block
   declarations claim their own include guards and re-declare everything except the block APIs,
   each omission documented with the non-block equivalent. CoreText is block-infested
   throughout, which is why `src/cg/text.zig` declares its thirteen functions by hand instead.
   (Blocks as *values* are another matter: `mac.objc` builds them by hand, to the Block ABI.)
3. **Struct-size assertions on bitfield structs** — CoreFoundation reaches `mach/message.h`,
   whose descriptors carry bitfields that translate-c can only render as `opaque`, leaving a
   top-level `comptime` block asking for `@sizeOf` of an opaque type. The assertion macros are
   blanked at the source.
4. **Objective-C's `BOOL`** — `objc/objc.h` makes it `bool` only when the compiler predefines
   `__OBJC_BOOL_IS_BOOL`, which clang does for arm64 and the translator does not. Left alone,
   `BOOL` would be `signed char` on Apple silicon: the call still works, but every type
   encoding says `c` where the runtime's say `B`. The macro is defined up front, as clang would.
5. **XPC's array nullability** — IOSurface's header reaches `xpc.h`, whose
   `const uuid_t XPC_NONNULL_ARRAY` parameters are the first problem again under another macro.
   `xpc/base.h` is included first, the way `xpc.h` includes it, and the macro blanked.
