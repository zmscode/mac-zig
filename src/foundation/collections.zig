//! `NSArray`, `NSMutableArray`, `NSDictionary` and `NSMutableDictionary`,
//! typed by what they hold.
//!
//! `Array(String)` hands back `String`s; `Dictionary(String, Number)` maps
//! one to the other. Nothing checks at run time that an array made
//! elsewhere really holds what its type says -- `from` is a cast -- but
//! everything made here does, by construction.
//!
//! Elements are `objc.Object` or a wrapper declared as an `extern struct`
//! with one `objc.Object` field, like every type in `foundation`. That is
//! what lets a `[]const T` go to Foundation as the C array of object
//! pointers it wants, with no copying.
//!
//! Indexing is bounds-checked here: `at` answers null, and the mutating
//! calls assert, rather than letting Foundation raise an exception.

const std = @import("std");
const objc = @import("../objc/objc.zig");
const generated = @import("generated.zig");

const Object = objc.Object;

fn checkElement(comptime T: type) void {
    const ok = T == Object or (objc.abi.isObject(T) and @typeInfo(T).@"struct".layout == .@"extern");
    if (!ok) @compileError(@typeName(T) ++ " cannot be a collection element: use objc.Object, " ++
        "or an `extern struct` whose only field is an objc.Object");
}

fn raw(comptime T: type, item: T) Object {
    return objc.abi.unwrap(item);
}

/// An immutable, ordered collection of `T`.
pub fn Array(comptime T: type) type {
    checkElement(T);
    return extern struct {
        object: Object,

        const Self = @This();
        pub const Element = T;

        pub fn class() objc.Class {
            return objc.getClass("NSArray").?;
        }

        /// Every method `NSArray` has, as the generated wrapper for the same
        /// object -- whose elements are untyped `objc.Object`s.
        pub fn all(self: Self) generated.Array {
            return .from(self.object);
        }

        /// An array holding `items`, each retained. Yours.
        pub fn init(items: []const T) Self {
            return class().msgSend(Object, "alloc", .{}).msgSend(Self, "initWithObjects:count:", .{
                @as([*]const T, items.ptr),
                @as(objc.UInteger, items.len),
            });
        }

        /// An array that came from elsewhere, taken to hold `T`.
        pub fn from(object: Object) Self {
            return .{ .object = object };
        }

        pub fn deinit(self: Self) void {
            self.object.release();
        }

        pub fn retain(self: Self) Self {
            return .{ .object = self.object.retain() };
        }

        pub fn autorelease(self: Self) Self {
            return .{ .object = self.object.autorelease() };
        }

        pub fn count(self: Self) usize {
            return self.object.msgSend(objc.UInteger, "count", .{});
        }

        /// The element at `index`, borrowed from the array, or null when
        /// `index` is out of range.
        pub fn at(self: Self, index: usize) ?T {
            if (index >= self.count()) return null;
            return self.object.msgSend(T, "objectAtIndex:", .{@as(objc.UInteger, index)});
        }

        pub fn first(self: Self) ?T {
            return self.object.msgSend(?T, "firstObject", .{});
        }

        pub fn last(self: Self) ?T {
            return self.object.msgSend(?T, "lastObject", .{});
        }

        /// Whether an element `isEqual:` to `item` is here.
        pub fn contains(self: Self, item: T) bool {
            return self.object.msgSend(bool, "containsObject:", .{raw(T, item)});
        }

        /// The index of the first element `isEqual:` to `item`.
        pub fn indexOf(self: Self, item: T) ?usize {
            const index = self.object.msgSend(objc.UInteger, "indexOfObject:", .{raw(T, item)});
            return if (index == objc.Range.not_found) null else index;
        }

        /// The elements, copied into memory the caller owns. The objects
        /// themselves are not retained.
        pub fn toOwnedSlice(self: Self, allocator: std.mem.Allocator) ![]T {
            const items = try allocator.alloc(T, self.count());
            self.object.msgSend(void, "getObjects:range:", .{
                @as([*]T, items.ptr),
                objc.Range{ .location = 0, .length = items.len },
            });
            return items;
        }

        /// A sorted copy, ordered by `order`. Autoreleased.
        pub fn sorted(self: Self, comptime order: fn (T, T) std.math.Order) Self {
            const Compare = objc.Block(struct {}, fn (T, T) objc.Integer);
            var comparator = Compare.init(.{}, struct {
                fn body(_: *const Compare.Captures, a: T, b: T) objc.Integer {
                    return switch (order(a, b)) {
                        .lt => -1,
                        .eq => 0,
                        .gt => 1,
                    };
                }
            }.body);
            return self.object.msgSend(Self, "sortedArrayUsingComparator:", .{&comparator});
        }

        pub fn iterator(self: Self) Iterator {
            return .{ .array = self, .index = 0, .end = self.count() };
        }

        pub const Iterator = struct {
            array: Self,
            index: usize,
            end: usize,

            pub fn next(it: *Iterator) ?T {
                if (it.index >= it.end) return null;
                defer it.index += 1;
                return it.array.object.msgSend(T, "objectAtIndex:", .{@as(objc.UInteger, it.index)});
            }
        };
    };
}

