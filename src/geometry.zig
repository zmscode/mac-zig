//! Points, sizes, rectangles and affine transforms.
//!
//! These are CoreGraphics' own structs -- the layouts are asserted against
//! the translated headers at the bottom of this file -- so they cross the
//! ABI boundary by value with no conversion. What changes is that the
//! free functions become methods, and the out-parameter pair that
//! `CGRectDivide` wants becomes a returned struct.
//!
//! A word about the coordinate system: a bitmap context's y axis points
//! **up** from the bottom-left corner, which is the opposite of what
//! AppKit and most layout maths assume. Nothing here needs to care --
//! a `Rect` is a `Rect` either way -- but `Rect.init(0, 0, w, h)` is the
//! *bottom* left corner of a context unless it has been flipped. See
//! `Context.flipVertically`.

const std = @import("std");
const raw = @import("cg_raw");

/// `CGFloat`: `f64` on every 64-bit Apple platform, which is all of them
/// that still ship. Spelled as an alias rather than as `f64` so that code
/// written against it stays correct if that ever stops being true.
pub const Float = raw.CGFloat;

pub const Point = extern struct {
    x: Float = 0,
    y: Float = 0,

    pub const zero: Point = .{};

    pub fn init(x: Float, y: Float) Point {
        return .{ .x = x, .y = y };
    }

    /// This struct as the CoreGraphics one it is laid out to match, for
    /// calling into `cg.raw` directly. The layouts are asserted at the
    /// bottom of this file, so it compiles to nothing.
    pub inline fn toRaw(self: Point) raw.CGPoint {
        return .{ .x = self.x, .y = self.y };
    }

    pub inline fn fromRaw(value: raw.CGPoint) Point {
        return .{ .x = value.x, .y = value.y };
    }

    pub fn eql(self: Point, other: Point) bool {
        return raw.CGPointEqualToPoint(self.toRaw(), other.toRaw());
    }

    pub fn applying(self: Point, transform: AffineTransform) Point {
        return fromRaw(raw.CGPointApplyAffineTransform(self.toRaw(), transform.toRaw()));
    }

    pub fn format(self: Point, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("({d}, {d})", .{ self.x, self.y });
    }
};

pub const Size = extern struct {
    width: Float = 0,
    height: Float = 0,

    pub const zero: Size = .{};

    pub fn init(width: Float, height: Float) Size {
        return .{ .width = width, .height = height };
    }

    pub inline fn toRaw(self: Size) raw.CGSize {
        return .{ .width = self.width, .height = self.height };
    }

    pub inline fn fromRaw(value: raw.CGSize) Size {
        return .{ .width = value.width, .height = value.height };
    }

    pub fn eql(self: Size, other: Size) bool {
        return raw.CGSizeEqualToSize(self.toRaw(), other.toRaw());
    }

    pub fn applying(self: Size, transform: AffineTransform) Size {
        return fromRaw(raw.CGSizeApplyAffineTransform(self.toRaw(), transform.toRaw()));
    }

    pub fn format(self: Size, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("{d}x{d}", .{ self.width, self.height });
    }
};

pub const Vector = extern struct {
    dx: Float = 0,
    dy: Float = 0,

    pub const zero: Vector = .{};

    pub fn init(dx: Float, dy: Float) Vector {
        return .{ .dx = dx, .dy = dy };
    }

    pub inline fn toRaw(self: Vector) raw.CGVector {
        return .{ .dx = self.dx, .dy = self.dy };
    }

    pub inline fn fromRaw(value: raw.CGVector) Vector {
        return .{ .dx = value.dx, .dy = value.dy };
    }
};

/// Which edge `Rect.divide` slices from.
pub const Edge = enum(u32) {
    min_x = 0,
    min_y = 1,
    max_x = 2,
    max_y = 3,
};

