//! Completion handlers, turned into something to wait on with `std.Io`.
//!
//! Apple's asynchronous APIs take a block and call it when they are done
//! -- on a thread of their choosing, some time later. `Completion` is that
//! block, plus the waiting:
//!
//! ```zig
//! var done = try objc.Completion(fn (?metal.Library, ?foundation.ErrorObject) void).init(gpa, io);
//! defer done.deinit();
//!
//! device.newLibraryWithSourceOptionsCompletionHandler(source, null, done.handler());
//! const library, const failure = try done.wait();     // an Io wait: cancelable
//! ```
//!
//! `wait` is an ordinary `std.Io` wait -- on `Io.Threaded` it blocks the
//! thread; on an evented `Io` it suspends the task -- and like any other it
//! can be canceled, or bounded with `waitTimeout`.
//!
//! ## What is kept
//!
//! The handler's arguments are kept when it runs, and objects and handles
//! (`cg.Image`, `coremedia.SampleBuffer`) among them are retained, so they
//! are still there when `wait` returns -- until `deinit`. `retain` one to
//! keep it longer.
//!
//! ## Giving up
//!
//! Waiting can stop before the handler runs -- canceled, or timed out --
//! and the handler may still run later. So the state the two share is
//! counted: `deinit` drops the waiter's claim, the handler drops its own
//! when it has run, and whichever is last frees it. The allocator must
//! therefore be usable from the thread the handler runs on.
//!
//! The handler must be one that is called once. Most completion handlers
//! are; a progress or enumeration block is not.

const std = @import("std");
const raw = @import("mac_raw");
const Io = std.Io;
const abi = @import("abi.zig");
const block = @import("block.zig");

const Object = @import("object.zig").Object;

pub fn Completion(comptime Signature_: type) type {
    const info = @typeInfo(Signature_).@"fn";
    if (info.return_type.? != void) @compileError("a completion handler returns void; found " ++ @typeName(Signature_));
    const Args = blk: {
        var list: [info.param_types.len]type = undefined;
        for (info.param_types, &list) |P, *slot| slot.* = P.?;
        const final = list;
        break :blk &final;
    };

    return struct {
        state: *State,

        const Self = @This();

        pub const Signature = Signature_;

        /// What `wait` returns: nothing, the one argument, or a tuple of
        /// them -- which destructures: `const a, const b = try done.wait();`.
        pub const Result = switch (Args.len) {
            0 => void,
            1 => Args[0],
            else => @Tuple(Args),
        };

        const Handler = block.Block(struct { state: *State }, Signature_);

        const State = struct {
            allocator: std.mem.Allocator,
            io: Io,
            event: Io.Event = .unset,
            /// The waiter's claim, plus the handler's once it is handed out.
            claims: std.atomic.Value(u8) = .init(1),
            handed_out: bool = false,
            fired: bool = false,
            result: Result = undefined,
            handler: Handler = undefined,

            fn drop(state: *State) void {
                if (state.claims.fetchSub(1, .acq_rel) != 1) return;
                if (state.fired) releaseObjects(&state.result);
                state.allocator.destroy(state);
            }
        };

        pub fn init(allocator: std.mem.Allocator, io: Io) std.mem.Allocator.Error!Self {
            const state = try allocator.create(State);
            state.* = .{ .allocator = allocator, .io = io };
            state.handler = Handler.initTuple(.{ .state = state }, Body.run);
            return .{ .state = state };
        }

        /// The block to hand to the API. Once only: it is the one block
        /// this completion waits for.
        pub fn handler(self: Self) block.BlockRef(Signature_) {
            std.debug.assert(!self.state.handed_out);
            self.state.handed_out = true;
            _ = self.state.claims.fetchAdd(1, .acq_rel);
            return self.state.handler.ref();
        }

        /// Waits for the handler to run, and returns what it was given.
        pub fn wait(self: Self) Io.Cancelable!Result {
            try self.state.event.wait(self.state.io);
            return self.state.result;
        }

        /// `wait`, giving up after `timeout` with `error.Timeout`. The
        /// handler may still run afterwards; see the note on giving up.
        pub fn waitTimeout(self: Self, timeout: Io.Timeout) Io.Event.WaitTimeoutError!Result {
            try self.state.event.waitTimeout(self.state.io, timeout);
            return self.state.result;
        }

        /// Whether the handler has run.
        pub fn isDone(self: Self) bool {
            return self.state.event.isSet();
        }

        /// Gives up this side's claim. Objects in the result are released
        /// with the state.
        pub fn deinit(self: Self) void {
            self.state.drop();
        }

        const Body = struct {
            fn run(captures: *const Handler.Captures, args: Handler.Arguments) void {
                const state = captures.state;
                if (state.fired) return; // called twice: not a completion handler
                inline for (0..Args.len) |i| retainObject(Args[i], args[i]);
                state.result = switch (Args.len) {
                    0 => {},
                    1 => args[0],
                    else => args,
                };
                state.fired = true;
                state.event.set(state.io);
                state.drop();
            }
        };

        fn releaseObjects(result: *Result) void {
            switch (Args.len) {
                0 => {},
                1 => releaseObject(Args[0], result.*),
                else => inline for (0..Args.len) |i| releaseObject(Args[i], result[i]),
            }
        }
    };
}

