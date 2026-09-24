//! Defining an Objective-C class as a Zig struct.
//!
//! ```zig
//! const Counter = objc.Subclass(.{ .name = "MyCounter" }, struct {
//!     count: objc.Integer = 0,
//!     history: std.ArrayList(objc.Integer) = .empty,
//!
//!     pub fn increment(self: *@This()) void {
//!         self.count += 1;
//!     }
//!
//!     pub fn @"add:"(self: *@This(), amount: objc.Integer) objc.Integer {
//!         self.count += amount;
//!         return self.count;
//!     }
//!
//!     pub fn deinit(self: *@This()) void {
//!         self.history.deinit(allocator);
//!     }
//! });
//!
//! const counter = Counter.new();
//! defer counter.release();
//! _ = counter.msgSend(objc.Integer, "add:", .{@as(objc.Integer, 2)});
//! counter.state().count; // 2
//! ```
//!
//! The struct is the class's state: its fields live inside every instance,
//! set to their default values when the instance is allocated, and its
//! `deinit` runs when the instance is freed. Every `pub fn` whose first
//! parameter is a receiver becomes a method, named by the function -- use
//! `@"name:with:"` for a selector with colons. The receiver may be:
//!
//! | First parameter            | Kind            | What it is                   |
//! | -------------------------- | --------------- | ---------------------------- |
//! | `*State` / `*const State`  | instance method | the instance's state         |
//! | the `Subclass` type itself | instance method | the instance, typed          |
//! | `objc.Object`              | instance method | the instance, untyped        |
//! | `objc.Class`               | class method    | the class                    |
//!
//! There is no `_cmd` parameter. Any other `pub` declaration is left alone,
//! so helpers are free to live in the struct.
//!
//! Zig does not let a field and a function share a name, so a getter for a
//! field has to be named differently from it: a `count` method over a
//! `total` field, not over a `count` field.
//!
//! The class is registered with the runtime the first time `class()` is
//! called -- by `new`, or by anything else that needs it -- and once only,
//! even with several threads racing to be first.

const std = @import("std");
const raw = @import("mac_raw");
const abi = @import("abi.zig");
const encoding = @import("encoding.zig");
const message = @import("message.zig");
const sel = @import("sel.zig");

const Object = @import("object.zig").Object;
const class_ = @import("class.zig");
const Class = class_.Class;
const Sel = sel.Sel;
const protocol = @import("protocol.zig");

pub const Options = struct {
    /// The class's name, which is process-wide. Prefix it so that it will
    /// not collide with anyone else's.
    name: [:0]const u8,
    /// The class to inherit from, by name. It must be loaded -- an AppKit
    /// class needs AppKit linked.
    superclass: [:0]const u8 = "NSObject",
    /// Protocols the class adopts, by name. The methods are up to the
    /// struct.
    protocols: []const [:0]const u8 = &.{},
};

