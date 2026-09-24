//! [Grand Central Dispatch](https://developer.apple.com/documentation/dispatch):
//! queues, and the main thread -- reached as `mac.dispatch`.
//!
//! The one thing most programs need from it is getting back onto the main
//! thread, which AppKit insists on:
//!
//! ```zig
//! mac.dispatch.Queue.main().async(state, struct {
//!     fn run(s: *State) void {
//!         s.window.setTitle(.literal("done"));
//!     }
//! }.run);
//! ```
//!
//! libdispatch is part of libSystem, so there is nothing to link and no
//! build option. Its headers are written in terms of blocks, which the C
//! translator cannot read, so the handful of calls here are declared by
//! hand -- every one of them the `_f` variant that takes a function pointer
//! and a context pointer, which is what a Zig function is.

const std = @import("std");

// -- the C API --------------------------------------------------------------

const Work = *const fn (context: ?*anyopaque) callconv(.c) void;

extern var _dispatch_main_q: u8;
extern var _dispatch_queue_attr_concurrent: u8;
extern fn dispatch_get_global_queue(identifier: isize, flags: usize) ?*anyopaque;
extern fn dispatch_queue_create(label: ?[*:0]const u8, attr: ?*anyopaque) ?*anyopaque;
extern fn dispatch_release(object: *anyopaque) void;
extern fn dispatch_async_f(queue: *anyopaque, context: ?*anyopaque, work: Work) void;
extern fn dispatch_sync_f(queue: *anyopaque, context: ?*anyopaque, work: Work) void;
extern fn dispatch_after_f(when: u64, queue: *anyopaque, context: ?*anyopaque, work: Work) void;
extern fn dispatch_time(when: u64, delta: i64) u64;
extern fn dispatch_semaphore_create(value: isize) ?*anyopaque;
extern fn dispatch_semaphore_signal(semaphore: *anyopaque) isize;
extern fn dispatch_semaphore_wait(semaphore: *anyopaque, timeout: u64) isize;
extern fn pthread_main_np() c_int;

const time_now: u64 = 0;
const time_forever: u64 = std.math.maxInt(u64);

/// True on the process's main thread: the one AppKit runs on.
pub fn isMainThread() bool {
    return pthread_main_np() != 0;
}

/// How urgent a global queue's work is.
pub const Qos = enum(isize) {
    /// Work the user is waiting to see: animation, event handling.
    user_interactive = 0x21,
    /// Work the user asked for and is waiting on.
    user_initiated = 0x19,
    default = 0x15,
    /// Long-running work the user can see progress of.
    utility = 0x11,
    /// Work the user is not waiting for at all.
    background = 0x09,
};

/// A queue of work, run in order (serial) or in parallel (concurrent) on
/// threads the system manages.
pub const Queue = struct {
    handle: *anyopaque,
    owned: bool = false,

    /// The main thread's queue. Work sent here runs on the main thread,
    /// in order, from the main run loop -- so only once the program is
    /// running one, which `appkit.app.run` does.
    pub fn main() Queue {
        return .{ .handle = &_dispatch_main_q };
    }

    /// One of the shared concurrent queues. Nothing to release.
    pub fn global(qos: Qos) Queue {
        return .{ .handle = dispatch_get_global_queue(@backingInt(qos), 0).? };
    }

    /// A new queue that runs one piece of work at a time, in order.
    /// Yours to `deinit`; work already sent to it still runs.
    pub fn initSerial(label: [:0]const u8) Queue {
        return .{ .handle = dispatch_queue_create(label.ptr, null).?, .owned = true };
    }

    /// A new queue that runs work in parallel. Yours to `deinit`.
    pub fn initConcurrent(label: [:0]const u8) Queue {
        return .{ .handle = dispatch_queue_create(label.ptr, &_dispatch_queue_attr_concurrent).?, .owned = true };
    }

    pub fn deinit(self: Queue) void {
        if (self.owned) dispatch_release(self.handle);
    }

    /// Runs `f(context)` on this queue, soon, and returns at once.
    /// `context` is a pointer, and whatever it points at has to live until
    /// `f` has run -- see `asyncOwned` for work that outlives its caller.
    pub fn async(self: Queue, context: anytype, comptime f: fn (@TypeOf(context)) void) void {
        dispatch_async_f(self.handle, erase(context), Trampoline(@TypeOf(context), f).run);
    }

    /// Runs `f(context)` on this queue and waits for it. Never do this to
    /// the queue you are already on -- `main()` from the main thread
    /// included -- which waits forever.
    pub fn sync(self: Queue, context: anytype, comptime f: fn (@TypeOf(context)) void) void {
        std.debug.assert(!(self.handle == @as(*anyopaque, &_dispatch_main_q) and isMainThread()));
        dispatch_sync_f(self.handle, erase(context), Trampoline(@TypeOf(context), f).run);
    }

    /// Runs `f(context)` on this queue once `seconds` have passed.
    pub fn after(self: Queue, seconds: f64, context: anytype, comptime f: fn (@TypeOf(context)) void) void {
        const delay: i64 = @intFromFloat(seconds * std.time.ns_per_s);
        dispatch_after_f(dispatch_time(time_now, delay), self.handle, erase(context), Trampoline(@TypeOf(context), f).run);
    }

    /// `async`, for work that outlives the caller: `value` is copied to
    /// memory from `allocator`, `f` gets a pointer to the copy, and the
    /// copy is freed after `f` returns. `allocator` must be usable from
    /// the queue's thread.
    pub fn asyncOwned(
        self: Queue,
        allocator: std.mem.Allocator,
        value: anytype,
        comptime f: fn (*@TypeOf(value)) void,
    ) std.mem.Allocator.Error!void {
        const T = @TypeOf(value);
        const Box = struct {
            allocator: std.mem.Allocator,
            value: T,

            fn run(box: *@This()) void {
                f(&box.value);
                box.allocator.destroy(box);
            }
        };
        const box = try allocator.create(Box);
        box.* = .{ .allocator = allocator, .value = value };
        self.async(box, Box.run);
    }
};

