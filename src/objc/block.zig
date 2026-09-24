//! Blocks: Objective-C's closures, built from Zig.
//!
//! The translator cannot read block syntax, so `^{ ... }` has no Zig
//! spelling. It does not need one: a block is a struct with a documented
//! layout -- the [Block ABI][abi] -- and this file lays one out by hand:
//!
//! ```text
//! isa         &_NSConcreteStackBlock, until copied to the heap
//! flags       has copy/dispose helpers, has a signature
//! reserved
//! invoke      a C function taking the block, then the arguments
//! descriptor  size, copy and dispose helpers, type signature
//! captures    whatever the closure closed over
//! ```
//!
//! `Block` makes one; `BlockRef` calls one that Objective-C handed over.
//!
//! [abi]: https://clang.llvm.org/docs/Block-ABI-Apple.html

const std = @import("std");
const builtin = @import("builtin");
const raw = @import("mac_raw");
const abi = @import("abi.zig");
const encoding = @import("encoding.zig");
const errors = @import("../errors.zig");

const Error = errors.Error;
const Object = @import("object.zig").Object;

const block_has_copy_dispose: c_int = 1 << 25;
const block_has_stret: c_int = 1 << 29;
const block_has_signature: c_int = 1 << 30;

/// A block taking `Args` and returning `Return`, which carries a
/// `Captures` along with it.
///
/// ```zig
/// const Sum = objc.Block(struct { total: *i64 }, &.{ objc.Object, objc.UInteger, *bool }, void);
///
/// var total: i64 = 0;
/// var block = Sum.init(.{ .total = &total }, struct {
///     fn body(captures: *const Sum.Captures, item: objc.Object, _: objc.UInteger, _: *bool) void {
///         captures.total.* += item.msgSend(i64, "longLongValue", .{});
///     }
/// }.body);
///
/// array.msgSend(void, "enumerateObjectsUsingBlock:", .{&block});
/// ```
///
/// `init` makes a *stack* block: it lives exactly as long as the Zig
/// variable holding it, which is right for a call that uses the block and
/// returns, like the enumeration above. A method that keeps the block to
/// call later -- a completion handler, a notification observer -- copies
/// it to the heap itself, as the Block ABI requires, and that copy is
/// independent of the variable. `copy` makes such a heap copy from Zig.
///
/// `Captures` is copied bit for bit when the block is, except that any
/// field that is an `Object` (or `?Object`, or a wrapper) is retained by
/// the copy and released when the copy is freed -- as a C compiler does.
/// A pointer captured to Zig memory is just a pointer: it had better
/// outlive every copy of the block.
pub fn Block(comptime Captures_: type, comptime Args: []const type, comptime Return: type) type {
    return extern struct {
        isa: ?*anyopaque,
        flags: c_int,
        reserved: c_int = 0,
        invoke: *const Invoke,
        descriptor: *const Descriptor,
        captured: [@sizeOf(Captures)]u8 align(@alignOf(Captures)),

        const Self = @This();

        pub const Captures = Captures_;

        /// Marks this type for the encoder, which spells a block `@?`.
        pub const is_objc_block = {};

        const Invoke = abi.CFn(invokeParams(*Self, Args), abi.Abi(Return));

        const Descriptor = extern struct {
            reserved: c_ulong = 0,
            size: c_ulong,
            copy_helper: *const fn (dst: *Self, src: *const Self) callconv(.c) void,
            dispose_helper: *const fn (block: *const Self) callconv(.c) void,
            signature: [*:0]const u8,
        };

        const block_descriptor: Descriptor = .{
            .size = @sizeOf(Self),
            .copy_helper = &copyHelper,
            .dispose_helper = &disposeHelper,
            .signature = encoding.block(Return, Args),
        };

        const block_flags: c_int = block_has_copy_dispose | block_has_signature |
            (if (usesStret(Return)) block_has_stret else 0);

        /// A stack block running `body`, which takes a pointer to the
        /// captures and then `Args`:
        ///
        /// ```zig
        /// fn body(captures: *const Captures, a: Args[0], b: Args[1]) Return
        /// ```
        ///
        /// `*Captures` works as well, if the body changes them.
        pub fn init(captures_value: Captures, comptime body: anytype) Self {
            var self: Self = .{
                .isa = @ptrCast(&raw._NSConcreteStackBlock),
                .flags = block_flags,
                .invoke = invokeFor(body),
                .descriptor = &block_descriptor,
                .captured = undefined,
            };
            self.captures().* = captures_value;
            return self;
        }

        pub fn captures(self: *Self) *Captures {
            return @ptrCast(&self.captured);
        }

        /// Calls the block, as Objective-C would.
        pub fn call(self: *Self, args: @Tuple(Args)) Return {
            return callBlock(*Self, self, self.invoke, Args, Return, args);
        }

        /// A heap copy, which is yours to `release`. Copying a heap block
        /// only retains it.
        pub fn copy(self: *const Self) Error!*Self {
            return @ptrCast(@alignCast(raw._Block_copy(self) orelse return Error.Failed));
        }

        /// Gives up a heap copy from `copy`. Never call this on a stack
        /// block made by `init`.
        pub fn release(self: *Self) void {
            raw._Block_release(self);
        }

        fn invokeFor(comptime body: anytype) *const Invoke {
            const F = @TypeOf(body);
            const params = @typeInfo(F).@"fn".param_types;
            if (params.len != Args.len + 1) @compileError(std.fmt.comptimePrint(
                "a block body takes a pointer to the captures and then {d} argument(s); found {s}",
                .{ Args.len, @typeName(F) },
            ));
            if (abi.ReturnOf(F) != Return) @compileError(
                "a block body must return " ++ @typeName(Return) ++ "; found " ++ @typeName(F),
            );

            const Body = struct {
                fn run(c_args: anytype) abi.Abi(Return) {
                    var args: std.meta.ArgsTuple(F) = undefined;
                    args[0] = c_args[0].captures();
                    inline for (Args, 1..) |A, i| args[i] = abi.fromAbi(A, c_args[i]);
                    return abi.toAbi(Return, @call(.auto, body, args));
                }
            };
            return abi.cFunction(invokeParams(*Self, Args), abi.Abi(Return), Body.run);
        }

        fn copyHelper(dst: *Self, src: *const Self) callconv(.c) void {
            _ = src;
            forEachObject(dst.captures(), Object.retain);
        }

        fn disposeHelper(block: *const Self) callconv(.c) void {
            forEachObject(@constCast(block).captures(), Object.release);
        }
    };
}