/// An Objective-C class whose instance state is `State_`. See the top of
/// this file.
pub fn Subclass(comptime options: Options, comptime State_: type) type {
    // `extern` so that a slice of them is a C array of object pointers,
    // which is what lets one go in a `foundation.Array`.
    return extern struct {
        object: Object,

        const Self = @This();

        pub const State = State_;
        pub const name = options.name;

        const ivar_name = "zig_state";

        /// Every field's default value, applied when an instance is
        /// allocated. The runtime would otherwise leave zeroes, which is
        /// not a valid value of most Zig types.
        const initial: State = blk: {
            const info = @typeInfo(State).@"struct";
            for (info.field_names, info.field_attrs) |field, attrs| {
                if (attrs.default_value_ptr == null) @compileError(
                    "field '" ++ field ++ "' of " ++ options.name ++ "'s state needs a default " ++
                        "value: the runtime allocates the instance, so there is nowhere else " ++
                        "for its first value to come from",
                );
            }
            break :blk .{};
        };

        // Set once, by `register`, before `registered` is published.
        var registered: ?*raw.struct_objc_class = null;
        var state_offset: usize = undefined;

        /// The class, registered with the runtime on first use.
        pub fn class() Class {
            if (@atomicLoad(?*raw.struct_objc_class, &registered, .acquire)) |value| {
                return .{ .value = value };
            }
            return register();
        }

        /// An uninitialised instance, for an `init...` message --
        /// `View.alloc().msgSend(View, "initWithFrame:", .{frame})`. The
        /// state already has its defaults. Yours to `release`.
        pub fn alloc() Self {
            return class().msgSend(Self, "alloc", .{});
        }

        /// `[[Class alloc] init]`: a new instance, which is yours to
        /// `release`.
        pub fn new() Self {
            return class().msgSend(Self, "new", .{});
        }

        /// The instance's Zig state, inside the object.
        pub fn state(self: Self) *State {
            return @ptrFromInt(@intFromPtr(self.object.value) + state_offset);
        }

        /// The instance whose state this is.
        pub fn fromState(state_pointer: *const State) Self {
            return .{ .object = .{ .value = @ptrFromInt(@intFromPtr(state_pointer) - state_offset) } };
        }

        pub inline fn msgSend(self: Self, comptime Return: type, selector: anytype, args: anytype) Return {
            return self.object.msgSend(Return, selector, args);
        }

        pub fn retain(self: Self) Self {
            return .{ .object = self.object.retain() };
        }

        pub fn release(self: Self) void {
            self.object.release();
        }

        pub fn autorelease(self: Self) Self {
            return .{ .object = self.object.autorelease() };
        }

        fn register() Class {
            const superclass = class_.getClass(options.superclass) orelse std.debug.panic(
                "{s}: superclass {s} is not loaded -- is its framework linked?",
                .{ options.name, options.superclass },
            );

            const cls = class_.allocateClassPair(superclass, options.name) catch
                return adoptExisting();

            cls.addIvar(State, ivar_name) catch
                std.debug.panic("{s}: could not add its state", .{options.name});

            inline for (@typeInfo(State).@"struct".decl_names) |decl| {
                const Receiver = receiverOf(decl);
                if (Receiver == Class) {
                    addMethod(cls.metaclass(), decl);
                } else if (Receiver != void) {
                    addMethod(cls, decl);
                }
            }

            cls.metaclass().addMethod("allocWithZone:", allocWithZone) catch
                std.debug.panic("{s}: defines allocWithZone: itself, which Subclass needs", .{options.name});
            cls.addMethod("dealloc", dealloc) catch
                std.debug.panic("{s}: defines dealloc; put cleanup in deinit instead", .{options.name});

            for (options.protocols) |protocol_name| {
                const adopted = protocol.getProtocol(protocol_name) orelse std.debug.panic(
                    "{s}: protocol {s} is not loaded -- is its framework linked?",
                    .{ options.name, protocol_name },
                );
                cls.addProtocol(adopted) catch {};
            }

            class_.registerClassPair(cls);
            publish(cls);
            return cls;
        }

        /// Another thread got there first, or a class of this name already
        /// exists. The first is fine: wait for it to be registered. The
        /// second is a name collision, and a class without our state is no
        /// use to us.
        fn adoptExisting() Class {
            while (true) {
                if (class_.getClass(options.name)) |existing| {
                    if (raw.class_getInstanceVariable(existing.value, ivar_name) == null or
                        existing.instanceSize() < @sizeOf(State))
                    {
                        std.debug.panic("a class named {s} already exists and is not this one", .{options.name});
                    }
                    publish(existing);
                    return existing;
                }
                std.atomic.spinLoopHint();
            }
        }

        fn publish(cls: Class) void {
            const variable = raw.class_getInstanceVariable(cls.value, ivar_name).?;
            state_offset = @intCast(raw.ivar_getOffset(variable));
            @atomicStore(?*raw.struct_objc_class, &registered, cls.value, .release);
        }

        /// The receiver type of the `pub` declaration `decl`, or `void`
        /// when it is not a method.
        fn receiverOf(comptime decl: [:0]const u8) type {
            if (std.mem.eql(u8, decl, "deinit")) return void;
            const F = @TypeOf(@field(State, decl));
            const info = switch (@typeInfo(F)) {
                .@"fn" => |f| f,
                else => return void,
            };
            if (info.param_types.len == 0) return void;
            const P = info.param_types[0] orelse return void;
            if (P == *State or P == *const State or P == Self or P == Object or P == Class) return P;
            return void;
        }

        fn addMethod(target: Class, comptime decl: [:0]const u8) void {
            const f = @field(State, decl);
            const params = @typeInfo(@TypeOf(f)).@"fn".param_types;
            comptime sel.checkArity(decl, params.len - 1, "the method " ++ decl);
            _ = raw.class_replaceMethod(
                target.value,
                Sel.cached(decl).value,
                imp(f),
                comptime methodEncoding(@TypeOf(f)),
            );
        }

        /// A C method implementation for `f`: the receiver converted to
        /// whatever `f` takes first, `_cmd` dropped, everything else
        /// through `abi`.
        fn imp(comptime f: anytype) raw.IMP {
            const F = @TypeOf(f);
            const params = @typeInfo(F).@"fn".param_types;
            const R = abi.ReturnOf(F);
            const Receiver = params[0].?;

            const c_params = comptime blk: {
                var list: [params.len + 1]type = undefined;
                list[0] = abi.Id;
                list[1] = abi.Abi(Sel);
                for (params[1..], list[2..]) |P, *slot| slot.* = abi.Abi(P.?);
                const final = list;
                break :blk &final;
            };

            const Body = struct {
                fn call(c_args: anytype) abi.Abi(R) {
                    var args: std.meta.ArgsTuple(F) = undefined;
                    const object: Object = .{ .value = c_args[0].? };
                    args[0] = if (Receiver == Class)
                        Class{ .value = @ptrCast(object.value) }
                    else if (Receiver == Object)
                        object
                    else if (Receiver == Self)
                        Self{ .object = object }
                    else
                        (Self{ .object = object }).state();
                    inline for (params[1..], 1..) |P, i| args[i] = abi.fromAbi(P.?, c_args[i + 1]);
                    return abi.toAbi(R, @call(.auto, f, args));
                }
            };
            return @ptrCast(abi.cFunction(c_params, abi.Abi(R), Body.call));
        }

        fn methodEncoding(comptime F: type) [:0]const u8 {
            const params = @typeInfo(F).@"fn".param_types;
            var args: [params.len - 1]type = undefined;
            for (params[1..], &args) |P, *slot| slot.* = P.?;
            const final = args;
            return encoding.methodFrom(abi.ReturnOf(F), &final);
        }

        fn allocWithZone(cls: Class, _: Sel, zone: ?*anyopaque) ?Object {
            // Our superclass, not `cls`'s: when `cls` is a subclass of this
            // one, its superclass is us, and asking it would recurse.
            const superclass = class().superclass().?.metaclass();
            const object = message.sendSuper(cls.value, superclass, ?Object, "allocWithZone:", .{zone}) orelse
                return null;
            // A subclass of this class runs this too, through `super`, and
            // its own state lives at its own offset -- so this is always
            // our offset, whatever class `cls` is.
            (Self{ .object = object }).state().* = initial;
            return object;
        }

        fn dealloc(self: Object, _: Sel) void {
            if (@hasDecl(State, "deinit")) (Self{ .object = self }).state().deinit();
            const superclass = class().superclass().?;
            message.sendSuper(self.value, superclass, void, "dealloc", .{});
        }
    };
}
