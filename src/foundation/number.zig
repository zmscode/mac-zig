//! `NSNumber`.

const std = @import("std");
const objc = @import("../objc/objc.zig");
const generated = @import("generated.zig");

const Object = objc.Object;

/// A boxed number or boolean, for the collections, which hold only
/// objects. Small ones are tagged pointers -- no allocation at all.
pub const Number = extern struct {
    object: Object,

    pub fn class() objc.Class {
        return objc.getClass("NSNumber").?;
    }

    /// Yours.
    pub fn initInt(value: i64) Number {
        return class().msgSend(Object, "alloc", .{}).msgSend(Number, "initWithLongLong:", .{value});
    }

    /// Yours.
    pub fn initFloat(value: f64) Number {
        return class().msgSend(Object, "alloc", .{}).msgSend(Number, "initWithDouble:", .{value});
    }

    /// Yours.
    pub fn initBool(value: bool) Number {
        return class().msgSend(Object, "alloc", .{}).msgSend(Number, "initWithBool:", .{value});
    }

    /// Every method `NSNumber` has -- this is the everyday part -- as the
    /// generated wrapper for the same object.
    pub fn all(self: Number) generated.Number {
        return .from(self.object);
    }

    pub fn deinit(self: Number) void {
        self.object.release();
    }

    pub fn retain(self: Number) Number {
        return .{ .object = self.object.retain() };
    }

    pub fn autorelease(self: Number) Number {
        return .{ .object = self.object.autorelease() };
    }

    /// The value as an integer, truncating a float.
    pub fn toInt(self: Number) i64 {
        return self.object.msgSend(i64, "longLongValue", .{});
    }

    pub fn toFloat(self: Number) f64 {
        return self.object.msgSend(f64, "doubleValue", .{});
    }

    pub fn toBool(self: Number) bool {
        return self.object.msgSend(bool, "boolValue", .{});
    }

    /// True when the value was stored as a float or double.
    pub fn isFloat(self: Number) bool {
        const kind = self.object.msgSend([*:0]const u8, "objCType", .{})[0];
        return kind == 'f' or kind == 'd';
    }

    /// Numeric equality: 1 equals 1.0.
    pub fn eql(self: Number, other: Number) bool {
        return self.object.msgSend(bool, "isEqualToNumber:", .{other});
    }

    pub fn order(self: Number, other: Number) std.math.Order {
        return switch (self.object.msgSend(objc.Integer, "compare:", .{other})) {
            -1 => .lt,
            0 => .eq,
            else => .gt,
        };
    }
};

test "numbers" {
    const n = Number.initInt(42);
    defer n.deinit();
    const f = Number.initFloat(42.0);
    defer f.deinit();
    const t = Number.initBool(true);
    defer t.deinit();

    try std.testing.expectEqual(@as(i64, 42), n.toInt());
    try std.testing.expect(!n.isFloat());
    try std.testing.expect(f.isFloat());
    try std.testing.expect(n.eql(f));
    try std.testing.expect(t.toBool());
    try std.testing.expectEqual(std.math.Order.lt, t.order(n));
}