/// A growable, ordered collection of `T`.
pub fn MutableArray(comptime T: type) type {
    checkElement(T);
    return extern struct {
        object: Object,

        const Self = @This();

        pub fn class() objc.Class {
            return objc.getClass("NSMutableArray").?;
        }

        /// Every method `NSMutableArray` has, as the generated wrapper for the same
        /// object -- whose elements are untyped `objc.Object`s.
        pub fn all(self: Self) generated.MutableArray {
            return .from(self.object);
        }

        /// An empty array with room for `capacity` without growing. Yours.
        pub fn init(capacity: usize) Self {
            return class().msgSend(Object, "alloc", .{})
                .msgSend(Self, "initWithCapacity:", .{@as(objc.UInteger, capacity)});
        }

        pub fn from(object: Object) Self {
            return .{ .object = object };
        }

        pub fn deinit(self: Self) void {
            self.object.release();
        }

        pub fn retain(self: Self) Self {
            return .{ .object = self.object.retain() };
        }

        /// The same array, seen as immutable -- for reading, and for
        /// passing wherever an `Array(T)` is taken.
        pub fn asArray(self: Self) Array(T) {
            return .{ .object = self.object };
        }

        pub fn count(self: Self) usize {
            return self.asArray().count();
        }

        pub fn at(self: Self, index: usize) ?T {
            return self.asArray().at(index);
        }

        pub fn iterator(self: Self) Array(T).Iterator {
            return self.asArray().iterator();
        }

        /// Adds `item` at the end, retaining it.
        pub fn append(self: Self, item: T) void {
            self.object.msgSend(void, "addObject:", .{raw(T, item)});
        }

        /// Adds `item` at `index`, which is at most `count()`.
        pub fn insert(self: Self, index: usize, item: T) void {
            std.debug.assert(index <= self.count());
            self.object.msgSend(void, "insertObject:atIndex:", .{ raw(T, item), @as(objc.UInteger, index) });
        }

        /// Removes the element at `index`, which is less than `count()`.
        pub fn orderedRemove(self: Self, index: usize) void {
            std.debug.assert(index < self.count());
            self.object.msgSend(void, "removeObjectAtIndex:", .{@as(objc.UInteger, index)});
        }

        pub fn clearRetainingCapacity(self: Self) void {
            self.object.msgSend(void, "removeAllObjects", .{});
        }
    };
}

/// An immutable map from `K` to `V`. Keys are copied in, so they must
/// adopt `NSCopying`: strings and numbers do.
pub fn Dictionary(comptime K: type, comptime V: type) type {
    checkElement(K);
    checkElement(V);
    return extern struct {
        object: Object,

        const Self = @This();

        pub fn class() objc.Class {
            return objc.getClass("NSDictionary").?;
        }

        /// Every method `NSDictionary` has, as the generated wrapper for the same
        /// object -- whose elements are untyped `objc.Object`s.
        pub fn all(self: Self) generated.Dictionary {
            return .from(self.object);
        }

        /// A dictionary mapping `key_items[i]` to `value_items[i]`. The two slices
        /// must be the same length. Yours.
        pub fn init(key_items: []const K, value_items: []const V) Self {
            std.debug.assert(key_items.len == value_items.len);
            return class().msgSend(Object, "alloc", .{}).msgSend(Self, "initWithObjects:forKeys:count:", .{
                @as([*]const V, value_items.ptr),
                @as([*]const K, key_items.ptr),
                @as(objc.UInteger, key_items.len),
            });
        }

        pub fn from(object: Object) Self {
            return .{ .object = object };
        }

        pub fn deinit(self: Self) void {
            self.object.release();
        }

        pub fn retain(self: Self) Self {
            return .{ .object = self.object.retain() };
        }

        pub fn count(self: Self) usize {
            return self.object.msgSend(objc.UInteger, "count", .{});
        }

        /// The value for `key`, borrowed from the dictionary.
        pub fn get(self: Self, key: K) ?V {
            return self.object.msgSend(?V, "objectForKey:", .{raw(K, key)});
        }

        pub fn contains(self: Self, key: K) bool {
            return self.get(key) != null;
        }

        /// The keys, in no particular order. Autoreleased.
        pub fn keys(self: Self) Array(K) {
            return self.object.msgSend(Array(K), "allKeys", .{});
        }

        /// The values, in the order of `keys`. Autoreleased.
        pub fn values(self: Self) Array(V) {
            return self.object.msgSend(Array(V), "allValues", .{});
        }

        pub const Entry = struct { key: K, value: V };

        /// Walks the entries, in no particular order. Takes one
        /// autoreleased array of keys, so run it inside a pool.
        pub fn iterator(self: Self) Iterator {
            return .{ .dictionary = self, .keys = self.keys().iterator() };
        }

        pub const Iterator = struct {
            dictionary: Self,
            keys: Array(K).Iterator,

            pub fn next(it: *Iterator) ?Entry {
                const key = it.keys.next() orelse return null;
                return .{ .key = key, .value = it.dictionary.get(key).? };
            }
        };
    };
}

