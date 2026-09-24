//! The line between the types this binding hands out and the types the
//! runtime actually traffics in.
//!
//! Every value that crosses into Objective-C -- a `msgSend` argument, a
//! method implementation's parameters, a block's -- passes through `Abi`,
//! `toAbi` and `fromAbi` here. They are the identity for anything already
//! C-shaped (integers, floats, pointers, `extern struct`s such as
//! `cg.Rect`) and do three real jobs:
//!
//! - `Object`, `Class`, `Sel`, `Protocol`, and any struct whose only field
//!   is an `Object`, become the bare pointer the runtime expects;
//! - so does any other *handle* -- a struct whose only field is a
//!   non-optional pointer, like `cg.Image` or `cg.Context` -- so a
//!   `CGImageRef` goes in and comes out as the `cg` type;
//! - `bool` becomes `BOOL`, which is `bool` on Apple silicon and
//!   `signed char` on Intel;
//! - things that have no C form -- `comptime_int`, a Zig error union --
//!   are rejected at compile time with a message saying what to write
//!   instead, rather than passed through to fail somewhere less legible.
//!
//! ## Why objects are `*anyopaque`
//!
//! The translated `id` is `[*c]struct_objc_object`, a pointer to an
//! eight-byte-aligned struct. But many objects are not at an address at
//! all: small `NSNumber`s, short `NSString`s and most `NSDate`s are
//! *tagged pointers*, with the value packed into the pointer bits. Casting
//! one of those to `id` trips Zig's alignment check and panics. So objects
//! are held as `*anyopaque` throughout, and the handful of runtime calls
//! that take an `id` are declared again below with that type.

const std = @import("std");
const builtin = @import("builtin");
const raw = @import("mac_raw");

const Object = @import("object.zig").Object;
const Class = @import("class.zig").Class;
const Sel = @import("sel.zig").Sel;
const Protocol = @import("protocol.zig").Protocol;

/// An object pointer as the runtime sees it, at alignment 1 so a tagged
/// pointer is representable. See the note at the top of this file.
pub const Id = ?*anyopaque;

// The runtime calls that take or return `id`, re-declared with `Id`. The
// symbols are the same ones `raw` names; only the pointer type differs.
pub extern fn object_getClass(obj: Id) raw.Class;
pub extern fn objc_retain(obj: Id) Id;
pub extern fn objc_release(obj: Id) void;
pub extern fn objc_autorelease(obj: Id) Id;
pub extern fn objc_autoreleasePoolPush() ?*anyopaque;
pub extern fn objc_autoreleasePoolPop(pool: ?*anyopaque) void;

/// The message-send trampolines. Declared with no parameters, as the
/// header does, because each call site casts to its own exact type.
pub extern fn objc_msgSend() void;
pub extern fn objc_msgSendSuper() void;
// Intel only; referenced only from Intel code paths, so they are never
// looked for on Apple silicon, where they do not exist.
extern fn objc_msgSend_stret() void;
extern fn objc_msgSendSuper_stret() void;
extern fn objc_msgSend_fpret() void;

/// `struct objc_super`, with the receiver as `Id`.
pub const Super = extern struct {
    receiver: Id,
    super_class: raw.Class,
};

/// True for `Object` and for any struct whose only field is an `Object`:
/// the typed wrappers a program builds around it, like
/// `struct { object: objc.Object }`.
pub inline fn isObject(comptime T: type) bool {
    return T == Object or objectField(T) != null;
}

/// The name of a wrapper's `Object` field, or null if `T` is not one.
pub inline fn objectField(comptime T: type) ?[:0]const u8 {
    if (T == Object) return null;
    const info = switch (@typeInfo(T)) {
        .@"struct" => |s| s,
        else => return null,
    };
    if (info.field_types.len != 1 or info.field_types[0] != Object) return null;
    return info.field_names[0];
}

/// The name of the pointer field of a handle -- a struct whose only field
/// is a non-optional single pointer, like `cg.Image` -- or null if `T` is
/// not one. `Object` and its wrappers are handles too, but are asked
/// about first everywhere, because they are also objects.
pub inline fn handleField(comptime T: type) ?[:0]const u8 {
    const info = switch (@typeInfo(T)) {
        .@"struct" => |s| s,
        else => return null,
    };
    if (info.field_types.len != 1) return null;
    return switch (@typeInfo(info.field_types[0])) {
        .pointer => |p| if (p.size == .one) info.field_names[0] else null,
        else => null,
    };
}

/// The object inside `value`, which is an `Object` or a wrapper of one.
pub inline fn unwrap(value: anytype) Object {
    const T = @TypeOf(value);
    return if (T == Object) value else @field(value, objectField(T).?);
}

