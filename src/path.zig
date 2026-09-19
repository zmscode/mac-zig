//! Paths: the outlines everything else is drawn from.
//!
//! CoreGraphics has one path object with two spellings -- `CGPathRef` and
//! `CGMutablePathRef` -- and relies on `const` to keep them apart. Here
//! they are two types, so a `Path` cannot be appended to and a
//! `MutablePath` does not have to be trusted not to be.
//!
//! ## Transforms
//!
//! Every C path call takes a `const CGAffineTransform *` that is almost
//! always `NULL`. Rather than carry an optional through every signature,
//! the building calls here take no transform and `Path.transformed` makes a
//! transformed copy. The one exception is `addPathTransformed`, where
//! placing a sub-path somewhere is the entire purpose.
//!
//! ## Walking a path
//!
//! `CGPathApply` hands a callback a `CGPathElement` whose `points` array
//! has a length you are expected to infer from the element's type -- read
//! `points[2]` on a `moveTo` and you read whatever was next in memory.
//! `Element` is a tagged union, so the points you can reach are the points
//! that are there.

const std = @import("std");
const raw = @import("cg_raw");
const errors = @import("errors.zig");
const geometry = @import("geometry.zig");

const Error = errors.Error;
const Float = geometry.Float;
const Point = geometry.Point;
const Rect = geometry.Rect;
const AffineTransform = geometry.AffineTransform;

/// How the ends of an open stroked subpath are drawn.
pub const LineCap = enum(i32) {
    /// Stops dead at the endpoint.
    butt = 0,
    /// A half-circle past the endpoint.
    round = 1,
    /// A half-square past the endpoint.
    square = 2,
    _,
};

/// How two stroked segments meet.
pub const LineJoin = enum(i32) {
    /// Extended to a point, unless that point would be further away than
    /// the miter limit, in which case it is beveled instead.
    miter = 0,
    round = 1,
    bevel = 2,
    _,
};

/// What `Context.drawPath` does with the current path.
pub const DrawingMode = enum(i32) {
    fill = 0,
    eo_fill = 1,
    stroke = 2,
    fill_stroke = 3,
    eo_fill_stroke = 4,
    _,
};

/// One step of a path.
pub const Element = union(enum) {
    move_to: Point,
    line_to: Point,
    quad_curve_to: struct { control: Point, end: Point },
    curve_to: struct { control1: Point, control2: Point, end: Point },
    close_subpath,

    fn fromRaw(element: *const raw.struct_CGPathElement) Element {
        const points = element.points;
        return switch (element.type) {
            raw.kCGPathElementMoveToPoint => .{ .move_to = Point.fromRaw(points[0]) },
            raw.kCGPathElementAddLineToPoint => .{ .line_to = Point.fromRaw(points[0]) },
            raw.kCGPathElementAddQuadCurveToPoint => .{ .quad_curve_to = .{
                .control = Point.fromRaw(points[0]),
                .end = Point.fromRaw(points[1]),
            } },
            raw.kCGPathElementAddCurveToPoint => .{ .curve_to = .{
                .control1 = Point.fromRaw(points[0]),
                .control2 = Point.fromRaw(points[1]),
                .end = Point.fromRaw(points[2]),
            } },
            else => .close_subpath,
        };
    }

    /// The point the path is left at after this element, or null for
    /// `close_subpath`, which returns to the start of the subpath.
    pub fn endPoint(self: Element) ?Point {
        return switch (self) {
            .move_to, .line_to => |p| p,
            .quad_curve_to => |c| c.end,
            .curve_to => |c| c.end,
            .close_subpath => null,
        };
    }
};