pub const Rect = extern struct {
    origin: Point = .{},
    size: Size = .{},

    pub const zero: Rect = .{};

    /// The rectangle `CGRectIntersection` returns when two rectangles do not
    /// overlap. It is not the same as an empty rectangle at the origin, and
    /// `isNull` is the only reliable way to recognise it.
    pub inline fn nullRect() Rect {
        return fromRaw(raw.CGRectNull);
    }

    /// The rectangle that contains every point. Clipping to it is a no-op.
    pub inline fn infinite() Rect {
        return fromRaw(raw.CGRectInfinite);
    }

    pub fn init(x: Float, y: Float, w: Float, h: Float) Rect {
        return .{
            .origin = .{ .x = x, .y = y },
            .size = .{ .width = w, .height = h },
        };
    }

    /// A rectangle at the origin with this size -- what a whole bitmap or a
    /// whole page usually wants.
    pub fn fromSize(size: Size) Rect {
        return .{ .size = size };
    }

    pub inline fn toRaw(self: Rect) raw.CGRect {
        return .{ .origin = self.origin.toRaw(), .size = self.size.toRaw() };
    }

    pub inline fn fromRaw(value: raw.CGRect) Rect {
        return .{
            .origin = Point.fromRaw(value.origin),
            .size = Size.fromRaw(value.size),
        };
    }

    // -- edges ----------------------------------------------------------
    //
    // These go through CoreGraphics rather than reading the fields, because
    // a rectangle with a negative width or height is legal and these must
    // report the standardized edges for one.

    pub fn minX(self: Rect) Float {
        return raw.CGRectGetMinX(self.toRaw());
    }
    pub fn midX(self: Rect) Float {
        return raw.CGRectGetMidX(self.toRaw());
    }
    pub fn maxX(self: Rect) Float {
        return raw.CGRectGetMaxX(self.toRaw());
    }
    pub fn minY(self: Rect) Float {
        return raw.CGRectGetMinY(self.toRaw());
    }
    pub fn midY(self: Rect) Float {
        return raw.CGRectGetMidY(self.toRaw());
    }
    pub fn maxY(self: Rect) Float {
        return raw.CGRectGetMaxY(self.toRaw());
    }
    pub fn width(self: Rect) Float {
        return raw.CGRectGetWidth(self.toRaw());
    }
    pub fn height(self: Rect) Float {
        return raw.CGRectGetHeight(self.toRaw());
    }

    pub fn center(self: Rect) Point {
        return .{ .x = self.midX(), .y = self.midY() };
    }

    // -- tests ----------------------------------------------------------

    pub fn eql(self: Rect, other: Rect) bool {
        return raw.CGRectEqualToRect(self.toRaw(), other.toRaw());
    }

    pub fn isEmpty(self: Rect) bool {
        return raw.CGRectIsEmpty(self.toRaw());
    }

    /// True for the rectangle `intersection` returns when there is no
    /// overlap. A null rectangle is also empty, but not every empty
    /// rectangle is null.
    pub fn isNull(self: Rect) bool {
        return raw.CGRectIsNull(self.toRaw());
    }

    pub fn isInfinite(self: Rect) bool {
        return raw.CGRectIsInfinite(self.toRaw());
    }

    pub fn contains(self: Rect, point: Point) bool {
        return raw.CGRectContainsPoint(self.toRaw(), point.toRaw());
    }

    pub fn containsRect(self: Rect, other: Rect) bool {
        return raw.CGRectContainsRect(self.toRaw(), other.toRaw());
    }

    pub fn intersects(self: Rect, other: Rect) bool {
        return raw.CGRectIntersectsRect(self.toRaw(), other.toRaw());
    }

    // -- derived rectangles ---------------------------------------------

    /// Negative widths and heights resolved into an equivalent rectangle
    /// with positive ones.
    pub fn standardized(self: Rect) Rect {
        return fromRaw(raw.CGRectStandardize(self.toRaw()));
    }

    /// The smallest rectangle on integer boundaries that contains this one.
    pub fn integral(self: Rect) Rect {
        return fromRaw(raw.CGRectIntegral(self.toRaw()));
    }

    /// Shrinks by `dx` on the left and right and `dy` on the top and
    /// bottom. Negative amounts grow it.
    pub fn inset(self: Rect, dx: Float, dy: Float) Rect {
        return fromRaw(raw.CGRectInset(self.toRaw(), dx, dy));
    }

    pub fn offset(self: Rect, dx: Float, dy: Float) Rect {
        return fromRaw(raw.CGRectOffset(self.toRaw(), dx, dy));
    }

    /// The smallest rectangle containing both. Named `unionWith` because
    /// `union` is a keyword.
    pub fn unionWith(self: Rect, other: Rect) Rect {
        return fromRaw(raw.CGRectUnion(self.toRaw(), other.toRaw()));
    }

    /// The overlap, or a null rectangle when there is none -- check with
    /// `isNull`, not `isEmpty`.
    pub fn intersection(self: Rect, other: Rect) Rect {
        return fromRaw(raw.CGRectIntersection(self.toRaw(), other.toRaw()));
    }

    pub fn applying(self: Rect, transform: AffineTransform) Rect {
        return fromRaw(raw.CGRectApplyAffineTransform(self.toRaw(), transform.toRaw()));
    }

    /// `CGRectDivide`, which in C writes two rectangles through out
    /// parameters. `amount` is measured from `edge`.
    pub fn divide(self: Rect, amount: Float, edge: Edge) Division {
        var slice: raw.CGRect = undefined;
        var remainder: raw.CGRect = undefined;
        raw.CGRectDivide(self.toRaw(), &slice, &remainder, amount, @backingInt(edge));
        return .{ .slice = fromRaw(slice), .remainder = fromRaw(remainder) };
    }

    pub const Division = struct {
        slice: Rect,
        remainder: Rect,
    };

    pub fn format(self: Rect, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("({d}, {d}) {d}x{d}", .{
            self.origin.x,
            self.origin.y,
            self.size.width,
            self.size.height,
        });
    }
};