/// A CoreFoundation-style handle among the handler's arguments -- a
/// `cg.Image`, a `coremedia.SampleBuffer` -- or an object, as the pointer
/// to retain and release. Handles are CF types, so `CFRetain` covers both.
fn retainedPointer(comptime T: type, value: T) ?*const anyopaque {
    if (comptime abi.isObject(T)) return abi.unwrap(value).value;
    if (comptime abi.handleField(T)) |field| return @ptrCast(@field(value, field));
    if (@typeInfo(T) == .optional) {
        const Child = @typeInfo(T).optional.child;
        if (comptime abi.isObject(Child) or abi.handleField(Child) != null) {
            return if (value) |present| retainedPointer(Child, present) else null;
        }
    }
    return null;
}

fn retainObject(comptime T: type, value: T) void {
    if (retainedPointer(T, value)) |pointer| _ = raw.CFRetain(pointer);
}

fn releaseObject(comptime T: type, value: T) void {
    if (retainedPointer(T, value)) |pointer| raw.CFRelease(pointer);
}

// The handler may free the state on its own thread, so these use a
// thread-safe allocator; `std.testing.allocator` is not one.

test "a completion waited on, with the handler run from another thread" {
    const dispatch = @import("../dispatch/dispatch.zig");
    const io = std.testing.io;

    var done = try Completion(fn (i64, bool) void).init(std.heap.smp_allocator, io);
    defer done.deinit();

    // Stands in for an Apple API: keeps the block, calls it later, elsewhere.
    const handler = try done.handler().copy();
    dispatch.Queue.global(.default).after(0.02, handler.object.value, struct {
        fn later(pointer: *anyopaque) void {
            const kept: block.BlockRef(fn (i64, bool) void) = .{ .object = .{ .value = pointer } };
            kept.call(.{ 42, true });
            kept.release();
        }
    }.later);

    const number, const flag = try done.wait();
    try std.testing.expectEqual(@as(i64, 42), number);
    try std.testing.expect(flag);
    try std.testing.expect(done.isDone());
}

test "giving up before the handler runs leaves it safe to run later" {
    const dispatch = @import("../dispatch/dispatch.zig");
    const io = std.testing.io;

    var finished: dispatch.Semaphore = .init(0);
    defer finished.deinit();

    {
        var done = try Completion(fn () void).init(std.heap.smp_allocator, io);
        defer done.deinit(); // before the handler runs: the handler frees the state

        const Late = struct { handler: *anyopaque, finished: *dispatch.Semaphore };
        var late: Late = .{ .handler = (try done.handler().copy()).object.value, .finished = &finished };
        dispatch.Queue.global(.default).after(0.1, &late, struct {
            fn later(context: *Late) void {
                const kept: block.BlockRef(fn () void) = .{ .object = .{ .value = context.handler } };
                kept.call(.{});
                kept.release();
                context.finished.signal();
            }
        }.later);

        try std.testing.expectError(error.Timeout, done.waitTimeout(.{ .duration = .{
            .raw = .fromMilliseconds(5),
            .clock = .awake,
        } }));
        // `late` must outlive the dispatch; wait for it below, after deinit.
        try std.testing.expect(finished.wait(5));
    }
}

test "a completion never handed out frees on deinit" {
    var done = try Completion(fn (Object) void).init(std.heap.smp_allocator, std.testing.io);
    done.deinit();
}
