//! Objective-C type encodings, computed from Zig types at compile time.
//!
//! The runtime wants a string describing a method's signature when one is
//! added (`class_addMethod`), an instance variable's type when one is
//! declared, and a block's signature when a block is made. In C these come
//! from `@encode`; here they come from `encode`, which walks the type:
//!
//! | Zig                               | Encoding             |
//! | --------------------------------- | -------------------- |
//! | `void`                            | `v`                  |
//! | `bool` (as `BOOL`)                | `B` arm64, `c` Intel |
//! | `i8` `i16` `i32` `i64`            | `c` `s` `i` `q`      |
//! | `u8` `u16` `u32` `u64`            | `C` `S` `I` `Q`      |
//! | `f32` `f64`                       | `f` `d`              |
//! | `Object`, a wrapper, `Protocol`   | `@`                  |
//! | `Class` / `Sel`                   | `#` / `:`            |
//! | a block                           | `@?`                 |
//! | `[*:0]const u8`                   | `*`                  |
//! | `*T`                              | `^` then `T`         |
//! | `cg.Rect` and the other geometry  | `{CGRect=...}`       |
//! | an `extern struct`                | `{?=...}`            |
//!
//! A struct can name itself by declaring `pub const objc_encoding`, which
//! is used verbatim; `objc.Range` does, as `{_NSRange=QQ}`. Anything with
//! no encoding at all -- an auto-layout Zig struct kept in an instance
//! variable, say -- is `?`, which the runtime accepts as "unknown".
//!
//! The runtime reads these for introspection, forwarding and
//! `NSInvocation`; it does not use them to call a method. A struct spelled
//! `{?=dd}` instead of `{CGPoint=dd}` still works, it just describes itself
//! less well.

const std = @import("std");
const raw = @import("mac_raw");
const geometry = @import("../cg/geometry.zig");

const Object = @import("object.zig").Object;
const Class = @import("class.zig").Class;
const Sel = @import("sel.zig").Sel;
const Protocol = @import("protocol.zig").Protocol;
const abi = @import("abi.zig");

/// The encoding of `T`.
pub fn encode(comptime T: type) [:0]const u8 {
    return comptime inner(T) ++ "";
}

/// The encoding of a method implementation `F`, whose first two
/// parameters are the receiver and the selector.
pub fn method(comptime F: type) [:0]const u8 {
    return comptime blk: {
        const info = @typeInfo(F).@"fn";
        var out: []const u8 = inner(info.return_type.?) ++ "@:";
        for (info.param_types[2..]) |P| out = out ++ inner(P.?);
        break :blk out ++ "";
    };
}

/// The encoding of a method taking `Args` and returning `Return`, with
/// the receiver and selector supplied.
pub fn methodFrom(comptime Return: type, comptime Args: []const type) [:0]const u8 {
    return comptime blk: {
        var out: []const u8 = inner(Return) ++ "@:";
        for (Args) |A| out = out ++ inner(A);
        break :blk out ++ "";
    };
}

/// The signature of a block taking `Args` and returning `Return`. The
/// block itself is the hidden first argument, spelled `@?`.
pub fn block(comptime Return: type, comptime Args: []const type) [:0]const u8 {
    return comptime blk: {
        var out: []const u8 = inner(Return) ++ "@?";
        for (Args) |A| out = out ++ inner(A);
        break :blk out ++ "";
    };
}

/// Whether `T` is a block pointer's pointee: a `Block(...)` or a
/// `BlockRef(...)`.
inline fn isBlock(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .@"struct", .@"union", .@"enum", .@"opaque" => @hasDecl(T, "is_objc_block"),
        else => false,
    };
}