/// `object` seen as `T`, which is `Object` or a wrapper of one.
pub inline fn wrap(comptime T: type, object: Object) T {
    if (T == Object) {
        return object;
    } else {
        var wrapped: T = undefined;
        @field(wrapped, objectField(T).?) = object;
        return wrapped;
    }
}

/// The C type `T` crosses the boundary as.
pub fn Abi(comptime T: type) type {
    if (T == bool) return raw.BOOL;
    if (isObject(T) or T == Protocol) return Id;
    if (T == Class) return raw.Class;
    if (T == Sel) return raw.SEL;
    if (handleField(T) != null) return Id;

    switch (@typeInfo(T)) {
        .optional => |optional| {
            const C = optional.child;
            if (isObject(C) or C == Protocol or C == Class or C == Sel or handleField(C) != null) return Abi(C);
            return T;
        },
        .comptime_int => @compileError(
            "an integer literal has no C type; give it one, e.g. @as(objc.Integer, 3)",
        ),
        .comptime_float => @compileError(
            "a float literal has no C type; give it one, e.g. @as(cg.Float, 1.5)",
        ),
        .null => @compileError(
            "a bare `null` has no C type; give it one, e.g. @as(?objc.Object, null)",
        ),
        .enum_literal => @compileError(
            "an enum literal has no C type; spell out the enum it belongs to",
        ),
        .error_union, .error_set => @compileError(
            "a Zig error cannot cross into Objective-C; handle it inside the function",
        ),
        else => return T,
    }
}

pub inline fn toAbi(comptime T: type, value: T) Abi(T) {
    if (T == bool) {
        return if (raw.BOOL == bool) value else @intFromBool(value);
    } else if (isObject(T)) {
        return unwrap(value).value;
    } else if (T == Protocol or T == Class or T == Sel) {
        return value.value;
    } else if (handleField(T)) |field| {
        return @ptrCast(@constCast(@field(value, field)));
    } else if (@typeInfo(T) == .optional and Abi(T) != T) {
        return if (value) |present| toAbi(@TypeOf(present), present) else null;
    } else {
        return value;
    }
}

/// A non-optional handle asserts that the runtime did not hand back nil;
/// ask for `?T` where nil is a real answer.
pub inline fn fromAbi(comptime T: type, value: Abi(T)) T {
    if (T == bool) {
        return if (raw.BOOL == bool) value else value != 0;
    } else if (isObject(T)) {
        return wrap(T, .{ .value = value.? });
    } else if (T == Protocol) {
        return .{ .value = @ptrCast(@alignCast(value.?)) };
    } else if (T == Class or T == Sel) {
        return .{ .value = value.? };
    } else if (handleField(T)) |field| {
        var handle: T = undefined;
        @field(handle, field) = @ptrCast(@alignCast(value.?));
        return handle;
    } else if (@typeInfo(T) == .optional and Abi(T) != T) {
        return if (value == null) null else fromAbi(@typeInfo(T).optional.child, value);
    } else {
        return value;
    }
}

/// The C function type with these parameters and result.
pub fn CFn(comptime params: []const type, comptime Return: type) type {
    return @Fn(params, &@splat(.{}), Return, .{ .@"callconv" = .c });
}

/// The C-ABI form of each parameter of `F`, a function type.
pub fn abiParams(comptime F: type) []const type {
    const params = @typeInfo(F).@"fn".param_types;
    var out: [params.len]type = undefined;
    for (params, &out) |P, *slot| slot.* = Abi(P orelse
        @compileError("an Objective-C callback cannot take `anytype`"));
    const final = out;
    return &final;
}