/// The 3x2 matrix CoreGraphics transforms everything with. The third column
/// is always (0, 0, 1), so it is not stored.
///
/// The order matters and is the opposite of the reading order: `t.scaled(2,
/// 2).translated(10, 0)` translates *first* and then scales, because each
/// call concatenates the new transform on the left of the existing one --
/// the same rule as the `Context.scale`/`Context.translate` pair.
pub const AffineTransform = extern struct {
    a: Float = 1,
    b: Float = 0,
    c: Float = 0,
    d: Float = 1,
    tx: Float = 0,
    ty: Float = 0,

    pub const identity: AffineTransform = .{};

    pub fn init(a: Float, b: Float, c: Float, d: Float, tx: Float, ty: Float) AffineTransform {
        return .{ .a = a, .b = b, .c = c, .d = d, .tx = tx, .ty = ty };
    }

    pub inline fn toRaw(self: AffineTransform) raw.CGAffineTransform {
        return .{
            .a = self.a,
            .b = self.b,
            .c = self.c,
            .d = self.d,
            .tx = self.tx,
            .ty = self.ty,
        };
    }

    pub inline fn fromRaw(value: raw.CGAffineTransform) AffineTransform {
        return .{
            .a = value.a,
            .b = value.b,
            .c = value.c,
            .d = value.d,
            .tx = value.tx,
            .ty = value.ty,
        };
    }

    pub fn translation(tx: Float, ty: Float) AffineTransform {
        return fromRaw(raw.CGAffineTransformMakeTranslation(tx, ty));
    }

    pub fn scaling(sx: Float, sy: Float) AffineTransform {
        return fromRaw(raw.CGAffineTransformMakeScale(sx, sy));
    }

    /// `angle` is in radians, counter-clockwise in CoreGraphics' bottom-left
    /// coordinate system.
    pub fn rotation(angle: Float) AffineTransform {
        return fromRaw(raw.CGAffineTransformMakeRotation(angle));
    }

    pub fn isIdentity(self: AffineTransform) bool {
        return raw.CGAffineTransformIsIdentity(self.toRaw());
    }

    pub fn eql(self: AffineTransform, other: AffineTransform) bool {
        return raw.CGAffineTransformEqualToTransform(self.toRaw(), other.toRaw());
    }

    pub fn translated(self: AffineTransform, tx: Float, ty: Float) AffineTransform {
        return fromRaw(raw.CGAffineTransformTranslate(self.toRaw(), tx, ty));
    }

    pub fn scaled(self: AffineTransform, sx: Float, sy: Float) AffineTransform {
        return fromRaw(raw.CGAffineTransformScale(self.toRaw(), sx, sy));
    }

    pub fn rotated(self: AffineTransform, angle: Float) AffineTransform {
        return fromRaw(raw.CGAffineTransformRotate(self.toRaw(), angle));
    }

    /// The inverse, or the transform unchanged when it is not invertible --
    /// which is what CoreGraphics does, and it does not say which happened.
    /// Compare against the input if you need to know.
    pub fn inverted(self: AffineTransform) AffineTransform {
        return fromRaw(raw.CGAffineTransformInvert(self.toRaw()));
    }

    /// `self` then `other`.
    pub fn concat(self: AffineTransform, other: AffineTransform) AffineTransform {
        return fromRaw(raw.CGAffineTransformConcat(self.toRaw(), other.toRaw()));
    }

    /// Pulls the matrix apart into the scale, shear, rotation and
    /// translation that produce it. macOS 13 and later.
    pub fn decompose(self: AffineTransform) Components {
        const c = raw.CGAffineTransformDecompose(self.toRaw());
        return .{
            .scale = Size.fromRaw(c.scale),
            .horizontal_shear = c.horizontalShear,
            .rotation = c.rotation,
            .translation = Vector.fromRaw(c.translation),
        };
    }

    pub const Components = extern struct {
        scale: Size,
        horizontal_shear: Float,
        /// Radians.
        rotation: Float,
        translation: Vector,

        pub fn compose(self: Components) AffineTransform {
            return AffineTransform.fromRaw(raw.CGAffineTransformMakeWithComponents(.{
                .scale = self.scale.toRaw(),
                .horizontalShear = self.horizontal_shear,
                .rotation = self.rotation,
                .translation = self.translation.toRaw(),
            }));
        }
    };
};