/// A counting semaphore: `wait` blocks until someone has `signal`ed.
/// The usual way to wait for work sent to another queue.
pub const Semaphore = struct {
    handle: *anyopaque,

    /// Yours to `deinit`. `value` is the number of `wait`s that go through
    /// before the first `signal`.
    pub fn init(value: usize) Semaphore {
        return .{ .handle = dispatch_semaphore_create(@intCast(value)).? };
    }

    pub fn deinit(self: Semaphore) void {
        dispatch_release(self.handle);
    }

    pub fn signal(self: Semaphore) void {
        _ = dispatch_semaphore_signal(self.handle);
    }

    /// Waits for a `signal`, or for `timeout` seconds; null waits for
    /// ever. False when it timed out.
    pub fn wait(self: Semaphore, timeout: ?f64) bool {
        const deadline = if (timeout) |seconds|
            dispatch_time(time_now, @intFromFloat(seconds * std.time.ns_per_s))
        else
            time_forever;
        return dispatch_semaphore_wait(self.handle, deadline) == 0;
    }
};

fn erase(context: anytype) ?*anyopaque {
    const C = @TypeOf(context);
    switch (@typeInfo(C)) {
        .pointer => |p| if (p.size != .one) @compileError("dispatch context must be a single pointer; found " ++ @typeName(C)),
        else => @compileError("dispatch context must be a pointer, so that it survives until the work runs; found " ++ @typeName(C)),
    }
    return @ptrCast(@constCast(context));
}

fn Trampoline(comptime C: type, comptime f: fn (C) void) type {
    return struct {
        fn run(context: ?*anyopaque) callconv(.c) void {
            f(@ptrCast(@alignCast(context)));
        }
    };
}

test "work on a global queue, waited for" {
    const Job = struct {
        total: std.atomic.Value(u32) = .init(0),
        done: Semaphore,

        fn run(job: *@This()) void {
            _ = job.total.fetchAdd(1, .monotonic);
            job.done.signal();
        }
    };
    var job: Job = .{ .done = .init(0) };
    defer job.done.deinit();

    const queue = Queue.global(.user_initiated);
    for (0..4) |_| queue.async(&job, Job.run);
    for (0..4) |_| try std.testing.expect(job.done.wait(5));
    try std.testing.expectEqual(@as(u32, 4), job.total.load(.monotonic));
}

test "a serial queue keeps order, and sync waits" {
    const Log = struct {
        items: [3]u8 = undefined,
        len: usize = 0,

        fn a(log: *@This()) void {
            log.items[log.len] = 'a';
            log.len += 1;
        }
        fn b(log: *@This()) void {
            log.items[log.len] = 'b';
            log.len += 1;
        }
    };
    const queue = Queue.initSerial("mac-zig.test");
    defer queue.deinit();

    var log: Log = .{};
    queue.async(&log, Log.a);
    queue.async(&log, Log.b);
    queue.sync(&log, Log.a);
    try std.testing.expectEqualStrings("aba", log.items[0..log.len]);
}

test "owned work frees its copy" {
    const Message = struct {
        value: u64,
        out: *std.atomic.Value(u64),
        done: Semaphore,

        fn run(message: *@This()) void {
            message.out.store(message.value, .monotonic);
            message.done.signal();
        }
    };
    var out: std.atomic.Value(u64) = .init(0);
    const done: Semaphore = .init(0);
    defer done.deinit();

    // The testing allocator is not thread-safe; a global queue's work runs
    // on another thread, so a serial queue that is waited on stands in.
    const queue = Queue.initSerial("mac-zig.owned");
    defer queue.deinit();
    try queue.asyncOwned(std.testing.allocator, Message{ .value = 42, .out = &out, .done = done }, Message.run);
    try std.testing.expect(done.wait(5));
    queue.sync(&out, struct {
        fn drain(_: *std.atomic.Value(u64)) void {}
    }.drain);
    try std.testing.expectEqual(@as(u64, 42), out.load(.monotonic));
}

test "a semaphore times out" {
    const semaphore: Semaphore = .init(0);
    defer semaphore.deinit();
    try std.testing.expect(!semaphore.wait(0.01));
    semaphore.signal();
    try std.testing.expect(semaphore.wait(0.01));
}