/// A C function over `params` whose body is `body(.{ a0, a1, ... })`.
///
/// This is how a Zig function becomes a method implementation or a block
/// body: `body` converts each C argument with `fromAbi`, calls the Zig
/// function, and converts its result back. Zig cannot make a function of
/// computed arity, so each arity is spelled out; sixteen is more than any
/// Objective-C method in the SDK takes.
pub fn cFunction(
    comptime params: []const type,
    comptime Return: type,
    comptime body: anytype,
) *const CFn(params, Return) {
    const P = params;
    const R = Return;
    return switch (P.len) {
        0 => &struct {
            fn f() callconv(.c) R {
                return body(.{});
            }
        }.f,
        1 => &struct {
            fn f(a0: P[0]) callconv(.c) R {
                return body(.{a0});
            }
        }.f,
        2 => &struct {
            fn f(a0: P[0], a1: P[1]) callconv(.c) R {
                return body(.{ a0, a1 });
            }
        }.f,
        3 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2]) callconv(.c) R {
                return body(.{ a0, a1, a2 });
            }
        }.f,
        4 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3 });
            }
        }.f,
        5 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4 });
            }
        }.f,
        6 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5 });
            }
        }.f,
        7 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6 });
            }
        }.f,
        8 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6], a7: P[7]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6, a7 });
            }
        }.f,
        9 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6], a7: P[7], a8: P[8]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6, a7, a8 });
            }
        }.f,
        10 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6], a7: P[7], a8: P[8], a9: P[9]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6, a7, a8, a9 });
            }
        }.f,
        11 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6], a7: P[7], a8: P[8], a9: P[9], a10: P[10]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 });
            }
        }.f,
        12 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6], a7: P[7], a8: P[8], a9: P[9], a10: P[10], a11: P[11]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11 });
            }
        }.f,
        13 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6], a7: P[7], a8: P[8], a9: P[9], a10: P[10], a11: P[11], a12: P[12]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12 });
            }
        }.f,
        14 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6], a7: P[7], a8: P[8], a9: P[9], a10: P[10], a11: P[11], a12: P[12], a13: P[13]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13 });
            }
        }.f,
        15 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6], a7: P[7], a8: P[8], a9: P[9], a10: P[10], a11: P[11], a12: P[12], a13: P[13], a14: P[14]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14 });
            }
        }.f,
        16 => &struct {
            fn f(a0: P[0], a1: P[1], a2: P[2], a3: P[3], a4: P[4], a5: P[5], a6: P[6], a7: P[7], a8: P[8], a9: P[9], a10: P[10], a11: P[11], a12: P[12], a13: P[13], a14: P[14], a15: P[15]) callconv(.c) R {
                return body(.{ a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 });
            }
        }.f,
        else => @compileError(std.fmt.comptimePrint(
            "{d} parameters is more than an Objective-C callback here can take (16)",
            .{P.len},
        )),
    };
}

/// A Zig function `f` as a C function: each argument converted with
/// `fromAbi`, the result with `toAbi`. `f` may use any calling convention
/// and any of the types `Abi` accepts.
pub fn adapt(comptime f: anytype) *const CFn(abiParams(@TypeOf(f)), Abi(ReturnOf(@TypeOf(f)))) {
    const F = @TypeOf(f);
    const params = @typeInfo(F).@"fn".param_types;
    const R = ReturnOf(F);

    const Body = struct {
        fn call(c_args: anytype) Abi(R) {
            var args: std.meta.ArgsTuple(F) = undefined;
            inline for (params, 0..) |P, i| args[i] = fromAbi(P.?, c_args[i]);
            return toAbi(R, @call(.auto, f, args));
        }
    };
    return cFunction(abiParams(F), Abi(R), Body.call);
}

pub fn ReturnOf(comptime F: type) type {
    const info = @typeInfo(F);
    if (info != .@"fn") @compileError("expected a function, found " ++ @typeName(F));
    if (info.@"fn".is_generic) @compileError("an Objective-C callback cannot be generic");
    return info.@"fn".return_type.?;
}

/// Which trampoline sends a message returning `Return`. On Apple silicon
/// it is always the plain one. On Intel, a struct too big for registers
/// comes back through memory and needs `_stret`, and `long double` needs
/// `_fpret`; the calling convention itself -- the hidden result pointer --
/// is what Zig's C ABI already does, so only the entry point differs.
pub fn trampoline(comptime Return: type, comptime to_super: bool) *const fn () callconv(.c) void {
    const R = Abi(Return);
    if (builtin.target.cpu.arch == .x86_64) {
        const in_memory = switch (@typeInfo(R)) {
            .@"struct", .@"union", .array => @sizeOf(R) > 16,
            else => false,
        };
        if (in_memory) return if (to_super) &objc_msgSendSuper_stret else &objc_msgSend_stret;
        if (R == c_longdouble and !to_super) return &objc_msgSend_fpret;
    }
    return if (to_super) &objc_msgSendSuper else &objc_msgSend;
}

test "the C types each Zig type crosses as" {
    try std.testing.expect(Abi(Object) == Id);
    try std.testing.expect(Abi(?Object) == Id);
    try std.testing.expect(Abi(Class) == raw.Class);
    try std.testing.expect(Abi(Sel) == raw.SEL);
    try std.testing.expect(Abi(bool) == raw.BOOL);
    try std.testing.expect(Abi(f64) == f64);
    try std.testing.expect(Abi(?*u8) == ?*u8);

    const Window = struct { object: Object };
    try std.testing.expect(Abi(Window) == Id);
    try std.testing.expect(Abi(?Window) == Id);
    try std.testing.expect(Abi(struct { a: Object, b: Object }) != Id);

    // A handle: one pointer field, like cg.Image.
    const Handle = struct { handle: *opaque {} };
    try std.testing.expect(Abi(Handle) == Id);
    try std.testing.expect(Abi(?Handle) == Id);
    try std.testing.expect(Abi(struct { handle: ?*u8 }) != Id);
}

test "bool survives the BOOL round trip" {
    try std.testing.expect(fromAbi(bool, toAbi(bool, true)));
    try std.testing.expect(!fromAbi(bool, toAbi(bool, false)));
}