comptime {
    std.debug.assert(@sizeOf(Point) == @sizeOf(raw.CGPoint));
    std.debug.assert(@sizeOf(Size) == @sizeOf(raw.CGSize));
    std.debug.assert(@sizeOf(Vector) == @sizeOf(raw.CGVector));
    std.debug.assert(@sizeOf(Rect) == @sizeOf(raw.CGRect));
    std.debug.assert(@sizeOf(AffineTransform) == @sizeOf(raw.CGAffineTransform));
    std.debug.assert(@sizeOf(AffineTransform.Components) == @sizeOf(raw.CGAffineTransformComponents));
    std.debug.assert(@offsetOf(Rect, "size") == @offsetOf(raw.CGRect, "size"));
    std.debug.assert(@offsetOf(AffineTransform, "tx") == @offsetOf(raw.CGAffineTransform, "tx"));
}

test "rect edges are standardized" {
    // A negative height is legal, and the edges must still come back in
    // the right order.
    const upside_down = Rect.init(10, 30, 20, -20);
    try std.testing.expectEqual(@as(Float, 10), upside_down.minY());
    try std.testing.expectEqual(@as(Float, 30), upside_down.maxY());
    try std.testing.expectEqual(@as(Float, 20), upside_down.height());
}

test "intersection of disjoint rects is null, not empty-at-origin" {
    const left = Rect.init(0, 0, 10, 10);
    const right = Rect.init(100, 100, 10, 10);
    const none = left.intersection(right);
    try std.testing.expect(none.isNull());
    try std.testing.expect(!none.eql(Rect.zero));
}

test "divide returns both halves" {
    const whole = Rect.init(0, 0, 100, 40);
    const split = whole.divide(30, .min_x);
    try std.testing.expect(split.slice.eql(Rect.init(0, 0, 30, 40)));
    try std.testing.expect(split.remainder.eql(Rect.init(30, 0, 70, 40)));
}

test "transform order is apply-first, concatenate-left" {
    const t = AffineTransform.identity.scaled(2, 2).translated(10, 0);
    // The translation happens in the already-scaled space, so the point
    // lands at (2*10 + 2*1) rather than (10 + 2).
    const moved = Point.init(1, 0).applying(t);
    try std.testing.expectEqual(@as(Float, 22), moved.x);
}

test "inset shrinks and negative inset grows" {
    const r = Rect.init(0, 0, 100, 100);
    try std.testing.expect(r.inset(10, 10).eql(Rect.init(10, 10, 80, 80)));
    try std.testing.expect(r.inset(-5, -5).eql(Rect.init(-5, -5, 110, 110)));
}