/// A block that came from Objective-C -- the completion handler passed to
/// a method you implemented, say -- known to take `Args` and return
/// `Return`. Nothing checks that; the signature has to be right.
///
/// It is an object, so it goes in a method's parameter list as itself:
///
/// ```zig
/// const Handler = objc.BlockRef(&.{objc.Object}, void);
///
/// fn load(self: objc.Object, _: objc.Sel, done: Handler) void {
///     done.call(.{result});
/// }
/// ```
///
/// A block kept past the method's return has to be copied with `copy`
/// and later released, as in C.
pub fn BlockRef(comptime Args: []const type, comptime Return: type) type {
    return extern struct {
        object: Object,

        const Self = @This();

        pub const is_objc_block = {};

        const Invoke = abi.CFn(invokeParams(*anyopaque, Args), abi.Abi(Return));

        const Header = extern struct {
            isa: ?*anyopaque,
            flags: c_int,
            reserved: c_int,
            invoke: *const Invoke,
        };

        /// Calls the block.
        pub fn call(self: Self, args: @Tuple(Args)) Return {
            const header: *const Header = @ptrCast(@alignCast(self.object.value));
            return callBlock(*anyopaque, self.object.value, header.invoke, Args, Return, args);
        }

        /// A heap copy that outlives the call it arrived in. Yours to
        /// `release`.
        pub fn copy(self: Self) Error!Self {
            const copied = raw._Block_copy(self.object.value) orelse return Error.Failed;
            return .{ .object = .{ .value = copied } };
        }

        pub fn release(self: Self) void {
            raw._Block_release(self.object.value);
        }
    };
}

