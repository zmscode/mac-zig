//! Just enough CoreFoundation to work CoreGraphics.
//!
//! This is not a CoreFoundation binding. It covers the types that appear in
//! CoreGraphics signatures -- strings for colour space and font names, data
//! for image bytes, dictionaries for the options bags, arrays and numbers
//! for the window list -- and stops there. Anything else is in `cg.raw`.
//!
//! ## The one rule
//!
//! CoreFoundation's ownership rule is in the *name* of the call that gave
//! you the object:
//!
//! - a name with **Create** or **Copy** in it hands over a reference that is
//!   yours, and you must release it;
//! - a name with **Get** in it hands over a borrowed reference that is
//!   valid only as long as its owner is, and releasing it is a bug.
//!
//! This binding keeps the rule visible: anything with a `deinit` is yours,
//! and anything returned without one is borrowed. Where a borrowed value
//! needs to outlive its owner, `retain` makes it yours and pairs with
//! `deinit`.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("errors.zig");

const Error = errors.Error;

/// `kCFAllocatorDefault`, which is null and means "the default allocator".
/// CoreFoundation allocates its own memory; a Zig allocator never reaches
/// it. The allocator-taking calls in this module are the ones that copy
/// *out* of CoreFoundation and into memory you own.
const default_allocator: raw.CFAllocatorRef = null;

/// An untyped reference, for the calls that take or return `CFTypeRef`.
///
/// `extern` so that a `[]const Type` is laid out exactly like the C array of
/// pointers that `CFArrayCreate` wants, which is what lets `Array.init`
/// avoid a temporary allocation.
pub const Type = extern struct {
    handle: *const anyopaque,

    pub fn fromRaw(value: raw.CFTypeRef) ?Type {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Type) raw.CFTypeRef {
        return self.handle;
    }

    pub fn retain(self: Type) Type {
        return .{ .handle = raw.CFRetain(self.handle).? };
    }

    pub fn deinit(self: Type) void {
        raw.CFRelease(self.handle);
    }

    pub fn typeId(self: Type) raw.CFTypeID {
        return raw.CFGetTypeID(self.handle);
    }

    pub fn eql(self: Type, other: Type) bool {
        return raw.CFEqual(self.handle, other.handle) != 0;
    }

    /// The object as a `String`, the way `CFCopyDescription` renders it.
    /// Owned by the caller.
    pub fn description(self: Type) Error!String {
        return .{ .handle = try errors.checkPtr(raw.CFCopyDescription(self.handle)) };
    }

    /// The object as one of this module's types, or null when it is
    /// something else. This is how a value pulled out of a dictionary or an
    /// array gets narrowed, since those hold `CFTypeRef`.
    pub fn as(self: Type, comptime T: type) ?T {
        if (self.typeId() != T.typeId()) return null;
        return .{ .handle = @ptrCast(self.handle) };
    }
};