/// An immutable path.
pub const Path = struct {
    handle: *const raw.struct_CGPath,

    // -- ready-made shapes ----------------------------------------------

    pub fn initRect(area: Rect) Error!Path {
        const created = raw.CGPathCreateWithRect(area.toRaw(), null);
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// The ellipse inscribed in `area`; a circle when `area` is square.
    pub fn initEllipse(area: Rect) Error!Path {
        const created = raw.CGPathCreateWithEllipseInRect(area.toRaw(), null);
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// A rounded rectangle. Corner radii larger than half the corresponding
    /// side are clamped by CoreGraphics.
    pub fn initRoundedRect(
        area: Rect,
        corner_width: Float,
        corner_height: Float,
    ) Error!Path {
        const created = raw.CGPathCreateWithRoundedRect(
            area.toRaw(),
            corner_width,
            corner_height,
            null,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Path) void {
        raw.CGPathRelease(self.handle);
    }

    pub fn retain(self: Path) Path {
        return .{ .handle = raw.CGPathRetain(self.handle).? };
    }

    pub fn fromRaw(value: raw.CGPathRef) ?Path {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Path) raw.CGPathRef {
        return self.handle;
    }

    // -- what it is -----------------------------------------------------

    pub fn isEmpty(self: Path) bool {
        return raw.CGPathIsEmpty(self.handle);
    }

    pub fn eql(self: Path, other: Path) bool {
        return raw.CGPathEqualToPath(self.handle, other.handle);
    }

    /// The rectangle this path was built as, when it is exactly one
    /// rectangle and nothing else.
    pub fn asRect(self: Path) ?Rect {
        var area: raw.CGRect = undefined;
        if (!raw.CGPathIsRect(self.handle, &area)) return null;
        return Rect.fromRaw(area);
    }

    /// The tightest rectangle containing the path itself. Slower than
    /// `controlPointBoundingBox` and usually the one you want.
    pub fn boundingBox(self: Path) Rect {
        return .fromRaw(raw.CGPathGetPathBoundingBox(self.handle));
    }

    /// The rectangle containing the path's control points, which for a
    /// curve is larger than the curve. Cheap, and fine for culling.
    pub fn controlPointBoundingBox(self: Path) Rect {
        return .fromRaw(raw.CGPathGetBoundingBox(self.handle));
    }

    pub fn currentPoint(self: Path) Point {
        return .fromRaw(raw.CGPathGetCurrentPoint(self.handle));
    }

    /// Whether `point` is inside the path. `even_odd` picks the fill rule:
    /// false is the non-zero winding rule, which is CoreGraphics' default.
    pub fn contains(self: Path, point: Point, even_odd: bool) bool {
        return raw.CGPathContainsPoint(self.handle, null, point.toRaw(), even_odd);
    }

    /// Whether two paths overlap anywhere. macOS 13 and later.
    pub fn intersects(self: Path, other: Path, even_odd: bool) bool {
        return raw.CGPathIntersectsPath(self.handle, other.handle, even_odd);
    }

    // -- derived paths, each one a new path the caller owns --------------

    pub fn copy(self: Path) Error!Path {
        return .{ .handle = try errors.checkPtr(raw.CGPathCreateCopy(self.handle)) };
    }

    pub fn mutableCopy(self: Path) Error!MutablePath {
        const created = raw.CGPathCreateMutableCopy(self.handle);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn transformed(self: Path, transform: AffineTransform) Error!Path {
        var matrix = transform.toRaw();
        const created = raw.CGPathCreateCopyByTransformingPath(self.handle, &matrix);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub const StrokeOptions = struct {
        line_width: Float = 1,
        cap: LineCap = .butt,
        join: LineJoin = .miter,
        miter_limit: Float = 10,
    };

    /// The outline this path would have if it were stroked -- a shape that
    /// can then be filled. This is how a stroke becomes a clip region.
    pub fn stroked(self: Path, options: StrokeOptions) Error!Path {
        const created = raw.CGPathCreateCopyByStrokingPath(
            self.handle,
            null,
            options.line_width,
            @backingInt(options.cap),
            @backingInt(options.join),
            options.miter_limit,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// This path cut into dashes. `lengths` alternates on and off, starting
    /// with on; `phase` is how far into that pattern to start.
    pub fn dashed(self: Path, phase: Float, lengths: []const Float) Error!Path {
        const created = raw.CGPathCreateCopyByDashingPath(
            self.handle,
            null,
            phase,
            lengths.ptr,
            lengths.len,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// Curves replaced by line segments within `threshold` of them.
    /// macOS 13 and later.
    pub fn flattened(self: Path, threshold: Float) Error!Path {
        const created = raw.CGPathCreateCopyByFlattening(self.handle, threshold);
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// Self-intersections removed and the winding direction made
    /// consistent, so that even-odd and non-zero fills agree.
    /// macOS 13 and later.
    pub fn normalized(self: Path, even_odd: bool) Error!Path {
        const created = raw.CGPathCreateCopyByNormalizing(self.handle, even_odd);
        return .{ .handle = try errors.checkPtr(created) };
    }

    // -- boolean operations, macOS 13 and later --------------------------

    /// Named `unionWith` because `union` is a keyword.
    pub fn unionWith(self: Path, other: Path, even_odd: bool) Error!Path {
        const created = raw.CGPathCreateCopyByUnioningPath(self.handle, other.handle, even_odd);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn intersection(self: Path, other: Path, even_odd: bool) Error!Path {
        const created = raw.CGPathCreateCopyByIntersectingPath(self.handle, other.handle, even_odd);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn subtracting(self: Path, other: Path, even_odd: bool) Error!Path {
        const created = raw.CGPathCreateCopyBySubtractingPath(self.handle, other.handle, even_odd);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn symmetricDifference(self: Path, other: Path, even_odd: bool) Error!Path {
        const created = raw.CGPathCreateCopyBySymmetricDifferenceOfPath(
            self.handle,
            other.handle,
            even_odd,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    // -- walking --------------------------------------------------------

    /// Calls `handler` once per element, in order.
    ///
    /// `context` must be a pointer; it is handed back to `handler`
    /// unchanged, which is how state gets in and out of the walk. The
    /// handler runs on this thread before `apply` returns, so pointing at a
    /// local is fine.
    pub fn apply(
        self: Path,
        context: anytype,
        comptime handler: fn (@TypeOf(context), Element) void,
    ) void {
        const Context = @TypeOf(context);
        comptime std.debug.assert(@typeInfo(Context) == .pointer);

        const trampoline = struct {
            fn call(info: ?*anyopaque, element: [*c]const raw.struct_CGPathElement) callconv(.c) void {
                const recovered: Context = @ptrCast(@alignCast(info.?));
                const current: *const raw.struct_CGPathElement = @ptrCast(element);
                handler(recovered, Element.fromRaw(current));
            }
        };

        raw.CGPathApply(self.handle, @ptrCast(@constCast(context)), trampoline.call);
    }

    /// Every element of the path, in memory the caller owns.
    pub fn toOwnedElements(
        self: Path,
        allocator: std.mem.Allocator,
    ) std.mem.Allocator.Error![]Element {
        var collector: Collector = .{ .allocator = allocator };
        errdefer collector.list.deinit(allocator);

        self.apply(&collector, Collector.push);
        if (collector.failed) return error.OutOfMemory;

        return collector.list.toOwnedSlice(allocator);
    }

    const Collector = struct {
        allocator: std.mem.Allocator,
        list: std.ArrayList(Element) = .empty,
        /// `CGPathApply` cannot be stopped part way and its callback
        /// cannot fail, so an allocation failure is recorded and the rest
        /// of the walk runs without appending.
        failed: bool = false,

        fn push(self: *Collector, element: Element) void {
            if (self.failed) return;
            self.list.append(self.allocator, element) catch {
                self.failed = true;
            };
        }
    };
};

/// A path being built.
pub const MutablePath = struct {
    handle: *raw.struct_CGPath,

    pub fn init() Error!MutablePath {
        return .{ .handle = try errors.checkPtr(raw.CGPathCreateMutable()) };
    }

    pub fn deinit(self: MutablePath) void {
        raw.CGPathRelease(self.handle);
    }

    /// The same path seen as immutable, borrowed rather than copied. Do not
    /// `deinit` the result -- and do not keep it past the next change to
    /// this path, because it is the same object.
    pub fn asPath(self: MutablePath) Path {
        return .{ .handle = self.handle };
    }

    /// An immutable snapshot that is independent of further changes.
    pub fn toOwnedPath(self: MutablePath) Error!Path {
        return self.asPath().copy();
    }

    pub inline fn toRaw(self: MutablePath) raw.CGMutablePathRef {
        return self.handle;
    }

    // -- building -------------------------------------------------------

    /// Starts a new subpath at `point`. A path must begin with one of
    /// these; a `lineTo` before any `moveTo` is ignored.
    pub fn moveTo(self: MutablePath, point: Point) void {
        raw.CGPathMoveToPoint(self.handle, null, point.x, point.y);
    }

    pub fn lineTo(self: MutablePath, point: Point) void {
        raw.CGPathAddLineToPoint(self.handle, null, point.x, point.y);
    }

    pub fn quadCurveTo(self: MutablePath, control: Point, end: Point) void {
        raw.CGPathAddQuadCurveToPoint(self.handle, null, control.x, control.y, end.x, end.y);
    }

    pub fn curveTo(self: MutablePath, control1: Point, control2: Point, end: Point) void {
        raw.CGPathAddCurveToPoint(
            self.handle,
            null,
            control1.x,
            control1.y,
            control2.x,
            control2.y,
            end.x,
            end.y,
        );
    }

    /// Closes the current subpath with a line back to its start. Only a
    /// closed subpath has a join at that corner when stroked.
    pub fn closeSubpath(self: MutablePath) void {
        raw.CGPathCloseSubpath(self.handle);
    }

    pub fn addRect(self: MutablePath, area: Rect) void {
        raw.CGPathAddRect(self.handle, null, area.toRaw());
    }

    pub fn addRects(self: MutablePath, areas: []const Rect) void {
        raw.CGPathAddRects(self.handle, null, @ptrCast(areas.ptr), areas.len);
    }

    /// A connected series of line segments through `points`, as one
    /// subpath. Fewer than two points does nothing.
    pub fn addLines(self: MutablePath, points: []const Point) void {
        raw.CGPathAddLines(self.handle, null, @ptrCast(points.ptr), points.len);
    }

    pub fn addEllipseInRect(self: MutablePath, area: Rect) void {
        raw.CGPathAddEllipseInRect(self.handle, null, area.toRaw());
    }

    pub fn addRoundedRect(
        self: MutablePath,
        area: Rect,
        corner_width: Float,
        corner_height: Float,
    ) void {
        raw.CGPathAddRoundedRect(self.handle, null, area.toRaw(), corner_width, corner_height);
    }

    /// An arc of the circle at `center`. Angles are in radians and measured
    /// counter-clockwise from the positive x axis, in the path's own
    /// coordinate system -- which means that in a context that has been
    /// flipped, `clockwise` is visually the opposite of what it says.
    ///
    /// A line is drawn from the current point to the start of the arc, so
    /// call `moveTo` first if that is not wanted.
    pub fn addArc(
        self: MutablePath,
        center: Point,
        radius: Float,
        start_angle: Float,
        end_angle: Float,
        clockwise: bool,
    ) void {
        raw.CGPathAddArc(
            self.handle,
            null,
            center.x,
            center.y,
            radius,
            start_angle,
            end_angle,
            clockwise,
        );
    }

    /// An arc of `delta` radians from `start_angle`, which unlike `addArc`
    /// can wrap more than once around.
    pub fn addRelativeArc(
        self: MutablePath,
        center: Point,
        radius: Float,
        start_angle: Float,
        delta: Float,
    ) void {
        raw.CGPathAddRelativeArc(
            self.handle,
            null,
            center.x,
            center.y,
            radius,
            start_angle,
            delta,
        );
    }

    /// The arc of radius `radius` that is tangent to both the line from the
    /// current point to `corner` and the line from `corner` to `end`. This
    /// is how a rounded corner is drawn between two known segments.
    pub fn addArcToPoint(self: MutablePath, corner: Point, end: Point, radius: Float) void {
        raw.CGPathAddArcToPoint(self.handle, null, corner.x, corner.y, end.x, end.y, radius);
    }

    pub fn addPath(self: MutablePath, other: Path) void {
        raw.CGPathAddPath(self.handle, null, other.handle);
    }

    /// `other`, placed by `transform`. Useful for stamping the same shape
    /// in several positions without rebuilding it.
    pub fn addPathTransformed(
        self: MutablePath,
        other: Path,
        transform: AffineTransform,
    ) void {
        var matrix = transform.toRaw();
        raw.CGPathAddPath(self.handle, &matrix, other.handle);
    }

    // -- reading, without having to convert first ------------------------

    pub fn isEmpty(self: MutablePath) bool {
        return self.asPath().isEmpty();
    }

    pub fn currentPoint(self: MutablePath) Point {
        return self.asPath().currentPoint();
    }

    pub fn boundingBox(self: MutablePath) Rect {
        return self.asPath().boundingBox();
    }
};

test "a built path reports the elements it was given" {
    const path = try MutablePath.init();
    defer path.deinit();

    try std.testing.expect(path.isEmpty());

    path.moveTo(.init(0, 0));
    path.lineTo(.init(10, 0));
    path.curveTo(.init(10, 5), .init(5, 10), .init(0, 10));
    path.closeSubpath();

    try std.testing.expect(!path.isEmpty());

    const elements = try path.asPath().toOwnedElements(std.testing.allocator);
    defer std.testing.allocator.free(elements);

    try std.testing.expectEqual(@as(usize, 4), elements.len);
    try std.testing.expect(elements[0] == .move_to);
    try std.testing.expect(elements[1] == .line_to);
    try std.testing.expect(elements[2] == .curve_to);
    try std.testing.expect(elements[3] == .close_subpath);

    // The union only lets the right points be reached, and they are the
    // ones that went in.
    try std.testing.expectEqual(@as(Float, 10), elements[1].line_to.x);
    try std.testing.expectEqual(@as(Float, 5), elements[2].curve_to.control2.x);
    try std.testing.expect(elements[3].endPoint() == null);
}

test "a rectangle path knows it is a rectangle" {
    const area = Rect.init(1, 2, 30, 40);
    const path = try Path.initRect(area);
    defer path.deinit();

    try std.testing.expect(path.asRect().?.eql(area));
    try std.testing.expect(path.boundingBox().eql(area));

    const ellipse = try Path.initEllipse(area);
    defer ellipse.deinit();
    try std.testing.expect(ellipse.asRect() == null);
}

test "containment uses the fill rule it is given" {
    const path = try Path.initEllipse(.init(0, 0, 100, 100));
    defer path.deinit();

    try std.testing.expect(path.contains(.init(50, 50), false));
    // A corner of the bounding box is outside the inscribed ellipse.
    try std.testing.expect(!path.contains(.init(1, 1), false));
}

test "transforming a path moves its bounding box" {
    const path = try Path.initRect(.init(0, 0, 10, 10));
    defer path.deinit();

    const moved = try path.transformed(.translation(5, 7));
    defer moved.deinit();

    try std.testing.expect(moved.boundingBox().eql(Rect.init(5, 7, 10, 10)));
    try std.testing.expect(!moved.eql(path));
}

test "stroking turns an outline into a fillable shape" {
    const line = try MutablePath.init();
    defer line.deinit();
    line.moveTo(.init(0, 0));
    line.lineTo(.init(10, 0));

    const outline = try line.asPath().stroked(.{ .line_width = 4 });
    defer outline.deinit();

    // A zero-height line becomes a 4-unit-tall rectangle around it.
    const box = outline.boundingBox();
    try std.testing.expectApproxEqAbs(@as(Float, 4), box.height(), 1e-9);
    try std.testing.expect(outline.contains(.init(5, 0), false));
}

test "apply hands state through a pointer" {
    const path = try MutablePath.init();
    defer path.deinit();
    path.moveTo(.init(0, 0));
    path.lineTo(.init(3, 0));
    path.lineTo(.init(3, 4));

    var counter: struct { moves: usize = 0, lines: usize = 0 } = .{};
    path.asPath().apply(&counter, struct {
        fn each(state: *@TypeOf(counter), element: Element) void {
            switch (element) {
                .move_to => state.moves += 1,
                .line_to => state.lines += 1,
                else => {},
            }
        }
    }.each);

    try std.testing.expectEqual(@as(usize, 1), counter.moves);
    try std.testing.expectEqual(@as(usize, 2), counter.lines);
}