fn invokeParams(comptime Receiver: type, comptime Args: []const type) []const type {
    var params: [Args.len + 1]type = undefined;
    params[0] = Receiver;
    for (Args, params[1..]) |A, *slot| slot.* = abi.Abi(A);
    const final = params;
    return &final;
}

fn callBlock(
    comptime Receiver: type,
    receiver: anytype,
    invoke: anytype,
    comptime Args: []const type,
    comptime Return: type,
    args: @Tuple(Args),
) Return {
    var c_args: @Tuple(invokeParams(Receiver, Args)) = undefined;
    c_args[0] = receiver;
    inline for (Args, 1..) |A, i| c_args[i] = abi.toAbi(A, args[i - 1]);
    return abi.fromAbi(Return, @call(.auto, invoke, c_args));
}

/// Whether a block returning `Return` returns it through memory, which
/// the block's flags must say on Intel.
fn usesStret(comptime Return: type) bool {
    if (builtin.target.cpu.arch != .x86_64) return false;
    const R = abi.Abi(Return);
    return switch (@typeInfo(R)) {
        .@"struct", .@"union", .array => @sizeOf(R) > 16,
        else => false,
    };
}

/// Calls `action` on each object held in `captures`: the value itself if
/// it is an object, or each field of a struct that is one.
fn forEachObject(captures: anytype, comptime action: anytype) void {
    const T = @typeInfo(@TypeOf(captures)).pointer.child;
    if (abi.isObject(T)) {
        _ = action(abi.unwrap(captures.*));
    } else switch (@typeInfo(T)) {
        .optional => |optional| if (abi.isObject(optional.child)) {
            if (captures.*) |present| _ = action(abi.unwrap(present));
        },
        .@"struct" => |s| inline for (s.field_names, s.field_types) |field, F| {
            if (abi.isObject(F)) {
                _ = action(abi.unwrap(@field(captures.*, field)));
            } else if (@typeInfo(F) == .optional and abi.isObject(@typeInfo(F).optional.child)) {
                if (@field(captures.*, field)) |present| _ = action(abi.unwrap(present));
            }
        },
        else => {},
    }
}

test "a block calls its body with its captures" {
    const Add = Block(struct { offset: i32 }, &.{ i32, i32 }, i32);
    var block = Add.init(.{ .offset = 100 }, struct {
        fn body(captures: *const Add.Captures, a: i32, b: i32) i32 {
            return captures.offset + a + b;
        }
    }.body);
    try std.testing.expectEqual(@as(i32, 103), block.call(.{ 1, 2 }));
}

test "a heap copy is independent of the stack block" {
    const Get = Block(struct { value: f64 }, &.{}, f64);
    var stack = Get.init(.{ .value = 2.5 }, struct {
        fn body(captures: *const Get.Captures) f64 {
            return captures.value;
        }
    }.body);

    const heap = try stack.copy();
    defer heap.release();

    stack.captures().value = 0;
    try std.testing.expectEqual(@as(f64, 2.5), heap.call(.{}));
    try std.testing.expect(heap != &stack);
}

test "a block can change what it captured" {
    const Count = Block(struct { hits: u32 }, &.{}, void);
    var block = Count.init(.{ .hits = 0 }, struct {
        fn body(captures: *Count.Captures) void {
            captures.hits += 1;
        }
    }.body);
    block.call(.{});
    block.call(.{});
    try std.testing.expectEqual(@as(u32, 2), block.captures().hits);
}

test "a block's signature is its type encoding" {
    const B = Block(struct {}, &.{ Object, bool }, void);
    const expected = if (raw.BOOL == bool) "v@?@B" else "v@?@c";
    try std.testing.expectEqualStrings(expected, std.mem.span(B.block_descriptor.signature));
}