/// A UTF-16 string. `init` copies; the result is yours.
pub const String = struct {
    handle: *const raw.struct___CFString,

    pub fn typeId() raw.CFTypeID {
        return raw.CFStringGetTypeID();
    }

    /// Copies `text`, which must be valid UTF-8.
    pub fn init(text: []const u8) Error!String {
        const created = raw.CFStringCreateWithBytes(
            default_allocator,
            text.ptr,
            @intCast(text.len),
            raw.kCFStringEncodingUTF8,
            0,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: String) void {
        raw.CFRelease(self.handle);
    }

    pub fn retain(self: String) String {
        return .{ .handle = @ptrCast(raw.CFRetain(self.handle).?) };
    }

    pub fn asType(self: String) Type {
        return .{ .handle = self.handle };
    }

    pub fn fromRaw(value: raw.CFStringRef) ?String {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: String) raw.CFStringRef {
        return self.handle;
    }

    /// The length in UTF-16 code units, which is what CoreFoundation counts
    /// and is *not* the number of bytes a UTF-8 copy will need.
    pub fn length(self: String) usize {
        return @intCast(raw.CFStringGetLength(self.handle));
    }

    /// A UTF-8 copy in memory the caller owns.
    ///
    /// CoreFoundation will sometimes hand out a pointer to its own UTF-8
    /// bytes and sometimes refuse, depending on how the string was made, so
    /// this always copies rather than exposing a borrowed slice that is
    /// only sometimes available.
    pub fn toOwnedSlice(self: String, allocator: std.mem.Allocator) ![]u8 {
        const utf16_len = raw.CFStringGetLength(self.handle);
        const max = raw.CFStringGetMaximumSizeForEncoding(utf16_len, raw.kCFStringEncodingUTF8);
        const buffer = try allocator.alloc(u8, @intCast(max + 1));
        errdefer allocator.free(buffer);

        if (raw.CFStringGetCString(
            self.handle,
            buffer.ptr,
            @intCast(buffer.len),
            raw.kCFStringEncodingUTF8,
        ) == 0) return Error.Failed;

        const len = std.mem.indexOfScalar(u8, buffer, 0) orelse buffer.len;
        return allocator.realloc(buffer, len);
    }
};

/// An immutable byte buffer. This is what an encoded PNG comes back as and
/// what a decoder is handed.
pub const Data = struct {
    handle: *const raw.struct___CFData,

    pub fn typeId() raw.CFTypeID {
        return raw.CFDataGetTypeID();
    }

    /// Copies `contents`.
    pub fn init(contents: []const u8) Error!Data {
        const created = raw.CFDataCreate(default_allocator, contents.ptr, @intCast(contents.len));
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Data) void {
        raw.CFRelease(self.handle);
    }

    pub fn retain(self: Data) Data {
        return .{ .handle = @ptrCast(raw.CFRetain(self.handle).?) };
    }

    pub fn asType(self: Data) Type {
        return .{ .handle = self.handle };
    }

    pub fn fromRaw(value: raw.CFDataRef) ?Data {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Data) raw.CFDataRef {
        return self.handle;
    }

    /// The bytes, borrowed from CoreFoundation. Valid until this `Data` is
    /// released; copy them if they need to outlive it.
    pub fn bytes(self: Data) []const u8 {
        const len: usize = @intCast(raw.CFDataGetLength(self.handle));
        const base = raw.CFDataGetBytePtr(self.handle);
        if (base == null or len == 0) return &.{};
        return base[0..len];
    }
};

/// A growable byte buffer. An encoder writes into one of these when the
/// destination is memory rather than a file.
pub const MutableData = struct {
    handle: *raw.struct___CFData,

    /// `capacity` of 0 means unbounded.
    pub fn init(capacity: usize) Error!MutableData {
        const created = raw.CFDataCreateMutable(default_allocator, @intCast(capacity));
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: MutableData) void {
        raw.CFRelease(self.handle);
    }

    pub fn append(self: MutableData, extra: []const u8) void {
        raw.CFDataAppendBytes(self.handle, extra.ptr, @intCast(extra.len));
    }

    /// The same buffer seen as immutable. Borrowed, not a copy -- do not
    /// `deinit` the result.
    pub fn asData(self: MutableData) Data {
        return .{ .handle = self.handle };
    }

    pub fn bytes(self: MutableData) []const u8 {
        return self.asData().bytes();
    }

    pub inline fn toRaw(self: MutableData) raw.CFMutableDataRef {
        return self.handle;
    }
};

/// A boxed number. CoreFoundation stores the width it was given and
/// converts on the way out, so a value written as an integer reads back as
/// a float without complaint.
pub const Number = struct {
    handle: *const raw.struct___CFNumber,

    pub fn typeId() raw.CFTypeID {
        return raw.CFNumberGetTypeID();
    }

    pub fn initInt(value: i64) Error!Number {
        var storage = value;
        const created = raw.CFNumberCreate(default_allocator, raw.kCFNumberSInt64Type, &storage);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn initFloat(value: f64) Error!Number {
        var storage = value;
        const created = raw.CFNumberCreate(default_allocator, raw.kCFNumberDoubleType, &storage);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Number) void {
        raw.CFRelease(self.handle);
    }

    pub fn asType(self: Number) Type {
        return .{ .handle = self.handle };
    }

    pub fn fromRaw(value: raw.CFNumberRef) ?Number {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Number) raw.CFNumberRef {
        return self.handle;
    }

    /// True when the value was stored as a float. Reading an integer out of
    /// one of those truncates.
    pub fn isFloat(self: Number) bool {
        return raw.CFNumberIsFloatType(self.handle) != 0;
    }

    pub fn toInt(self: Number) i64 {
        var value: i64 = 0;
        _ = raw.CFNumberGetValue(self.handle, raw.kCFNumberSInt64Type, &value);
        return value;
    }

    pub fn toFloat(self: Number) f64 {
        var value: f64 = 0;
        _ = raw.CFNumberGetValue(self.handle, raw.kCFNumberDoubleType, &value);
        return value;
    }
};

/// One of the two shared boolean singletons. There is nothing to release.
pub const Boolean = struct {
    handle: *const raw.struct___CFBoolean,

    pub fn typeId() raw.CFTypeID {
        return raw.CFBooleanGetTypeID();
    }

    pub fn of(flag: bool) Boolean {
        return .{ .handle = (if (flag) raw.kCFBooleanTrue else raw.kCFBooleanFalse).? };
    }

    pub fn value(self: Boolean) bool {
        return raw.CFBooleanGetValue(self.handle) != 0;
    }

    pub fn asType(self: Boolean) Type {
        return .{ .handle = self.handle };
    }

    pub inline fn toRaw(self: Boolean) raw.CFBooleanRef {
        return self.handle;
    }
};

/// An ordered collection of `CFTypeRef`. Mostly encountered as a return
/// value -- the window list, the components of a path -- rather than built.
pub const Array = struct {
    handle: *const raw.struct___CFArray,

    pub fn typeId() raw.CFTypeID {
        return raw.CFArrayGetTypeID();
    }

    /// Retains each value, as CoreFoundation's type callbacks do. The
    /// slice is handed straight to CoreFoundation -- `Type` is a single
    /// pointer, so there is nothing to marshal.
    pub fn init(values: []const Type) Error!Array {
        const created = raw.CFArrayCreate(
            default_allocator,
            @ptrCast(@constCast(values.ptr)),
            @intCast(values.len),
            &raw.kCFTypeArrayCallBacks,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Array) void {
        raw.CFRelease(self.handle);
    }

    pub fn asType(self: Array) Type {
        return .{ .handle = self.handle };
    }

    pub fn fromRaw(value: raw.CFArrayRef) ?Array {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Array) raw.CFArrayRef {
        return self.handle;
    }

    pub fn count(self: Array) usize {
        return @intCast(raw.CFArrayGetCount(self.handle));
    }

    /// The element at `index`, borrowed from the array. Null when `index`
    /// is out of range, which is a bounds check CoreFoundation does not do.
    pub fn at(self: Array, index: usize) ?Type {
        if (index >= self.count()) return null;
        return Type.fromRaw(raw.CFArrayGetValueAtIndex(self.handle, @intCast(index)));
    }

    /// Walks the array in order.
    pub fn iterator(self: Array) Iterator {
        return .{ .array = self, .index = 0 };
    }

    pub const Iterator = struct {
        array: Array,
        index: usize,

        pub fn next(self: *Iterator) ?Type {
            if (self.index >= self.array.count()) return null;
            defer self.index += 1;
            return self.array.at(self.index);
        }
    };
};

/// A keyed collection of `CFTypeRef`, which is how every CoreGraphics and
/// ImageIO options bag is spelled.
pub const Dictionary = struct {
    handle: *const raw.struct___CFDictionary,

    pub const Pair = struct {
        key: Type,
        value: Type,
    };

    pub fn typeId() raw.CFTypeID {
        return raw.CFDictionaryGetTypeID();
    }

    /// Retains each key and value. The dictionary is yours; the things you
    /// put in it still need their own `deinit`.
    ///
    /// `allocator` is for the two parallel arrays CoreFoundation wants and
    /// nothing else -- both are freed before this returns, and no Zig
    /// memory reaches CoreFoundation.
    pub fn init(
        allocator: std.mem.Allocator,
        pairs: []const Pair,
    ) (Error || std.mem.Allocator.Error)!Dictionary {
        const scratch = try allocator.alloc(?*const anyopaque, pairs.len * 2);
        defer allocator.free(scratch);

        const keys = scratch[0..pairs.len];
        const values = scratch[pairs.len..];
        for (pairs, keys, values) |pair, *key_slot, *value_slot| {
            key_slot.* = pair.key.handle;
            value_slot.* = pair.value.handle;
        }

        const created = raw.CFDictionaryCreate(
            default_allocator,
            keys.ptr,
            values.ptr,
            @intCast(pairs.len),
            &raw.kCFTypeDictionaryKeyCallBacks,
            &raw.kCFTypeDictionaryValueCallBacks,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// A dictionary of a comptime-known number of pairs, built on the
    /// stack. `pairs` is a tuple or array of `Pair`:
    ///
    /// ```zig
    /// const options = try cf.Dictionary.initFixed(.{
    ///     .{ .key = quality_key, .value = quality.asType() },
    /// });
    /// ```
    pub fn initFixed(pairs: anytype) Error!Dictionary {
        const n = @typeInfo(@TypeOf(pairs)).@"struct".field_names.len;
        var keys: [n]?*const anyopaque = undefined;
        var values: [n]?*const anyopaque = undefined;

        inline for (pairs, 0..) |pair, i| {
            keys[i] = pair.key.handle;
            values[i] = pair.value.handle;
        }

        const created = raw.CFDictionaryCreate(
            default_allocator,
            &keys,
            &values,
            n,
            &raw.kCFTypeDictionaryKeyCallBacks,
            &raw.kCFTypeDictionaryValueCallBacks,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Dictionary) void {
        raw.CFRelease(self.handle);
    }

    pub fn asType(self: Dictionary) Type {
        return .{ .handle = self.handle };
    }

    pub fn fromRaw(value: raw.CFDictionaryRef) ?Dictionary {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Dictionary) raw.CFDictionaryRef {
        return self.handle;
    }

    pub fn count(self: Dictionary) usize {
        return @intCast(raw.CFDictionaryGetCount(self.handle));
    }

    /// The value for `key`, borrowed from the dictionary.
    pub fn get(self: Dictionary, key: Type) ?Type {
        return Type.fromRaw(raw.CFDictionaryGetValue(self.handle, key.handle));
    }

    /// The value for a string key, narrowed to `T` -- `null` when the key
    /// is absent *or* holds something else. This is the shape most reads of
    /// a CoreGraphics dictionary want, and it collapses the three-step
    /// lookup-then-typecheck-then-cast the C version needs.
    pub fn getAs(self: Dictionary, comptime T: type, key: raw.CFStringRef) ?T {
        const found = Type.fromRaw(raw.CFDictionaryGetValue(self.handle, key)) orelse return null;
        return found.as(T);
    }

    /// Shorthand for a numeric entry read as an integer.
    pub fn getInt(self: Dictionary, key: raw.CFStringRef) ?i64 {
        return (self.getAs(Number, key) orelse return null).toInt();
    }

    /// Shorthand for a numeric entry read as a float.
    pub fn getFloat(self: Dictionary, key: raw.CFStringRef) ?f64 {
        return (self.getAs(Number, key) orelse return null).toFloat();
    }

    pub fn getBool(self: Dictionary, key: raw.CFStringRef) ?bool {
        return (self.getAs(Boolean, key) orelse return null).value();
    }

    /// Looks a value up by a plain Zig string key, narrowed to `T`.
    ///
    /// Slower than `getAs`, because CoreFoundation needs a `CFString` to
    /// look up with and one is made and released here. Use it for the
    /// frameworks whose dictionary keys are plain C strings -- IOKit's
    /// are -- and `getAs` where a `CFStringRef` constant already exists.
    pub fn lookup(self: Dictionary, comptime T: type, key: []const u8) Error!?T {
        const cf_key = try String.init(key);
        defer cf_key.deinit();
        return self.getAs(T, cf_key.toRaw());
    }

    pub fn lookupInt(self: Dictionary, key: []const u8) Error!?i64 {
        return (try self.lookup(Number, key) orelse return null).toInt();
    }

    pub fn lookupFloat(self: Dictionary, key: []const u8) Error!?f64 {
        return (try self.lookup(Number, key) orelse return null).toFloat();
    }

    pub fn lookupBool(self: Dictionary, key: []const u8) Error!?bool {
        return (try self.lookup(Boolean, key) orelse return null).value();
    }

    /// A UTF-8 copy of a string entry found by a plain Zig string key.
    pub fn lookupString(
        self: Dictionary,
        allocator: std.mem.Allocator,
        key: []const u8,
    ) ![]u8 {
        const found = try self.lookup(String, key) orelse return Error.Failed;
        return found.toOwnedSlice(allocator);
    }

    /// True when a string entry holds exactly `expected`. This is how
    /// IOKit's enumerated values -- "AC Power", "InternalBattery" -- are
    /// compared without allocating.
    pub fn lookupStringEquals(
        self: Dictionary,
        key: []const u8,
        expected: []const u8,
    ) Error!bool {
        const found = try self.lookup(String, key) orelse return false;
        const wanted = try String.init(expected);
        defer wanted.deinit();
        return raw.CFEqual(found.handle, wanted.handle) != 0;
    }

    /// A UTF-8 copy of a string entry, in memory the caller owns.
    pub fn getString(
        self: Dictionary,
        allocator: std.mem.Allocator,
        key: raw.CFStringRef,
    ) !?[]u8 {
        const found = self.getAs(String, key) orelse return null;
        return try found.toOwnedSlice(allocator);
    }
};

/// A URL, needed because the file-writing side of ImageIO and the PDF
/// context take one rather than a path.
pub const Url = struct {
    handle: *const raw.struct___CFURL,

    pub fn typeId() raw.CFTypeID {
        return raw.CFURLGetTypeID();
    }

    /// A `file://` URL for a filesystem path, which may be relative.
    pub fn initFilePath(path: []const u8) Error!Url {
        const text = try String.init(path);
        defer text.deinit();

        const created = raw.CFURLCreateWithFileSystemPath(
            default_allocator,
            text.handle,
            raw.kCFURLPOSIXPathStyle,
            0,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Url) void {
        raw.CFRelease(self.handle);
    }

    pub fn asType(self: Url) Type {
        return .{ .handle = self.handle };
    }

    pub inline fn toRaw(self: Url) raw.CFURLRef {
        return self.handle;
    }
};

test "a string survives a round trip through CoreFoundation" {
    const text = try String.init("hello, τ world");
    defer text.deinit();

    const copy = try text.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(copy);

    try std.testing.expectEqualStrings("hello, τ world", copy);
    // Two UTF-16 code units fewer than the UTF-8 byte count, because of τ.
    try std.testing.expectEqual(@as(usize, 14), text.length());
}

test "numbers remember whether they were stored as floats" {
    const whole = try Number.initInt(42);
    defer whole.deinit();
    try std.testing.expect(!whole.isFloat());
    try std.testing.expectEqual(@as(i64, 42), whole.toInt());
    try std.testing.expectEqual(@as(f64, 42), whole.toFloat());

    const fractional = try Number.initFloat(1.5);
    defer fractional.deinit();
    try std.testing.expect(fractional.isFloat());
    try std.testing.expectEqual(@as(f64, 1.5), fractional.toFloat());
}

test "a dictionary narrows its values by type" {
    const key = try String.init("count");
    defer key.deinit();
    const value = try Number.initInt(7);
    defer value.deinit();

    const dict = try Dictionary.init(
        std.testing.allocator,
        &.{.{ .key = key.asType(), .value = value.asType() }},
    );
    defer dict.deinit();

    try std.testing.expectEqual(@as(usize, 1), dict.count());
    try std.testing.expectEqual(@as(i64, 7), dict.getInt(key.toRaw()).?);
    // Present, but not a string -- so `null` rather than a wrong answer.
    try std.testing.expect(dict.getAs(String, key.toRaw()) == null);
}

test "an array bounds-checks where CoreFoundation does not" {
    const first = try Number.initInt(1);
    defer first.deinit();
    const second = try Number.initInt(2);
    defer second.deinit();

    const array = try Array.init(&.{ first.asType(), second.asType() });
    defer array.deinit();

    try std.testing.expectEqual(@as(usize, 2), array.count());
    try std.testing.expect(array.at(5) == null);

    var total: i64 = 0;
    var it = array.iterator();
    while (it.next()) |item| total += item.as(Number).?.toInt();
    try std.testing.expectEqual(@as(i64, 3), total);
}

test "data borrows its bytes from CoreFoundation" {
    const data = try Data.init("png bytes");
    defer data.deinit();
    try std.testing.expectEqualStrings("png bytes", data.bytes());
}
