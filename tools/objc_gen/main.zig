//! Generates Zig wrappers for Objective-C classes from the macOS SDK.
//!
//!     zig build generate
//!
//! For each class and enum in the manifest (`appkit.zig`), clang -- by way
//! of `zig cc` -- dumps its declarations as JSON; this reads the dumps and
//! writes one Zig file of wrapper structs and enums. The file is checked
//! in, so a package user never runs this and never needs the SDK's
//! Objective-C headers to parse.
//!
//! Every wrapper method is one `msgSend` with the selector spelled out, so
//! the selector's colon count is checked against the arguments when the
//! generated file compiles -- a mistake here is a compile error there.
//!
//! Anything whose C type has no safe Zig spelling -- a C function pointer,
//! a variadic method, an enum the manifest does not list -- is left out
//! and named in a comment, rather than guessed at.

const std = @import("std");
const manifest = @import("manifest");

const Allocator = std.mem.Allocator;
const Value = std.json.Value;

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;

    const args = try init.minimal.args.toSlice(arena);
    if (args.len != 5) {
        std.debug.print("usage: objc_gen <zig> <sdk> <scratch dir> <output dir>\n", .{});
        std.process.exit(2);
    }
    const zig_exe = args[1];
    const sdk = args[2];
    const scratch = args[3];
    const output = try std.fs.path.join(arena, &.{ args[4], "generated.zig" });

    // One dump per prefix: `NS` catches every AppKit and Foundation
    // declaration, categories included whatever they are called, in a single
    // parse. A listed name no prefix covers gets a dump of its own.
    var filters: std.ArrayList([]const u8) = .empty;
    try filters.appendSlice(arena, &manifest.prefixes);
    for ([_][]const []const u8{ &manifest.classes, &manifest.protocols, &manifest.enums, &manifest.structs }) |list| {
        for (list) |name| {
            const covered = for (manifest.prefixes) |prefix| {
                if (std.mem.indexOf(u8, name, prefix) != null) break true;
            } else false;
            if (!covered) try filters.append(arena, name);
        }
    }

    const dumps = try dumpAll(arena, io, zig_exe, sdk, scratch, filters.items);

    var model: Model = .{ .arena = arena };
    for (dumps) |dump| try model.load(dump);

    var out: std.Io.Writer.Allocating = .init(arena);
    try model.emit(&out.writer);

    try std.Io.Dir.cwd().writeFile(io, .{ .sub_path = output, .data = out.written() });
    std.debug.print("wrote {s}: {d} classes, {d} enums\n", .{ output, model.classes.count(), model.enums.count() });
}

// -- running clang --------------------------------------------------------

/// Dumps the declarations matching each filter, in parallel -- a parse of
/// the umbrella header apiece, about a second -- and returns the JSON text
/// of each.
fn dumpAll(
    arena: Allocator,
    io: std.Io,
    zig_exe: []const u8,
    sdk: []const u8,
    scratch: []const u8,
    names: []const []const u8,
) ![][]const u8 {
    const cwd = std.Io.Dir.cwd();
    try cwd.createDirPath(io, scratch);

    const source = try std.fs.path.join(arena, &.{ scratch, "umbrella.m" });
    try cwd.writeFile(io, .{
        .sub_path = source,
        .data = blk: {
            var text: []const u8 = "";
            for (manifest.imports) |header| text = try std.fmt.allocPrint(arena, "{s}#import <{s}>\n", .{ text, header });
            break :blk text;
        },
    });
    const frameworks = try std.fs.path.join(arena, &.{ sdk, "System/Library/Frameworks" });

    const Job = struct { child: std.process.Child, out_path: []const u8, err_path: []const u8 };
    const jobs = try arena.alloc(Job, names.len);

    for (names, jobs) |name, *job| {
        job.out_path = try std.fmt.allocPrint(arena, "{s}/{s}.json", .{ scratch, name });
        job.err_path = try std.fmt.allocPrint(arena, "{s}/{s}.err", .{ scratch, name });
        const out_file = try cwd.createFile(io, job.out_path, .{});
        defer out_file.close(io);
        const err_file = try cwd.createFile(io, job.err_path, .{});
        defer err_file.close(io);

        job.child = try std.process.spawn(io, .{
            .argv = &.{
                zig_exe,                                                        "cc",
                "-x",                                                           "objective-c",
                "-fsyntax-only",                                                "-isysroot",
                sdk,                                                            "-iframework",
                frameworks,                                                     "-Xclang",
                "-ast-dump=json",                                               "-Xclang",
                try std.fmt.allocPrint(arena, "-ast-dump-filter={s}", .{name}), "umbrella.m",
            },
            // Run from the scratch directory: `zig cc` leaves an empty
            // a.out behind, and it should not land in the source tree.
            .cwd = .{ .path = scratch },
            .stdin = .ignore,
            .stdout = .{ .file = out_file },
            .stderr = .{ .file = err_file },
        });
    }

    const texts = try arena.alloc([]const u8, names.len);
    for (jobs, texts, names) |*job, *text, name| {
        _ = try job.child.wait(io);
        // `zig cc` always exits 1 here: after the dump, it looks for an
        // output file that -fsyntax-only never writes. So success is judged
        // by what clang said, not by the exit code.
        const errors = try cwd.readFileAlloc(io, job.err_path, arena, .unlimited);
        if (std.mem.indexOf(u8, errors, "fatal error") != null or
            std.mem.indexOf(u8, errors, " error: ") != null and
                std.mem.indexOf(u8, errors, "error: FileNotFound") == null)
        {
            std.debug.print("clang failed on {s}:\n{s}\n", .{ name, errors });
            return error.ClangFailed;
        }
        text.* = try cwd.readFileAlloc(io, job.out_path, arena, .unlimited);
    }
    return texts;
}

// -- reading the dump -----------------------------------------------------

const TypeRef = struct {
    qual: []const u8,
    desugared: ?[]const u8,

    fn from(value: Value) TypeRef {
        const object = value.object;
        return .{
            .qual = object.get("qualType").?.string,
            .desugared = if (object.get("desugaredQualType")) |d| d.string else null,
        };
    }
};

const Param = struct { name: []const u8, type: TypeRef };

const Method = struct {
    selector: []const u8,
    instance: bool,
    returns: TypeRef,
    params: []const Param,
    variadic: bool,
};

/// A class, or a protocol -- both are a name and a list of methods.
const Class = struct {
    name: []const u8,
    superclass: ?[]const u8 = null,
    is_protocol: bool = false,
    methods: std.ArrayList(Method) = .empty,
    seen: std.StringHashMapUnmanaged(void) = .empty,

    fn key(arena: Allocator, m: Method) ![]const u8 {
        return std.fmt.allocPrint(arena, "{c}{s}", .{ @as(u8, if (m.instance) '-' else '+'), m.selector });
    }
};

/// A C struct, from a manifest `structs` entry.
const Record = struct {
    name: []const u8,
    fields: []const Param,
};

const Constant = struct { name: []const u8, value: i128 };

const Enum = struct {
    name: []const u8,
    underlying: ?TypeRef,
    flags: bool,
    constants: []const Constant,
};