/// A map from `K` to `V` that can change.
pub fn MutableDictionary(comptime K: type, comptime V: type) type {
    checkElement(K);
    checkElement(V);
    return extern struct {
        object: Object,

        const Self = @This();

        pub fn class() objc.Class {
            return objc.getClass("NSMutableDictionary").?;
        }

        /// Every method `NSMutableDictionary` has, as the generated wrapper for the same
        /// object -- whose elements are untyped `objc.Object`s.
        pub fn all(self: Self) generated.MutableDictionary {
            return .from(self.object);
        }

        /// An empty dictionary. Yours.
        pub fn init(capacity: usize) Self {
            return class().msgSend(Object, "alloc", .{})
                .msgSend(Self, "initWithCapacity:", .{@as(objc.UInteger, capacity)});
        }

        pub fn from(object: Object) Self {
            return .{ .object = object };
        }

        pub fn deinit(self: Self) void {
            self.object.release();
        }

        pub fn asDictionary(self: Self) Dictionary(K, V) {
            return .{ .object = self.object };
        }

        pub fn count(self: Self) usize {
            return self.asDictionary().count();
        }

        pub fn get(self: Self, key: K) ?V {
            return self.asDictionary().get(key);
        }

        /// Maps `key` to `value`, replacing what was there. The key is
        /// copied and the value retained.
        pub fn put(self: Self, key: K, value: V) void {
            self.object.msgSend(void, "setObject:forKey:", .{ raw(V, value), raw(K, key) });
        }

        /// Removes `key`, if it is there.
        pub fn remove(self: Self, key: K) void {
            self.object.msgSend(void, "removeObjectForKey:", .{raw(K, key)});
        }
    };
}

const String = @import("string.zig").String;
const Number = @import("number.zig").Number;

test "an array of strings" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const words = Array(String).init(&.{ .literal("b"), .literal("c"), .literal("a") });
    defer words.deinit();

    try std.testing.expectEqual(@as(usize, 3), words.count());
    try std.testing.expect(words.at(0).?.eql(.literal("b")));
    try std.testing.expect(words.at(3) == null);
    try std.testing.expectEqual(@as(?usize, 1), words.indexOf(.literal("c")));
    try std.testing.expect(!words.contains(.literal("z")));

    const alphabetical = words.sorted(struct {
        fn order(a: String, b: String) std.math.Order {
            return std.mem.order(u8, a.utf8(), b.utf8());
        }
    }.order);
    var joined: [3]u8 = undefined;
    var it = alphabetical.iterator();
    var i: usize = 0;
    while (it.next()) |word| : (i += 1) joined[i] = word.utf8()[0];
    try std.testing.expectEqualStrings("abc", &joined);

    const copy = try words.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(copy);
    try std.testing.expect(copy[2].eql(.literal("a")));
}

test "a mutable array" {
    const numbers = MutableArray(Number).init(0);
    defer numbers.deinit();

    for (0..4) |n| {
        const boxed = Number.initInt(@intCast(n));
        defer boxed.deinit();
        numbers.append(boxed);
    }
    numbers.orderedRemove(0);
    const ten = Number.initInt(10);
    defer ten.deinit();
    numbers.insert(0, ten);

    var total: i64 = 0;
    var it = numbers.iterator();
    while (it.next()) |n| total += n.toInt();
    try std.testing.expectEqual(@as(i64, 10 + 1 + 2 + 3), total);

    numbers.clearRetainingCapacity();
    try std.testing.expectEqual(@as(usize, 0), numbers.count());
}

test "dictionaries" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const one = Number.initInt(1);
    defer one.deinit();
    const two = Number.initInt(2);
    defer two.deinit();

    const fixed = Dictionary(String, Number).init(&.{ .literal("one"), .literal("two") }, &.{ one, two });
    defer fixed.deinit();
    try std.testing.expectEqual(@as(i64, 2), fixed.get(.literal("two")).?.toInt());
    try std.testing.expect(fixed.get(.literal("three")) == null);

    var total: i64 = 0;
    var it = fixed.iterator();
    while (it.next()) |entry| total += entry.value.toInt();
    try std.testing.expectEqual(@as(i64, 3), total);

    const growing = MutableDictionary(String, Number).init(0);
    defer growing.deinit();
    growing.put(.literal("x"), one);
    growing.put(.literal("x"), two);
    try std.testing.expectEqual(@as(usize, 1), growing.count());
    try std.testing.expectEqual(@as(i64, 2), growing.get(.literal("x")).?.toInt());
    growing.remove(.literal("x"));
    try std.testing.expect(growing.get(.literal("x")) == null);
}