fn inner(comptime T: type) []const u8 {
    if (T == void) return "v";
    if (T == bool) return if (raw.BOOL == bool) "B" else "c";
    if (isBlock(T)) return "@?";
    if (abi.isObject(T) or T == Protocol) return "@";
    if (T == Class) return "#";
    if (T == Sel) return ":";
    if (abi.handleField(T) != null) return "^v";

    if (T == geometry.Point) return "{CGPoint=dd}";
    if (T == geometry.Size) return "{CGSize=dd}";
    if (T == geometry.Vector) return "{CGVector=dd}";
    if (T == geometry.Rect) return "{CGRect={CGPoint=dd}{CGSize=dd}}";
    if (T == geometry.AffineTransform) return "{CGAffineTransform=dddddd}";

    switch (@typeInfo(T)) {
        .@"struct", .@"union", .@"enum" => if (@hasDecl(T, "objc_encoding")) return T.objc_encoding,
        else => {},
    }

    return switch (@typeInfo(T)) {
        .int => |int| switch (int.bits) {
            8 => if (int.signedness == .signed) "c" else "C",
            16 => if (int.signedness == .signed) "s" else "S",
            32 => if (int.signedness == .signed) "i" else "I",
            64 => if (int.signedness == .signed) "q" else "Q",
            128 => if (int.signedness == .signed) "t" else "T",
            else => "?",
        },
        .float => |float| switch (float.bits) {
            32 => "f",
            64 => "d",
            80, 128 => "D",
            else => "?",
        },
        .optional => |optional| inner(optional.child),
        .pointer => |pointer| pointerEncoding(pointer),
        .@"enum" => |e| inner(e.tag_type),
        .@"struct" => |s| switch (s.layout) {
            .@"packed" => inner(s.backing_integer.?),
            .@"extern" => blk: {
                var out: []const u8 = "{?=";
                for (s.field_types) |F| out = out ++ inner(F);
                break :blk out ++ "}";
            },
            .auto => "?",
        },
        .@"union" => |u| if (u.layout == .@"extern") blk: {
            var out: []const u8 = "(?=";
            for (u.field_types) |F| out = out ++ inner(F);
            break :blk out ++ ")";
        } else "?",
        .array => |array| std.fmt.comptimePrint("[{d}{s}]", .{ array.len, inner(array.child) }),
        else => "?",
    };
}

fn pointerEncoding(comptime pointer: std.lang.Type.Pointer) []const u8 {
    const C = pointer.child;
    if (isBlock(C)) return "@?";
    if (C == u8 and pointer.size != .one and pointer.sentinel() == 0) return "*";
    if (pointer.size == .c and C == u8) return "*";
    return switch (@typeInfo(C)) {
        .@"fn" => "^?",
        .@"opaque" => "^v",
        else => "^" ++ inner(C),
    };
}

test "scalars" {
    try std.testing.expectEqualStrings("v", encode(void));
    try std.testing.expectEqualStrings("q", encode(i64));
    try std.testing.expectEqualStrings("Q", encode(c_ulong));
    try std.testing.expectEqualStrings("i", encode(c_int));
    try std.testing.expectEqualStrings("d", encode(f64));
    try std.testing.expectEqualStrings("*", encode([*:0]const u8));
    try std.testing.expectEqualStrings("^v", encode(*anyopaque));
    try std.testing.expectEqualStrings("^i", encode(*i32));
}

test "the runtime's handle types" {
    try std.testing.expectEqualStrings("@", encode(Object));
    try std.testing.expectEqualStrings("@", encode(?Object));
    try std.testing.expectEqualStrings("#", encode(Class));
    try std.testing.expectEqualStrings(":", encode(Sel));
    try std.testing.expectEqualStrings("@", encode(struct { object: Object }));
}

test "structs" {
    try std.testing.expectEqualStrings("{CGRect={CGPoint=dd}{CGSize=dd}}", encode(geometry.Rect));
    try std.testing.expectEqualStrings("{?=iq}", encode(extern struct { a: i32, b: i64 }));
    try std.testing.expectEqualStrings("?", encode(struct { a: i32 }));
    try std.testing.expectEqualStrings("[4d]", encode([4]f64));
}

test "a method signature puts self and _cmd first" {
    const imp = struct {
        fn f(_: Object, _: Sel, _: i64, _: geometry.Point) bool {
            return true;
        }
    }.f;
    const expected = if (raw.BOOL == bool) "B@:q{CGPoint=dd}" else "c@:q{CGPoint=dd}";
    try std.testing.expectEqualStrings(expected, method(@TypeOf(imp)));
}