const Model = struct {
    arena: Allocator,
    classes: std.StringArrayHashMapUnmanaged(Class) = .empty,
    protocols: std.StringArrayHashMapUnmanaged(Class) = .empty,
    enums: std.StringArrayHashMapUnmanaged(Enum) = .empty,
    structs: std.StringArrayHashMapUnmanaged(Record) = .empty,
    /// The fields of the last nameless struct seen: `typedef struct {...}
    /// MTLClearColor` dumps as a nameless record, then the typedef naming it.
    anonymous_fields: ?[]const Param = null,

    fn wantsClass(name: []const u8) bool {
        for (manifest.classes) |c| if (std.mem.eql(u8, c, name)) return true;
        return false;
    }

    fn wantsEnum(name: []const u8) bool {
        for (manifest.enums) |e| if (std.mem.eql(u8, e, name)) return true;
        return false;
    }

    fn wantsProtocol(name: []const u8) bool {
        for (manifest.protocols) |p| if (std.mem.eql(u8, p, name)) return true;
        return false;
    }

    fn wantsStruct(name: []const u8) bool {
        for (manifest.structs) |r| if (std.mem.eql(u8, r, name)) return true;
        return false;
    }

    /// Reads one dump: a series of top-level JSON objects, one per
    /// declaration whose name matched the filter.
    /// A dump can run to a couple of hundred megabytes, nearly all of it
    /// declarations nobody asked for, so each is skimmed -- its kind and name
    /// read off the text -- and only the wanted ones are parsed.
    fn load(self: *Model, text: []const u8) !void {
        var rest = text;
        while (nextObject(rest)) |span| {
            rest = rest[span.end..];
            if (!wanted(skim(span.text))) {
                // A nameless struct is only ever named by the very next
                // declaration; anything else in between breaks the pair.
                self.anonymous_fields = null;
                continue;
            }
            const value = try std.json.parseFromSliceLeaky(Value, self.arena, span.text, .{});
            try self.declaration(value);
        }
    }

    const Skim = struct { kind: []const u8, name: ?[]const u8, interface: ?[]const u8 };

    /// The declaration's kind and name, and a category's class, from the
    /// part of its JSON before `inner` -- where clang writes them.
    fn skim(text: []const u8) Skim {
        const head = text[0 .. std.mem.indexOf(u8, text, "\"inner\"") orelse text.len];
        const interface = if (std.mem.indexOf(u8, head, "\"interface\":")) |at| stringAfter(head[at..], "\"name\": \"") else null;
        const name_head = if (std.mem.indexOf(u8, head, "\"interface\":")) |at| head[0..at] else head;
        return .{
            .kind = stringAfter(head, "\"kind\": \"") orelse "",
            .name = stringAfter(name_head, "\"name\": \""),
            .interface = interface,
        };
    }

    fn wanted(skimmed: Skim) bool {
        const kind = skimmed.kind;
        const name = skimmed.name orelse return std.mem.eql(u8, kind, "RecordDecl");
        if (std.mem.eql(u8, kind, "ObjCInterfaceDecl")) return wantsClass(name);
        if (std.mem.eql(u8, kind, "ObjCCategoryDecl")) return wantsClass(skimmed.interface orelse return false);
        if (std.mem.eql(u8, kind, "ObjCProtocolDecl")) return wantsProtocol(name);
        if (std.mem.eql(u8, kind, "EnumDecl")) return wantsEnum(name);
        if (std.mem.eql(u8, kind, "RecordDecl") or std.mem.eql(u8, kind, "TypedefDecl")) return wantsStruct(name);
        return false;
    }

    fn declaration(self: *Model, value: Value) !void {
        const object = value.object;
        const kind = object.get("kind").?.string;
        if (std.mem.eql(u8, kind, "RecordDecl") and object.get("name") == null) {
            self.anonymous_fields = if (object.get("inner")) |inner| try self.fields(inner) else null;
            return;
        }
        const name = if (object.get("name")) |n| n.string else return;

        if (std.mem.eql(u8, kind, "TypedefDecl") and wantsStruct(name) and !self.structs.contains(name)) {
            if (self.anonymous_fields) |pending| {
                if (pending.len > 0) try self.structs.put(self.arena, name, .{ .name = name, .fields = pending });
            }
            self.anonymous_fields = null;
            return;
        }

        if (std.mem.eql(u8, kind, "ObjCInterfaceDecl") and wantsClass(name)) {
            const inner = object.get("inner") orelse return; // a forward declaration
            const class = try self.classNamed(name);
            if (object.get("super")) |super| class.superclass = super.object.get("name").?.string;
            try self.methods(class, inner);
        } else if (std.mem.eql(u8, kind, "ObjCCategoryDecl")) {
            const interface = (object.get("interface") orelse return).object.get("name").?.string;
            if (!wantsClass(interface)) return;
            const inner = object.get("inner") orelse return;
            try self.methods(try self.classNamed(interface), inner);
        } else if (std.mem.eql(u8, kind, "ObjCProtocolDecl") and wantsProtocol(name)) {
            const inner = object.get("inner") orelse return;
            const entry = try self.protocols.getOrPut(self.arena, name);
            if (!entry.found_existing) entry.value_ptr.* = .{ .name = name, .is_protocol = true };
            // A protocol's parent is its "superclass" here: the first one
            // it adopts that is also being generated.
            if (entry.value_ptr.superclass == null) if (object.get("protocols")) |parents| {
                for (parents.array.items) |parent| {
                    const parent_name = parent.object.get("name").?.string;
                    if (wantsProtocol(parent_name)) {
                        entry.value_ptr.superclass = parent_name;
                        break;
                    }
                }
            };
            try self.methods(entry.value_ptr, inner);
        } else if (std.mem.eql(u8, kind, "RecordDecl") and wantsStruct(name) and !self.structs.contains(name)) {
            const inner = object.get("inner") orelse return;
            const found = try self.fields(inner);
            if (found.len > 0) try self.structs.put(self.arena, name, .{ .name = name, .fields = found });
        } else if (std.mem.eql(u8, kind, "EnumDecl") and wantsEnum(name) and !self.enums.contains(name)) {
            const inner = object.get("inner") orelse return;
            var constants: std.ArrayList(Constant) = .empty;
            var flags = false;
            var next_value: i128 = 0;
            for (inner.array.items) |child| {
                const child_kind = child.object.get("kind").?.string;
                if (std.mem.eql(u8, child_kind, "FlagEnumAttr")) flags = true;
                if (!std.mem.eql(u8, child_kind, "EnumConstantDecl")) continue;
                const constant_value = constantValue(child) orelse next_value;
                try constants.append(self.arena, .{
                    .name = child.object.get("name").?.string,
                    .value = constant_value,
                });
                next_value = constant_value + 1;
            }
            if (constants.items.len == 0) return; // a redeclaration
            try self.enums.put(self.arena, name, .{
                .name = name,
                .underlying = if (object.get("fixedUnderlyingType")) |t| TypeRef.from(t) else null,
                .flags = flags,
                .constants = constants.items,
            });
        }
    }

    fn fields(self: *Model, inner: Value) ![]const Param {
        var list: std.ArrayList(Param) = .empty;
        for (inner.array.items) |child| {
            if (!std.mem.eql(u8, child.object.get("kind").?.string, "FieldDecl")) continue;
            try list.append(self.arena, .{
                .name = child.object.get("name").?.string,
                .type = .from(child.object.get("type").?),
            });
        }
        return list.items;
    }

    fn classNamed(self: *Model, name: []const u8) !*Class {
        const entry = try self.classes.getOrPut(self.arena, name);
        if (!entry.found_existing) entry.value_ptr.* = .{ .name = name };
        return entry.value_ptr;
    }

    fn methods(self: *Model, class: *Class, inner: Value) !void {
        // Whether each property -- by name, and by getter -- was declared
        // with explicit nullability. See `recoverNullability`.
        var explicit: std.StringHashMapUnmanaged(bool) = .empty;
        for (inner.array.items) |child| {
            const object = child.object;
            if (!std.mem.eql(u8, object.get("kind").?.string, "ObjCPropertyDecl")) continue;
            const flagged = if (object.get("nullability")) |n| n.bool else false;
            try explicit.put(self.arena, object.get("name").?.string, flagged);
            if (object.get("getter")) |getter| {
                if (getter.object.get("name")) |g| try explicit.put(self.arena, g.string, flagged);
            }
        }

        for (inner.array.items) |child| {
            const object = child.object;
            if (!std.mem.eql(u8, object.get("kind").?.string, "ObjCMethodDecl")) continue;
            if (hasAttr(child, "UnavailableAttr")) continue;

            const selector = object.get("name").?.string;
            const instance = object.get("instance").?.bool;
            const key = try std.fmt.allocPrint(self.arena, "{c}{s}", .{ @as(u8, if (instance) '-' else '+'), selector });
            if ((try class.seen.getOrPut(self.arena, key)).found_existing) continue;

            const implicit = if (object.get("isImplicit")) |i| i.bool else false;
            const property: ?bool = if (!implicit) null else explicit.get(accessorProperty(selector)) orelse
                explicit.get(selector);

            var params: std.ArrayList(Param) = .empty;
            if (object.get("inner")) |parts| for (parts.array.items) |part| {
                if (!std.mem.eql(u8, part.object.get("kind").?.string, "ParmVarDecl")) continue;
                try params.append(self.arena, .{
                    .name = if (part.object.get("name")) |n| n.string else "arg",
                    .type = try self.recoverNullability(.from(part.object.get("type").?), property),
                });
            };
            try class.methods.append(self.arena, .{
                .selector = selector,
                .instance = instance,
                .returns = try self.recoverNullability(.from(object.get("returnType").?), property),
                .params = params.items,
                .variadic = if (object.get("variadic")) |v| v.bool else false,
            });
        }
    }

    /// A property's accessor inside `NS_ASSUME_NONNULL` is non-null, and
    /// clang spells that as `_Nonnull` -- except when the property carries
    /// an availability macro, when the spelling is `API_AVAILABLE(...) T *`
    /// and the implicit nullability is gone. The property declaration still
    /// says whether nullability was written out, which inside those regions
    /// means `nullable`; otherwise the region's non-null applies.
    fn recoverNullability(self: *Model, t: TypeRef, explicitly: ?bool) !TypeRef {
        const flagged = explicitly orelse return t;
        const q = t.qual;
        const annotated = std.mem.indexOf(u8, q, "_Nonnull") != null or
            std.mem.indexOf(u8, q, "_Nullable") != null or
            std.mem.indexOf(u8, q, "_Null_unspecified") != null;
        const macro_spelled = std.mem.indexOf(u8, q, "API_") != null or std.mem.indexOf(u8, q, "NS_") != null;
        if (annotated or !macro_spelled) return t;
        return .{
            .qual = try std.fmt.allocPrint(self.arena, "{s} {s}", .{ q, if (flagged) "_Nullable" else "_Nonnull" }),
            .desugared = t.desugared,
        };
    }

    // -- writing Zig ---------------------------------------------------

    fn emit(self: *Model, w: *std.Io.Writer) !void {
        try w.print(
            \\//! {s} wrappers generated from the macOS SDK by `zig build generate`,
            \\//! from the manifest in `tools/objc_gen/{s}.zig`. Do not edit: add to the
            \\//! manifest and regenerate, or write a hand-made wrapper beside this file.
            \\
            \\const objc = @import("../objc/objc.zig");
            \\const foundation = @import("../foundation/foundation.zig");
            \\const cg = @import("../cg/cg.zig");
            \\
            \\/// Whether `Descendant` is `Ancestor`, or inherits from it.
            \\fn inherits(comptime Descendant: type, comptime Ancestor: type) bool {{
            \\    if (Ancestor == objc.Object) return true;
            \\    comptime var current: type = Descendant;
            \\    inline while (true) {{
            \\        if (current == Ancestor) return true;
            \\        if (current.Super == objc.Object) return false;
            \\        current = current.Super;
            \\    }}
            \\}}
            \\
            \\fn lookUp(comptime name: [:0]const u8) objc.Class {{
            \\    return objc.getClass(name) orelse @panic(name ++ " is not loaded: link " ++ framework);
            \\}}
            \\
            \\const framework = "{s}";
            \\
        , .{ manifest.framework, lowerFramework(), manifest.framework });

        for (manifest.structs) |name| {
            const record = self.structs.get(name) orelse {
                try w.print("\n// Not generated: struct {s}, which was not found.\n", .{name});
                continue;
            };
            try self.emitStruct(w, record);
        }
        for (manifest.enums) |name| {
            const e = self.enums.get(name) orelse {
                try w.print("\n// Not generated: enum {s}, which the SDK does not declare as an enum.\n", .{name});
                continue;
            };
            try self.emitEnum(w, e);
        }
        for (manifest.classes) |name| {
            const class = self.classes.getPtr(name) orelse {
                try w.print("\n// Not generated: class {s}, which was not found.\n", .{name});
                continue;
            };
            try self.emitClass(w, class);
        }
        for (manifest.protocols) |name| {
            const protocol = self.protocols.getPtr(name) orelse {
                try w.print("\n// Not generated: protocol {s}, which was not found.\n", .{name});
                continue;
            };
            try self.emitClass(w, protocol);
        }
    }

    fn emitStruct(self: *Model, w: *std.Io.Writer, record: Record) !void {
        var dummy: Class = .{ .name = record.name };
        try w.print("\n/// `{s}`.\npub const {s} = extern struct {{\n", .{ record.name, stripPrefix(record.name) });
        for (record.fields) |field| {
            const t = self.zigType(&dummy, field.type, .param) catch {
                try w.print("    // Not generated: field {s}, of type {s}\n", .{ field.name, field.type.qual });
                continue;
            };
            try w.print("    {f}: {s},\n", .{ ident(try self.snake(field.name)), t });
        }
        try w.writeAll("};\n");
    }

    /// `pub const signatures`: each method's Zig function type, without
    /// the receiver, keyed by selector -- `+` first for a class method.
    /// `objc.Subclass` checks an override against these. A method with a
    /// block parameter has no single type and is left out.
    fn emitSignatures(self: *Model, w: *std.Io.Writer, class: *Class, list: []const Method) !void {
        try w.writeAll("\n    /// Each method's signature, for `objc.Subclass` to check overrides against.\n");
        try w.writeAll("    pub const signatures = struct {\n");
        for (list) |m| {
            if (self.unsupportedReason(class, m) != null) continue;
            const result = try self.zigType(class, m.returns, .result);
            var params: std.ArrayList(u8) = .empty;
            var generic = false;
            for (m.params, 0..) |p, i| {
                const t = try self.zigType(class, p.type, .param);
                if (std.mem.eql(u8, t, "anytype")) generic = true;
                if (i > 0) try params.appendSlice(self.arena, ", ");
                try params.appendSlice(self.arena, t);
            }
            if (generic) continue;
            try w.print("        pub const @\"{s}{s}\" = fn ({s}) {s};\n", .{
                if (m.instance) "" else "+", m.selector, params.items, result,
            });
        }
        try w.writeAll("    };\n");
    }

    fn emitEnum(self: *Model, w: *std.Io.Writer, e: Enum) !void {
        const zig_name = stripPrefix(e.name);
        const backing = if (e.underlying) |u| scalar(u.qual) orelse scalar(u.desugared orelse "") orelse "c_int" else "c_int";
        const prefix = constantPrefix(e);

        try w.print("\n/// `{s}`.\n", .{e.name});
        if (e.flags) {
            const bits = backingBits(backing);
            try w.print("pub const {s} = packed struct(u{d}) {{\n", .{ zig_name, bits });
            var owner: [64]?[]const u8 = @splat(null);
            for (e.constants) |c| {
                const unsigned: u64 = @truncate(@as(u128, @bitCast(c.value)));
                if (unsigned != 0 and std.math.isPowerOfTwo(unsigned)) {
                    const bit = std.math.log2_int(u64, unsigned);
                    if (bit < bits and owner[bit] == null) owner[bit] = c.name;
                }
            }
            var bit: usize = 0;
            while (bit < bits) {
                if (owner[bit]) |name| {
                    try w.print("    {f}: bool = false,\n", .{ident(try self.snake(name[prefix.len..]))});
                    bit += 1;
                } else {
                    const start = bit;
                    while (bit < bits and owner[bit] == null) bit += 1;
                    try w.print("    _{d}: u{d} = 0,\n", .{ start, bit - start });
                }
            }
            for (e.constants) |c| {
                const unsigned: u64 = @truncate(@as(u128, @bitCast(c.value)));
                const is_field = unsigned != 0 and std.math.isPowerOfTwo(unsigned) and
                    std.mem.eql(u8, owner[std.math.log2_int(u64, unsigned)] orelse "", c.name);
                if (is_field) continue;
                try w.print("    pub const {f}: {s} = @fromBackingInt(0x{x});\n", .{
                    ident(try self.snake(c.name[prefix.len..])), zig_name, unsigned,
                });
            }
            try w.writeAll("};\n");
        } else {
            try w.print("pub const {s} = enum({s}) {{\n", .{ zig_name, backing });
            var seen: std.AutoHashMapUnmanaged(i128, []const u8) = .empty;
            var aliases: std.ArrayList(Constant) = .empty;
            for (e.constants) |c| {
                const found = try seen.getOrPut(self.arena, c.value);
                if (found.found_existing) {
                    try aliases.append(self.arena, c);
                    continue;
                }
                found.value_ptr.* = c.name;
                try w.print("    {f} = {d},\n", .{ ident(try self.snake(c.name[prefix.len..])), c.value });
            }
            try w.writeAll("    _,\n");
            for (aliases.items) |c| {
                const original = seen.get(c.value).?;
                const alias = try self.snake(c.name[prefix.len..]);
                const target = try self.snake(original[prefix.len..]);
                if (std.mem.eql(u8, alias, target)) continue;
                try w.print("    pub const {f}: {s} = .{f};\n", .{ ident(alias), zig_name, ident(target) });
            }
            try w.writeAll("};\n");
        }
    }

    fn isGenerated(name: []const u8) bool {
        return wantsClass(name) or wantsProtocol(name);
    }

    /// A generated class or protocol by name.
    fn container(self: *Model, name: []const u8) ?*Class {
        return self.classes.getPtr(name) orelse self.protocols.getPtr(name);
    }

    fn emitClass(self: *Model, w: *std.Io.Writer, class: *Class) !void {
        const zig_name = stripPrefix(class.name);
        const super: []const u8 = if (class.superclass) |s|
            (if (isGenerated(s)) stripPrefix(s) else "objc.Object")
        else
            "objc.Object";

        if (class.is_protocol) try w.print(
            \\
            \\/// An object conforming to `{s}`{s}{s}{s}. As an `objc.Subclass`
            \\/// protocol, each method the class implements is checked against it.
            \\pub const {s} = extern struct {{
            \\    object: objc.Object,
            \\
            \\    const Self = @This();
            \\    pub const Super = {s};
            \\    pub const protocol_name = "{s}";
            \\
            \\    /// An object that came from elsewhere, taken to conform to `{s}`.
            \\    pub fn from(object: objc.Object) Self {{
            \\        return .{{ .object = object }};
            \\    }}
            \\
            \\    /// This object as a parent protocol's wrapper, or `objc.Object`.
            \\    pub fn into(self: Self, comptime T: type) T {{
            \\        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
            \\        return objc.abi.wrap(T, self.object);
            \\    }}
            \\
            \\    pub fn retain(self: Self) Self {{
            \\        return .{{ .object = self.object.retain() }};
            \\    }}
            \\
            \\    pub fn release(self: Self) void {{
            \\        self.object.release();
            \\    }}
            \\
            \\    pub fn autorelease(self: Self) Self {{
            \\        return .{{ .object = self.object.autorelease() }};
            \\    }}
            \\
        , .{
            class.name,
            if (class.superclass != null) ", which extends `" else "",
            class.superclass orelse "",
            if (class.superclass != null) "`" else "",
            zig_name,
            super,
            class.name,
            class.name,
        }) else try w.print(
            \\
            \\/// `{s}`{s}{s}{s}.
            \\pub const {s} = extern struct {{
            \\    object: objc.Object,
            \\
            \\    const Self = @This();
            \\    pub const Super = {s};
            \\    pub const class_name = "{s}";
            \\
            \\    pub fn class() objc.Class {{
            \\        return lookUp(class_name);
            \\    }}
            \\
            \\    /// An uninitialised instance, for an `init...` method. Yours.
            \\    pub fn alloc() Self {{
            \\        return class().msgSend(Self, "alloc", .{{}});
            \\    }}
            \\
            \\    /// `[[{s} alloc] init]`. Yours.
            \\    pub fn new() Self {{
            \\        return class().msgSend(Self, "new", .{{}});
            \\    }}
            \\
            \\    /// An object that came from elsewhere, taken to be a `{s}`.
            \\    pub fn from(object: objc.Object) Self {{
            \\        return .{{ .object = object }};
            \\    }}
            \\
            \\    /// This object as a superclass's wrapper, or `objc.Object`.
            \\    pub fn into(self: Self, comptime T: type) T {{
            \\        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
            \\        return objc.abi.wrap(T, self.object);
            \\    }}
            \\
            \\    pub fn retain(self: Self) Self {{
            \\        return .{{ .object = self.object.retain() }};
            \\    }}
            \\
            \\    pub fn release(self: Self) void {{
            \\        self.object.release();
            \\    }}
            \\
            \\    pub fn autorelease(self: Self) Self {{
            \\        return .{{ .object = self.object.autorelease() }};
            \\    }}
            \\
        , .{
            class.name,
            if (class.superclass != null) ", a subclass of `" else "",
            class.superclass orelse "",
            if (class.superclass != null) "`" else "",
            zig_name,
            super,
            class.name,
            class.name,
            class.name,
        });

        // Names the struct already uses, which a method must not take.
        var taken: std.StringHashMapUnmanaged(void) = .empty;
        for ([_][]const u8{ "object", "Self", "Super", "class_name", "protocol_name", "class", "alloc", "new", "from", "into", "retain", "release", "autorelease", "signatures" }) |n| {
            try taken.put(self.arena, n, {});
        }

        // Its own methods, then each generated ancestor's that it does not
        // redeclare -- so that `window.becomeFirstResponder()` works without
        // `into(Responder)` first.
        const Entry = struct { method: Method, origin: []const u8 };
        var all: std.ArrayList(Entry) = .empty;
        var keys: std.StringHashMapUnmanaged(void) = .empty;
        var owner: ?*Class = class;
        while (owner) |current| {
            for (current.methods.items) |m| {
                // A protocol's class methods have no class to be sent to.
                if (class.is_protocol and !m.instance) continue;
                if ((try keys.getOrPut(self.arena, try Class.key(self.arena, m))).found_existing) continue;
                try all.append(self.arena, .{ .method = m, .origin = current.name });
            }
            const next = current.superclass orelse break;
            owner = if (isGenerated(next)) self.container(next) else null;
        }

        var skipped: std.ArrayList([]const u8) = .empty;
        var method_names: std.ArrayList([]const u8) = .empty;
        for (all.items) |entry| {
            const m = entry.method;
            var name = try methodName(self.arena, m.selector);
            if (!m.instance and taken.contains(name)) name = try std.fmt.allocPrint(self.arena, "class{c}{s}", .{ std.ascii.toUpper(name[0]), name[1..] });
            while (taken.contains(name)) name = try std.fmt.allocPrint(self.arena, "{s}_", .{name});
            try taken.put(self.arena, name, {});
            try method_names.append(self.arena, name);
        }

        for (all.items, method_names.items) |entry, name| {
            const m = entry.method;
            if (self.unsupportedReason(class, m)) |why| {
                // An ancestor's gaps are listed on the ancestor.
                if (entry.origin.ptr != class.name.ptr) continue;
                try skipped.append(self.arena, try std.fmt.allocPrint(self.arena, "{c}[{s} {s}]: {s}", .{
                    @as(u8, if (m.instance) '-' else '+'), class.name, m.selector, why,
                }));
            } else {
                try self.emitMethod(w, class, entry.origin, m, name, &taken);
            }
        }
        try self.emitSignatures(w, class, class.methods.items);
        if (skipped.items.len > 0) {
            try w.writeAll("\n    // Not generated:\n");
            for (skipped.items) |line| try w.print("    //   {s}\n", .{line});
        }
        try w.writeAll("};\n");
    }

    /// Why `m` cannot be generated, or null when it can.
    fn unsupportedReason(self: *Model, class: *Class, m: Method) ?[]const u8 {
        if (m.variadic) return "variadic";
        _ = self.zigType(class, m.returns, .result) catch return typeReason(m.returns);
        for (m.params) |p| _ = self.zigType(class, p.type, .param) catch return typeReason(p.type);
        return null;
    }

    /// A skipped method is described by the C type that stopped it.
    fn typeReason(t: TypeRef) []const u8 {
        return t.qual;
    }

    fn emitMethod(self: *Model, w: *std.Io.Writer, class: *Class, origin: []const u8, m: Method, name: []const u8, taken: *std.StringHashMapUnmanaged(void)) !void {
        const result = try self.zigType(class, m.returns, .result);

        try w.print("\n    /// `{c}[{s} {s}]`\n    pub fn {f}(", .{
            @as(u8, if (m.instance) '-' else '+'), origin, m.selector, ident(name),
        });
        if (m.instance) try w.writeAll("self: Self");

        var param_names: std.ArrayList([]const u8) = .empty;
        for (m.params, 0..) |p, i| {
            var pname = try self.snake(p.name);
            while (taken.contains(pname) or isFileScope(pname) or std.mem.eql(u8, pname, "self") or
                contains(param_names.items, pname))
            {
                pname = try std.fmt.allocPrint(self.arena, "{s}_", .{pname});
            }
            try param_names.append(self.arena, pname);
            if (m.instance or i > 0) try w.writeAll(", ");
            try w.print("{f}: {s}", .{ ident(pname), try self.zigType(class, p.type, .param) });
        }
        try w.print(") {s} {{\n        return ", .{result});
        try w.writeAll(if (m.instance) "self.object" else "class()");
        try w.print(".msgSend({s}, \"{s}\", .{{", .{ result, m.selector });
        for (param_names.items, 0..) |pname, i| {
            if (i > 0) try w.writeAll(", ");
            try w.print("{f}", .{ident(pname)});
        }
        try w.writeAll("});\n    }\n");
    }

    // -- types ---------------------------------------------------------

    const Position = enum { param, result };

    /// The Zig spelling of a C type, or `error.Unsupported`.
    fn zigType(self: *Model, class: *Class, t: TypeRef, position: Position) error{ Unsupported, OutOfMemory }![]const u8 {
        if (try self.spell(class, t.qual, position)) |s| return s;
        if (t.desugared) |d| if (try self.spell(class, d, position)) |s| return s;
        return error.Unsupported;
    }

    fn spell(self: *Model, class: *Class, raw_type: []const u8, position: Position) Allocator.Error!?[]const u8 {
        const cleaned = try clean(self.arena, raw_type);
        const text = cleaned.text;
        const optional = !cleaned.nonnull;

        if (std.mem.indexOf(u8, text, "(^") != null) {
            // A block goes in as a pointer to an `objc.Block`, whose type
            // the caller chooses; it cannot come back out.
            return if (position == .param) "anytype" else null;
        }
        // Checked on the spelling as clang gave it: cleaning moves the
        // spaces in `(* _Nonnull)`.
        if (std.mem.indexOf(u8, raw_type, "(*") != null) return try self.functionPointer(class, raw_type);
        if (std.mem.indexOfScalar(u8, text, '(') != null) return null;

        var depth: usize = 0;
        var base = text;
        while (std.mem.endsWith(u8, base, "*")) {
            depth += 1;
            base = std.mem.trimEnd(u8, base[0 .. base.len - 1], " ");
        }
        var is_const = std.mem.startsWith(u8, base, "const ");
        if (is_const) base = base["const ".len..];
        if (std.mem.endsWith(u8, base, " const")) {
            is_const = true;
            base = base[0 .. base.len - " const".len];
        }

        switch (depth) {
            0 => {
                if (std.mem.eql(u8, base, "void")) return "void";
                if (std.mem.eql(u8, base, "instancetype")) {
                    return try self.maybeOptional(if (class.is_protocol) "objc.Object" else stripPrefix(class.name), optional);
                }
                if (cgHandle(base)) |handle| return try self.maybeOptional(handle, optional);
                if (std.mem.startsWith(u8, base, "id<") and std.mem.endsWith(u8, base, ">")) {
                    // One generated protocol: its wrapper. Otherwise a bare object.
                    const inside = std.mem.trim(u8, base[3 .. base.len - 1], " ");
                    const wrapper = if (std.mem.indexOfScalar(u8, inside, ',') == null and wantsProtocol(inside))
                        stripPrefix(inside)
                    else
                        "objc.Object";
                    return try self.maybeOptional(wrapper, optional);
                }
                if (std.mem.eql(u8, base, "id")) return try self.maybeOptional("objc.Object", optional);
                if (std.mem.eql(u8, base, "SEL")) return try self.maybeOptional("objc.Sel", optional);
                // `Class<NSWindowRestoration>` is a class that adopts a protocol.
                if (std.mem.eql(u8, base, "Class") or std.mem.startsWith(u8, base, "Class<"))
                    return try self.maybeOptional("objc.Class", optional);
                if (scalar(base)) |s| return s;
                if (structType(base)) |s| return s;
                const struct_name = if (std.mem.startsWith(u8, base, "struct ")) base["struct ".len..] else base;
                if (self.structs.contains(struct_name)) return stripPrefix(struct_name);
                const enum_name = if (std.mem.startsWith(u8, base, "enum ")) base["enum ".len..] else base;
                if (self.enums.contains(enum_name)) return stripPrefix(enum_name);
                return null;
            },
            1 => {
                if (std.mem.eql(u8, base, "char")) return if (optional) "?[*:0]const u8" else "[*:0]const u8";
                if (std.mem.eql(u8, base, "void")) return if (is_const) "?*const anyopaque" else "?*anyopaque";
                if (std.mem.eql(u8, base, "id") or std.mem.startsWith(u8, base, "id<")) {
                    return try self.objectArray(raw_type, base, is_const);
                }
                if (scalar(base) orelse structType(base) orelse self.generatedStruct(base)) |s| {
                    // An input handed over by pointer is, in C, nearly always
                    // an array -- offsets, viewports, lengths -- and so are
                    // bytes. A pointer to be written through is one value:
                    // `BOOL *stop`, `NSRect *out`.
                    const many = is_const or std.mem.eql(u8, s, "u8") or std.mem.eql(u8, s, "i8");
                    return try std.fmt.allocPrint(self.arena, "?{s}{s}{s}", .{
                        if (many) "[*]" else "*", if (is_const) "const " else "", s,
                    });
                }
                // An opaque C handle -- `CGImageRef`, `NSModalSession` --
                // which Zig can carry without knowing what it points at.
                if (std.mem.startsWith(u8, base, "struct ")) return if (is_const) "?*const anyopaque" else "?*anyopaque";
                if (try self.objectType(base)) |object| return try self.maybeOptional(object, optional);
                return null;
            },
            2 => {
                // `NSError **` and friends: an out-parameter for an object.
                if (try self.objectType(base) != null) return "?*objc.abi.Id";
                // `unsigned char **`: an array of byte buffers, like the
                // planes of a bitmap.
                if (scalar(base)) |s| if (std.mem.eql(u8, s, "u8")) return "?[*]?[*]u8";
                return null;
            },
            else => return null,
        }
    }

    /// A C function pointer, `R (*)(A, B)`, as a Zig one. The pieces go
    /// through the same mapping as any other type, and since every wrapper
    /// is the size of the pointer it holds, a Zig function taking wrappers
    /// is what the C caller expects.
    fn functionPointer(self: *Model, class: *Class, text: []const u8) Allocator.Error!?[]const u8 {
        // `R (* _Nonnull)(A, B)`: the pointer's own parentheses, then the
        // parameters'.
        const marker = std.mem.indexOf(u8, text, "(*").?;
        const pointer_close = std.mem.indexOfScalarPos(u8, text, marker, ')') orelse return null;
        const result = try self.spell(class, std.mem.trim(u8, text[0..marker], " "), .result) orelse return null;
        const open = std.mem.indexOfScalarPos(u8, text, pointer_close, '(') orelse return null;
        const close = std.mem.lastIndexOfScalar(u8, text, ')') orelse return null;
        var params: std.ArrayList(u8) = .empty;
        var it = std.mem.splitScalar(u8, text[open + 1 .. close], ',');
        var first = true;
        while (it.next()) |piece| {
            const trimmed = std.mem.trim(u8, piece, " ");
            if (trimmed.len == 0 or std.mem.eql(u8, trimmed, "void")) continue;
            const param = try self.spell(class, trimmed, .param) orelse return null;
            if (std.mem.eql(u8, param, "anytype")) return null;
            if (!first) try params.appendSlice(self.arena, ", ");
            try params.appendSlice(self.arena, param);
            first = false;
        }
        const optional = std.mem.indexOf(u8, text[marker..open], "_Nullable") != null;
        return try std.fmt.allocPrint(self.arena, "{s}*const fn ({s}) callconv(.c) {s}", .{
            if (optional) "?" else "", params.items, result,
        });
    }

    fn generatedStruct(self: *Model, base: []const u8) ?[]const u8 {
        const name = if (std.mem.startsWith(u8, base, "struct ")) base["struct ".len..] else base;
        return if (self.structs.contains(name)) stripPrefix(name) else null;
    }

    /// A C array of objects, `id<MTLTexture> _Nullable const *`: a pointer
    /// to wrappers, which are pointer-sized, or to `objc.Nullable` wrappers
    /// where an element may be nil.
    fn objectArray(self: *Model, raw_type: []const u8, element: []const u8, is_const: bool) ![]const u8 {
        // Before the last `*` is the elements' nullability; after it, the
        // pointer's own.
        const last_star = std.mem.lastIndexOfScalar(u8, raw_type, '*').?;
        const elements_nullable = std.mem.indexOf(u8, raw_type[0..last_star], "_Nullable") != null;
        const optional = std.mem.indexOf(u8, raw_type[last_star..], "_Nonnull") == null;
        var wrapper: []const u8 = "objc.Object";
        if (std.mem.startsWith(u8, element, "id<")) {
            const inside = std.mem.trim(u8, element[3 .. element.len - 1], " ");
            if (std.mem.indexOfScalar(u8, inside, ',') == null and wantsProtocol(inside)) wrapper = stripPrefix(inside);
        }
        const item = if (elements_nullable)
            try std.fmt.allocPrint(self.arena, "objc.Nullable({s})", .{wrapper})
        else
            wrapper;
        return try std.fmt.allocPrint(self.arena, "{s}[*]{s}{s}", .{
            if (optional) "?" else "", if (is_const) "const " else "", item,
        });
    }

    fn maybeOptional(self: *Model, name: []const u8, optional: bool) ![]const u8 {
        return if (optional) try std.fmt.allocPrint(self.arena, "?{s}", .{name}) else name;
    }

    /// The wrapper for a pointer to class `base` -- which may carry
    /// generic arguments, `NSArray<NSWindow *>`, or protocols,
    /// `NSObject<NSCopying>` -- or null when `base` is not a class.
    fn objectType(self: *Model, base: []const u8) Allocator.Error!?[]const u8 {
        const angle = std.mem.indexOfScalar(u8, base, '<');
        const name = std.mem.trim(u8, if (angle) |a| base[0..a] else base, " ");
        if (!isClassName(name)) return null;

        const generics = if (angle) |a| base[a + 1 .. std.mem.lastIndexOfScalar(u8, base, '>') orelse base.len] else "";
        if (std.mem.eql(u8, name, "NSArray") or std.mem.eql(u8, name, "NSMutableArray")) {
            const element = try self.elementType(generics);
            return try std.fmt.allocPrint(self.arena, "foundation.{s}({s})", .{
                if (name.len == "NSArray".len) "Array" else "MutableArray", element,
            });
        }
        if (std.mem.eql(u8, name, "NSDictionary") or std.mem.eql(u8, name, "NSMutableDictionary")) {
            var key: []const u8 = "objc.Object";
            var value: []const u8 = "objc.Object";
            if (splitTopLevelComma(generics)) |parts| {
                key = try self.elementType(parts[0]);
                value = try self.elementType(parts[1]);
            }
            return try std.fmt.allocPrint(self.arena, "foundation.{s}({s}, {s})", .{
                if (name.len == "NSDictionary".len) "Dictionary" else "MutableDictionary", key, value,
            });
        }
        if (foundationType(name)) |f| return f;
        if (wantsClass(name)) return stripPrefix(name);
        return "objc.Object";
    }

    /// A collection's element type: a known wrapper, or `objc.Object`.
    fn elementType(self: *Model, text: []const u8) Allocator.Error![]const u8 {
        const cleaned = try clean(self.arena, text);
        var t = cleaned.text;
        if (!std.mem.endsWith(u8, t, "*")) return "objc.Object";
        t = std.mem.trimEnd(u8, t[0 .. t.len - 1], " ");
        if (std.mem.indexOfScalar(u8, t, '<') != null) return "objc.Object";
        return (try self.objectType(t)) orelse "objc.Object";
    }

    fn snake(self: *Model, raw_name: []const u8) ![]const u8 {
        // `BGRA8Unorm_sRGB` should read `bgra8_unorm_srgb`, not `..._s_rgb`.
        const name = try std.mem.replaceOwned(u8, self.arena, raw_name, "sRGB", "Srgb");
        var out: std.ArrayList(u8) = .empty;
        for (name, 0..) |c, i| {
            if (std.ascii.isUpper(c) and i > 0) {
                const previous = name[i - 1];
                const next_lower = i + 1 < name.len and std.ascii.isLower(name[i + 1]);
                if (std.ascii.isLower(previous) or std.ascii.isDigit(previous) or
                    (std.ascii.isUpper(previous) and next_lower)) try out.append(self.arena, '_');
            }
            try out.append(self.arena, std.ascii.toLower(c));
        }
        if (out.items.len == 0) try out.appendSlice(self.arena, "none");
        return out.items;
    }
};

// -- helpers ----------------------------------------------------------------

const Span = struct { text: []const u8, end: usize };

/// The next complete `{...}` in `text`, skipping anything before it --
/// the dump prints each declaration as its own top-level object.
fn nextObject(text: []const u8) ?Span {
    const start = std.mem.indexOfScalar(u8, text, '{') orelse return null;
    var depth: usize = 0;
    var in_string = false;
    var i = start;
    while (i < text.len) : (i += 1) {
        const c = text[i];
        if (in_string) {
            if (c == '\\') i += 1 else if (c == '"') in_string = false;
            continue;
        }
        switch (c) {
            '"' => in_string = true,
            '{' => depth += 1,
            '}' => {
                depth -= 1;
                if (depth == 0) return .{ .text = text[start .. i + 1], .end = i + 1 };
            },
            else => {},
        }
    }
    return null;
}

/// The JSON string that follows `marker` in `text`, unescaped only as far
/// as identifiers need -- which is not at all.
fn stringAfter(text: []const u8, marker: []const u8) ?[]const u8 {
    const at = std.mem.indexOf(u8, text, marker) orelse return null;
    const start = at + marker.len;
    const end = std.mem.indexOfScalarPos(u8, text, start, '"') orelse return null;
    return text[start..end];
}

fn hasAttr(value: Value, kind: []const u8) bool {
    const inner = value.object.get("inner") orelse return false;
    for (inner.array.items) |child| {
        if (std.mem.eql(u8, child.object.get("kind").?.string, kind)) return true;
    }
    return false;
}

/// The integer an enum constant was given, from the constant expression
/// clang evaluated for it.
fn constantValue(value: Value) ?i128 {
    const object = value.object;
    if (std.mem.eql(u8, object.get("kind").?.string, "ConstantExpr")) {
        if (object.get("value")) |v| return std.fmt.parseInt(i128, v.string, 10) catch null;
    }
    const inner = object.get("inner") orelse return null;
    for (inner.array.items) |child| if (constantValue(child)) |v| return v;
    return null;
}

const Cleaned = struct { text: []const u8, nonnull: bool };

/// A C type spelling with the availability macros, ownership qualifiers
/// and nullability removed -- nullability noted on the way.
fn clean(arena: Allocator, text: []const u8) !Cleaned {
    var out: std.ArrayList(u8) = .empty;
    var nonnull = false;
    var i: usize = 0;
    while (i < text.len) {
        // Macros with arguments: API_AVAILABLE(...), NS_SWIFT_NAME(...).
        if (std.ascii.isUpper(text[i]) and (i == 0 or text[i - 1] == ' ')) {
            var j = i;
            while (j < text.len and (std.ascii.isUpper(text[j]) or text[j] == '_')) j += 1;
            // Attribute macros without arguments: NS_RETURNS_INNER_POINTER.
            if (j < text.len and text[j] == ' ' and j - i > 3 and
                std.mem.indexOfScalar(u8, text[i..j], '_') != null)
            {
                i = j + 1;
                continue;
            }
            if (j < text.len and text[j] == '(' and j - i > 3) {
                var depth: usize = 0;
                while (j < text.len) : (j += 1) {
                    if (text[j] == '(') depth += 1;
                    if (text[j] == ')') {
                        depth -= 1;
                        if (depth == 0) break;
                    }
                }
                i = j + 1;
                continue;
            }
        }
        try out.append(arena, text[i]);
        i += 1;
    }
    var result: []const u8 = out.items;
    for ([_][]const u8{ "_Nonnull", "_Nullable_result", "_Nullable", "_Null_unspecified", "__kindof", "__strong", "__weak", "__unsafe_unretained", "__autoreleasing", "__unused" }) |word| {
        if (std.mem.indexOf(u8, result, word) != null) {
            if (std.mem.eql(u8, word, "_Nonnull")) nonnull = true;
            result = try std.mem.replaceOwned(u8, arena, result, word, "");
        }
    }
    // Collapse the spaces left behind.
    var collapsed: std.ArrayList(u8) = .empty;
    for (std.mem.trim(u8, result, " "), 0..) |c, k| {
        if (c == ' ' and k > 0 and collapsed.items.len > 0 and collapsed.items[collapsed.items.len - 1] == ' ') continue;
        try collapsed.append(arena, c);
    }
    const final = try std.mem.replaceOwned(u8, arena, collapsed.items, " *", "*");
    const spaced = try std.mem.replaceOwned(u8, arena, final, "*", " *");
    return .{ .text = std.mem.trim(u8, try std.mem.replaceOwned(u8, arena, spaced, "  ", " "), " "), .nonnull = nonnull };
}

fn scalar(name: []const u8) ?[]const u8 {
    const table = .{
        .{ "BOOL", "bool" },                      .{ "bool", "bool" },
        .{ "_Bool", "bool" },                     .{ "NSInteger", "objc.Integer" },
        .{ "long", "objc.Integer" },              .{ "NSUInteger", "objc.UInteger" },
        .{ "unsigned long", "objc.UInteger" },    .{ "int", "c_int" },
        .{ "unsigned int", "c_uint" },            .{ "short", "c_short" },
        .{ "unsigned short", "c_ushort" },        .{ "long long", "c_longlong" },
        .{ "unsigned long long", "c_ulonglong" }, .{ "char", "u8" },
        .{ "signed char", "i8" },                 .{ "unsigned char", "u8" },
        .{ "float", "f32" },                      .{ "double", "f64" },
        .{ "CGFloat", "cg.Float" },               .{ "int8_t", "i8" },
        .{ "int16_t", "i16" },                    .{ "int32_t", "i32" },
        .{ "int64_t", "i64" },                    .{ "uint8_t", "u8" },
        .{ "uint16_t", "u16" },                   .{ "uint32_t", "u32" },
        .{ "uint64_t", "u64" },                   .{ "size_t", "usize" },
        .{ "unichar", "u16" },                    .{ "NSTimeInterval", "f64" },
        .{ "pid_t", "c_int" },                    .{ "CGDirectDisplayID", "u32" },
    };
    inline for (table) |entry| if (std.mem.eql(u8, name, entry[0])) return entry[1];
    return null;
}

fn structType(name: []const u8) ?[]const u8 {
    const table = .{
        .{ "NSRect", "cg.Rect" },                              .{ "CGRect", "cg.Rect" },
        .{ "struct CGRect", "cg.Rect" },                       .{ "NSPoint", "cg.Point" },
        .{ "CGPoint", "cg.Point" },                            .{ "struct CGPoint", "cg.Point" },
        .{ "NSSize", "cg.Size" },                              .{ "CGSize", "cg.Size" },
        .{ "struct CGSize", "cg.Size" },                       .{ "CGVector", "cg.Vector" },
        .{ "struct CGVector", "cg.Vector" },                   .{ "CGAffineTransform", "cg.AffineTransform" },
        .{ "struct CGAffineTransform", "cg.AffineTransform" }, .{ "NSRange", "objc.Range" },
        .{ "struct _NSRange", "objc.Range" },
    };
    inline for (table) |entry| if (std.mem.eql(u8, name, entry[0])) return entry[1];
    return null;
}

/// A CoreGraphics handle, as the `cg` type that wraps it. Each is a struct
/// over one pointer, which `objc.abi` passes as the pointer.
fn cgHandle(name: []const u8) ?[]const u8 {
    const table = .{
        .{ "CGImageRef", "cg.Image" },           .{ "CGColorRef", "cg.Color" },
        .{ "CGColorSpaceRef", "cg.ColorSpace" }, .{ "CGContextRef", "cg.Context" },
        .{ "CGPathRef", "cg.Path" },             .{ "CGMutablePathRef", "cg.MutablePath" },
        .{ "CGGradientRef", "cg.Gradient" },     .{ "CGLayerRef", "cg.Layer" },
    };
    inline for (table) |entry| if (std.mem.eql(u8, name, entry[0])) return entry[1];
    return null;
}

/// The property an implicit accessor belongs to: `setTitle:` to `title`,
/// `title` to itself.
fn accessorProperty(selector: []const u8) []const u8 {
    if (std.mem.startsWith(u8, selector, "set") and std.mem.endsWith(u8, selector, ":") and selector.len > 4) {
        const Lowered = struct {
            var buffer: [256]u8 = undefined;
        };
        const name = selector[3 .. selector.len - 1];
        if (name.len > Lowered.buffer.len) return selector;
        @memcpy(Lowered.buffer[0..name.len], name);
        Lowered.buffer[0] = std.ascii.toLower(name[0]);
        return Lowered.buffer[0..name.len];
    }
    return selector;
}

fn foundationType(name: []const u8) ?[]const u8 {
    const table = .{
        .{ "NSString", "foundation.String" },     .{ "NSNumber", "foundation.Number" },
        .{ "NSData", "foundation.Data" },         .{ "NSURL", "foundation.Url" },
        .{ "NSError", "foundation.ErrorObject" },
    };
    inline for (table) |entry| if (std.mem.eql(u8, name, entry[0])) return entry[1];
    return null;
}

fn backingBits(backing: []const u8) u16 {
    if (std.mem.indexOf(u8, backing, "Integer") != null or std.mem.indexOf(u8, backing, "longlong") != null or
        std.mem.endsWith(u8, backing, "64")) return 64;
    if (std.mem.endsWith(u8, backing, "16") or std.mem.endsWith(u8, backing, "short")) return 16;
    if (std.mem.endsWith(u8, backing, "8")) return 8;
    return 32;
}

/// The part every constant of `e` starts with, cut back to a word
/// boundary: `NSWindowStyleMask` for `NSWindowStyleMaskTitled`.
fn constantPrefix(e: Enum) []const u8 {
    var prefix: []const u8 = if (e.constants.len == 1) e.name else e.constants[0].name;
    for (e.constants) |c| {
        const n = std.mem.indexOfDiff(u8, prefix, c.name) orelse prefix.len;
        prefix = prefix[0..@min(n, prefix.len)];
    }
    if (e.constants.len == 1 and !std.mem.startsWith(u8, e.constants[0].name, prefix)) prefix = manifest.prefixes[0];
    while (prefix.len > 0) {
        var ok = true;
        for (e.constants) |c| {
            if (c.name.len <= prefix.len or !(std.ascii.isUpper(c.name[prefix.len]) or std.ascii.isDigit(c.name[prefix.len]))) ok = false;
        }
        if (ok) break;
        prefix = prefix[0 .. prefix.len - 1];
    }
    return prefix;
}

fn stripPrefix(name: []const u8) []const u8 {
    // Only before a word: `MTL4CounterHeapType` keeps its prefix, since
    // `4CounterHeapType` is not a name.
    for (manifest.prefixes) |prefix| {
        if (std.mem.startsWith(u8, name, prefix) and name.len > prefix.len and std.ascii.isUpper(name[prefix.len])) {
            return name[prefix.len..];
        }
    }
    return name;
}

fn lowerFramework() []const u8 {
    const Lower = struct {
        const value = blk: {
            var buffer: [manifest.framework.len]u8 = undefined;
            for (manifest.framework, &buffer) |c, *slot| slot.* = std.ascii.toLower(c);
            const final = buffer;
            break :blk &final;
        };
    };
    return Lower.value;
}

/// `initWithContentRect:styleMask:backing:defer:` to
/// `initWithContentRectStyleMaskBackingDefer`.
fn methodName(arena: Allocator, selector: []const u8) ![]const u8 {
    var out: std.ArrayList(u8) = .empty;
    var it = std.mem.splitScalar(u8, selector, ':');
    var first = true;
    while (it.next()) |piece| {
        if (piece.len == 0) continue;
        if (first) {
            try out.appendSlice(arena, piece);
            first = false;
        } else {
            try out.append(arena, std.ascii.toUpper(piece[0]));
            try out.appendSlice(arena, piece[1..]);
        }
    }
    return out.items;
}

fn splitTopLevelComma(text: []const u8) ?[2][]const u8 {
    var depth: usize = 0;
    for (text, 0..) |c, i| switch (c) {
        '<' => depth += 1,
        '>' => depth -|= 1,
        ',' => if (depth == 0) return .{ std.mem.trim(u8, text[0..i], " "), std.mem.trim(u8, text[i + 1 ..], " ") },
        else => {},
    };
    return null;
}

/// Whether `name` is spelled like an Objective-C class: a capital-letter
/// prefix, then more of an identifier -- `NSWindow`, `NSURL`, `CIFilter`.
/// Scalars and C structs are matched before this is asked.
fn isClassName(name: []const u8) bool {
    if (name.len < 3 or !std.ascii.isUpper(name[0]) or !std.ascii.isUpper(name[1])) return false;
    for (name) |c| if (!std.ascii.isAlphanumeric(c)) return false;
    return true;
}

fn contains(list: []const []const u8, name: []const u8) bool {
    for (list) |item| if (std.mem.eql(u8, item, name)) return true;
    return false;
}

/// Names declared at the top of the generated file, which a parameter
/// may not shadow.
fn isFileScope(name: []const u8) bool {
    return contains(&.{ "objc", "foundation", "cg", "inherits", "lookUp", "framework" }, name) or
        cgHandle(name) != null;
}

/// An identifier, quoted with `@"..."` when it is a keyword or a
/// primitive type name.
fn ident(name: []const u8) std.fmt.Alt([]const u8, formatIdent) {
    return .{ .data = name };
}

fn formatIdent(name: []const u8, w: *std.Io.Writer) std.Io.Writer.Error!void {
    if (std.zig.isValidId(name) and !std.zig.primitives.isPrimitive(name)) {
        try w.writeAll(name);
    } else {
        try w.print("@\"{s}\"", .{name});
    }
}
