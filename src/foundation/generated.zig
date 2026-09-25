//! Foundation wrappers generated from the macOS SDK by `zig build generate`,
//! from the manifest in `tools/objc_gen/foundation.zig`. Do not edit: add to the
//! manifest and regenerate, or write a hand-made wrapper beside this file.

const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const cg = @import("../cg/cg.zig");
// Snake case, which no generated method is: `-[MTLTexture iosurface]`
// would otherwise hide it.
const io_surface = @import("../iosurface/iosurface.zig");

/// Whether `Descendant` is `Ancestor`, or inherits from it.
fn inherits(comptime Descendant: type, comptime Ancestor: type) bool {
    if (Ancestor == objc.Object) return true;
    comptime var current: type = Descendant;
    inline while (true) {
        if (current == Ancestor) return true;
        if (current.Super == objc.Object) return false;
        current = current.Super;
    }
}

fn lookUp(comptime name: [:0]const u8) objc.Class {
    return objc.getClass(name) orelse @panic(name ++ " is not loaded: link " ++ framework);
}

const framework = "Foundation";

/// Every constant and C function is linked weakly: one that a newer SDK
/// declares and the running macOS lacks leaves the program able to start,
/// and panics only if it is used.
fn missing(comptime name: []const u8) noreturn {
    @panic(name ++ " is not in this version of macOS");
}

/// `NSComparisonResult`.
pub const ComparisonResult = enum(objc.Integer) {
    ascending = -1,
    same = 0,
    descending = 1,
    _,
};

/// `NSSearchPathDirectory`.
pub const SearchPathDirectory = enum(objc.UInteger) {
    application_directory = 1,
    demo_application_directory = 2,
    developer_application_directory = 3,
    admin_application_directory = 4,
    library_directory = 5,
    developer_directory = 6,
    user_directory = 7,
    documentation_directory = 8,
    document_directory = 9,
    core_service_directory = 10,
    autosaved_information_directory = 11,
    desktop_directory = 12,
    caches_directory = 13,
    application_support_directory = 14,
    downloads_directory = 15,
    input_methods_directory = 16,
    movies_directory = 17,
    music_directory = 18,
    pictures_directory = 19,
    printer_description_directory = 20,
    shared_public_directory = 21,
    preference_panes_directory = 22,
    application_scripts_directory = 23,
    item_replacement_directory = 99,
    all_applications_directory = 100,
    all_libraries_directory = 101,
    trash_directory = 102,
    _,
};

/// `NSSearchPathDomainMask`.
pub const SearchPathDomainMask = packed struct(u64) {
    user_domain_mask: bool = false,
    local_domain_mask: bool = false,
    network_domain_mask: bool = false,
    system_domain_mask: bool = false,
    _4: u60 = 0,
    pub const all_domains_mask: SearchPathDomainMask = @fromBackingInt(0xffff);
};

/// `NSQualityOfService`.
pub const QualityOfService = enum(objc.Integer) {
    user_interactive = 33,
    user_initiated = 25,
    utility = 17,
    background = 9,
    default = -1,
    _,
};

// -- constants and functions -----------------------------------------------

/// `NSFoundationVersionNumber`.
pub fn foundationVersionNumber() f64 {
    const symbol = @extern(?*const objc.abi.Abi(f64), .{ .name = "NSFoundationVersionNumber", .linkage = .weak }) orelse missing("NSFoundationVersionNumber");
    return objc.abi.fromAbi(f64, symbol.*);
}

/// `NSStringFromSelector`.
pub fn stringFromSelector(a_selector: objc.Sel) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Sel)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSStringFromSelector", .linkage = .weak }) orelse missing("NSStringFromSelector");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(objc.Sel, a_selector)));
}

/// `NSSelectorFromString`.
pub fn selectorFromString(a_selector_name: foundation.String) objc.Sel {
    const function = @extern(?*const fn (objc.abi.Abi(foundation.String)) callconv(.c) objc.abi.Abi(objc.Sel), .{ .name = "NSSelectorFromString", .linkage = .weak }) orelse missing("NSSelectorFromString");
    return objc.abi.fromAbi(objc.Sel, function(objc.abi.toAbi(foundation.String, a_selector_name)));
}

/// `NSStringFromClass`.
pub fn stringFromClass(a_class: objc.Class) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Class)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSStringFromClass", .linkage = .weak }) orelse missing("NSStringFromClass");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(objc.Class, a_class)));
}

/// `NSClassFromString`.
pub fn classFromString(a_class_name: foundation.String) ?objc.Class {
    const function = @extern(?*const fn (objc.abi.Abi(foundation.String)) callconv(.c) objc.abi.Abi(?objc.Class), .{ .name = "NSClassFromString", .linkage = .weak }) orelse missing("NSClassFromString");
    return objc.abi.fromAbi(?objc.Class, function(objc.abi.toAbi(foundation.String, a_class_name)));
}

/// `NSStringFromProtocol`.
pub fn stringFromProtocol(proto: objc.Protocol) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Protocol)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSStringFromProtocol", .linkage = .weak }) orelse missing("NSStringFromProtocol");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(objc.Protocol, proto)));
}

/// `NSProtocolFromString`.
pub fn protocolFromString(namestr: foundation.String) ?objc.Protocol {
    const function = @extern(?*const fn (objc.abi.Abi(foundation.String)) callconv(.c) objc.abi.Abi(?objc.Protocol), .{ .name = "NSProtocolFromString", .linkage = .weak }) orelse missing("NSProtocolFromString");
    return objc.abi.fromAbi(?objc.Protocol, function(objc.abi.toAbi(foundation.String, namestr)));
}

/// `NSGetSizeAndAlignment`.
pub fn getSizeAndAlignment(type_ptr: [*:0]const u8, sizep: ?*objc.UInteger, alignp: ?*objc.UInteger) [*:0]const u8 {
    const function = @extern(?*const fn (objc.abi.Abi([*:0]const u8), objc.abi.Abi(?*objc.UInteger), objc.abi.Abi(?*objc.UInteger)) callconv(.c) objc.abi.Abi([*:0]const u8), .{ .name = "NSGetSizeAndAlignment", .linkage = .weak }) orelse missing("NSGetSizeAndAlignment");
    return objc.abi.fromAbi([*:0]const u8, function(objc.abi.toAbi([*:0]const u8, type_ptr), objc.abi.toAbi(?*objc.UInteger, sizep), objc.abi.toAbi(?*objc.UInteger, alignp)));
}

/// `NSLogv`.
pub fn logv(arg: ?objc.Object, arg_: ?[*:0]const u8) void {
    const function = @extern(?*const fn (objc.abi.Abi(?objc.Object), objc.abi.Abi(?[*:0]const u8)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSLogv", .linkage = .weak }) orelse missing("NSLogv");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(?objc.Object, arg), objc.abi.toAbi(?[*:0]const u8, arg_)));
}

/// `NSDefaultMallocZone`.
pub fn defaultMallocZone() objc.Object {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(objc.Object), .{ .name = "NSDefaultMallocZone", .linkage = .weak }) orelse missing("NSDefaultMallocZone");
    return objc.abi.fromAbi(objc.Object, function());
}

/// `NSCreateZone`. What it returns is yours to release.
pub fn createZone(start_size: objc.UInteger, granularity: objc.UInteger, can_free: bool) objc.Object {
    const function = @extern(?*const fn (objc.abi.Abi(objc.UInteger), objc.abi.Abi(objc.UInteger), objc.abi.Abi(bool)) callconv(.c) objc.abi.Abi(objc.Object), .{ .name = "NSCreateZone", .linkage = .weak }) orelse missing("NSCreateZone");
    return objc.abi.fromAbi(objc.Object, function(objc.abi.toAbi(objc.UInteger, start_size), objc.abi.toAbi(objc.UInteger, granularity), objc.abi.toAbi(bool, can_free)));
}

/// `NSRecycleZone`.
pub fn recycleZone(zone: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSRecycleZone", .linkage = .weak }) orelse missing("NSRecycleZone");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, zone)));
}

/// `NSSetZoneName`.
pub fn setZoneName(zone: ?objc.Object, name: foundation.String) void {
    const function = @extern(?*const fn (objc.abi.Abi(?objc.Object), objc.abi.Abi(foundation.String)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSSetZoneName", .linkage = .weak }) orelse missing("NSSetZoneName");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(?objc.Object, zone), objc.abi.toAbi(foundation.String, name)));
}

/// `NSZoneName`.
pub fn zoneName(zone: ?objc.Object) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(?objc.Object)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSZoneName", .linkage = .weak }) orelse missing("NSZoneName");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(?objc.Object, zone)));
}

/// `NSZoneFromPointer`.
pub fn zoneFromPointer(ptr: ?*anyopaque) ?objc.Object {
    const function = @extern(?*const fn (objc.abi.Abi(?*anyopaque)) callconv(.c) objc.abi.Abi(?objc.Object), .{ .name = "NSZoneFromPointer", .linkage = .weak }) orelse missing("NSZoneFromPointer");
    return objc.abi.fromAbi(?objc.Object, function(objc.abi.toAbi(?*anyopaque, ptr)));
}

/// `NSZoneMalloc`.
pub fn zoneMalloc(zone: ?objc.Object, size: objc.UInteger) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(?objc.Object), objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSZoneMalloc", .linkage = .weak }) orelse missing("NSZoneMalloc");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(?objc.Object, zone), objc.abi.toAbi(objc.UInteger, size)));
}

/// `NSZoneCalloc`.
pub fn zoneCalloc(zone: ?objc.Object, num_elems: objc.UInteger, byte_size: objc.UInteger) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(?objc.Object), objc.abi.Abi(objc.UInteger), objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSZoneCalloc", .linkage = .weak }) orelse missing("NSZoneCalloc");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(?objc.Object, zone), objc.abi.toAbi(objc.UInteger, num_elems), objc.abi.toAbi(objc.UInteger, byte_size)));
}

/// `NSZoneRealloc`.
pub fn zoneRealloc(zone: ?objc.Object, ptr: ?*anyopaque, size: objc.UInteger) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(?objc.Object), objc.abi.Abi(?*anyopaque), objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSZoneRealloc", .linkage = .weak }) orelse missing("NSZoneRealloc");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(?objc.Object, zone), objc.abi.toAbi(?*anyopaque, ptr), objc.abi.toAbi(objc.UInteger, size)));
}

/// `NSZoneFree`.
pub fn zoneFree(zone: ?objc.Object, ptr: ?*anyopaque) void {
    const function = @extern(?*const fn (objc.abi.Abi(?objc.Object), objc.abi.Abi(?*anyopaque)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSZoneFree", .linkage = .weak }) orelse missing("NSZoneFree");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(?objc.Object, zone), objc.abi.toAbi(?*anyopaque, ptr)));
}

/// `NSAllocateCollectable`.
pub fn allocateCollectable(size: objc.UInteger, options: objc.UInteger) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(objc.UInteger), objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSAllocateCollectable", .linkage = .weak }) orelse missing("NSAllocateCollectable");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(objc.UInteger, size), objc.abi.toAbi(objc.UInteger, options)));
}

/// `NSReallocateCollectable`.
pub fn reallocateCollectable(ptr: ?*anyopaque, size: objc.UInteger, options: objc.UInteger) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(?*anyopaque), objc.abi.Abi(objc.UInteger), objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSReallocateCollectable", .linkage = .weak }) orelse missing("NSReallocateCollectable");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(?*anyopaque, ptr), objc.abi.toAbi(objc.UInteger, size), objc.abi.toAbi(objc.UInteger, options)));
}

/// `NSPageSize`.
pub fn pageSize() objc.UInteger {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(objc.UInteger), .{ .name = "NSPageSize", .linkage = .weak }) orelse missing("NSPageSize");
    return objc.abi.fromAbi(objc.UInteger, function());
}

/// `NSLogPageSize`.
pub fn logPageSize() objc.UInteger {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(objc.UInteger), .{ .name = "NSLogPageSize", .linkage = .weak }) orelse missing("NSLogPageSize");
    return objc.abi.fromAbi(objc.UInteger, function());
}

/// `NSRoundUpToMultipleOfPageSize`.
pub fn roundUpToMultipleOfPageSize(bytes: objc.UInteger) objc.UInteger {
    const function = @extern(?*const fn (objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(objc.UInteger), .{ .name = "NSRoundUpToMultipleOfPageSize", .linkage = .weak }) orelse missing("NSRoundUpToMultipleOfPageSize");
    return objc.abi.fromAbi(objc.UInteger, function(objc.abi.toAbi(objc.UInteger, bytes)));
}

/// `NSRoundDownToMultipleOfPageSize`.
pub fn roundDownToMultipleOfPageSize(bytes: objc.UInteger) objc.UInteger {
    const function = @extern(?*const fn (objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(objc.UInteger), .{ .name = "NSRoundDownToMultipleOfPageSize", .linkage = .weak }) orelse missing("NSRoundDownToMultipleOfPageSize");
    return objc.abi.fromAbi(objc.UInteger, function(objc.abi.toAbi(objc.UInteger, bytes)));
}

/// `NSAllocateMemoryPages`.
pub fn allocateMemoryPages(bytes: objc.UInteger) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSAllocateMemoryPages", .linkage = .weak }) orelse missing("NSAllocateMemoryPages");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(objc.UInteger, bytes)));
}

/// `NSDeallocateMemoryPages`.
pub fn deallocateMemoryPages(ptr: ?*anyopaque, bytes: objc.UInteger) void {
    const function = @extern(?*const fn (objc.abi.Abi(?*anyopaque), objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSDeallocateMemoryPages", .linkage = .weak }) orelse missing("NSDeallocateMemoryPages");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(?*anyopaque, ptr), objc.abi.toAbi(objc.UInteger, bytes)));
}

/// `NSCopyMemoryPages`. What it returns is yours to release.
pub fn copyMemoryPages(source: ?*const anyopaque, dest: ?*anyopaque, bytes: objc.UInteger) void {
    const function = @extern(?*const fn (objc.abi.Abi(?*const anyopaque), objc.abi.Abi(?*anyopaque), objc.abi.Abi(objc.UInteger)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSCopyMemoryPages", .linkage = .weak }) orelse missing("NSCopyMemoryPages");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(?*const anyopaque, source), objc.abi.toAbi(?*anyopaque, dest), objc.abi.toAbi(objc.UInteger, bytes)));
}

/// `NSRealMemoryAvailable`.
pub fn realMemoryAvailable() objc.UInteger {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(objc.UInteger), .{ .name = "NSRealMemoryAvailable", .linkage = .weak }) orelse missing("NSRealMemoryAvailable");
    return objc.abi.fromAbi(objc.UInteger, function());
}

/// `NSAllocateObject`.
pub fn allocateObject(a_class: objc.Class, extra_bytes: objc.UInteger, zone: ?objc.Object) objc.Object {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Class), objc.abi.Abi(objc.UInteger), objc.abi.Abi(?objc.Object)) callconv(.c) objc.abi.Abi(objc.Object), .{ .name = "NSAllocateObject", .linkage = .weak }) orelse missing("NSAllocateObject");
    return objc.abi.fromAbi(objc.Object, function(objc.abi.toAbi(objc.Class, a_class), objc.abi.toAbi(objc.UInteger, extra_bytes), objc.abi.toAbi(?objc.Object, zone)));
}

/// `NSDeallocateObject`.
pub fn deallocateObject(object: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSDeallocateObject", .linkage = .weak }) orelse missing("NSDeallocateObject");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, object)));
}

/// `NSCopyObject`. What it returns is yours to release.
pub fn copyObject(object: objc.Object, extra_bytes: objc.UInteger, zone: ?objc.Object) objc.Object {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(objc.UInteger), objc.abi.Abi(?objc.Object)) callconv(.c) objc.abi.Abi(objc.Object), .{ .name = "NSCopyObject", .linkage = .weak }) orelse missing("NSCopyObject");
    return objc.abi.fromAbi(objc.Object, function(objc.abi.toAbi(objc.Object, object), objc.abi.toAbi(objc.UInteger, extra_bytes), objc.abi.toAbi(?objc.Object, zone)));
}

/// `NSShouldRetainWithZone`.
pub fn shouldRetainWithZone(an_object: objc.Object, requested_zone: ?objc.Object) bool {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?objc.Object)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSShouldRetainWithZone", .linkage = .weak }) orelse missing("NSShouldRetainWithZone");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(objc.Object, an_object), objc.abi.toAbi(?objc.Object, requested_zone)));
}

/// `NSIncrementExtraRefCount`.
pub fn incrementExtraRefCount(object: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSIncrementExtraRefCount", .linkage = .weak }) orelse missing("NSIncrementExtraRefCount");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, object)));
}

/// `NSDecrementExtraRefCountWasZero`.
pub fn decrementExtraRefCountWasZero(object: objc.Object) bool {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSDecrementExtraRefCountWasZero", .linkage = .weak }) orelse missing("NSDecrementExtraRefCountWasZero");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(objc.Object, object)));
}

/// `NSExtraRefCount`.
pub fn extraRefCount(object: objc.Object) objc.UInteger {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(objc.UInteger), .{ .name = "NSExtraRefCount", .linkage = .weak }) orelse missing("NSExtraRefCount");
    return objc.abi.fromAbi(objc.UInteger, function(objc.abi.toAbi(objc.Object, object)));
}

/// `NSUnionRange`.
pub fn unionRange(range1: objc.Range, range2: objc.Range) objc.Range {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Range), objc.abi.Abi(objc.Range)) callconv(.c) objc.abi.Abi(objc.Range), .{ .name = "NSUnionRange", .linkage = .weak }) orelse missing("NSUnionRange");
    return objc.abi.fromAbi(objc.Range, function(objc.abi.toAbi(objc.Range, range1), objc.abi.toAbi(objc.Range, range2)));
}

/// `NSIntersectionRange`.
pub fn intersectionRange(range1: objc.Range, range2: objc.Range) objc.Range {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Range), objc.abi.Abi(objc.Range)) callconv(.c) objc.abi.Abi(objc.Range), .{ .name = "NSIntersectionRange", .linkage = .weak }) orelse missing("NSIntersectionRange");
    return objc.abi.fromAbi(objc.Range, function(objc.abi.toAbi(objc.Range, range1), objc.abi.toAbi(objc.Range, range2)));
}

/// `NSStringFromRange`.
pub fn stringFromRange(range: objc.Range) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Range)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSStringFromRange", .linkage = .weak }) orelse missing("NSStringFromRange");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(objc.Range, range)));
}

/// `NSRangeFromString`.
pub fn rangeFromString(a_string: foundation.String) objc.Range {
    const function = @extern(?*const fn (objc.abi.Abi(foundation.String)) callconv(.c) objc.abi.Abi(objc.Range), .{ .name = "NSRangeFromString", .linkage = .weak }) orelse missing("NSRangeFromString");
    return objc.abi.fromAbi(objc.Range, function(objc.abi.toAbi(foundation.String, a_string)));
}

/// `NSItemProviderPreferredImageSizeKey`.
pub fn itemProviderPreferredImageSizeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSItemProviderPreferredImageSizeKey", .linkage = .weak }) orelse missing("NSItemProviderPreferredImageSizeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSExtensionJavaScriptPreprocessingResultsKey`.
pub fn extensionJavaScriptPreprocessingResultsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSExtensionJavaScriptPreprocessingResultsKey", .linkage = .weak }) orelse missing("NSExtensionJavaScriptPreprocessingResultsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSItemProviderErrorDomain`.
pub fn itemProviderErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSItemProviderErrorDomain", .linkage = .weak }) orelse missing("NSItemProviderErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformLatinToKatakana`.
pub fn stringTransformLatinToKatakana() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformLatinToKatakana", .linkage = .weak }) orelse missing("NSStringTransformLatinToKatakana");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformLatinToHiragana`.
pub fn stringTransformLatinToHiragana() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformLatinToHiragana", .linkage = .weak }) orelse missing("NSStringTransformLatinToHiragana");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformLatinToHangul`.
pub fn stringTransformLatinToHangul() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformLatinToHangul", .linkage = .weak }) orelse missing("NSStringTransformLatinToHangul");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformLatinToArabic`.
pub fn stringTransformLatinToArabic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformLatinToArabic", .linkage = .weak }) orelse missing("NSStringTransformLatinToArabic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformLatinToHebrew`.
pub fn stringTransformLatinToHebrew() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformLatinToHebrew", .linkage = .weak }) orelse missing("NSStringTransformLatinToHebrew");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformLatinToThai`.
pub fn stringTransformLatinToThai() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformLatinToThai", .linkage = .weak }) orelse missing("NSStringTransformLatinToThai");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformLatinToCyrillic`.
pub fn stringTransformLatinToCyrillic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformLatinToCyrillic", .linkage = .weak }) orelse missing("NSStringTransformLatinToCyrillic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformLatinToGreek`.
pub fn stringTransformLatinToGreek() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformLatinToGreek", .linkage = .weak }) orelse missing("NSStringTransformLatinToGreek");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformToLatin`.
pub fn stringTransformToLatin() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformToLatin", .linkage = .weak }) orelse missing("NSStringTransformToLatin");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformMandarinToLatin`.
pub fn stringTransformMandarinToLatin() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformMandarinToLatin", .linkage = .weak }) orelse missing("NSStringTransformMandarinToLatin");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformHiraganaToKatakana`.
pub fn stringTransformHiraganaToKatakana() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformHiraganaToKatakana", .linkage = .weak }) orelse missing("NSStringTransformHiraganaToKatakana");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformFullwidthToHalfwidth`.
pub fn stringTransformFullwidthToHalfwidth() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformFullwidthToHalfwidth", .linkage = .weak }) orelse missing("NSStringTransformFullwidthToHalfwidth");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformToXMLHex`.
pub fn stringTransformToXMLHex() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformToXMLHex", .linkage = .weak }) orelse missing("NSStringTransformToXMLHex");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformToUnicodeName`.
pub fn stringTransformToUnicodeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformToUnicodeName", .linkage = .weak }) orelse missing("NSStringTransformToUnicodeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformStripCombiningMarks`.
pub fn stringTransformStripCombiningMarks() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformStripCombiningMarks", .linkage = .weak }) orelse missing("NSStringTransformStripCombiningMarks");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringTransformStripDiacritics`.
pub fn stringTransformStripDiacritics() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringTransformStripDiacritics", .linkage = .weak }) orelse missing("NSStringTransformStripDiacritics");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringEncodingDetectionSuggestedEncodingsKey`.
pub fn stringEncodingDetectionSuggestedEncodingsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringEncodingDetectionSuggestedEncodingsKey", .linkage = .weak }) orelse missing("NSStringEncodingDetectionSuggestedEncodingsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringEncodingDetectionDisallowedEncodingsKey`.
pub fn stringEncodingDetectionDisallowedEncodingsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringEncodingDetectionDisallowedEncodingsKey", .linkage = .weak }) orelse missing("NSStringEncodingDetectionDisallowedEncodingsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringEncodingDetectionUseOnlySuggestedEncodingsKey`.
pub fn stringEncodingDetectionUseOnlySuggestedEncodingsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringEncodingDetectionUseOnlySuggestedEncodingsKey", .linkage = .weak }) orelse missing("NSStringEncodingDetectionUseOnlySuggestedEncodingsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringEncodingDetectionAllowLossyKey`.
pub fn stringEncodingDetectionAllowLossyKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringEncodingDetectionAllowLossyKey", .linkage = .weak }) orelse missing("NSStringEncodingDetectionAllowLossyKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringEncodingDetectionFromWindowsKey`.
pub fn stringEncodingDetectionFromWindowsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringEncodingDetectionFromWindowsKey", .linkage = .weak }) orelse missing("NSStringEncodingDetectionFromWindowsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringEncodingDetectionLossySubstitutionKey`.
pub fn stringEncodingDetectionLossySubstitutionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringEncodingDetectionLossySubstitutionKey", .linkage = .weak }) orelse missing("NSStringEncodingDetectionLossySubstitutionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringEncodingDetectionLikelyLanguageKey`.
pub fn stringEncodingDetectionLikelyLanguageKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringEncodingDetectionLikelyLanguageKey", .linkage = .weak }) orelse missing("NSStringEncodingDetectionLikelyLanguageKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCharacterConversionException`.
pub fn characterConversionException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCharacterConversionException", .linkage = .weak }) orelse missing("NSCharacterConversionException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSParseErrorException`.
pub fn parseErrorException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSParseErrorException", .linkage = .weak }) orelse missing("NSParseErrorException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressEstimatedTimeRemainingKey`.
pub fn progressEstimatedTimeRemainingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressEstimatedTimeRemainingKey", .linkage = .weak }) orelse missing("NSProgressEstimatedTimeRemainingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressThroughputKey`.
pub fn progressThroughputKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressThroughputKey", .linkage = .weak }) orelse missing("NSProgressThroughputKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressKindFile`.
pub fn progressKindFile() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressKindFile", .linkage = .weak }) orelse missing("NSProgressKindFile");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileOperationKindKey`.
pub fn progressFileOperationKindKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileOperationKindKey", .linkage = .weak }) orelse missing("NSProgressFileOperationKindKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileOperationKindDownloading`.
pub fn progressFileOperationKindDownloading() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileOperationKindDownloading", .linkage = .weak }) orelse missing("NSProgressFileOperationKindDownloading");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileOperationKindDecompressingAfterDownloading`.
pub fn progressFileOperationKindDecompressingAfterDownloading() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileOperationKindDecompressingAfterDownloading", .linkage = .weak }) orelse missing("NSProgressFileOperationKindDecompressingAfterDownloading");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileOperationKindReceiving`.
pub fn progressFileOperationKindReceiving() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileOperationKindReceiving", .linkage = .weak }) orelse missing("NSProgressFileOperationKindReceiving");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileOperationKindCopying`.
pub fn progressFileOperationKindCopying() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileOperationKindCopying", .linkage = .weak }) orelse missing("NSProgressFileOperationKindCopying");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileOperationKindUploading`.
pub fn progressFileOperationKindUploading() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileOperationKindUploading", .linkage = .weak }) orelse missing("NSProgressFileOperationKindUploading");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileOperationKindDuplicating`.
pub fn progressFileOperationKindDuplicating() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileOperationKindDuplicating", .linkage = .weak }) orelse missing("NSProgressFileOperationKindDuplicating");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileURLKey`.
pub fn progressFileURLKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileURLKey", .linkage = .weak }) orelse missing("NSProgressFileURLKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileTotalCountKey`.
pub fn progressFileTotalCountKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileTotalCountKey", .linkage = .weak }) orelse missing("NSProgressFileTotalCountKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileCompletedCountKey`.
pub fn progressFileCompletedCountKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileCompletedCountKey", .linkage = .weak }) orelse missing("NSProgressFileCompletedCountKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileAnimationImageKey`.
pub fn progressFileAnimationImageKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileAnimationImageKey", .linkage = .weak }) orelse missing("NSProgressFileAnimationImageKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileAnimationImageOriginalRectKey`.
pub fn progressFileAnimationImageOriginalRectKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileAnimationImageOriginalRectKey", .linkage = .weak }) orelse missing("NSProgressFileAnimationImageOriginalRectKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProgressFileIconKey`.
pub fn progressFileIconKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProgressFileIconKey", .linkage = .weak }) orelse missing("NSProgressFileIconKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSBundleDidLoadNotification`.
pub fn bundleDidLoadNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSBundleDidLoadNotification", .linkage = .weak }) orelse missing("NSBundleDidLoadNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLoadedClasses`.
pub fn loadedClasses() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLoadedClasses", .linkage = .weak }) orelse missing("NSLoadedClasses");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSBundleResourceRequestLoadingPriorityUrgent`.
pub fn bundleResourceRequestLoadingPriorityUrgent() f64 {
    const symbol = @extern(?*const objc.abi.Abi(f64), .{ .name = "NSBundleResourceRequestLoadingPriorityUrgent", .linkage = .weak }) orelse missing("NSBundleResourceRequestLoadingPriorityUrgent");
    return objc.abi.fromAbi(f64, symbol.*);
}

/// `NSSystemClockDidChangeNotification`.
pub fn systemClockDidChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSSystemClockDidChangeNotification", .linkage = .weak }) orelse missing("NSSystemClockDidChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierGregorian`.
pub fn calendarIdentifierGregorian() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierGregorian", .linkage = .weak }) orelse missing("NSCalendarIdentifierGregorian");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierBuddhist`.
pub fn calendarIdentifierBuddhist() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierBuddhist", .linkage = .weak }) orelse missing("NSCalendarIdentifierBuddhist");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierChinese`.
pub fn calendarIdentifierChinese() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierChinese", .linkage = .weak }) orelse missing("NSCalendarIdentifierChinese");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierCoptic`.
pub fn calendarIdentifierCoptic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierCoptic", .linkage = .weak }) orelse missing("NSCalendarIdentifierCoptic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierEthiopicAmeteMihret`.
pub fn calendarIdentifierEthiopicAmeteMihret() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierEthiopicAmeteMihret", .linkage = .weak }) orelse missing("NSCalendarIdentifierEthiopicAmeteMihret");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierEthiopicAmeteAlem`.
pub fn calendarIdentifierEthiopicAmeteAlem() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierEthiopicAmeteAlem", .linkage = .weak }) orelse missing("NSCalendarIdentifierEthiopicAmeteAlem");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierHebrew`.
pub fn calendarIdentifierHebrew() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierHebrew", .linkage = .weak }) orelse missing("NSCalendarIdentifierHebrew");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierISO8601`.
pub fn calendarIdentifierISO8601() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierISO8601", .linkage = .weak }) orelse missing("NSCalendarIdentifierISO8601");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierIndian`.
pub fn calendarIdentifierIndian() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierIndian", .linkage = .weak }) orelse missing("NSCalendarIdentifierIndian");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierIslamic`.
pub fn calendarIdentifierIslamic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierIslamic", .linkage = .weak }) orelse missing("NSCalendarIdentifierIslamic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierIslamicCivil`.
pub fn calendarIdentifierIslamicCivil() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierIslamicCivil", .linkage = .weak }) orelse missing("NSCalendarIdentifierIslamicCivil");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierJapanese`.
pub fn calendarIdentifierJapanese() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierJapanese", .linkage = .weak }) orelse missing("NSCalendarIdentifierJapanese");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierPersian`.
pub fn calendarIdentifierPersian() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierPersian", .linkage = .weak }) orelse missing("NSCalendarIdentifierPersian");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierRepublicOfChina`.
pub fn calendarIdentifierRepublicOfChina() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierRepublicOfChina", .linkage = .weak }) orelse missing("NSCalendarIdentifierRepublicOfChina");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierIslamicTabular`.
pub fn calendarIdentifierIslamicTabular() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierIslamicTabular", .linkage = .weak }) orelse missing("NSCalendarIdentifierIslamicTabular");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierIslamicUmmAlQura`.
pub fn calendarIdentifierIslamicUmmAlQura() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierIslamicUmmAlQura", .linkage = .weak }) orelse missing("NSCalendarIdentifierIslamicUmmAlQura");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierBangla`.
pub fn calendarIdentifierBangla() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierBangla", .linkage = .weak }) orelse missing("NSCalendarIdentifierBangla");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierGujarati`.
pub fn calendarIdentifierGujarati() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierGujarati", .linkage = .weak }) orelse missing("NSCalendarIdentifierGujarati");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierKannada`.
pub fn calendarIdentifierKannada() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierKannada", .linkage = .weak }) orelse missing("NSCalendarIdentifierKannada");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierMalayalam`.
pub fn calendarIdentifierMalayalam() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierMalayalam", .linkage = .weak }) orelse missing("NSCalendarIdentifierMalayalam");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierMarathi`.
pub fn calendarIdentifierMarathi() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierMarathi", .linkage = .weak }) orelse missing("NSCalendarIdentifierMarathi");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierOdia`.
pub fn calendarIdentifierOdia() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierOdia", .linkage = .weak }) orelse missing("NSCalendarIdentifierOdia");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierTamil`.
pub fn calendarIdentifierTamil() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierTamil", .linkage = .weak }) orelse missing("NSCalendarIdentifierTamil");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierTelugu`.
pub fn calendarIdentifierTelugu() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierTelugu", .linkage = .weak }) orelse missing("NSCalendarIdentifierTelugu");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierVikram`.
pub fn calendarIdentifierVikram() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierVikram", .linkage = .weak }) orelse missing("NSCalendarIdentifierVikram");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierDangi`.
pub fn calendarIdentifierDangi() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierDangi", .linkage = .weak }) orelse missing("NSCalendarIdentifierDangi");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarIdentifierVietnamese`.
pub fn calendarIdentifierVietnamese() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarIdentifierVietnamese", .linkage = .weak }) orelse missing("NSCalendarIdentifierVietnamese");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCalendarDayChangedNotification`.
pub fn calendarDayChangedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCalendarDayChangedNotification", .linkage = .weak }) orelse missing("NSCalendarDayChangedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NXReadNSObjectFromCoder`.
pub fn nxReadNSObjectFromCoder(decoder: objc.Object) ?objc.Object {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(?objc.Object), .{ .name = "NXReadNSObjectFromCoder", .linkage = .weak }) orelse missing("NXReadNSObjectFromCoder");
    return objc.abi.fromAbi(?objc.Object, function(objc.abi.toAbi(objc.Object, decoder)));
}

/// `NSInflectionConceptsKey`.
pub fn inflectionConceptsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInflectionConceptsKey", .linkage = .weak }) orelse missing("NSInflectionConceptsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInlinePresentationIntentAttributeName`.
pub fn inlinePresentationIntentAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInlinePresentationIntentAttributeName", .linkage = .weak }) orelse missing("NSInlinePresentationIntentAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSAlternateDescriptionAttributeName`.
pub fn alternateDescriptionAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAlternateDescriptionAttributeName", .linkage = .weak }) orelse missing("NSAlternateDescriptionAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSImageURLAttributeName`.
pub fn imageURLAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSImageURLAttributeName", .linkage = .weak }) orelse missing("NSImageURLAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLanguageIdentifierAttributeName`.
pub fn languageIdentifierAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLanguageIdentifierAttributeName", .linkage = .weak }) orelse missing("NSLanguageIdentifierAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMarkdownSourcePositionAttributeName`.
pub fn markdownSourcePositionAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMarkdownSourcePositionAttributeName", .linkage = .weak }) orelse missing("NSMarkdownSourcePositionAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSReplacementIndexAttributeName`.
pub fn replacementIndexAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSReplacementIndexAttributeName", .linkage = .weak }) orelse missing("NSReplacementIndexAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMorphologyAttributeName`.
pub fn morphologyAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMorphologyAttributeName", .linkage = .weak }) orelse missing("NSMorphologyAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInflectionRuleAttributeName`.
pub fn inflectionRuleAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInflectionRuleAttributeName", .linkage = .weak }) orelse missing("NSInflectionRuleAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInflectionAgreementArgumentAttributeName`.
pub fn inflectionAgreementArgumentAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInflectionAgreementArgumentAttributeName", .linkage = .weak }) orelse missing("NSInflectionAgreementArgumentAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInflectionAgreementConceptAttributeName`.
pub fn inflectionAgreementConceptAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInflectionAgreementConceptAttributeName", .linkage = .weak }) orelse missing("NSInflectionAgreementConceptAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInflectionReferentConceptAttributeName`.
pub fn inflectionReferentConceptAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInflectionReferentConceptAttributeName", .linkage = .weak }) orelse missing("NSInflectionReferentConceptAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInflectionAlternativeAttributeName`.
pub fn inflectionAlternativeAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInflectionAlternativeAttributeName", .linkage = .weak }) orelse missing("NSInflectionAlternativeAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocalizedNumberFormatAttributeName`.
pub fn localizedNumberFormatAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocalizedNumberFormatAttributeName", .linkage = .weak }) orelse missing("NSLocalizedNumberFormatAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSListItemDelimiterAttributeName`.
pub fn listItemDelimiterAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSListItemDelimiterAttributeName", .linkage = .weak }) orelse missing("NSListItemDelimiterAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPresentationIntentAttributeName`.
pub fn presentationIntentAttributeName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPresentationIntentAttributeName", .linkage = .weak }) orelse missing("NSPresentationIntentAttributeName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCurrentLocaleDidChangeNotification`.
pub fn currentLocaleDidChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCurrentLocaleDidChangeNotification", .linkage = .weak }) orelse missing("NSCurrentLocaleDidChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleIdentifier`.
pub fn localeIdentifier() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleIdentifier", .linkage = .weak }) orelse missing("NSLocaleIdentifier");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleLanguageCode`.
pub fn localeLanguageCode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleLanguageCode", .linkage = .weak }) orelse missing("NSLocaleLanguageCode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleCountryCode`.
pub fn localeCountryCode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleCountryCode", .linkage = .weak }) orelse missing("NSLocaleCountryCode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleScriptCode`.
pub fn localeScriptCode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleScriptCode", .linkage = .weak }) orelse missing("NSLocaleScriptCode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleVariantCode`.
pub fn localeVariantCode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleVariantCode", .linkage = .weak }) orelse missing("NSLocaleVariantCode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleExemplarCharacterSet`.
pub fn localeExemplarCharacterSet() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleExemplarCharacterSet", .linkage = .weak }) orelse missing("NSLocaleExemplarCharacterSet");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleCalendar`.
pub fn localeCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleCalendar", .linkage = .weak }) orelse missing("NSLocaleCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleCollationIdentifier`.
pub fn localeCollationIdentifier() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleCollationIdentifier", .linkage = .weak }) orelse missing("NSLocaleCollationIdentifier");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleUsesMetricSystem`.
pub fn localeUsesMetricSystem() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleUsesMetricSystem", .linkage = .weak }) orelse missing("NSLocaleUsesMetricSystem");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleMeasurementSystem`.
pub fn localeMeasurementSystem() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleMeasurementSystem", .linkage = .weak }) orelse missing("NSLocaleMeasurementSystem");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleDecimalSeparator`.
pub fn localeDecimalSeparator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleDecimalSeparator", .linkage = .weak }) orelse missing("NSLocaleDecimalSeparator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleGroupingSeparator`.
pub fn localeGroupingSeparator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleGroupingSeparator", .linkage = .weak }) orelse missing("NSLocaleGroupingSeparator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleCurrencySymbol`.
pub fn localeCurrencySymbol() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleCurrencySymbol", .linkage = .weak }) orelse missing("NSLocaleCurrencySymbol");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleCurrencyCode`.
pub fn localeCurrencyCode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleCurrencyCode", .linkage = .weak }) orelse missing("NSLocaleCurrencyCode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleCollatorIdentifier`.
pub fn localeCollatorIdentifier() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleCollatorIdentifier", .linkage = .weak }) orelse missing("NSLocaleCollatorIdentifier");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleQuotationBeginDelimiterKey`.
pub fn localeQuotationBeginDelimiterKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleQuotationBeginDelimiterKey", .linkage = .weak }) orelse missing("NSLocaleQuotationBeginDelimiterKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleQuotationEndDelimiterKey`.
pub fn localeQuotationEndDelimiterKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleQuotationEndDelimiterKey", .linkage = .weak }) orelse missing("NSLocaleQuotationEndDelimiterKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleAlternateQuotationBeginDelimiterKey`.
pub fn localeAlternateQuotationBeginDelimiterKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleAlternateQuotationBeginDelimiterKey", .linkage = .weak }) orelse missing("NSLocaleAlternateQuotationBeginDelimiterKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocaleAlternateQuotationEndDelimiterKey`.
pub fn localeAlternateQuotationEndDelimiterKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocaleAlternateQuotationEndDelimiterKey", .linkage = .weak }) orelse missing("NSLocaleAlternateQuotationEndDelimiterKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSGregorianCalendar`.
pub fn gregorianCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSGregorianCalendar", .linkage = .weak }) orelse missing("NSGregorianCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSBuddhistCalendar`.
pub fn buddhistCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSBuddhistCalendar", .linkage = .weak }) orelse missing("NSBuddhistCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSChineseCalendar`.
pub fn chineseCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSChineseCalendar", .linkage = .weak }) orelse missing("NSChineseCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHebrewCalendar`.
pub fn hebrewCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHebrewCalendar", .linkage = .weak }) orelse missing("NSHebrewCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSIslamicCalendar`.
pub fn islamicCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSIslamicCalendar", .linkage = .weak }) orelse missing("NSIslamicCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSIslamicCivilCalendar`.
pub fn islamicCivilCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSIslamicCivilCalendar", .linkage = .weak }) orelse missing("NSIslamicCivilCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSJapaneseCalendar`.
pub fn japaneseCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSJapaneseCalendar", .linkage = .weak }) orelse missing("NSJapaneseCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSRepublicOfChinaCalendar`.
pub fn republicOfChinaCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSRepublicOfChinaCalendar", .linkage = .weak }) orelse missing("NSRepublicOfChinaCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPersianCalendar`.
pub fn persianCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPersianCalendar", .linkage = .weak }) orelse missing("NSPersianCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSIndianCalendar`.
pub fn indianCalendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSIndianCalendar", .linkage = .weak }) orelse missing("NSIndianCalendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSISO8601Calendar`.
pub fn iso8601Calendar() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSISO8601Calendar", .linkage = .weak }) orelse missing("NSISO8601Calendar");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPersonNameComponentKey`.
pub fn personNameComponentKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPersonNameComponentKey", .linkage = .weak }) orelse missing("NSPersonNameComponentKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPersonNameComponentGivenName`.
pub fn personNameComponentGivenName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPersonNameComponentGivenName", .linkage = .weak }) orelse missing("NSPersonNameComponentGivenName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPersonNameComponentFamilyName`.
pub fn personNameComponentFamilyName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPersonNameComponentFamilyName", .linkage = .weak }) orelse missing("NSPersonNameComponentFamilyName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPersonNameComponentMiddleName`.
pub fn personNameComponentMiddleName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPersonNameComponentMiddleName", .linkage = .weak }) orelse missing("NSPersonNameComponentMiddleName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPersonNameComponentPrefix`.
pub fn personNameComponentPrefix() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPersonNameComponentPrefix", .linkage = .weak }) orelse missing("NSPersonNameComponentPrefix");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPersonNameComponentSuffix`.
pub fn personNameComponentSuffix() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPersonNameComponentSuffix", .linkage = .weak }) orelse missing("NSPersonNameComponentSuffix");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPersonNameComponentNickname`.
pub fn personNameComponentNickname() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPersonNameComponentNickname", .linkage = .weak }) orelse missing("NSPersonNameComponentNickname");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPersonNameComponentDelimiter`.
pub fn personNameComponentDelimiter() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPersonNameComponentDelimiter", .linkage = .weak }) orelse missing("NSPersonNameComponentDelimiter");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDecimalCopy`. What it returns is yours to release.
pub fn decimalCopy(destination: objc.Object, source: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSDecimalCopy", .linkage = .weak }) orelse missing("NSDecimalCopy");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, destination), objc.abi.toAbi(objc.Object, source)));
}

/// `NSDecimalCompact`.
pub fn decimalCompact(number: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSDecimalCompact", .linkage = .weak }) orelse missing("NSDecimalCompact");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, number)));
}

/// `NSDecimalCompare`.
pub fn decimalCompare(left_operand: objc.Object, right_operand: objc.Object) ComparisonResult {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(ComparisonResult), .{ .name = "NSDecimalCompare", .linkage = .weak }) orelse missing("NSDecimalCompare");
    return objc.abi.fromAbi(ComparisonResult, function(objc.abi.toAbi(objc.Object, left_operand), objc.abi.toAbi(objc.Object, right_operand)));
}

/// `NSDecimalString`.
pub fn decimalString(dcm: objc.Object, locale: ?objc.Object) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?objc.Object)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSDecimalString", .linkage = .weak }) orelse missing("NSDecimalString");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(objc.Object, dcm), objc.abi.toAbi(?objc.Object, locale)));
}

/// `NSGenericException`.
pub fn genericException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSGenericException", .linkage = .weak }) orelse missing("NSGenericException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSRangeException`.
pub fn rangeException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSRangeException", .linkage = .weak }) orelse missing("NSRangeException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInvalidArgumentException`.
pub fn invalidArgumentException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInvalidArgumentException", .linkage = .weak }) orelse missing("NSInvalidArgumentException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInternalInconsistencyException`.
pub fn internalInconsistencyException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInternalInconsistencyException", .linkage = .weak }) orelse missing("NSInternalInconsistencyException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMallocException`.
pub fn mallocException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMallocException", .linkage = .weak }) orelse missing("NSMallocException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSObjectInaccessibleException`.
pub fn objectInaccessibleException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSObjectInaccessibleException", .linkage = .weak }) orelse missing("NSObjectInaccessibleException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSObjectNotAvailableException`.
pub fn objectNotAvailableException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSObjectNotAvailableException", .linkage = .weak }) orelse missing("NSObjectNotAvailableException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDestinationInvalidException`.
pub fn destinationInvalidException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDestinationInvalidException", .linkage = .weak }) orelse missing("NSDestinationInvalidException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPortTimeoutException`.
pub fn portTimeoutException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPortTimeoutException", .linkage = .weak }) orelse missing("NSPortTimeoutException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInvalidSendPortException`.
pub fn invalidSendPortException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInvalidSendPortException", .linkage = .weak }) orelse missing("NSInvalidSendPortException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInvalidReceivePortException`.
pub fn invalidReceivePortException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInvalidReceivePortException", .linkage = .weak }) orelse missing("NSInvalidReceivePortException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPortSendException`.
pub fn portSendException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPortSendException", .linkage = .weak }) orelse missing("NSPortSendException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPortReceiveException`.
pub fn portReceiveException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPortReceiveException", .linkage = .weak }) orelse missing("NSPortReceiveException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSOldStyleException`.
pub fn oldStyleException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSOldStyleException", .linkage = .weak }) orelse missing("NSOldStyleException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInconsistentArchiveException`.
pub fn inconsistentArchiveException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInconsistentArchiveException", .linkage = .weak }) orelse missing("NSInconsistentArchiveException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSGetUncaughtExceptionHandler`.
pub fn getUncaughtExceptionHandler() ?objc.Object {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(?objc.Object), .{ .name = "NSGetUncaughtExceptionHandler", .linkage = .weak }) orelse missing("NSGetUncaughtExceptionHandler");
    return objc.abi.fromAbi(?objc.Object, function());
}

/// `NSSetUncaughtExceptionHandler`.
pub fn setUncaughtExceptionHandler(arg: ?objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(?objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSSetUncaughtExceptionHandler", .linkage = .weak }) orelse missing("NSSetUncaughtExceptionHandler");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(?objc.Object, arg)));
}

/// `NSAssertionHandlerKey`.
pub fn assertionHandlerKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAssertionHandlerKey", .linkage = .weak }) orelse missing("NSAssertionHandlerKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDecimalNumberExactnessException`.
pub fn decimalNumberExactnessException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDecimalNumberExactnessException", .linkage = .weak }) orelse missing("NSDecimalNumberExactnessException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDecimalNumberOverflowException`.
pub fn decimalNumberOverflowException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDecimalNumberOverflowException", .linkage = .weak }) orelse missing("NSDecimalNumberOverflowException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDecimalNumberUnderflowException`.
pub fn decimalNumberUnderflowException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDecimalNumberUnderflowException", .linkage = .weak }) orelse missing("NSDecimalNumberUnderflowException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDecimalNumberDivideByZeroException`.
pub fn decimalNumberDivideByZeroException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDecimalNumberDivideByZeroException", .linkage = .weak }) orelse missing("NSDecimalNumberDivideByZeroException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCocoaErrorDomain`.
pub fn cocoaErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCocoaErrorDomain", .linkage = .weak }) orelse missing("NSCocoaErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPOSIXErrorDomain`.
pub fn posixErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPOSIXErrorDomain", .linkage = .weak }) orelse missing("NSPOSIXErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSOSStatusErrorDomain`.
pub fn osStatusErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSOSStatusErrorDomain", .linkage = .weak }) orelse missing("NSOSStatusErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMachErrorDomain`.
pub fn machErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMachErrorDomain", .linkage = .weak }) orelse missing("NSMachErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUnderlyingErrorKey`.
pub fn underlyingErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUnderlyingErrorKey", .linkage = .weak }) orelse missing("NSUnderlyingErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMultipleUnderlyingErrorsKey`.
pub fn multipleUnderlyingErrorsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMultipleUnderlyingErrorsKey", .linkage = .weak }) orelse missing("NSMultipleUnderlyingErrorsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocalizedDescriptionKey`.
pub fn localizedDescriptionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocalizedDescriptionKey", .linkage = .weak }) orelse missing("NSLocalizedDescriptionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocalizedFailureReasonErrorKey`.
pub fn localizedFailureReasonErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocalizedFailureReasonErrorKey", .linkage = .weak }) orelse missing("NSLocalizedFailureReasonErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocalizedRecoverySuggestionErrorKey`.
pub fn localizedRecoverySuggestionErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocalizedRecoverySuggestionErrorKey", .linkage = .weak }) orelse missing("NSLocalizedRecoverySuggestionErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocalizedRecoveryOptionsErrorKey`.
pub fn localizedRecoveryOptionsErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocalizedRecoveryOptionsErrorKey", .linkage = .weak }) orelse missing("NSLocalizedRecoveryOptionsErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSRecoveryAttempterErrorKey`.
pub fn recoveryAttempterErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSRecoveryAttempterErrorKey", .linkage = .weak }) orelse missing("NSRecoveryAttempterErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHelpAnchorErrorKey`.
pub fn helpAnchorErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHelpAnchorErrorKey", .linkage = .weak }) orelse missing("NSHelpAnchorErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDebugDescriptionErrorKey`.
pub fn debugDescriptionErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDebugDescriptionErrorKey", .linkage = .weak }) orelse missing("NSDebugDescriptionErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocalizedFailureErrorKey`.
pub fn localizedFailureErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocalizedFailureErrorKey", .linkage = .weak }) orelse missing("NSLocalizedFailureErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStringEncodingErrorKey`.
pub fn stringEncodingErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStringEncodingErrorKey", .linkage = .weak }) orelse missing("NSStringEncodingErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLErrorKey`.
pub fn urlErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLErrorKey", .linkage = .weak }) orelse missing("NSURLErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFilePathErrorKey`.
pub fn filePathErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFilePathErrorKey", .linkage = .weak }) orelse missing("NSFilePathErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDefaultRunLoopMode`.
pub fn defaultRunLoopMode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDefaultRunLoopMode", .linkage = .weak }) orelse missing("NSDefaultRunLoopMode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSRunLoopCommonModes`.
pub fn runLoopCommonModes() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSRunLoopCommonModes", .linkage = .weak }) orelse missing("NSRunLoopCommonModes");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHandleOperationException`.
pub fn fileHandleOperationException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHandleOperationException", .linkage = .weak }) orelse missing("NSFileHandleOperationException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHandleReadCompletionNotification`.
pub fn fileHandleReadCompletionNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHandleReadCompletionNotification", .linkage = .weak }) orelse missing("NSFileHandleReadCompletionNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHandleReadToEndOfFileCompletionNotification`.
pub fn fileHandleReadToEndOfFileCompletionNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHandleReadToEndOfFileCompletionNotification", .linkage = .weak }) orelse missing("NSFileHandleReadToEndOfFileCompletionNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHandleConnectionAcceptedNotification`.
pub fn fileHandleConnectionAcceptedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHandleConnectionAcceptedNotification", .linkage = .weak }) orelse missing("NSFileHandleConnectionAcceptedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHandleDataAvailableNotification`.
pub fn fileHandleDataAvailableNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHandleDataAvailableNotification", .linkage = .weak }) orelse missing("NSFileHandleDataAvailableNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHandleNotificationDataItem`.
pub fn fileHandleNotificationDataItem() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHandleNotificationDataItem", .linkage = .weak }) orelse missing("NSFileHandleNotificationDataItem");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHandleNotificationFileHandleItem`.
pub fn fileHandleNotificationFileHandleItem() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHandleNotificationFileHandleItem", .linkage = .weak }) orelse missing("NSFileHandleNotificationFileHandleItem");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHandleNotificationMonitorModes`.
pub fn fileHandleNotificationMonitorModes() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHandleNotificationMonitorModes", .linkage = .weak }) orelse missing("NSFileHandleNotificationMonitorModes");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUserName`.
pub fn userName() foundation.String {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSUserName", .linkage = .weak }) orelse missing("NSUserName");
    return objc.abi.fromAbi(foundation.String, function());
}

/// `NSFullUserName`.
pub fn fullUserName() foundation.String {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSFullUserName", .linkage = .weak }) orelse missing("NSFullUserName");
    return objc.abi.fromAbi(foundation.String, function());
}

/// `NSHomeDirectory`.
pub fn homeDirectory() foundation.String {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSHomeDirectory", .linkage = .weak }) orelse missing("NSHomeDirectory");
    return objc.abi.fromAbi(foundation.String, function());
}

/// `NSHomeDirectoryForUser`.
pub fn homeDirectoryForUser(user_name: ?foundation.String) ?foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(?foundation.String)) callconv(.c) objc.abi.Abi(?foundation.String), .{ .name = "NSHomeDirectoryForUser", .linkage = .weak }) orelse missing("NSHomeDirectoryForUser");
    return objc.abi.fromAbi(?foundation.String, function(objc.abi.toAbi(?foundation.String, user_name)));
}

/// `NSTemporaryDirectory`.
pub fn temporaryDirectory() foundation.String {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSTemporaryDirectory", .linkage = .weak }) orelse missing("NSTemporaryDirectory");
    return objc.abi.fromAbi(foundation.String, function());
}

/// `NSOpenStepRootDirectory`.
pub fn openStepRootDirectory() foundation.String {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSOpenStepRootDirectory", .linkage = .weak }) orelse missing("NSOpenStepRootDirectory");
    return objc.abi.fromAbi(foundation.String, function());
}

/// `NSSearchPathForDirectoriesInDomains`.
pub fn searchPathForDirectoriesInDomains(directory: SearchPathDirectory, domain_mask: SearchPathDomainMask, expand_tilde: bool) foundation.Array(foundation.String) {
    const function = @extern(?*const fn (objc.abi.Abi(SearchPathDirectory), objc.abi.Abi(SearchPathDomainMask), objc.abi.Abi(bool)) callconv(.c) objc.abi.Abi(foundation.Array(foundation.String)), .{ .name = "NSSearchPathForDirectoriesInDomains", .linkage = .weak }) orelse missing("NSSearchPathForDirectoriesInDomains");
    return objc.abi.fromAbi(foundation.Array(foundation.String), function(objc.abi.toAbi(SearchPathDirectory, directory), objc.abi.toAbi(SearchPathDomainMask, domain_mask), objc.abi.toAbi(bool, expand_tilde)));
}

/// `NSHTTPPropertyStatusCodeKey`.
pub fn httpPropertyStatusCodeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPPropertyStatusCodeKey", .linkage = .weak }) orelse missing("NSHTTPPropertyStatusCodeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPPropertyStatusReasonKey`.
pub fn httpPropertyStatusReasonKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPPropertyStatusReasonKey", .linkage = .weak }) orelse missing("NSHTTPPropertyStatusReasonKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPPropertyServerHTTPVersionKey`.
pub fn httpPropertyServerHTTPVersionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPPropertyServerHTTPVersionKey", .linkage = .weak }) orelse missing("NSHTTPPropertyServerHTTPVersionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPPropertyRedirectionHeadersKey`.
pub fn httpPropertyRedirectionHeadersKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPPropertyRedirectionHeadersKey", .linkage = .weak }) orelse missing("NSHTTPPropertyRedirectionHeadersKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPPropertyErrorPageDataKey`.
pub fn httpPropertyErrorPageDataKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPPropertyErrorPageDataKey", .linkage = .weak }) orelse missing("NSHTTPPropertyErrorPageDataKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPPropertyHTTPProxy`.
pub fn httpPropertyHTTPProxy() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPPropertyHTTPProxy", .linkage = .weak }) orelse missing("NSHTTPPropertyHTTPProxy");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFTPPropertyUserLoginKey`.
pub fn ftpPropertyUserLoginKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFTPPropertyUserLoginKey", .linkage = .weak }) orelse missing("NSFTPPropertyUserLoginKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFTPPropertyUserPasswordKey`.
pub fn ftpPropertyUserPasswordKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFTPPropertyUserPasswordKey", .linkage = .weak }) orelse missing("NSFTPPropertyUserPasswordKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFTPPropertyActiveTransferModeKey`.
pub fn ftpPropertyActiveTransferModeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFTPPropertyActiveTransferModeKey", .linkage = .weak }) orelse missing("NSFTPPropertyActiveTransferModeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFTPPropertyFileOffsetKey`.
pub fn ftpPropertyFileOffsetKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFTPPropertyFileOffsetKey", .linkage = .weak }) orelse missing("NSFTPPropertyFileOffsetKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFTPPropertyFTPProxy`.
pub fn ftpPropertyFTPProxy() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFTPPropertyFTPProxy", .linkage = .weak }) orelse missing("NSFTPPropertyFTPProxy");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileScheme`.
pub fn urlFileScheme() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileScheme", .linkage = .weak }) orelse missing("NSURLFileScheme");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLKeysOfUnsetValuesKey`.
pub fn urlKeysOfUnsetValuesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLKeysOfUnsetValuesKey", .linkage = .weak }) orelse missing("NSURLKeysOfUnsetValuesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLNameKey`.
pub fn urlNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLNameKey", .linkage = .weak }) orelse missing("NSURLNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLLocalizedNameKey`.
pub fn urlLocalizedNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLLocalizedNameKey", .linkage = .weak }) orelse missing("NSURLLocalizedNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsRegularFileKey`.
pub fn urlIsRegularFileKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsRegularFileKey", .linkage = .weak }) orelse missing("NSURLIsRegularFileKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsDirectoryKey`.
pub fn urlIsDirectoryKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsDirectoryKey", .linkage = .weak }) orelse missing("NSURLIsDirectoryKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsSymbolicLinkKey`.
pub fn urlIsSymbolicLinkKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsSymbolicLinkKey", .linkage = .weak }) orelse missing("NSURLIsSymbolicLinkKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsVolumeKey`.
pub fn urlIsVolumeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsVolumeKey", .linkage = .weak }) orelse missing("NSURLIsVolumeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsPackageKey`.
pub fn urlIsPackageKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsPackageKey", .linkage = .weak }) orelse missing("NSURLIsPackageKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsApplicationKey`.
pub fn urlIsApplicationKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsApplicationKey", .linkage = .weak }) orelse missing("NSURLIsApplicationKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLApplicationIsScriptableKey`.
pub fn urlApplicationIsScriptableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLApplicationIsScriptableKey", .linkage = .weak }) orelse missing("NSURLApplicationIsScriptableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsSystemImmutableKey`.
pub fn urlIsSystemImmutableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsSystemImmutableKey", .linkage = .weak }) orelse missing("NSURLIsSystemImmutableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsUserImmutableKey`.
pub fn urlIsUserImmutableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsUserImmutableKey", .linkage = .weak }) orelse missing("NSURLIsUserImmutableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsHiddenKey`.
pub fn urlIsHiddenKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsHiddenKey", .linkage = .weak }) orelse missing("NSURLIsHiddenKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLHasHiddenExtensionKey`.
pub fn urlHasHiddenExtensionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLHasHiddenExtensionKey", .linkage = .weak }) orelse missing("NSURLHasHiddenExtensionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLCreationDateKey`.
pub fn urlCreationDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLCreationDateKey", .linkage = .weak }) orelse missing("NSURLCreationDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLContentAccessDateKey`.
pub fn urlContentAccessDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLContentAccessDateKey", .linkage = .weak }) orelse missing("NSURLContentAccessDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLContentModificationDateKey`.
pub fn urlContentModificationDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLContentModificationDateKey", .linkage = .weak }) orelse missing("NSURLContentModificationDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAttributeModificationDateKey`.
pub fn urlAttributeModificationDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAttributeModificationDateKey", .linkage = .weak }) orelse missing("NSURLAttributeModificationDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLLinkCountKey`.
pub fn urlLinkCountKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLLinkCountKey", .linkage = .weak }) orelse missing("NSURLLinkCountKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLParentDirectoryURLKey`.
pub fn urlParentDirectoryURLKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLParentDirectoryURLKey", .linkage = .weak }) orelse missing("NSURLParentDirectoryURLKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeURLKey`.
pub fn urlVolumeURLKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeURLKey", .linkage = .weak }) orelse missing("NSURLVolumeURLKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLTypeIdentifierKey`.
pub fn urlTypeIdentifierKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLTypeIdentifierKey", .linkage = .weak }) orelse missing("NSURLTypeIdentifierKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLContentTypeKey`.
pub fn urlContentTypeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLContentTypeKey", .linkage = .weak }) orelse missing("NSURLContentTypeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLLocalizedTypeDescriptionKey`.
pub fn urlLocalizedTypeDescriptionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLLocalizedTypeDescriptionKey", .linkage = .weak }) orelse missing("NSURLLocalizedTypeDescriptionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLLabelNumberKey`.
pub fn urlLabelNumberKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLLabelNumberKey", .linkage = .weak }) orelse missing("NSURLLabelNumberKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLLabelColorKey`.
pub fn urlLabelColorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLLabelColorKey", .linkage = .weak }) orelse missing("NSURLLabelColorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLLocalizedLabelKey`.
pub fn urlLocalizedLabelKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLLocalizedLabelKey", .linkage = .weak }) orelse missing("NSURLLocalizedLabelKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLEffectiveIconKey`.
pub fn urlEffectiveIconKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLEffectiveIconKey", .linkage = .weak }) orelse missing("NSURLEffectiveIconKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLCustomIconKey`.
pub fn urlCustomIconKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLCustomIconKey", .linkage = .weak }) orelse missing("NSURLCustomIconKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceIdentifierKey`.
pub fn urlFileResourceIdentifierKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceIdentifierKey", .linkage = .weak }) orelse missing("NSURLFileResourceIdentifierKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIdentifierKey`.
pub fn urlVolumeIdentifierKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIdentifierKey", .linkage = .weak }) orelse missing("NSURLVolumeIdentifierKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLPreferredIOBlockSizeKey`.
pub fn urlPreferredIOBlockSizeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLPreferredIOBlockSizeKey", .linkage = .weak }) orelse missing("NSURLPreferredIOBlockSizeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsReadableKey`.
pub fn urlIsReadableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsReadableKey", .linkage = .weak }) orelse missing("NSURLIsReadableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsWritableKey`.
pub fn urlIsWritableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsWritableKey", .linkage = .weak }) orelse missing("NSURLIsWritableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsExecutableKey`.
pub fn urlIsExecutableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsExecutableKey", .linkage = .weak }) orelse missing("NSURLIsExecutableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileSecurityKey`.
pub fn urlFileSecurityKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileSecurityKey", .linkage = .weak }) orelse missing("NSURLFileSecurityKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsExcludedFromBackupKey`.
pub fn urlIsExcludedFromBackupKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsExcludedFromBackupKey", .linkage = .weak }) orelse missing("NSURLIsExcludedFromBackupKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLTagNamesKey`.
pub fn urlTagNamesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLTagNamesKey", .linkage = .weak }) orelse missing("NSURLTagNamesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLPathKey`.
pub fn urlPathKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLPathKey", .linkage = .weak }) orelse missing("NSURLPathKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLCanonicalPathKey`.
pub fn urlCanonicalPathKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLCanonicalPathKey", .linkage = .weak }) orelse missing("NSURLCanonicalPathKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsMountTriggerKey`.
pub fn urlIsMountTriggerKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsMountTriggerKey", .linkage = .weak }) orelse missing("NSURLIsMountTriggerKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLGenerationIdentifierKey`.
pub fn urlGenerationIdentifierKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLGenerationIdentifierKey", .linkage = .weak }) orelse missing("NSURLGenerationIdentifierKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLDocumentIdentifierKey`.
pub fn urlDocumentIdentifierKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLDocumentIdentifierKey", .linkage = .weak }) orelse missing("NSURLDocumentIdentifierKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAddedToDirectoryDateKey`.
pub fn urlAddedToDirectoryDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAddedToDirectoryDateKey", .linkage = .weak }) orelse missing("NSURLAddedToDirectoryDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLQuarantinePropertiesKey`.
pub fn urlQuarantinePropertiesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLQuarantinePropertiesKey", .linkage = .weak }) orelse missing("NSURLQuarantinePropertiesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceTypeKey`.
pub fn urlFileResourceTypeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceTypeKey", .linkage = .weak }) orelse missing("NSURLFileResourceTypeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileIdentifierKey`.
pub fn urlFileIdentifierKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileIdentifierKey", .linkage = .weak }) orelse missing("NSURLFileIdentifierKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileContentIdentifierKey`.
pub fn urlFileContentIdentifierKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileContentIdentifierKey", .linkage = .weak }) orelse missing("NSURLFileContentIdentifierKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLMayShareFileContentKey`.
pub fn urlMayShareFileContentKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLMayShareFileContentKey", .linkage = .weak }) orelse missing("NSURLMayShareFileContentKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLMayHaveExtendedAttributesKey`.
pub fn urlMayHaveExtendedAttributesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLMayHaveExtendedAttributesKey", .linkage = .weak }) orelse missing("NSURLMayHaveExtendedAttributesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsPurgeableKey`.
pub fn urlIsPurgeableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsPurgeableKey", .linkage = .weak }) orelse missing("NSURLIsPurgeableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsSparseKey`.
pub fn urlIsSparseKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsSparseKey", .linkage = .weak }) orelse missing("NSURLIsSparseKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceTypeNamedPipe`.
pub fn urlFileResourceTypeNamedPipe() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceTypeNamedPipe", .linkage = .weak }) orelse missing("NSURLFileResourceTypeNamedPipe");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceTypeCharacterSpecial`.
pub fn urlFileResourceTypeCharacterSpecial() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceTypeCharacterSpecial", .linkage = .weak }) orelse missing("NSURLFileResourceTypeCharacterSpecial");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceTypeDirectory`.
pub fn urlFileResourceTypeDirectory() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceTypeDirectory", .linkage = .weak }) orelse missing("NSURLFileResourceTypeDirectory");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceTypeBlockSpecial`.
pub fn urlFileResourceTypeBlockSpecial() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceTypeBlockSpecial", .linkage = .weak }) orelse missing("NSURLFileResourceTypeBlockSpecial");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceTypeRegular`.
pub fn urlFileResourceTypeRegular() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceTypeRegular", .linkage = .weak }) orelse missing("NSURLFileResourceTypeRegular");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceTypeSymbolicLink`.
pub fn urlFileResourceTypeSymbolicLink() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceTypeSymbolicLink", .linkage = .weak }) orelse missing("NSURLFileResourceTypeSymbolicLink");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceTypeSocket`.
pub fn urlFileResourceTypeSocket() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceTypeSocket", .linkage = .weak }) orelse missing("NSURLFileResourceTypeSocket");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileResourceTypeUnknown`.
pub fn urlFileResourceTypeUnknown() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileResourceTypeUnknown", .linkage = .weak }) orelse missing("NSURLFileResourceTypeUnknown");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLThumbnailDictionaryKey`.
pub fn urlThumbnailDictionaryKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLThumbnailDictionaryKey", .linkage = .weak }) orelse missing("NSURLThumbnailDictionaryKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLThumbnailKey`.
pub fn urlThumbnailKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLThumbnailKey", .linkage = .weak }) orelse missing("NSURLThumbnailKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSThumbnail1024x1024SizeKey`.
pub fn thumbnail1024x1024SizeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSThumbnail1024x1024SizeKey", .linkage = .weak }) orelse missing("NSThumbnail1024x1024SizeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileSizeKey`.
pub fn urlFileSizeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileSizeKey", .linkage = .weak }) orelse missing("NSURLFileSizeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileAllocatedSizeKey`.
pub fn urlFileAllocatedSizeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileAllocatedSizeKey", .linkage = .weak }) orelse missing("NSURLFileAllocatedSizeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLTotalFileSizeKey`.
pub fn urlTotalFileSizeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLTotalFileSizeKey", .linkage = .weak }) orelse missing("NSURLTotalFileSizeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLTotalFileAllocatedSizeKey`.
pub fn urlTotalFileAllocatedSizeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLTotalFileAllocatedSizeKey", .linkage = .weak }) orelse missing("NSURLTotalFileAllocatedSizeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsAliasFileKey`.
pub fn urlIsAliasFileKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsAliasFileKey", .linkage = .weak }) orelse missing("NSURLIsAliasFileKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileProtectionKey`.
pub fn urlFileProtectionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileProtectionKey", .linkage = .weak }) orelse missing("NSURLFileProtectionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileProtectionNone`.
pub fn urlFileProtectionNone() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileProtectionNone", .linkage = .weak }) orelse missing("NSURLFileProtectionNone");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileProtectionComplete`.
pub fn urlFileProtectionComplete() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileProtectionComplete", .linkage = .weak }) orelse missing("NSURLFileProtectionComplete");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileProtectionCompleteUnlessOpen`.
pub fn urlFileProtectionCompleteUnlessOpen() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileProtectionCompleteUnlessOpen", .linkage = .weak }) orelse missing("NSURLFileProtectionCompleteUnlessOpen");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLFileProtectionCompleteUntilFirstUserAuthentication`.
pub fn urlFileProtectionCompleteUntilFirstUserAuthentication() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLFileProtectionCompleteUntilFirstUserAuthentication", .linkage = .weak }) orelse missing("NSURLFileProtectionCompleteUntilFirstUserAuthentication");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLDirectoryEntryCountKey`.
pub fn urlDirectoryEntryCountKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLDirectoryEntryCountKey", .linkage = .weak }) orelse missing("NSURLDirectoryEntryCountKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeLocalizedFormatDescriptionKey`.
pub fn urlVolumeLocalizedFormatDescriptionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeLocalizedFormatDescriptionKey", .linkage = .weak }) orelse missing("NSURLVolumeLocalizedFormatDescriptionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeTotalCapacityKey`.
pub fn urlVolumeTotalCapacityKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeTotalCapacityKey", .linkage = .weak }) orelse missing("NSURLVolumeTotalCapacityKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeAvailableCapacityKey`.
pub fn urlVolumeAvailableCapacityKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeAvailableCapacityKey", .linkage = .weak }) orelse missing("NSURLVolumeAvailableCapacityKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeResourceCountKey`.
pub fn urlVolumeResourceCountKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeResourceCountKey", .linkage = .weak }) orelse missing("NSURLVolumeResourceCountKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsPersistentIDsKey`.
pub fn urlVolumeSupportsPersistentIDsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsPersistentIDsKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsPersistentIDsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsSymbolicLinksKey`.
pub fn urlVolumeSupportsSymbolicLinksKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsSymbolicLinksKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsSymbolicLinksKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsHardLinksKey`.
pub fn urlVolumeSupportsHardLinksKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsHardLinksKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsHardLinksKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsJournalingKey`.
pub fn urlVolumeSupportsJournalingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsJournalingKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsJournalingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsJournalingKey`.
pub fn urlVolumeIsJournalingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsJournalingKey", .linkage = .weak }) orelse missing("NSURLVolumeIsJournalingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsSparseFilesKey`.
pub fn urlVolumeSupportsSparseFilesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsSparseFilesKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsSparseFilesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsZeroRunsKey`.
pub fn urlVolumeSupportsZeroRunsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsZeroRunsKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsZeroRunsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsCaseSensitiveNamesKey`.
pub fn urlVolumeSupportsCaseSensitiveNamesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsCaseSensitiveNamesKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsCaseSensitiveNamesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsCasePreservedNamesKey`.
pub fn urlVolumeSupportsCasePreservedNamesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsCasePreservedNamesKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsCasePreservedNamesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsRootDirectoryDatesKey`.
pub fn urlVolumeSupportsRootDirectoryDatesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsRootDirectoryDatesKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsRootDirectoryDatesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsVolumeSizesKey`.
pub fn urlVolumeSupportsVolumeSizesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsVolumeSizesKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsVolumeSizesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsRenamingKey`.
pub fn urlVolumeSupportsRenamingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsRenamingKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsRenamingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsAdvisoryFileLockingKey`.
pub fn urlVolumeSupportsAdvisoryFileLockingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsAdvisoryFileLockingKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsAdvisoryFileLockingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsExtendedSecurityKey`.
pub fn urlVolumeSupportsExtendedSecurityKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsExtendedSecurityKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsExtendedSecurityKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsBrowsableKey`.
pub fn urlVolumeIsBrowsableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsBrowsableKey", .linkage = .weak }) orelse missing("NSURLVolumeIsBrowsableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeMaximumFileSizeKey`.
pub fn urlVolumeMaximumFileSizeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeMaximumFileSizeKey", .linkage = .weak }) orelse missing("NSURLVolumeMaximumFileSizeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsEjectableKey`.
pub fn urlVolumeIsEjectableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsEjectableKey", .linkage = .weak }) orelse missing("NSURLVolumeIsEjectableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsRemovableKey`.
pub fn urlVolumeIsRemovableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsRemovableKey", .linkage = .weak }) orelse missing("NSURLVolumeIsRemovableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsInternalKey`.
pub fn urlVolumeIsInternalKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsInternalKey", .linkage = .weak }) orelse missing("NSURLVolumeIsInternalKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsAutomountedKey`.
pub fn urlVolumeIsAutomountedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsAutomountedKey", .linkage = .weak }) orelse missing("NSURLVolumeIsAutomountedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsLocalKey`.
pub fn urlVolumeIsLocalKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsLocalKey", .linkage = .weak }) orelse missing("NSURLVolumeIsLocalKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsReadOnlyKey`.
pub fn urlVolumeIsReadOnlyKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsReadOnlyKey", .linkage = .weak }) orelse missing("NSURLVolumeIsReadOnlyKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeCreationDateKey`.
pub fn urlVolumeCreationDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeCreationDateKey", .linkage = .weak }) orelse missing("NSURLVolumeCreationDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeURLForRemountingKey`.
pub fn urlVolumeURLForRemountingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeURLForRemountingKey", .linkage = .weak }) orelse missing("NSURLVolumeURLForRemountingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeUUIDStringKey`.
pub fn urlVolumeUUIDStringKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeUUIDStringKey", .linkage = .weak }) orelse missing("NSURLVolumeUUIDStringKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeNameKey`.
pub fn urlVolumeNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeNameKey", .linkage = .weak }) orelse missing("NSURLVolumeNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeLocalizedNameKey`.
pub fn urlVolumeLocalizedNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeLocalizedNameKey", .linkage = .weak }) orelse missing("NSURLVolumeLocalizedNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsEncryptedKey`.
pub fn urlVolumeIsEncryptedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsEncryptedKey", .linkage = .weak }) orelse missing("NSURLVolumeIsEncryptedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeIsRootFileSystemKey`.
pub fn urlVolumeIsRootFileSystemKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeIsRootFileSystemKey", .linkage = .weak }) orelse missing("NSURLVolumeIsRootFileSystemKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsCompressionKey`.
pub fn urlVolumeSupportsCompressionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsCompressionKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsCompressionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsFileCloningKey`.
pub fn urlVolumeSupportsFileCloningKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsFileCloningKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsFileCloningKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsSwapRenamingKey`.
pub fn urlVolumeSupportsSwapRenamingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsSwapRenamingKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsSwapRenamingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsExclusiveRenamingKey`.
pub fn urlVolumeSupportsExclusiveRenamingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsExclusiveRenamingKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsExclusiveRenamingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsImmutableFilesKey`.
pub fn urlVolumeSupportsImmutableFilesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsImmutableFilesKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsImmutableFilesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsAccessPermissionsKey`.
pub fn urlVolumeSupportsAccessPermissionsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsAccessPermissionsKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsAccessPermissionsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSupportsFileProtectionKey`.
pub fn urlVolumeSupportsFileProtectionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSupportsFileProtectionKey", .linkage = .weak }) orelse missing("NSURLVolumeSupportsFileProtectionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeAvailableCapacityForImportantUsageKey`.
pub fn urlVolumeAvailableCapacityForImportantUsageKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeAvailableCapacityForImportantUsageKey", .linkage = .weak }) orelse missing("NSURLVolumeAvailableCapacityForImportantUsageKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeAvailableCapacityForOpportunisticUsageKey`.
pub fn urlVolumeAvailableCapacityForOpportunisticUsageKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeAvailableCapacityForOpportunisticUsageKey", .linkage = .weak }) orelse missing("NSURLVolumeAvailableCapacityForOpportunisticUsageKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeTypeNameKey`.
pub fn urlVolumeTypeNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeTypeNameKey", .linkage = .weak }) orelse missing("NSURLVolumeTypeNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeSubtypeKey`.
pub fn urlVolumeSubtypeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeSubtypeKey", .linkage = .weak }) orelse missing("NSURLVolumeSubtypeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLVolumeMountFromLocationKey`.
pub fn urlVolumeMountFromLocationKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLVolumeMountFromLocationKey", .linkage = .weak }) orelse missing("NSURLVolumeMountFromLocationKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLIsUbiquitousItemKey`.
pub fn urlIsUbiquitousItemKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLIsUbiquitousItemKey", .linkage = .weak }) orelse missing("NSURLIsUbiquitousItemKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemHasUnresolvedConflictsKey`.
pub fn urlUbiquitousItemHasUnresolvedConflictsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemHasUnresolvedConflictsKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemHasUnresolvedConflictsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemIsDownloadedKey`.
pub fn urlUbiquitousItemIsDownloadedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemIsDownloadedKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemIsDownloadedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemIsDownloadingKey`.
pub fn urlUbiquitousItemIsDownloadingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemIsDownloadingKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemIsDownloadingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemIsUploadedKey`.
pub fn urlUbiquitousItemIsUploadedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemIsUploadedKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemIsUploadedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemIsUploadingKey`.
pub fn urlUbiquitousItemIsUploadingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemIsUploadingKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemIsUploadingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemPercentDownloadedKey`.
pub fn urlUbiquitousItemPercentDownloadedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemPercentDownloadedKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemPercentDownloadedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemPercentUploadedKey`.
pub fn urlUbiquitousItemPercentUploadedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemPercentUploadedKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemPercentUploadedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemDownloadingStatusKey`.
pub fn urlUbiquitousItemDownloadingStatusKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemDownloadingStatusKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemDownloadingStatusKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemDownloadingErrorKey`.
pub fn urlUbiquitousItemDownloadingErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemDownloadingErrorKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemDownloadingErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemUploadingErrorKey`.
pub fn urlUbiquitousItemUploadingErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemUploadingErrorKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemUploadingErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemDownloadRequestedKey`.
pub fn urlUbiquitousItemDownloadRequestedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemDownloadRequestedKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemDownloadRequestedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemContainerDisplayNameKey`.
pub fn urlUbiquitousItemContainerDisplayNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemContainerDisplayNameKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemContainerDisplayNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemIsExcludedFromSyncKey`.
pub fn urlUbiquitousItemIsExcludedFromSyncKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemIsExcludedFromSyncKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemIsExcludedFromSyncKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemIsSharedKey`.
pub fn urlUbiquitousItemIsSharedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemIsSharedKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemIsSharedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousSharedItemCurrentUserRoleKey`.
pub fn urlUbiquitousSharedItemCurrentUserRoleKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousSharedItemCurrentUserRoleKey", .linkage = .weak }) orelse missing("NSURLUbiquitousSharedItemCurrentUserRoleKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousSharedItemCurrentUserPermissionsKey`.
pub fn urlUbiquitousSharedItemCurrentUserPermissionsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousSharedItemCurrentUserPermissionsKey", .linkage = .weak }) orelse missing("NSURLUbiquitousSharedItemCurrentUserPermissionsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousSharedItemOwnerNameComponentsKey`.
pub fn urlUbiquitousSharedItemOwnerNameComponentsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousSharedItemOwnerNameComponentsKey", .linkage = .weak }) orelse missing("NSURLUbiquitousSharedItemOwnerNameComponentsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousSharedItemMostRecentEditorNameComponentsKey`.
pub fn urlUbiquitousSharedItemMostRecentEditorNameComponentsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousSharedItemMostRecentEditorNameComponentsKey", .linkage = .weak }) orelse missing("NSURLUbiquitousSharedItemMostRecentEditorNameComponentsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemDownloadingStatusNotDownloaded`.
pub fn urlUbiquitousItemDownloadingStatusNotDownloaded() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemDownloadingStatusNotDownloaded", .linkage = .weak }) orelse missing("NSURLUbiquitousItemDownloadingStatusNotDownloaded");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemDownloadingStatusDownloaded`.
pub fn urlUbiquitousItemDownloadingStatusDownloaded() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemDownloadingStatusDownloaded", .linkage = .weak }) orelse missing("NSURLUbiquitousItemDownloadingStatusDownloaded");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemDownloadingStatusCurrent`.
pub fn urlUbiquitousItemDownloadingStatusCurrent() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemDownloadingStatusCurrent", .linkage = .weak }) orelse missing("NSURLUbiquitousItemDownloadingStatusCurrent");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousSharedItemRoleOwner`.
pub fn urlUbiquitousSharedItemRoleOwner() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousSharedItemRoleOwner", .linkage = .weak }) orelse missing("NSURLUbiquitousSharedItemRoleOwner");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousSharedItemRoleParticipant`.
pub fn urlUbiquitousSharedItemRoleParticipant() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousSharedItemRoleParticipant", .linkage = .weak }) orelse missing("NSURLUbiquitousSharedItemRoleParticipant");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousSharedItemPermissionsReadOnly`.
pub fn urlUbiquitousSharedItemPermissionsReadOnly() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousSharedItemPermissionsReadOnly", .linkage = .weak }) orelse missing("NSURLUbiquitousSharedItemPermissionsReadOnly");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousSharedItemPermissionsReadWrite`.
pub fn urlUbiquitousSharedItemPermissionsReadWrite() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousSharedItemPermissionsReadWrite", .linkage = .weak }) orelse missing("NSURLUbiquitousSharedItemPermissionsReadWrite");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemSupportedSyncControlsKey`.
pub fn urlUbiquitousItemSupportedSyncControlsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemSupportedSyncControlsKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemSupportedSyncControlsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLUbiquitousItemIsSyncPausedKey`.
pub fn urlUbiquitousItemIsSyncPausedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLUbiquitousItemIsSyncPausedKey", .linkage = .weak }) orelse missing("NSURLUbiquitousItemIsSyncPausedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileManagerUnmountDissentingProcessIdentifierErrorKey`.
pub fn fileManagerUnmountDissentingProcessIdentifierErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileManagerUnmountDissentingProcessIdentifierErrorKey", .linkage = .weak }) orelse missing("NSFileManagerUnmountDissentingProcessIdentifierErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUbiquityIdentityDidChangeNotification`.
pub fn ubiquityIdentityDidChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUbiquityIdentityDidChangeNotification", .linkage = .weak }) orelse missing("NSUbiquityIdentityDidChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileType`.
pub fn fileType() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileType", .linkage = .weak }) orelse missing("NSFileType");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileTypeDirectory`.
pub fn fileTypeDirectory() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileTypeDirectory", .linkage = .weak }) orelse missing("NSFileTypeDirectory");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileTypeRegular`.
pub fn fileTypeRegular() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileTypeRegular", .linkage = .weak }) orelse missing("NSFileTypeRegular");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileTypeSymbolicLink`.
pub fn fileTypeSymbolicLink() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileTypeSymbolicLink", .linkage = .weak }) orelse missing("NSFileTypeSymbolicLink");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileTypeSocket`.
pub fn fileTypeSocket() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileTypeSocket", .linkage = .weak }) orelse missing("NSFileTypeSocket");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileTypeCharacterSpecial`.
pub fn fileTypeCharacterSpecial() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileTypeCharacterSpecial", .linkage = .weak }) orelse missing("NSFileTypeCharacterSpecial");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileTypeBlockSpecial`.
pub fn fileTypeBlockSpecial() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileTypeBlockSpecial", .linkage = .weak }) orelse missing("NSFileTypeBlockSpecial");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileTypeUnknown`.
pub fn fileTypeUnknown() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileTypeUnknown", .linkage = .weak }) orelse missing("NSFileTypeUnknown");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileSize`.
pub fn fileSize() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileSize", .linkage = .weak }) orelse missing("NSFileSize");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileModificationDate`.
pub fn fileModificationDate() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileModificationDate", .linkage = .weak }) orelse missing("NSFileModificationDate");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileReferenceCount`.
pub fn fileReferenceCount() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileReferenceCount", .linkage = .weak }) orelse missing("NSFileReferenceCount");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileDeviceIdentifier`.
pub fn fileDeviceIdentifier() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileDeviceIdentifier", .linkage = .weak }) orelse missing("NSFileDeviceIdentifier");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileOwnerAccountName`.
pub fn fileOwnerAccountName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileOwnerAccountName", .linkage = .weak }) orelse missing("NSFileOwnerAccountName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileGroupOwnerAccountName`.
pub fn fileGroupOwnerAccountName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileGroupOwnerAccountName", .linkage = .weak }) orelse missing("NSFileGroupOwnerAccountName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFilePosixPermissions`.
pub fn filePosixPermissions() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFilePosixPermissions", .linkage = .weak }) orelse missing("NSFilePosixPermissions");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileSystemNumber`.
pub fn fileSystemNumber() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileSystemNumber", .linkage = .weak }) orelse missing("NSFileSystemNumber");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileSystemFileNumber`.
pub fn fileSystemFileNumber() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileSystemFileNumber", .linkage = .weak }) orelse missing("NSFileSystemFileNumber");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileExtensionHidden`.
pub fn fileExtensionHidden() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileExtensionHidden", .linkage = .weak }) orelse missing("NSFileExtensionHidden");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHFSCreatorCode`.
pub fn fileHFSCreatorCode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHFSCreatorCode", .linkage = .weak }) orelse missing("NSFileHFSCreatorCode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileHFSTypeCode`.
pub fn fileHFSTypeCode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileHFSTypeCode", .linkage = .weak }) orelse missing("NSFileHFSTypeCode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileImmutable`.
pub fn fileImmutable() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileImmutable", .linkage = .weak }) orelse missing("NSFileImmutable");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileAppendOnly`.
pub fn fileAppendOnly() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileAppendOnly", .linkage = .weak }) orelse missing("NSFileAppendOnly");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileCreationDate`.
pub fn fileCreationDate() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileCreationDate", .linkage = .weak }) orelse missing("NSFileCreationDate");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileOwnerAccountID`.
pub fn fileOwnerAccountID() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileOwnerAccountID", .linkage = .weak }) orelse missing("NSFileOwnerAccountID");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileGroupOwnerAccountID`.
pub fn fileGroupOwnerAccountID() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileGroupOwnerAccountID", .linkage = .weak }) orelse missing("NSFileGroupOwnerAccountID");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileBusy`.
pub fn fileBusy() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileBusy", .linkage = .weak }) orelse missing("NSFileBusy");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileProtectionKey`.
pub fn fileProtectionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileProtectionKey", .linkage = .weak }) orelse missing("NSFileProtectionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileProtectionNone`.
pub fn fileProtectionNone() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileProtectionNone", .linkage = .weak }) orelse missing("NSFileProtectionNone");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileProtectionComplete`.
pub fn fileProtectionComplete() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileProtectionComplete", .linkage = .weak }) orelse missing("NSFileProtectionComplete");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileProtectionCompleteUnlessOpen`.
pub fn fileProtectionCompleteUnlessOpen() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileProtectionCompleteUnlessOpen", .linkage = .weak }) orelse missing("NSFileProtectionCompleteUnlessOpen");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileProtectionCompleteUntilFirstUserAuthentication`.
pub fn fileProtectionCompleteUntilFirstUserAuthentication() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileProtectionCompleteUntilFirstUserAuthentication", .linkage = .weak }) orelse missing("NSFileProtectionCompleteUntilFirstUserAuthentication");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileSystemSize`.
pub fn fileSystemSize() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileSystemSize", .linkage = .weak }) orelse missing("NSFileSystemSize");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileSystemFreeSize`.
pub fn fileSystemFreeSize() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileSystemFreeSize", .linkage = .weak }) orelse missing("NSFileSystemFreeSize");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileSystemNodes`.
pub fn fileSystemNodes() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileSystemNodes", .linkage = .weak }) orelse missing("NSFileSystemNodes");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileSystemFreeNodes`.
pub fn fileSystemFreeNodes() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFileSystemFreeNodes", .linkage = .weak }) orelse missing("NSFileSystemFreeNodes");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFreeHashTable`.
pub fn freeHashTable(table: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSFreeHashTable", .linkage = .weak }) orelse missing("NSFreeHashTable");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSResetHashTable`.
pub fn resetHashTable(table: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSResetHashTable", .linkage = .weak }) orelse missing("NSResetHashTable");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSCompareHashTables`.
pub fn compareHashTables(table1: objc.Object, table2: objc.Object) bool {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSCompareHashTables", .linkage = .weak }) orelse missing("NSCompareHashTables");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(objc.Object, table1), objc.abi.toAbi(objc.Object, table2)));
}

/// `NSCopyHashTableWithZone`. What it returns is yours to release.
pub fn copyHashTableWithZone(table: objc.Object, zone: ?objc.Object) objc.Object {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?objc.Object)) callconv(.c) objc.abi.Abi(objc.Object), .{ .name = "NSCopyHashTableWithZone", .linkage = .weak }) orelse missing("NSCopyHashTableWithZone");
    return objc.abi.fromAbi(objc.Object, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?objc.Object, zone)));
}

/// `NSHashGet`.
pub fn hashGet(table: objc.Object, pointer: ?*const anyopaque) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSHashGet", .linkage = .weak }) orelse missing("NSHashGet");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, pointer)));
}

/// `NSHashInsert`.
pub fn hashInsert(table: objc.Object, pointer: ?*const anyopaque) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSHashInsert", .linkage = .weak }) orelse missing("NSHashInsert");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, pointer)));
}

/// `NSHashInsertKnownAbsent`.
pub fn hashInsertKnownAbsent(table: objc.Object, pointer: ?*const anyopaque) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSHashInsertKnownAbsent", .linkage = .weak }) orelse missing("NSHashInsertKnownAbsent");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, pointer)));
}

/// `NSHashInsertIfAbsent`.
pub fn hashInsertIfAbsent(table: objc.Object, pointer: ?*const anyopaque) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSHashInsertIfAbsent", .linkage = .weak }) orelse missing("NSHashInsertIfAbsent");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, pointer)));
}

/// `NSHashRemove`.
pub fn hashRemove(table: objc.Object, pointer: ?*const anyopaque) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSHashRemove", .linkage = .weak }) orelse missing("NSHashRemove");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, pointer)));
}

/// `NSNextHashEnumeratorItem`.
pub fn nextHashEnumeratorItem(enumerator: objc.Object) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSNextHashEnumeratorItem", .linkage = .weak }) orelse missing("NSNextHashEnumeratorItem");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(objc.Object, enumerator)));
}

/// `NSEndHashTableEnumeration`.
pub fn endHashTableEnumeration(enumerator: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSEndHashTableEnumeration", .linkage = .weak }) orelse missing("NSEndHashTableEnumeration");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, enumerator)));
}

/// `NSCountHashTable`.
pub fn countHashTable(table: objc.Object) objc.UInteger {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(objc.UInteger), .{ .name = "NSCountHashTable", .linkage = .weak }) orelse missing("NSCountHashTable");
    return objc.abi.fromAbi(objc.UInteger, function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSStringFromHashTable`.
pub fn stringFromHashTable(table: objc.Object) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSStringFromHashTable", .linkage = .weak }) orelse missing("NSStringFromHashTable");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSAllHashTableObjects`.
pub fn allHashTableObjects(table: objc.Object) foundation.Array(objc.Object) {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(foundation.Array(objc.Object)), .{ .name = "NSAllHashTableObjects", .linkage = .weak }) orelse missing("NSAllHashTableObjects");
    return objc.abi.fromAbi(foundation.Array(objc.Object), function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSHTTPCookieName`.
pub fn httpCookieName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieName", .linkage = .weak }) orelse missing("NSHTTPCookieName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieValue`.
pub fn httpCookieValue() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieValue", .linkage = .weak }) orelse missing("NSHTTPCookieValue");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieOriginURL`.
pub fn httpCookieOriginURL() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieOriginURL", .linkage = .weak }) orelse missing("NSHTTPCookieOriginURL");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieVersion`.
pub fn httpCookieVersion() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieVersion", .linkage = .weak }) orelse missing("NSHTTPCookieVersion");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieDomain`.
pub fn httpCookieDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieDomain", .linkage = .weak }) orelse missing("NSHTTPCookieDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookiePath`.
pub fn httpCookiePath() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookiePath", .linkage = .weak }) orelse missing("NSHTTPCookiePath");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieSecure`.
pub fn httpCookieSecure() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieSecure", .linkage = .weak }) orelse missing("NSHTTPCookieSecure");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieExpires`.
pub fn httpCookieExpires() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieExpires", .linkage = .weak }) orelse missing("NSHTTPCookieExpires");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieComment`.
pub fn httpCookieComment() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieComment", .linkage = .weak }) orelse missing("NSHTTPCookieComment");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieCommentURL`.
pub fn httpCookieCommentURL() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieCommentURL", .linkage = .weak }) orelse missing("NSHTTPCookieCommentURL");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieDiscard`.
pub fn httpCookieDiscard() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieDiscard", .linkage = .weak }) orelse missing("NSHTTPCookieDiscard");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieMaximumAge`.
pub fn httpCookieMaximumAge() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieMaximumAge", .linkage = .weak }) orelse missing("NSHTTPCookieMaximumAge");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookiePort`.
pub fn httpCookiePort() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookiePort", .linkage = .weak }) orelse missing("NSHTTPCookiePort");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieSetByJavaScript`.
pub fn httpCookieSetByJavaScript() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieSetByJavaScript", .linkage = .weak }) orelse missing("NSHTTPCookieSetByJavaScript");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieSameSitePolicy`.
pub fn httpCookieSameSitePolicy() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieSameSitePolicy", .linkage = .weak }) orelse missing("NSHTTPCookieSameSitePolicy");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieSameSiteLax`.
pub fn httpCookieSameSiteLax() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieSameSiteLax", .linkage = .weak }) orelse missing("NSHTTPCookieSameSiteLax");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieSameSiteStrict`.
pub fn httpCookieSameSiteStrict() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieSameSiteStrict", .linkage = .weak }) orelse missing("NSHTTPCookieSameSiteStrict");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieManagerAcceptPolicyChangedNotification`.
pub fn httpCookieManagerAcceptPolicyChangedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieManagerAcceptPolicyChangedNotification", .linkage = .weak }) orelse missing("NSHTTPCookieManagerAcceptPolicyChangedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHTTPCookieManagerCookiesChangedNotification`.
pub fn httpCookieManagerCookiesChangedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHTTPCookieManagerCookiesChangedNotification", .linkage = .weak }) orelse missing("NSHTTPCookieManagerCookiesChangedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndefinedKeyException`.
pub fn undefinedKeyException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndefinedKeyException", .linkage = .weak }) orelse missing("NSUndefinedKeyException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSAverageKeyValueOperator`.
pub fn averageKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAverageKeyValueOperator", .linkage = .weak }) orelse missing("NSAverageKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCountKeyValueOperator`.
pub fn countKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCountKeyValueOperator", .linkage = .weak }) orelse missing("NSCountKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDistinctUnionOfArraysKeyValueOperator`.
pub fn distinctUnionOfArraysKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDistinctUnionOfArraysKeyValueOperator", .linkage = .weak }) orelse missing("NSDistinctUnionOfArraysKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDistinctUnionOfObjectsKeyValueOperator`.
pub fn distinctUnionOfObjectsKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDistinctUnionOfObjectsKeyValueOperator", .linkage = .weak }) orelse missing("NSDistinctUnionOfObjectsKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDistinctUnionOfSetsKeyValueOperator`.
pub fn distinctUnionOfSetsKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDistinctUnionOfSetsKeyValueOperator", .linkage = .weak }) orelse missing("NSDistinctUnionOfSetsKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMaximumKeyValueOperator`.
pub fn maximumKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMaximumKeyValueOperator", .linkage = .weak }) orelse missing("NSMaximumKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMinimumKeyValueOperator`.
pub fn minimumKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMinimumKeyValueOperator", .linkage = .weak }) orelse missing("NSMinimumKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSSumKeyValueOperator`.
pub fn sumKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSSumKeyValueOperator", .linkage = .weak }) orelse missing("NSSumKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUnionOfArraysKeyValueOperator`.
pub fn unionOfArraysKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUnionOfArraysKeyValueOperator", .linkage = .weak }) orelse missing("NSUnionOfArraysKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUnionOfObjectsKeyValueOperator`.
pub fn unionOfObjectsKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUnionOfObjectsKeyValueOperator", .linkage = .weak }) orelse missing("NSUnionOfObjectsKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUnionOfSetsKeyValueOperator`.
pub fn unionOfSetsKeyValueOperator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUnionOfSetsKeyValueOperator", .linkage = .weak }) orelse missing("NSUnionOfSetsKeyValueOperator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSKeyValueChangeKindKey`.
pub fn keyValueChangeKindKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSKeyValueChangeKindKey", .linkage = .weak }) orelse missing("NSKeyValueChangeKindKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSKeyValueChangeNewKey`.
pub fn keyValueChangeNewKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSKeyValueChangeNewKey", .linkage = .weak }) orelse missing("NSKeyValueChangeNewKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSKeyValueChangeOldKey`.
pub fn keyValueChangeOldKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSKeyValueChangeOldKey", .linkage = .weak }) orelse missing("NSKeyValueChangeOldKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSKeyValueChangeIndexesKey`.
pub fn keyValueChangeIndexesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSKeyValueChangeIndexesKey", .linkage = .weak }) orelse missing("NSKeyValueChangeIndexesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSKeyValueChangeNotificationIsPriorKey`.
pub fn keyValueChangeNotificationIsPriorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSKeyValueChangeNotificationIsPriorKey", .linkage = .weak }) orelse missing("NSKeyValueChangeNotificationIsPriorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSZeroPoint`.
pub fn zeroPoint() cg.Point {
    const symbol = @extern(?*const objc.abi.Abi(cg.Point), .{ .name = "NSZeroPoint", .linkage = .weak }) orelse missing("NSZeroPoint");
    return objc.abi.fromAbi(cg.Point, symbol.*);
}

/// `NSZeroSize`.
pub fn zeroSize() cg.Size {
    const symbol = @extern(?*const objc.abi.Abi(cg.Size), .{ .name = "NSZeroSize", .linkage = .weak }) orelse missing("NSZeroSize");
    return objc.abi.fromAbi(cg.Size, symbol.*);
}

/// `NSZeroRect`.
pub fn zeroRect() cg.Rect {
    const symbol = @extern(?*const objc.abi.Abi(cg.Rect), .{ .name = "NSZeroRect", .linkage = .weak }) orelse missing("NSZeroRect");
    return objc.abi.fromAbi(cg.Rect, symbol.*);
}

/// `NSEqualPoints`.
pub fn equalPoints(a_point: cg.Point, b_point: cg.Point) bool {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Point), objc.abi.Abi(cg.Point)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSEqualPoints", .linkage = .weak }) orelse missing("NSEqualPoints");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(cg.Point, a_point), objc.abi.toAbi(cg.Point, b_point)));
}

/// `NSEqualSizes`.
pub fn equalSizes(a_size: cg.Size, b_size: cg.Size) bool {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Size), objc.abi.Abi(cg.Size)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSEqualSizes", .linkage = .weak }) orelse missing("NSEqualSizes");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(cg.Size, a_size), objc.abi.toAbi(cg.Size, b_size)));
}

/// `NSEqualRects`.
pub fn equalRects(a_rect: cg.Rect, b_rect: cg.Rect) bool {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect), objc.abi.Abi(cg.Rect)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSEqualRects", .linkage = .weak }) orelse missing("NSEqualRects");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(cg.Rect, a_rect), objc.abi.toAbi(cg.Rect, b_rect)));
}

/// `NSIsEmptyRect`.
pub fn isEmptyRect(a_rect: cg.Rect) bool {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSIsEmptyRect", .linkage = .weak }) orelse missing("NSIsEmptyRect");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(cg.Rect, a_rect)));
}

/// `NSInsetRect`.
pub fn insetRect(a_rect: cg.Rect, d_x: cg.Float, d_y: cg.Float) cg.Rect {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float)) callconv(.c) objc.abi.Abi(cg.Rect), .{ .name = "NSInsetRect", .linkage = .weak }) orelse missing("NSInsetRect");
    return objc.abi.fromAbi(cg.Rect, function(objc.abi.toAbi(cg.Rect, a_rect), objc.abi.toAbi(cg.Float, d_x), objc.abi.toAbi(cg.Float, d_y)));
}

/// `NSIntegralRect`.
pub fn integralRect(a_rect: cg.Rect) cg.Rect {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect)) callconv(.c) objc.abi.Abi(cg.Rect), .{ .name = "NSIntegralRect", .linkage = .weak }) orelse missing("NSIntegralRect");
    return objc.abi.fromAbi(cg.Rect, function(objc.abi.toAbi(cg.Rect, a_rect)));
}

/// `NSUnionRect`.
pub fn unionRect(a_rect: cg.Rect, b_rect: cg.Rect) cg.Rect {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect), objc.abi.Abi(cg.Rect)) callconv(.c) objc.abi.Abi(cg.Rect), .{ .name = "NSUnionRect", .linkage = .weak }) orelse missing("NSUnionRect");
    return objc.abi.fromAbi(cg.Rect, function(objc.abi.toAbi(cg.Rect, a_rect), objc.abi.toAbi(cg.Rect, b_rect)));
}

/// `NSIntersectionRect`.
pub fn intersectionRect(a_rect: cg.Rect, b_rect: cg.Rect) cg.Rect {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect), objc.abi.Abi(cg.Rect)) callconv(.c) objc.abi.Abi(cg.Rect), .{ .name = "NSIntersectionRect", .linkage = .weak }) orelse missing("NSIntersectionRect");
    return objc.abi.fromAbi(cg.Rect, function(objc.abi.toAbi(cg.Rect, a_rect), objc.abi.toAbi(cg.Rect, b_rect)));
}

/// `NSOffsetRect`.
pub fn offsetRect(a_rect: cg.Rect, d_x: cg.Float, d_y: cg.Float) cg.Rect {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float)) callconv(.c) objc.abi.Abi(cg.Rect), .{ .name = "NSOffsetRect", .linkage = .weak }) orelse missing("NSOffsetRect");
    return objc.abi.fromAbi(cg.Rect, function(objc.abi.toAbi(cg.Rect, a_rect), objc.abi.toAbi(cg.Float, d_x), objc.abi.toAbi(cg.Float, d_y)));
}

/// `NSPointInRect`.
pub fn pointInRect(a_point: cg.Point, a_rect: cg.Rect) bool {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Point), objc.abi.Abi(cg.Rect)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSPointInRect", .linkage = .weak }) orelse missing("NSPointInRect");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(cg.Point, a_point), objc.abi.toAbi(cg.Rect, a_rect)));
}

/// `NSMouseInRect`.
pub fn mouseInRect(a_point: cg.Point, a_rect: cg.Rect, flipped: bool) bool {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Point), objc.abi.Abi(cg.Rect), objc.abi.Abi(bool)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSMouseInRect", .linkage = .weak }) orelse missing("NSMouseInRect");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(cg.Point, a_point), objc.abi.toAbi(cg.Rect, a_rect), objc.abi.toAbi(bool, flipped)));
}

/// `NSContainsRect`.
pub fn containsRect(a_rect: cg.Rect, b_rect: cg.Rect) bool {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect), objc.abi.Abi(cg.Rect)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSContainsRect", .linkage = .weak }) orelse missing("NSContainsRect");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(cg.Rect, a_rect), objc.abi.toAbi(cg.Rect, b_rect)));
}

/// `NSIntersectsRect`.
pub fn intersectsRect(a_rect: cg.Rect, b_rect: cg.Rect) bool {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect), objc.abi.Abi(cg.Rect)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSIntersectsRect", .linkage = .weak }) orelse missing("NSIntersectsRect");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(cg.Rect, a_rect), objc.abi.toAbi(cg.Rect, b_rect)));
}

/// `NSStringFromPoint`.
pub fn stringFromPoint(a_point: cg.Point) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Point)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSStringFromPoint", .linkage = .weak }) orelse missing("NSStringFromPoint");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(cg.Point, a_point)));
}

/// `NSStringFromSize`.
pub fn stringFromSize(a_size: cg.Size) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Size)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSStringFromSize", .linkage = .weak }) orelse missing("NSStringFromSize");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(cg.Size, a_size)));
}

/// `NSStringFromRect`.
pub fn stringFromRect(a_rect: cg.Rect) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Rect)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSStringFromRect", .linkage = .weak }) orelse missing("NSStringFromRect");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(cg.Rect, a_rect)));
}

/// `NSPointFromString`.
pub fn pointFromString(a_string: foundation.String) cg.Point {
    const function = @extern(?*const fn (objc.abi.Abi(foundation.String)) callconv(.c) objc.abi.Abi(cg.Point), .{ .name = "NSPointFromString", .linkage = .weak }) orelse missing("NSPointFromString");
    return objc.abi.fromAbi(cg.Point, function(objc.abi.toAbi(foundation.String, a_string)));
}

/// `NSSizeFromString`.
pub fn sizeFromString(a_string: foundation.String) cg.Size {
    const function = @extern(?*const fn (objc.abi.Abi(foundation.String)) callconv(.c) objc.abi.Abi(cg.Size), .{ .name = "NSSizeFromString", .linkage = .weak }) orelse missing("NSSizeFromString");
    return objc.abi.fromAbi(cg.Size, function(objc.abi.toAbi(foundation.String, a_string)));
}

/// `NSRectFromString`.
pub fn rectFromString(a_string: foundation.String) cg.Rect {
    const function = @extern(?*const fn (objc.abi.Abi(foundation.String)) callconv(.c) objc.abi.Abi(cg.Rect), .{ .name = "NSRectFromString", .linkage = .weak }) orelse missing("NSRectFromString");
    return objc.abi.fromAbi(cg.Rect, function(objc.abi.toAbi(foundation.String, a_string)));
}

/// `NSInvalidArchiveOperationException`.
pub fn invalidArchiveOperationException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInvalidArchiveOperationException", .linkage = .weak }) orelse missing("NSInvalidArchiveOperationException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInvalidUnarchiveOperationException`.
pub fn invalidUnarchiveOperationException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInvalidUnarchiveOperationException", .linkage = .weak }) orelse missing("NSInvalidUnarchiveOperationException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSKeyedArchiveRootObjectKey`.
pub fn keyedArchiveRootObjectKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSKeyedArchiveRootObjectKey", .linkage = .weak }) orelse missing("NSKeyedArchiveRootObjectKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFreeMapTable`.
pub fn freeMapTable(table: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSFreeMapTable", .linkage = .weak }) orelse missing("NSFreeMapTable");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSResetMapTable`.
pub fn resetMapTable(table: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSResetMapTable", .linkage = .weak }) orelse missing("NSResetMapTable");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSCompareMapTables`.
pub fn compareMapTables(table1: objc.Object, table2: objc.Object) bool {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(bool), .{ .name = "NSCompareMapTables", .linkage = .weak }) orelse missing("NSCompareMapTables");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(objc.Object, table1), objc.abi.toAbi(objc.Object, table2)));
}

/// `NSCopyMapTableWithZone`. What it returns is yours to release.
pub fn copyMapTableWithZone(table: objc.Object, zone: ?objc.Object) objc.Object {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?objc.Object)) callconv(.c) objc.abi.Abi(objc.Object), .{ .name = "NSCopyMapTableWithZone", .linkage = .weak }) orelse missing("NSCopyMapTableWithZone");
    return objc.abi.fromAbi(objc.Object, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?objc.Object, zone)));
}

/// `NSMapGet`.
pub fn mapGet(table: objc.Object, key: ?*const anyopaque) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSMapGet", .linkage = .weak }) orelse missing("NSMapGet");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, key)));
}

/// `NSMapInsert`.
pub fn mapInsert(table: objc.Object, key: ?*const anyopaque, value: ?*const anyopaque) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSMapInsert", .linkage = .weak }) orelse missing("NSMapInsert");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, key), objc.abi.toAbi(?*const anyopaque, value)));
}

/// `NSMapInsertKnownAbsent`.
pub fn mapInsertKnownAbsent(table: objc.Object, key: ?*const anyopaque, value: ?*const anyopaque) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSMapInsertKnownAbsent", .linkage = .weak }) orelse missing("NSMapInsertKnownAbsent");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, key), objc.abi.toAbi(?*const anyopaque, value)));
}

/// `NSMapInsertIfAbsent`.
pub fn mapInsertIfAbsent(table: objc.Object, key: ?*const anyopaque, value: ?*const anyopaque) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "NSMapInsertIfAbsent", .linkage = .weak }) orelse missing("NSMapInsertIfAbsent");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, key), objc.abi.toAbi(?*const anyopaque, value)));
}

/// `NSMapRemove`.
pub fn mapRemove(table: objc.Object, key: ?*const anyopaque) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object), objc.abi.Abi(?*const anyopaque)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSMapRemove", .linkage = .weak }) orelse missing("NSMapRemove");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, table), objc.abi.toAbi(?*const anyopaque, key)));
}

/// `NSEndMapTableEnumeration`.
pub fn endMapTableEnumeration(enumerator: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "NSEndMapTableEnumeration", .linkage = .weak }) orelse missing("NSEndMapTableEnumeration");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, enumerator)));
}

/// `NSCountMapTable`.
pub fn countMapTable(table: objc.Object) objc.UInteger {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(objc.UInteger), .{ .name = "NSCountMapTable", .linkage = .weak }) orelse missing("NSCountMapTable");
    return objc.abi.fromAbi(objc.UInteger, function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSStringFromMapTable`.
pub fn stringFromMapTable(table: objc.Object) foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(foundation.String), .{ .name = "NSStringFromMapTable", .linkage = .weak }) orelse missing("NSStringFromMapTable");
    return objc.abi.fromAbi(foundation.String, function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSAllMapTableKeys`.
pub fn allMapTableKeys(table: objc.Object) foundation.Array(objc.Object) {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(foundation.Array(objc.Object)), .{ .name = "NSAllMapTableKeys", .linkage = .weak }) orelse missing("NSAllMapTableKeys");
    return objc.abi.fromAbi(foundation.Array(objc.Object), function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSAllMapTableValues`.
pub fn allMapTableValues(table: objc.Object) foundation.Array(objc.Object) {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(foundation.Array(objc.Object)), .{ .name = "NSAllMapTableValues", .linkage = .weak }) orelse missing("NSAllMapTableValues");
    return objc.abi.fromAbi(foundation.Array(objc.Object), function(objc.abi.toAbi(objc.Object, table)));
}

/// `NSInvocationOperationVoidResultException`.
pub fn invocationOperationVoidResultException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInvocationOperationVoidResultException", .linkage = .weak }) orelse missing("NSInvocationOperationVoidResultException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInvocationOperationCancelledException`.
pub fn invocationOperationCancelledException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInvocationOperationCancelledException", .linkage = .weak }) orelse missing("NSInvocationOperationCancelledException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPortDidBecomeInvalidNotification`.
pub fn portDidBecomeInvalidNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPortDidBecomeInvalidNotification", .linkage = .weak }) orelse missing("NSPortDidBecomeInvalidNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProcessInfoThermalStateDidChangeNotification`.
pub fn processInfoThermalStateDidChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProcessInfoThermalStateDidChangeNotification", .linkage = .weak }) orelse missing("NSProcessInfoThermalStateDidChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSProcessInfoPowerStateDidChangeNotification`.
pub fn processInfoPowerStateDidChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSProcessInfoPowerStateDidChangeNotification", .linkage = .weak }) orelse missing("NSProcessInfoPowerStateDidChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingNameKey`.
pub fn textCheckingNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingNameKey", .linkage = .weak }) orelse missing("NSTextCheckingNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingJobTitleKey`.
pub fn textCheckingJobTitleKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingJobTitleKey", .linkage = .weak }) orelse missing("NSTextCheckingJobTitleKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingOrganizationKey`.
pub fn textCheckingOrganizationKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingOrganizationKey", .linkage = .weak }) orelse missing("NSTextCheckingOrganizationKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingStreetKey`.
pub fn textCheckingStreetKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingStreetKey", .linkage = .weak }) orelse missing("NSTextCheckingStreetKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingCityKey`.
pub fn textCheckingCityKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingCityKey", .linkage = .weak }) orelse missing("NSTextCheckingCityKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingStateKey`.
pub fn textCheckingStateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingStateKey", .linkage = .weak }) orelse missing("NSTextCheckingStateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingZIPKey`.
pub fn textCheckingZIPKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingZIPKey", .linkage = .weak }) orelse missing("NSTextCheckingZIPKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingCountryKey`.
pub fn textCheckingCountryKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingCountryKey", .linkage = .weak }) orelse missing("NSTextCheckingCountryKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingPhoneKey`.
pub fn textCheckingPhoneKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingPhoneKey", .linkage = .weak }) orelse missing("NSTextCheckingPhoneKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingAirlineKey`.
pub fn textCheckingAirlineKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingAirlineKey", .linkage = .weak }) orelse missing("NSTextCheckingAirlineKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTextCheckingFlightKey`.
pub fn textCheckingFlightKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTextCheckingFlightKey", .linkage = .weak }) orelse missing("NSTextCheckingFlightKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSocketSecurityLevelKey`.
pub fn streamSocketSecurityLevelKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSocketSecurityLevelKey", .linkage = .weak }) orelse missing("NSStreamSocketSecurityLevelKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSocketSecurityLevelNone`.
pub fn streamSocketSecurityLevelNone() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSocketSecurityLevelNone", .linkage = .weak }) orelse missing("NSStreamSocketSecurityLevelNone");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSocketSecurityLevelSSLv2`.
pub fn streamSocketSecurityLevelSSLv2() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSocketSecurityLevelSSLv2", .linkage = .weak }) orelse missing("NSStreamSocketSecurityLevelSSLv2");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSocketSecurityLevelSSLv3`.
pub fn streamSocketSecurityLevelSSLv3() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSocketSecurityLevelSSLv3", .linkage = .weak }) orelse missing("NSStreamSocketSecurityLevelSSLv3");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSocketSecurityLevelTLSv1`.
pub fn streamSocketSecurityLevelTLSv1() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSocketSecurityLevelTLSv1", .linkage = .weak }) orelse missing("NSStreamSocketSecurityLevelTLSv1");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSocketSecurityLevelNegotiatedSSL`.
pub fn streamSocketSecurityLevelNegotiatedSSL() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSocketSecurityLevelNegotiatedSSL", .linkage = .weak }) orelse missing("NSStreamSocketSecurityLevelNegotiatedSSL");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSOCKSProxyConfigurationKey`.
pub fn streamSOCKSProxyConfigurationKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSOCKSProxyConfigurationKey", .linkage = .weak }) orelse missing("NSStreamSOCKSProxyConfigurationKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSOCKSProxyHostKey`.
pub fn streamSOCKSProxyHostKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSOCKSProxyHostKey", .linkage = .weak }) orelse missing("NSStreamSOCKSProxyHostKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSOCKSProxyPortKey`.
pub fn streamSOCKSProxyPortKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSOCKSProxyPortKey", .linkage = .weak }) orelse missing("NSStreamSOCKSProxyPortKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSOCKSProxyVersionKey`.
pub fn streamSOCKSProxyVersionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSOCKSProxyVersionKey", .linkage = .weak }) orelse missing("NSStreamSOCKSProxyVersionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSOCKSProxyUserKey`.
pub fn streamSOCKSProxyUserKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSOCKSProxyUserKey", .linkage = .weak }) orelse missing("NSStreamSOCKSProxyUserKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSOCKSProxyPasswordKey`.
pub fn streamSOCKSProxyPasswordKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSOCKSProxyPasswordKey", .linkage = .weak }) orelse missing("NSStreamSOCKSProxyPasswordKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSOCKSProxyVersion4`.
pub fn streamSOCKSProxyVersion4() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSOCKSProxyVersion4", .linkage = .weak }) orelse missing("NSStreamSOCKSProxyVersion4");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSOCKSProxyVersion5`.
pub fn streamSOCKSProxyVersion5() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSOCKSProxyVersion5", .linkage = .weak }) orelse missing("NSStreamSOCKSProxyVersion5");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamDataWrittenToMemoryStreamKey`.
pub fn streamDataWrittenToMemoryStreamKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamDataWrittenToMemoryStreamKey", .linkage = .weak }) orelse missing("NSStreamDataWrittenToMemoryStreamKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamFileCurrentOffsetKey`.
pub fn streamFileCurrentOffsetKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamFileCurrentOffsetKey", .linkage = .weak }) orelse missing("NSStreamFileCurrentOffsetKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSocketSSLErrorDomain`.
pub fn streamSocketSSLErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSocketSSLErrorDomain", .linkage = .weak }) orelse missing("NSStreamSocketSSLErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamSOCKSErrorDomain`.
pub fn streamSOCKSErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamSOCKSErrorDomain", .linkage = .weak }) orelse missing("NSStreamSOCKSErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamNetworkServiceType`.
pub fn streamNetworkServiceType() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamNetworkServiceType", .linkage = .weak }) orelse missing("NSStreamNetworkServiceType");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamNetworkServiceTypeVoIP`.
pub fn streamNetworkServiceTypeVoIP() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamNetworkServiceTypeVoIP", .linkage = .weak }) orelse missing("NSStreamNetworkServiceTypeVoIP");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamNetworkServiceTypeVideo`.
pub fn streamNetworkServiceTypeVideo() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamNetworkServiceTypeVideo", .linkage = .weak }) orelse missing("NSStreamNetworkServiceTypeVideo");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamNetworkServiceTypeBackground`.
pub fn streamNetworkServiceTypeBackground() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamNetworkServiceTypeBackground", .linkage = .weak }) orelse missing("NSStreamNetworkServiceTypeBackground");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamNetworkServiceTypeVoice`.
pub fn streamNetworkServiceTypeVoice() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamNetworkServiceTypeVoice", .linkage = .weak }) orelse missing("NSStreamNetworkServiceTypeVoice");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSStreamNetworkServiceTypeCallSignaling`.
pub fn streamNetworkServiceTypeCallSignaling() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSStreamNetworkServiceTypeCallSignaling", .linkage = .weak }) orelse missing("NSStreamNetworkServiceTypeCallSignaling");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSWillBecomeMultiThreadedNotification`.
pub fn willBecomeMultiThreadedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSWillBecomeMultiThreadedNotification", .linkage = .weak }) orelse missing("NSWillBecomeMultiThreadedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDidBecomeSingleThreadedNotification`.
pub fn didBecomeSingleThreadedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDidBecomeSingleThreadedNotification", .linkage = .weak }) orelse missing("NSDidBecomeSingleThreadedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSThreadWillExitNotification`.
pub fn threadWillExitNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSThreadWillExitNotification", .linkage = .weak }) orelse missing("NSThreadWillExitNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSSystemTimeZoneDidChangeNotification`.
pub fn systemTimeZoneDidChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSSystemTimeZoneDidChangeNotification", .linkage = .weak }) orelse missing("NSSystemTimeZoneDidChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLProtectionSpaceHTTP`.
pub fn urlProtectionSpaceHTTP() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLProtectionSpaceHTTP", .linkage = .weak }) orelse missing("NSURLProtectionSpaceHTTP");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLProtectionSpaceHTTPS`.
pub fn urlProtectionSpaceHTTPS() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLProtectionSpaceHTTPS", .linkage = .weak }) orelse missing("NSURLProtectionSpaceHTTPS");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLProtectionSpaceFTP`.
pub fn urlProtectionSpaceFTP() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLProtectionSpaceFTP", .linkage = .weak }) orelse missing("NSURLProtectionSpaceFTP");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLProtectionSpaceHTTPProxy`.
pub fn urlProtectionSpaceHTTPProxy() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLProtectionSpaceHTTPProxy", .linkage = .weak }) orelse missing("NSURLProtectionSpaceHTTPProxy");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLProtectionSpaceHTTPSProxy`.
pub fn urlProtectionSpaceHTTPSProxy() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLProtectionSpaceHTTPSProxy", .linkage = .weak }) orelse missing("NSURLProtectionSpaceHTTPSProxy");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLProtectionSpaceFTPProxy`.
pub fn urlProtectionSpaceFTPProxy() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLProtectionSpaceFTPProxy", .linkage = .weak }) orelse missing("NSURLProtectionSpaceFTPProxy");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLProtectionSpaceSOCKSProxy`.
pub fn urlProtectionSpaceSOCKSProxy() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLProtectionSpaceSOCKSProxy", .linkage = .weak }) orelse missing("NSURLProtectionSpaceSOCKSProxy");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAuthenticationMethodDefault`.
pub fn urlAuthenticationMethodDefault() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAuthenticationMethodDefault", .linkage = .weak }) orelse missing("NSURLAuthenticationMethodDefault");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAuthenticationMethodHTTPBasic`.
pub fn urlAuthenticationMethodHTTPBasic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAuthenticationMethodHTTPBasic", .linkage = .weak }) orelse missing("NSURLAuthenticationMethodHTTPBasic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAuthenticationMethodHTTPDigest`.
pub fn urlAuthenticationMethodHTTPDigest() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAuthenticationMethodHTTPDigest", .linkage = .weak }) orelse missing("NSURLAuthenticationMethodHTTPDigest");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAuthenticationMethodHTMLForm`.
pub fn urlAuthenticationMethodHTMLForm() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAuthenticationMethodHTMLForm", .linkage = .weak }) orelse missing("NSURLAuthenticationMethodHTMLForm");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAuthenticationMethodNTLM`.
pub fn urlAuthenticationMethodNTLM() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAuthenticationMethodNTLM", .linkage = .weak }) orelse missing("NSURLAuthenticationMethodNTLM");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAuthenticationMethodNegotiate`.
pub fn urlAuthenticationMethodNegotiate() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAuthenticationMethodNegotiate", .linkage = .weak }) orelse missing("NSURLAuthenticationMethodNegotiate");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAuthenticationMethodClientCertificate`.
pub fn urlAuthenticationMethodClientCertificate() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAuthenticationMethodClientCertificate", .linkage = .weak }) orelse missing("NSURLAuthenticationMethodClientCertificate");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLAuthenticationMethodServerTrust`.
pub fn urlAuthenticationMethodServerTrust() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLAuthenticationMethodServerTrust", .linkage = .weak }) orelse missing("NSURLAuthenticationMethodServerTrust");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLCredentialStorageChangedNotification`.
pub fn urlCredentialStorageChangedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLCredentialStorageChangedNotification", .linkage = .weak }) orelse missing("NSURLCredentialStorageChangedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLCredentialStorageRemoveSynchronizableCredentials`.
pub fn urlCredentialStorageRemoveSynchronizableCredentials() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLCredentialStorageRemoveSynchronizableCredentials", .linkage = .weak }) orelse missing("NSURLCredentialStorageRemoveSynchronizableCredentials");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLErrorDomain`.
pub fn urlErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLErrorDomain", .linkage = .weak }) orelse missing("NSURLErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLErrorFailingURLErrorKey`.
pub fn urlErrorFailingURLErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLErrorFailingURLErrorKey", .linkage = .weak }) orelse missing("NSURLErrorFailingURLErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLErrorFailingURLStringErrorKey`.
pub fn urlErrorFailingURLStringErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLErrorFailingURLStringErrorKey", .linkage = .weak }) orelse missing("NSURLErrorFailingURLStringErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSErrorFailingURLStringKey`.
pub fn errorFailingURLStringKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSErrorFailingURLStringKey", .linkage = .weak }) orelse missing("NSErrorFailingURLStringKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLErrorFailingURLPeerTrustErrorKey`.
pub fn urlErrorFailingURLPeerTrustErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLErrorFailingURLPeerTrustErrorKey", .linkage = .weak }) orelse missing("NSURLErrorFailingURLPeerTrustErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLErrorBackgroundTaskCancelledReasonKey`.
pub fn urlErrorBackgroundTaskCancelledReasonKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLErrorBackgroundTaskCancelledReasonKey", .linkage = .weak }) orelse missing("NSURLErrorBackgroundTaskCancelledReasonKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLErrorNetworkUnavailableReasonKey`.
pub fn urlErrorNetworkUnavailableReasonKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLErrorNetworkUnavailableReasonKey", .linkage = .weak }) orelse missing("NSURLErrorNetworkUnavailableReasonKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSGlobalDomain`.
pub fn globalDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSGlobalDomain", .linkage = .weak }) orelse missing("NSGlobalDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSArgumentDomain`.
pub fn argumentDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSArgumentDomain", .linkage = .weak }) orelse missing("NSArgumentDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSRegistrationDomain`.
pub fn registrationDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSRegistrationDomain", .linkage = .weak }) orelse missing("NSRegistrationDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUserDefaultsDidChangeNotification`.
pub fn userDefaultsDidChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUserDefaultsDidChangeNotification", .linkage = .weak }) orelse missing("NSUserDefaultsDidChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSWeekDayNameArray`.
pub fn weekDayNameArray() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSWeekDayNameArray", .linkage = .weak }) orelse missing("NSWeekDayNameArray");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSShortWeekDayNameArray`.
pub fn shortWeekDayNameArray() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSShortWeekDayNameArray", .linkage = .weak }) orelse missing("NSShortWeekDayNameArray");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMonthNameArray`.
pub fn monthNameArray() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMonthNameArray", .linkage = .weak }) orelse missing("NSMonthNameArray");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSShortMonthNameArray`.
pub fn shortMonthNameArray() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSShortMonthNameArray", .linkage = .weak }) orelse missing("NSShortMonthNameArray");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTimeFormatString`.
pub fn timeFormatString() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTimeFormatString", .linkage = .weak }) orelse missing("NSTimeFormatString");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDateFormatString`.
pub fn dateFormatString() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDateFormatString", .linkage = .weak }) orelse missing("NSDateFormatString");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTimeDateFormatString`.
pub fn timeDateFormatString() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTimeDateFormatString", .linkage = .weak }) orelse missing("NSTimeDateFormatString");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSShortTimeDateFormatString`.
pub fn shortTimeDateFormatString() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSShortTimeDateFormatString", .linkage = .weak }) orelse missing("NSShortTimeDateFormatString");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSCurrencySymbol`.
pub fn currencySymbol() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSCurrencySymbol", .linkage = .weak }) orelse missing("NSCurrencySymbol");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDecimalSeparator`.
pub fn decimalSeparator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDecimalSeparator", .linkage = .weak }) orelse missing("NSDecimalSeparator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSThousandsSeparator`.
pub fn thousandsSeparator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSThousandsSeparator", .linkage = .weak }) orelse missing("NSThousandsSeparator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDecimalDigits`.
pub fn decimalDigits() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDecimalDigits", .linkage = .weak }) orelse missing("NSDecimalDigits");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSAMPMDesignation`.
pub fn ampmDesignation() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAMPMDesignation", .linkage = .weak }) orelse missing("NSAMPMDesignation");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSHourNameDesignations`.
pub fn hourNameDesignations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSHourNameDesignations", .linkage = .weak }) orelse missing("NSHourNameDesignations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSYearMonthWeekDesignations`.
pub fn yearMonthWeekDesignations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSYearMonthWeekDesignations", .linkage = .weak }) orelse missing("NSYearMonthWeekDesignations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSEarlierTimeDesignations`.
pub fn earlierTimeDesignations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSEarlierTimeDesignations", .linkage = .weak }) orelse missing("NSEarlierTimeDesignations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLaterTimeDesignations`.
pub fn laterTimeDesignations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLaterTimeDesignations", .linkage = .weak }) orelse missing("NSLaterTimeDesignations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSThisDayDesignations`.
pub fn thisDayDesignations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSThisDayDesignations", .linkage = .weak }) orelse missing("NSThisDayDesignations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSNextDayDesignations`.
pub fn nextDayDesignations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSNextDayDesignations", .linkage = .weak }) orelse missing("NSNextDayDesignations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSNextNextDayDesignations`.
pub fn nextNextDayDesignations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSNextNextDayDesignations", .linkage = .weak }) orelse missing("NSNextNextDayDesignations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPriorDayDesignations`.
pub fn priorDayDesignations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPriorDayDesignations", .linkage = .weak }) orelse missing("NSPriorDayDesignations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSDateTimeOrdering`.
pub fn dateTimeOrdering() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSDateTimeOrdering", .linkage = .weak }) orelse missing("NSDateTimeOrdering");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSInternationalCurrencyString`.
pub fn internationalCurrencyString() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSInternationalCurrencyString", .linkage = .weak }) orelse missing("NSInternationalCurrencyString");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSShortDateFormatString`.
pub fn shortDateFormatString() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSShortDateFormatString", .linkage = .weak }) orelse missing("NSShortDateFormatString");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSPositiveCurrencyFormatString`.
pub fn positiveCurrencyFormatString() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSPositiveCurrencyFormatString", .linkage = .weak }) orelse missing("NSPositiveCurrencyFormatString");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSNegativeCurrencyFormatString`.
pub fn negativeCurrencyFormatString() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSNegativeCurrencyFormatString", .linkage = .weak }) orelse missing("NSNegativeCurrencyFormatString");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSNegateBooleanTransformerName`.
pub fn negateBooleanTransformerName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSNegateBooleanTransformerName", .linkage = .weak }) orelse missing("NSNegateBooleanTransformerName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSIsNilTransformerName`.
pub fn isNilTransformerName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSIsNilTransformerName", .linkage = .weak }) orelse missing("NSIsNilTransformerName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSIsNotNilTransformerName`.
pub fn isNotNilTransformerName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSIsNotNilTransformerName", .linkage = .weak }) orelse missing("NSIsNotNilTransformerName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUnarchiveFromDataTransformerName`.
pub fn unarchiveFromDataTransformerName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUnarchiveFromDataTransformerName", .linkage = .weak }) orelse missing("NSUnarchiveFromDataTransformerName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSKeyedUnarchiveFromDataTransformerName`.
pub fn keyedUnarchiveFromDataTransformerName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSKeyedUnarchiveFromDataTransformerName", .linkage = .weak }) orelse missing("NSKeyedUnarchiveFromDataTransformerName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSSecureUnarchiveFromDataTransformerName`.
pub fn secureUnarchiveFromDataTransformerName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSSecureUnarchiveFromDataTransformerName", .linkage = .weak }) orelse missing("NSSecureUnarchiveFromDataTransformerName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSXMLParserErrorDomain`.
pub fn xmlParserErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSXMLParserErrorDomain", .linkage = .weak }) orelse missing("NSXMLParserErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSExtensionItemsAndErrorsKey`.
pub fn extensionItemsAndErrorsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSExtensionItemsAndErrorsKey", .linkage = .weak }) orelse missing("NSExtensionItemsAndErrorsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSExtensionItemAttributedTitleKey`.
pub fn extensionItemAttributedTitleKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSExtensionItemAttributedTitleKey", .linkage = .weak }) orelse missing("NSExtensionItemAttributedTitleKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSExtensionItemAttributedContentTextKey`.
pub fn extensionItemAttributedContentTextKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSExtensionItemAttributedContentTextKey", .linkage = .weak }) orelse missing("NSExtensionItemAttributedContentTextKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSExtensionItemAttachmentsKey`.
pub fn extensionItemAttachmentsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSExtensionItemAttachmentsKey", .linkage = .weak }) orelse missing("NSExtensionItemAttachmentsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagSchemeTokenType`.
pub fn linguisticTagSchemeTokenType() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagSchemeTokenType", .linkage = .weak }) orelse missing("NSLinguisticTagSchemeTokenType");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagSchemeLexicalClass`.
pub fn linguisticTagSchemeLexicalClass() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagSchemeLexicalClass", .linkage = .weak }) orelse missing("NSLinguisticTagSchemeLexicalClass");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagSchemeNameType`.
pub fn linguisticTagSchemeNameType() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagSchemeNameType", .linkage = .weak }) orelse missing("NSLinguisticTagSchemeNameType");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagSchemeNameTypeOrLexicalClass`.
pub fn linguisticTagSchemeNameTypeOrLexicalClass() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagSchemeNameTypeOrLexicalClass", .linkage = .weak }) orelse missing("NSLinguisticTagSchemeNameTypeOrLexicalClass");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagSchemeLemma`.
pub fn linguisticTagSchemeLemma() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagSchemeLemma", .linkage = .weak }) orelse missing("NSLinguisticTagSchemeLemma");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagSchemeLanguage`.
pub fn linguisticTagSchemeLanguage() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagSchemeLanguage", .linkage = .weak }) orelse missing("NSLinguisticTagSchemeLanguage");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagSchemeScript`.
pub fn linguisticTagSchemeScript() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagSchemeScript", .linkage = .weak }) orelse missing("NSLinguisticTagSchemeScript");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagWord`.
pub fn linguisticTagWord() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagWord", .linkage = .weak }) orelse missing("NSLinguisticTagWord");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagPunctuation`.
pub fn linguisticTagPunctuation() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagPunctuation", .linkage = .weak }) orelse missing("NSLinguisticTagPunctuation");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagWhitespace`.
pub fn linguisticTagWhitespace() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagWhitespace", .linkage = .weak }) orelse missing("NSLinguisticTagWhitespace");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagOther`.
pub fn linguisticTagOther() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagOther", .linkage = .weak }) orelse missing("NSLinguisticTagOther");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagNoun`.
pub fn linguisticTagNoun() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagNoun", .linkage = .weak }) orelse missing("NSLinguisticTagNoun");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagVerb`.
pub fn linguisticTagVerb() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagVerb", .linkage = .weak }) orelse missing("NSLinguisticTagVerb");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagAdjective`.
pub fn linguisticTagAdjective() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagAdjective", .linkage = .weak }) orelse missing("NSLinguisticTagAdjective");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagAdverb`.
pub fn linguisticTagAdverb() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagAdverb", .linkage = .weak }) orelse missing("NSLinguisticTagAdverb");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagPronoun`.
pub fn linguisticTagPronoun() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagPronoun", .linkage = .weak }) orelse missing("NSLinguisticTagPronoun");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagDeterminer`.
pub fn linguisticTagDeterminer() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagDeterminer", .linkage = .weak }) orelse missing("NSLinguisticTagDeterminer");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagParticle`.
pub fn linguisticTagParticle() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagParticle", .linkage = .weak }) orelse missing("NSLinguisticTagParticle");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagPreposition`.
pub fn linguisticTagPreposition() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagPreposition", .linkage = .weak }) orelse missing("NSLinguisticTagPreposition");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagNumber`.
pub fn linguisticTagNumber() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagNumber", .linkage = .weak }) orelse missing("NSLinguisticTagNumber");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagConjunction`.
pub fn linguisticTagConjunction() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagConjunction", .linkage = .weak }) orelse missing("NSLinguisticTagConjunction");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagInterjection`.
pub fn linguisticTagInterjection() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagInterjection", .linkage = .weak }) orelse missing("NSLinguisticTagInterjection");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagClassifier`.
pub fn linguisticTagClassifier() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagClassifier", .linkage = .weak }) orelse missing("NSLinguisticTagClassifier");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagIdiom`.
pub fn linguisticTagIdiom() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagIdiom", .linkage = .weak }) orelse missing("NSLinguisticTagIdiom");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagOtherWord`.
pub fn linguisticTagOtherWord() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagOtherWord", .linkage = .weak }) orelse missing("NSLinguisticTagOtherWord");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagSentenceTerminator`.
pub fn linguisticTagSentenceTerminator() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagSentenceTerminator", .linkage = .weak }) orelse missing("NSLinguisticTagSentenceTerminator");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagOpenQuote`.
pub fn linguisticTagOpenQuote() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagOpenQuote", .linkage = .weak }) orelse missing("NSLinguisticTagOpenQuote");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagCloseQuote`.
pub fn linguisticTagCloseQuote() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagCloseQuote", .linkage = .weak }) orelse missing("NSLinguisticTagCloseQuote");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagOpenParenthesis`.
pub fn linguisticTagOpenParenthesis() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagOpenParenthesis", .linkage = .weak }) orelse missing("NSLinguisticTagOpenParenthesis");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagCloseParenthesis`.
pub fn linguisticTagCloseParenthesis() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagCloseParenthesis", .linkage = .weak }) orelse missing("NSLinguisticTagCloseParenthesis");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagWordJoiner`.
pub fn linguisticTagWordJoiner() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagWordJoiner", .linkage = .weak }) orelse missing("NSLinguisticTagWordJoiner");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagDash`.
pub fn linguisticTagDash() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagDash", .linkage = .weak }) orelse missing("NSLinguisticTagDash");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagOtherPunctuation`.
pub fn linguisticTagOtherPunctuation() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagOtherPunctuation", .linkage = .weak }) orelse missing("NSLinguisticTagOtherPunctuation");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagParagraphBreak`.
pub fn linguisticTagParagraphBreak() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagParagraphBreak", .linkage = .weak }) orelse missing("NSLinguisticTagParagraphBreak");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagOtherWhitespace`.
pub fn linguisticTagOtherWhitespace() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagOtherWhitespace", .linkage = .weak }) orelse missing("NSLinguisticTagOtherWhitespace");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagPersonalName`.
pub fn linguisticTagPersonalName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagPersonalName", .linkage = .weak }) orelse missing("NSLinguisticTagPersonalName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagPlaceName`.
pub fn linguisticTagPlaceName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagPlaceName", .linkage = .weak }) orelse missing("NSLinguisticTagPlaceName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLinguisticTagOrganizationName`.
pub fn linguisticTagOrganizationName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLinguisticTagOrganizationName", .linkage = .weak }) orelse missing("NSLinguisticTagOrganizationName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFSNameKey`.
pub fn metadataItemFSNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFSNameKey", .linkage = .weak }) orelse missing("NSMetadataItemFSNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemDisplayNameKey`.
pub fn metadataItemDisplayNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemDisplayNameKey", .linkage = .weak }) orelse missing("NSMetadataItemDisplayNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemURLKey`.
pub fn metadataItemURLKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemURLKey", .linkage = .weak }) orelse missing("NSMetadataItemURLKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemPathKey`.
pub fn metadataItemPathKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemPathKey", .linkage = .weak }) orelse missing("NSMetadataItemPathKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFSSizeKey`.
pub fn metadataItemFSSizeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFSSizeKey", .linkage = .weak }) orelse missing("NSMetadataItemFSSizeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFSCreationDateKey`.
pub fn metadataItemFSCreationDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFSCreationDateKey", .linkage = .weak }) orelse missing("NSMetadataItemFSCreationDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFSContentChangeDateKey`.
pub fn metadataItemFSContentChangeDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFSContentChangeDateKey", .linkage = .weak }) orelse missing("NSMetadataItemFSContentChangeDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemContentTypeKey`.
pub fn metadataItemContentTypeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemContentTypeKey", .linkage = .weak }) orelse missing("NSMetadataItemContentTypeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemContentTypeTreeKey`.
pub fn metadataItemContentTypeTreeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemContentTypeTreeKey", .linkage = .weak }) orelse missing("NSMetadataItemContentTypeTreeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemIsUbiquitousKey`.
pub fn metadataItemIsUbiquitousKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemIsUbiquitousKey", .linkage = .weak }) orelse missing("NSMetadataItemIsUbiquitousKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemHasUnresolvedConflictsKey`.
pub fn metadataUbiquitousItemHasUnresolvedConflictsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemHasUnresolvedConflictsKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemHasUnresolvedConflictsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemIsDownloadedKey`.
pub fn metadataUbiquitousItemIsDownloadedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemIsDownloadedKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemIsDownloadedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemDownloadingStatusKey`.
pub fn metadataUbiquitousItemDownloadingStatusKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemDownloadingStatusKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemDownloadingStatusKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemDownloadingStatusNotDownloaded`.
pub fn metadataUbiquitousItemDownloadingStatusNotDownloaded() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemDownloadingStatusNotDownloaded", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemDownloadingStatusNotDownloaded");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemDownloadingStatusDownloaded`.
pub fn metadataUbiquitousItemDownloadingStatusDownloaded() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemDownloadingStatusDownloaded", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemDownloadingStatusDownloaded");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemDownloadingStatusCurrent`.
pub fn metadataUbiquitousItemDownloadingStatusCurrent() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemDownloadingStatusCurrent", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemDownloadingStatusCurrent");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemIsDownloadingKey`.
pub fn metadataUbiquitousItemIsDownloadingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemIsDownloadingKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemIsDownloadingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemIsUploadedKey`.
pub fn metadataUbiquitousItemIsUploadedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemIsUploadedKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemIsUploadedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemIsUploadingKey`.
pub fn metadataUbiquitousItemIsUploadingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemIsUploadingKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemIsUploadingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemPercentDownloadedKey`.
pub fn metadataUbiquitousItemPercentDownloadedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemPercentDownloadedKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemPercentDownloadedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemPercentUploadedKey`.
pub fn metadataUbiquitousItemPercentUploadedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemPercentUploadedKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemPercentUploadedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemDownloadingErrorKey`.
pub fn metadataUbiquitousItemDownloadingErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemDownloadingErrorKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemDownloadingErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemUploadingErrorKey`.
pub fn metadataUbiquitousItemUploadingErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemUploadingErrorKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemUploadingErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemDownloadRequestedKey`.
pub fn metadataUbiquitousItemDownloadRequestedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemDownloadRequestedKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemDownloadRequestedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemIsExternalDocumentKey`.
pub fn metadataUbiquitousItemIsExternalDocumentKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemIsExternalDocumentKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemIsExternalDocumentKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemContainerDisplayNameKey`.
pub fn metadataUbiquitousItemContainerDisplayNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemContainerDisplayNameKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemContainerDisplayNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemURLInLocalContainerKey`.
pub fn metadataUbiquitousItemURLInLocalContainerKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemURLInLocalContainerKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemURLInLocalContainerKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousItemIsSharedKey`.
pub fn metadataUbiquitousItemIsSharedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousItemIsSharedKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousItemIsSharedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousSharedItemCurrentUserRoleKey`.
pub fn metadataUbiquitousSharedItemCurrentUserRoleKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousSharedItemCurrentUserRoleKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousSharedItemCurrentUserRoleKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousSharedItemCurrentUserPermissionsKey`.
pub fn metadataUbiquitousSharedItemCurrentUserPermissionsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousSharedItemCurrentUserPermissionsKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousSharedItemCurrentUserPermissionsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousSharedItemOwnerNameComponentsKey`.
pub fn metadataUbiquitousSharedItemOwnerNameComponentsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousSharedItemOwnerNameComponentsKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousSharedItemOwnerNameComponentsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousSharedItemMostRecentEditorNameComponentsKey`.
pub fn metadataUbiquitousSharedItemMostRecentEditorNameComponentsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousSharedItemMostRecentEditorNameComponentsKey", .linkage = .weak }) orelse missing("NSMetadataUbiquitousSharedItemMostRecentEditorNameComponentsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousSharedItemRoleOwner`.
pub fn metadataUbiquitousSharedItemRoleOwner() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousSharedItemRoleOwner", .linkage = .weak }) orelse missing("NSMetadataUbiquitousSharedItemRoleOwner");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousSharedItemRoleParticipant`.
pub fn metadataUbiquitousSharedItemRoleParticipant() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousSharedItemRoleParticipant", .linkage = .weak }) orelse missing("NSMetadataUbiquitousSharedItemRoleParticipant");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousSharedItemPermissionsReadOnly`.
pub fn metadataUbiquitousSharedItemPermissionsReadOnly() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousSharedItemPermissionsReadOnly", .linkage = .weak }) orelse missing("NSMetadataUbiquitousSharedItemPermissionsReadOnly");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataUbiquitousSharedItemPermissionsReadWrite`.
pub fn metadataUbiquitousSharedItemPermissionsReadWrite() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataUbiquitousSharedItemPermissionsReadWrite", .linkage = .weak }) orelse missing("NSMetadataUbiquitousSharedItemPermissionsReadWrite");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAttributeChangeDateKey`.
pub fn metadataItemAttributeChangeDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAttributeChangeDateKey", .linkage = .weak }) orelse missing("NSMetadataItemAttributeChangeDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemKeywordsKey`.
pub fn metadataItemKeywordsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemKeywordsKey", .linkage = .weak }) orelse missing("NSMetadataItemKeywordsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemTitleKey`.
pub fn metadataItemTitleKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemTitleKey", .linkage = .weak }) orelse missing("NSMetadataItemTitleKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAuthorsKey`.
pub fn metadataItemAuthorsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAuthorsKey", .linkage = .weak }) orelse missing("NSMetadataItemAuthorsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemEditorsKey`.
pub fn metadataItemEditorsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemEditorsKey", .linkage = .weak }) orelse missing("NSMetadataItemEditorsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemParticipantsKey`.
pub fn metadataItemParticipantsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemParticipantsKey", .linkage = .weak }) orelse missing("NSMetadataItemParticipantsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemProjectsKey`.
pub fn metadataItemProjectsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemProjectsKey", .linkage = .weak }) orelse missing("NSMetadataItemProjectsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemDownloadedDateKey`.
pub fn metadataItemDownloadedDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemDownloadedDateKey", .linkage = .weak }) orelse missing("NSMetadataItemDownloadedDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemWhereFromsKey`.
pub fn metadataItemWhereFromsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemWhereFromsKey", .linkage = .weak }) orelse missing("NSMetadataItemWhereFromsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemCommentKey`.
pub fn metadataItemCommentKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemCommentKey", .linkage = .weak }) orelse missing("NSMetadataItemCommentKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemCopyrightKey`.
pub fn metadataItemCopyrightKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemCopyrightKey", .linkage = .weak }) orelse missing("NSMetadataItemCopyrightKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemLastUsedDateKey`.
pub fn metadataItemLastUsedDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemLastUsedDateKey", .linkage = .weak }) orelse missing("NSMetadataItemLastUsedDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemContentCreationDateKey`.
pub fn metadataItemContentCreationDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemContentCreationDateKey", .linkage = .weak }) orelse missing("NSMetadataItemContentCreationDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemContentModificationDateKey`.
pub fn metadataItemContentModificationDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemContentModificationDateKey", .linkage = .weak }) orelse missing("NSMetadataItemContentModificationDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemDateAddedKey`.
pub fn metadataItemDateAddedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemDateAddedKey", .linkage = .weak }) orelse missing("NSMetadataItemDateAddedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemDurationSecondsKey`.
pub fn metadataItemDurationSecondsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemDurationSecondsKey", .linkage = .weak }) orelse missing("NSMetadataItemDurationSecondsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemContactKeywordsKey`.
pub fn metadataItemContactKeywordsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemContactKeywordsKey", .linkage = .weak }) orelse missing("NSMetadataItemContactKeywordsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemVersionKey`.
pub fn metadataItemVersionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemVersionKey", .linkage = .weak }) orelse missing("NSMetadataItemVersionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemPixelHeightKey`.
pub fn metadataItemPixelHeightKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemPixelHeightKey", .linkage = .weak }) orelse missing("NSMetadataItemPixelHeightKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemPixelWidthKey`.
pub fn metadataItemPixelWidthKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemPixelWidthKey", .linkage = .weak }) orelse missing("NSMetadataItemPixelWidthKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemPixelCountKey`.
pub fn metadataItemPixelCountKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemPixelCountKey", .linkage = .weak }) orelse missing("NSMetadataItemPixelCountKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemColorSpaceKey`.
pub fn metadataItemColorSpaceKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemColorSpaceKey", .linkage = .weak }) orelse missing("NSMetadataItemColorSpaceKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemBitsPerSampleKey`.
pub fn metadataItemBitsPerSampleKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemBitsPerSampleKey", .linkage = .weak }) orelse missing("NSMetadataItemBitsPerSampleKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFlashOnOffKey`.
pub fn metadataItemFlashOnOffKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFlashOnOffKey", .linkage = .weak }) orelse missing("NSMetadataItemFlashOnOffKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFocalLengthKey`.
pub fn metadataItemFocalLengthKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFocalLengthKey", .linkage = .weak }) orelse missing("NSMetadataItemFocalLengthKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAcquisitionMakeKey`.
pub fn metadataItemAcquisitionMakeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAcquisitionMakeKey", .linkage = .weak }) orelse missing("NSMetadataItemAcquisitionMakeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAcquisitionModelKey`.
pub fn metadataItemAcquisitionModelKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAcquisitionModelKey", .linkage = .weak }) orelse missing("NSMetadataItemAcquisitionModelKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemISOSpeedKey`.
pub fn metadataItemISOSpeedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemISOSpeedKey", .linkage = .weak }) orelse missing("NSMetadataItemISOSpeedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemOrientationKey`.
pub fn metadataItemOrientationKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemOrientationKey", .linkage = .weak }) orelse missing("NSMetadataItemOrientationKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemLayerNamesKey`.
pub fn metadataItemLayerNamesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemLayerNamesKey", .linkage = .weak }) orelse missing("NSMetadataItemLayerNamesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemWhiteBalanceKey`.
pub fn metadataItemWhiteBalanceKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemWhiteBalanceKey", .linkage = .weak }) orelse missing("NSMetadataItemWhiteBalanceKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemApertureKey`.
pub fn metadataItemApertureKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemApertureKey", .linkage = .weak }) orelse missing("NSMetadataItemApertureKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemProfileNameKey`.
pub fn metadataItemProfileNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemProfileNameKey", .linkage = .weak }) orelse missing("NSMetadataItemProfileNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemResolutionWidthDPIKey`.
pub fn metadataItemResolutionWidthDPIKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemResolutionWidthDPIKey", .linkage = .weak }) orelse missing("NSMetadataItemResolutionWidthDPIKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemResolutionHeightDPIKey`.
pub fn metadataItemResolutionHeightDPIKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemResolutionHeightDPIKey", .linkage = .weak }) orelse missing("NSMetadataItemResolutionHeightDPIKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemExposureModeKey`.
pub fn metadataItemExposureModeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemExposureModeKey", .linkage = .weak }) orelse missing("NSMetadataItemExposureModeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemExposureTimeSecondsKey`.
pub fn metadataItemExposureTimeSecondsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemExposureTimeSecondsKey", .linkage = .weak }) orelse missing("NSMetadataItemExposureTimeSecondsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemEXIFVersionKey`.
pub fn metadataItemEXIFVersionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemEXIFVersionKey", .linkage = .weak }) orelse missing("NSMetadataItemEXIFVersionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemCameraOwnerKey`.
pub fn metadataItemCameraOwnerKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemCameraOwnerKey", .linkage = .weak }) orelse missing("NSMetadataItemCameraOwnerKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFocalLength35mmKey`.
pub fn metadataItemFocalLength35mmKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFocalLength35mmKey", .linkage = .weak }) orelse missing("NSMetadataItemFocalLength35mmKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemLensModelKey`.
pub fn metadataItemLensModelKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemLensModelKey", .linkage = .weak }) orelse missing("NSMetadataItemLensModelKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemEXIFGPSVersionKey`.
pub fn metadataItemEXIFGPSVersionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemEXIFGPSVersionKey", .linkage = .weak }) orelse missing("NSMetadataItemEXIFGPSVersionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAltitudeKey`.
pub fn metadataItemAltitudeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAltitudeKey", .linkage = .weak }) orelse missing("NSMetadataItemAltitudeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemLatitudeKey`.
pub fn metadataItemLatitudeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemLatitudeKey", .linkage = .weak }) orelse missing("NSMetadataItemLatitudeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemLongitudeKey`.
pub fn metadataItemLongitudeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemLongitudeKey", .linkage = .weak }) orelse missing("NSMetadataItemLongitudeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemSpeedKey`.
pub fn metadataItemSpeedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemSpeedKey", .linkage = .weak }) orelse missing("NSMetadataItemSpeedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemTimestampKey`.
pub fn metadataItemTimestampKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemTimestampKey", .linkage = .weak }) orelse missing("NSMetadataItemTimestampKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSTrackKey`.
pub fn metadataItemGPSTrackKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSTrackKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSTrackKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemImageDirectionKey`.
pub fn metadataItemImageDirectionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemImageDirectionKey", .linkage = .weak }) orelse missing("NSMetadataItemImageDirectionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemNamedLocationKey`.
pub fn metadataItemNamedLocationKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemNamedLocationKey", .linkage = .weak }) orelse missing("NSMetadataItemNamedLocationKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSStatusKey`.
pub fn metadataItemGPSStatusKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSStatusKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSStatusKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSMeasureModeKey`.
pub fn metadataItemGPSMeasureModeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSMeasureModeKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSMeasureModeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSDOPKey`.
pub fn metadataItemGPSDOPKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSDOPKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSDOPKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSMapDatumKey`.
pub fn metadataItemGPSMapDatumKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSMapDatumKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSMapDatumKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSDestLatitudeKey`.
pub fn metadataItemGPSDestLatitudeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSDestLatitudeKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSDestLatitudeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSDestLongitudeKey`.
pub fn metadataItemGPSDestLongitudeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSDestLongitudeKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSDestLongitudeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSDestBearingKey`.
pub fn metadataItemGPSDestBearingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSDestBearingKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSDestBearingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSDestDistanceKey`.
pub fn metadataItemGPSDestDistanceKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSDestDistanceKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSDestDistanceKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSProcessingMethodKey`.
pub fn metadataItemGPSProcessingMethodKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSProcessingMethodKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSProcessingMethodKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSAreaInformationKey`.
pub fn metadataItemGPSAreaInformationKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSAreaInformationKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSAreaInformationKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSDateStampKey`.
pub fn metadataItemGPSDateStampKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSDateStampKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSDateStampKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGPSDifferentalKey`.
pub fn metadataItemGPSDifferentalKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGPSDifferentalKey", .linkage = .weak }) orelse missing("NSMetadataItemGPSDifferentalKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemCodecsKey`.
pub fn metadataItemCodecsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemCodecsKey", .linkage = .weak }) orelse missing("NSMetadataItemCodecsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemMediaTypesKey`.
pub fn metadataItemMediaTypesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemMediaTypesKey", .linkage = .weak }) orelse missing("NSMetadataItemMediaTypesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemStreamableKey`.
pub fn metadataItemStreamableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemStreamableKey", .linkage = .weak }) orelse missing("NSMetadataItemStreamableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemTotalBitRateKey`.
pub fn metadataItemTotalBitRateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemTotalBitRateKey", .linkage = .weak }) orelse missing("NSMetadataItemTotalBitRateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemVideoBitRateKey`.
pub fn metadataItemVideoBitRateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemVideoBitRateKey", .linkage = .weak }) orelse missing("NSMetadataItemVideoBitRateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAudioBitRateKey`.
pub fn metadataItemAudioBitRateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAudioBitRateKey", .linkage = .weak }) orelse missing("NSMetadataItemAudioBitRateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemDeliveryTypeKey`.
pub fn metadataItemDeliveryTypeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemDeliveryTypeKey", .linkage = .weak }) orelse missing("NSMetadataItemDeliveryTypeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAlbumKey`.
pub fn metadataItemAlbumKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAlbumKey", .linkage = .weak }) orelse missing("NSMetadataItemAlbumKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemHasAlphaChannelKey`.
pub fn metadataItemHasAlphaChannelKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemHasAlphaChannelKey", .linkage = .weak }) orelse missing("NSMetadataItemHasAlphaChannelKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemRedEyeOnOffKey`.
pub fn metadataItemRedEyeOnOffKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemRedEyeOnOffKey", .linkage = .weak }) orelse missing("NSMetadataItemRedEyeOnOffKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemMeteringModeKey`.
pub fn metadataItemMeteringModeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemMeteringModeKey", .linkage = .weak }) orelse missing("NSMetadataItemMeteringModeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemMaxApertureKey`.
pub fn metadataItemMaxApertureKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemMaxApertureKey", .linkage = .weak }) orelse missing("NSMetadataItemMaxApertureKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFNumberKey`.
pub fn metadataItemFNumberKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFNumberKey", .linkage = .weak }) orelse missing("NSMetadataItemFNumberKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemExposureProgramKey`.
pub fn metadataItemExposureProgramKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemExposureProgramKey", .linkage = .weak }) orelse missing("NSMetadataItemExposureProgramKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemExposureTimeStringKey`.
pub fn metadataItemExposureTimeStringKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemExposureTimeStringKey", .linkage = .weak }) orelse missing("NSMetadataItemExposureTimeStringKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemHeadlineKey`.
pub fn metadataItemHeadlineKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemHeadlineKey", .linkage = .weak }) orelse missing("NSMetadataItemHeadlineKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemInstructionsKey`.
pub fn metadataItemInstructionsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemInstructionsKey", .linkage = .weak }) orelse missing("NSMetadataItemInstructionsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemCityKey`.
pub fn metadataItemCityKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemCityKey", .linkage = .weak }) orelse missing("NSMetadataItemCityKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemStateOrProvinceKey`.
pub fn metadataItemStateOrProvinceKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemStateOrProvinceKey", .linkage = .weak }) orelse missing("NSMetadataItemStateOrProvinceKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemCountryKey`.
pub fn metadataItemCountryKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemCountryKey", .linkage = .weak }) orelse missing("NSMetadataItemCountryKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemTextContentKey`.
pub fn metadataItemTextContentKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemTextContentKey", .linkage = .weak }) orelse missing("NSMetadataItemTextContentKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAudioSampleRateKey`.
pub fn metadataItemAudioSampleRateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAudioSampleRateKey", .linkage = .weak }) orelse missing("NSMetadataItemAudioSampleRateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAudioChannelCountKey`.
pub fn metadataItemAudioChannelCountKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAudioChannelCountKey", .linkage = .weak }) orelse missing("NSMetadataItemAudioChannelCountKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemTempoKey`.
pub fn metadataItemTempoKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemTempoKey", .linkage = .weak }) orelse missing("NSMetadataItemTempoKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemKeySignatureKey`.
pub fn metadataItemKeySignatureKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemKeySignatureKey", .linkage = .weak }) orelse missing("NSMetadataItemKeySignatureKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemTimeSignatureKey`.
pub fn metadataItemTimeSignatureKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemTimeSignatureKey", .linkage = .weak }) orelse missing("NSMetadataItemTimeSignatureKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAudioEncodingApplicationKey`.
pub fn metadataItemAudioEncodingApplicationKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAudioEncodingApplicationKey", .linkage = .weak }) orelse missing("NSMetadataItemAudioEncodingApplicationKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemComposerKey`.
pub fn metadataItemComposerKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemComposerKey", .linkage = .weak }) orelse missing("NSMetadataItemComposerKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemLyricistKey`.
pub fn metadataItemLyricistKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemLyricistKey", .linkage = .weak }) orelse missing("NSMetadataItemLyricistKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAudioTrackNumberKey`.
pub fn metadataItemAudioTrackNumberKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAudioTrackNumberKey", .linkage = .weak }) orelse missing("NSMetadataItemAudioTrackNumberKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemRecordingDateKey`.
pub fn metadataItemRecordingDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemRecordingDateKey", .linkage = .weak }) orelse missing("NSMetadataItemRecordingDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemMusicalGenreKey`.
pub fn metadataItemMusicalGenreKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemMusicalGenreKey", .linkage = .weak }) orelse missing("NSMetadataItemMusicalGenreKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemIsGeneralMIDISequenceKey`.
pub fn metadataItemIsGeneralMIDISequenceKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemIsGeneralMIDISequenceKey", .linkage = .weak }) orelse missing("NSMetadataItemIsGeneralMIDISequenceKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemRecordingYearKey`.
pub fn metadataItemRecordingYearKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemRecordingYearKey", .linkage = .weak }) orelse missing("NSMetadataItemRecordingYearKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemOrganizationsKey`.
pub fn metadataItemOrganizationsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemOrganizationsKey", .linkage = .weak }) orelse missing("NSMetadataItemOrganizationsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemLanguagesKey`.
pub fn metadataItemLanguagesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemLanguagesKey", .linkage = .weak }) orelse missing("NSMetadataItemLanguagesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemRightsKey`.
pub fn metadataItemRightsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemRightsKey", .linkage = .weak }) orelse missing("NSMetadataItemRightsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemPublishersKey`.
pub fn metadataItemPublishersKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemPublishersKey", .linkage = .weak }) orelse missing("NSMetadataItemPublishersKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemContributorsKey`.
pub fn metadataItemContributorsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemContributorsKey", .linkage = .weak }) orelse missing("NSMetadataItemContributorsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemCoverageKey`.
pub fn metadataItemCoverageKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemCoverageKey", .linkage = .weak }) orelse missing("NSMetadataItemCoverageKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemSubjectKey`.
pub fn metadataItemSubjectKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemSubjectKey", .linkage = .weak }) orelse missing("NSMetadataItemSubjectKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemThemeKey`.
pub fn metadataItemThemeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemThemeKey", .linkage = .weak }) orelse missing("NSMetadataItemThemeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemDescriptionKey`.
pub fn metadataItemDescriptionKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemDescriptionKey", .linkage = .weak }) orelse missing("NSMetadataItemDescriptionKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemIdentifierKey`.
pub fn metadataItemIdentifierKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemIdentifierKey", .linkage = .weak }) orelse missing("NSMetadataItemIdentifierKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAudiencesKey`.
pub fn metadataItemAudiencesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAudiencesKey", .linkage = .weak }) orelse missing("NSMetadataItemAudiencesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemNumberOfPagesKey`.
pub fn metadataItemNumberOfPagesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemNumberOfPagesKey", .linkage = .weak }) orelse missing("NSMetadataItemNumberOfPagesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemPageWidthKey`.
pub fn metadataItemPageWidthKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemPageWidthKey", .linkage = .weak }) orelse missing("NSMetadataItemPageWidthKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemPageHeightKey`.
pub fn metadataItemPageHeightKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemPageHeightKey", .linkage = .weak }) orelse missing("NSMetadataItemPageHeightKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemSecurityMethodKey`.
pub fn metadataItemSecurityMethodKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemSecurityMethodKey", .linkage = .weak }) orelse missing("NSMetadataItemSecurityMethodKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemCreatorKey`.
pub fn metadataItemCreatorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemCreatorKey", .linkage = .weak }) orelse missing("NSMetadataItemCreatorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemEncodingApplicationsKey`.
pub fn metadataItemEncodingApplicationsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemEncodingApplicationsKey", .linkage = .weak }) orelse missing("NSMetadataItemEncodingApplicationsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemDueDateKey`.
pub fn metadataItemDueDateKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemDueDateKey", .linkage = .weak }) orelse missing("NSMetadataItemDueDateKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemStarRatingKey`.
pub fn metadataItemStarRatingKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemStarRatingKey", .linkage = .weak }) orelse missing("NSMetadataItemStarRatingKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemPhoneNumbersKey`.
pub fn metadataItemPhoneNumbersKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemPhoneNumbersKey", .linkage = .weak }) orelse missing("NSMetadataItemPhoneNumbersKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemEmailAddressesKey`.
pub fn metadataItemEmailAddressesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemEmailAddressesKey", .linkage = .weak }) orelse missing("NSMetadataItemEmailAddressesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemInstantMessageAddressesKey`.
pub fn metadataItemInstantMessageAddressesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemInstantMessageAddressesKey", .linkage = .weak }) orelse missing("NSMetadataItemInstantMessageAddressesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemKindKey`.
pub fn metadataItemKindKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemKindKey", .linkage = .weak }) orelse missing("NSMetadataItemKindKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemRecipientsKey`.
pub fn metadataItemRecipientsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemRecipientsKey", .linkage = .weak }) orelse missing("NSMetadataItemRecipientsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFinderCommentKey`.
pub fn metadataItemFinderCommentKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFinderCommentKey", .linkage = .weak }) orelse missing("NSMetadataItemFinderCommentKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemFontsKey`.
pub fn metadataItemFontsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemFontsKey", .linkage = .weak }) orelse missing("NSMetadataItemFontsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAppleLoopsRootKeyKey`.
pub fn metadataItemAppleLoopsRootKeyKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAppleLoopsRootKeyKey", .linkage = .weak }) orelse missing("NSMetadataItemAppleLoopsRootKeyKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAppleLoopsKeyFilterTypeKey`.
pub fn metadataItemAppleLoopsKeyFilterTypeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAppleLoopsKeyFilterTypeKey", .linkage = .weak }) orelse missing("NSMetadataItemAppleLoopsKeyFilterTypeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAppleLoopsLoopModeKey`.
pub fn metadataItemAppleLoopsLoopModeKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAppleLoopsLoopModeKey", .linkage = .weak }) orelse missing("NSMetadataItemAppleLoopsLoopModeKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAppleLoopDescriptorsKey`.
pub fn metadataItemAppleLoopDescriptorsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAppleLoopDescriptorsKey", .linkage = .weak }) orelse missing("NSMetadataItemAppleLoopDescriptorsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemMusicalInstrumentCategoryKey`.
pub fn metadataItemMusicalInstrumentCategoryKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemMusicalInstrumentCategoryKey", .linkage = .weak }) orelse missing("NSMetadataItemMusicalInstrumentCategoryKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemMusicalInstrumentNameKey`.
pub fn metadataItemMusicalInstrumentNameKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemMusicalInstrumentNameKey", .linkage = .weak }) orelse missing("NSMetadataItemMusicalInstrumentNameKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemCFBundleIdentifierKey`.
pub fn metadataItemCFBundleIdentifierKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemCFBundleIdentifierKey", .linkage = .weak }) orelse missing("NSMetadataItemCFBundleIdentifierKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemInformationKey`.
pub fn metadataItemInformationKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemInformationKey", .linkage = .weak }) orelse missing("NSMetadataItemInformationKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemDirectorKey`.
pub fn metadataItemDirectorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemDirectorKey", .linkage = .weak }) orelse missing("NSMetadataItemDirectorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemProducerKey`.
pub fn metadataItemProducerKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemProducerKey", .linkage = .weak }) orelse missing("NSMetadataItemProducerKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemGenreKey`.
pub fn metadataItemGenreKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemGenreKey", .linkage = .weak }) orelse missing("NSMetadataItemGenreKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemPerformersKey`.
pub fn metadataItemPerformersKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemPerformersKey", .linkage = .weak }) orelse missing("NSMetadataItemPerformersKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemOriginalFormatKey`.
pub fn metadataItemOriginalFormatKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemOriginalFormatKey", .linkage = .weak }) orelse missing("NSMetadataItemOriginalFormatKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemOriginalSourceKey`.
pub fn metadataItemOriginalSourceKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemOriginalSourceKey", .linkage = .weak }) orelse missing("NSMetadataItemOriginalSourceKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAuthorEmailAddressesKey`.
pub fn metadataItemAuthorEmailAddressesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAuthorEmailAddressesKey", .linkage = .weak }) orelse missing("NSMetadataItemAuthorEmailAddressesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemRecipientEmailAddressesKey`.
pub fn metadataItemRecipientEmailAddressesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemRecipientEmailAddressesKey", .linkage = .weak }) orelse missing("NSMetadataItemRecipientEmailAddressesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemAuthorAddressesKey`.
pub fn metadataItemAuthorAddressesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemAuthorAddressesKey", .linkage = .weak }) orelse missing("NSMetadataItemAuthorAddressesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemRecipientAddressesKey`.
pub fn metadataItemRecipientAddressesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemRecipientAddressesKey", .linkage = .weak }) orelse missing("NSMetadataItemRecipientAddressesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemIsLikelyJunkKey`.
pub fn metadataItemIsLikelyJunkKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemIsLikelyJunkKey", .linkage = .weak }) orelse missing("NSMetadataItemIsLikelyJunkKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemExecutableArchitecturesKey`.
pub fn metadataItemExecutableArchitecturesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemExecutableArchitecturesKey", .linkage = .weak }) orelse missing("NSMetadataItemExecutableArchitecturesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemExecutablePlatformKey`.
pub fn metadataItemExecutablePlatformKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemExecutablePlatformKey", .linkage = .weak }) orelse missing("NSMetadataItemExecutablePlatformKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemApplicationCategoriesKey`.
pub fn metadataItemApplicationCategoriesKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemApplicationCategoriesKey", .linkage = .weak }) orelse missing("NSMetadataItemApplicationCategoriesKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataItemIsApplicationManagedKey`.
pub fn metadataItemIsApplicationManagedKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataItemIsApplicationManagedKey", .linkage = .weak }) orelse missing("NSMetadataItemIsApplicationManagedKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryDidStartGatheringNotification`.
pub fn metadataQueryDidStartGatheringNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryDidStartGatheringNotification", .linkage = .weak }) orelse missing("NSMetadataQueryDidStartGatheringNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryGatheringProgressNotification`.
pub fn metadataQueryGatheringProgressNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryGatheringProgressNotification", .linkage = .weak }) orelse missing("NSMetadataQueryGatheringProgressNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryDidFinishGatheringNotification`.
pub fn metadataQueryDidFinishGatheringNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryDidFinishGatheringNotification", .linkage = .weak }) orelse missing("NSMetadataQueryDidFinishGatheringNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryDidUpdateNotification`.
pub fn metadataQueryDidUpdateNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryDidUpdateNotification", .linkage = .weak }) orelse missing("NSMetadataQueryDidUpdateNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryUpdateAddedItemsKey`.
pub fn metadataQueryUpdateAddedItemsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryUpdateAddedItemsKey", .linkage = .weak }) orelse missing("NSMetadataQueryUpdateAddedItemsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryUpdateChangedItemsKey`.
pub fn metadataQueryUpdateChangedItemsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryUpdateChangedItemsKey", .linkage = .weak }) orelse missing("NSMetadataQueryUpdateChangedItemsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryUpdateRemovedItemsKey`.
pub fn metadataQueryUpdateRemovedItemsKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryUpdateRemovedItemsKey", .linkage = .weak }) orelse missing("NSMetadataQueryUpdateRemovedItemsKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryResultContentRelevanceAttribute`.
pub fn metadataQueryResultContentRelevanceAttribute() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryResultContentRelevanceAttribute", .linkage = .weak }) orelse missing("NSMetadataQueryResultContentRelevanceAttribute");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryUserHomeScope`.
pub fn metadataQueryUserHomeScope() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryUserHomeScope", .linkage = .weak }) orelse missing("NSMetadataQueryUserHomeScope");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryLocalComputerScope`.
pub fn metadataQueryLocalComputerScope() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryLocalComputerScope", .linkage = .weak }) orelse missing("NSMetadataQueryLocalComputerScope");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryNetworkScope`.
pub fn metadataQueryNetworkScope() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryNetworkScope", .linkage = .weak }) orelse missing("NSMetadataQueryNetworkScope");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryIndexedLocalComputerScope`.
pub fn metadataQueryIndexedLocalComputerScope() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryIndexedLocalComputerScope", .linkage = .weak }) orelse missing("NSMetadataQueryIndexedLocalComputerScope");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryIndexedNetworkScope`.
pub fn metadataQueryIndexedNetworkScope() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryIndexedNetworkScope", .linkage = .weak }) orelse missing("NSMetadataQueryIndexedNetworkScope");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryUbiquitousDocumentsScope`.
pub fn metadataQueryUbiquitousDocumentsScope() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryUbiquitousDocumentsScope", .linkage = .weak }) orelse missing("NSMetadataQueryUbiquitousDocumentsScope");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryUbiquitousDataScope`.
pub fn metadataQueryUbiquitousDataScope() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryUbiquitousDataScope", .linkage = .weak }) orelse missing("NSMetadataQueryUbiquitousDataScope");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope`.
pub fn metadataQueryAccessibleUbiquitousExternalDocumentsScope() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope", .linkage = .weak }) orelse missing("NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSNetServicesErrorCode`.
pub fn netServicesErrorCode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSNetServicesErrorCode", .linkage = .weak }) orelse missing("NSNetServicesErrorCode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSNetServicesErrorDomain`.
pub fn netServicesErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSNetServicesErrorDomain", .linkage = .weak }) orelse missing("NSNetServicesErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUbiquitousKeyValueStoreDidChangeExternallyNotification`.
pub fn ubiquitousKeyValueStoreDidChangeExternallyNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUbiquitousKeyValueStoreDidChangeExternallyNotification", .linkage = .weak }) orelse missing("NSUbiquitousKeyValueStoreDidChangeExternallyNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUbiquitousKeyValueStoreChangeReasonKey`.
pub fn ubiquitousKeyValueStoreChangeReasonKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUbiquitousKeyValueStoreChangeReasonKey", .linkage = .weak }) orelse missing("NSUbiquitousKeyValueStoreChangeReasonKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUbiquitousKeyValueStoreChangedKeysKey`.
pub fn ubiquitousKeyValueStoreChangedKeysKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUbiquitousKeyValueStoreChangedKeysKey", .linkage = .weak }) orelse missing("NSUbiquitousKeyValueStoreChangedKeysKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndoManagerGroupIsDiscardableKey`.
pub fn undoManagerGroupIsDiscardableKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndoManagerGroupIsDiscardableKey", .linkage = .weak }) orelse missing("NSUndoManagerGroupIsDiscardableKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndoManagerCheckpointNotification`.
pub fn undoManagerCheckpointNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndoManagerCheckpointNotification", .linkage = .weak }) orelse missing("NSUndoManagerCheckpointNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndoManagerWillUndoChangeNotification`.
pub fn undoManagerWillUndoChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndoManagerWillUndoChangeNotification", .linkage = .weak }) orelse missing("NSUndoManagerWillUndoChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndoManagerWillRedoChangeNotification`.
pub fn undoManagerWillRedoChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndoManagerWillRedoChangeNotification", .linkage = .weak }) orelse missing("NSUndoManagerWillRedoChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndoManagerDidUndoChangeNotification`.
pub fn undoManagerDidUndoChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndoManagerDidUndoChangeNotification", .linkage = .weak }) orelse missing("NSUndoManagerDidUndoChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndoManagerDidRedoChangeNotification`.
pub fn undoManagerDidRedoChangeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndoManagerDidRedoChangeNotification", .linkage = .weak }) orelse missing("NSUndoManagerDidRedoChangeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndoManagerDidOpenUndoGroupNotification`.
pub fn undoManagerDidOpenUndoGroupNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndoManagerDidOpenUndoGroupNotification", .linkage = .weak }) orelse missing("NSUndoManagerDidOpenUndoGroupNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndoManagerWillCloseUndoGroupNotification`.
pub fn undoManagerWillCloseUndoGroupNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndoManagerWillCloseUndoGroupNotification", .linkage = .weak }) orelse missing("NSUndoManagerWillCloseUndoGroupNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUndoManagerDidCloseUndoGroupNotification`.
pub fn undoManagerDidCloseUndoGroupNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUndoManagerDidCloseUndoGroupNotification", .linkage = .weak }) orelse missing("NSUndoManagerDidCloseUndoGroupNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLSessionTransferSizeUnknown`.
pub fn urlSessionTransferSizeUnknown() i64 {
    const symbol = @extern(?*const objc.abi.Abi(i64), .{ .name = "NSURLSessionTransferSizeUnknown", .linkage = .weak }) orelse missing("NSURLSessionTransferSizeUnknown");
    return objc.abi.fromAbi(i64, symbol.*);
}

/// `NSURLSessionTaskPriorityDefault`.
pub fn urlSessionTaskPriorityDefault() f32 {
    const symbol = @extern(?*const objc.abi.Abi(f32), .{ .name = "NSURLSessionTaskPriorityDefault", .linkage = .weak }) orelse missing("NSURLSessionTaskPriorityDefault");
    return objc.abi.fromAbi(f32, symbol.*);
}

/// `NSURLSessionTaskPriorityLow`.
pub fn urlSessionTaskPriorityLow() f32 {
    const symbol = @extern(?*const objc.abi.Abi(f32), .{ .name = "NSURLSessionTaskPriorityLow", .linkage = .weak }) orelse missing("NSURLSessionTaskPriorityLow");
    return objc.abi.fromAbi(f32, symbol.*);
}

/// `NSURLSessionTaskPriorityHigh`.
pub fn urlSessionTaskPriorityHigh() f32 {
    const symbol = @extern(?*const objc.abi.Abi(f32), .{ .name = "NSURLSessionTaskPriorityHigh", .linkage = .weak }) orelse missing("NSURLSessionTaskPriorityHigh");
    return objc.abi.fromAbi(f32, symbol.*);
}

/// `NSURLSessionDownloadTaskResumeData`.
pub fn urlSessionDownloadTaskResumeData() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLSessionDownloadTaskResumeData", .linkage = .weak }) orelse missing("NSURLSessionDownloadTaskResumeData");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSURLSessionUploadTaskResumeData`.
pub fn urlSessionUploadTaskResumeData() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSURLSessionUploadTaskResumeData", .linkage = .weak }) orelse missing("NSURLSessionUploadTaskResumeData");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUserActivityTypeBrowsingWeb`.
pub fn userActivityTypeBrowsingWeb() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUserActivityTypeBrowsingWeb", .linkage = .weak }) orelse missing("NSUserActivityTypeBrowsingWeb");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSAppleScriptErrorMessage`.
pub fn appleScriptErrorMessage() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAppleScriptErrorMessage", .linkage = .weak }) orelse missing("NSAppleScriptErrorMessage");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSAppleScriptErrorNumber`.
pub fn appleScriptErrorNumber() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAppleScriptErrorNumber", .linkage = .weak }) orelse missing("NSAppleScriptErrorNumber");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSAppleScriptErrorAppName`.
pub fn appleScriptErrorAppName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAppleScriptErrorAppName", .linkage = .weak }) orelse missing("NSAppleScriptErrorAppName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSAppleScriptErrorBriefMessage`.
pub fn appleScriptErrorBriefMessage() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAppleScriptErrorBriefMessage", .linkage = .weak }) orelse missing("NSAppleScriptErrorBriefMessage");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSAppleScriptErrorRange`.
pub fn appleScriptErrorRange() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAppleScriptErrorRange", .linkage = .weak }) orelse missing("NSAppleScriptErrorRange");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSConnectionReplyMode`.
pub fn connectionReplyMode() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSConnectionReplyMode", .linkage = .weak }) orelse missing("NSConnectionReplyMode");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSConnectionDidDieNotification`.
pub fn connectionDidDieNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSConnectionDidDieNotification", .linkage = .weak }) orelse missing("NSConnectionDidDieNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFailedAuthenticationException`.
pub fn failedAuthenticationException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSFailedAuthenticationException", .linkage = .weak }) orelse missing("NSFailedAuthenticationException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSConnectionDidInitializeNotification`.
pub fn connectionDidInitializeNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSConnectionDidInitializeNotification", .linkage = .weak }) orelse missing("NSConnectionDidInitializeNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSLocalNotificationCenterType`.
pub fn localNotificationCenterType() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSLocalNotificationCenterType", .linkage = .weak }) orelse missing("NSLocalNotificationCenterType");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSTaskDidTerminateNotification`.
pub fn taskDidTerminateNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSTaskDidTerminateNotification", .linkage = .weak }) orelse missing("NSTaskDidTerminateNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSAppleEventTimeOutDefault`.
pub fn appleEventTimeOutDefault() f64 {
    const symbol = @extern(?*const objc.abi.Abi(f64), .{ .name = "NSAppleEventTimeOutDefault", .linkage = .weak }) orelse missing("NSAppleEventTimeOutDefault");
    return objc.abi.fromAbi(f64, symbol.*);
}

/// `NSAppleEventTimeOutNone`.
pub fn appleEventTimeOutNone() f64 {
    const symbol = @extern(?*const objc.abi.Abi(f64), .{ .name = "NSAppleEventTimeOutNone", .linkage = .weak }) orelse missing("NSAppleEventTimeOutNone");
    return objc.abi.fromAbi(f64, symbol.*);
}

/// `NSAppleEventManagerWillProcessFirstEventNotification`.
pub fn appleEventManagerWillProcessFirstEventNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSAppleEventManagerWillProcessFirstEventNotification", .linkage = .weak }) orelse missing("NSAppleEventManagerWillProcessFirstEventNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSClassDescriptionNeededForClassNotification`.
pub fn classDescriptionNeededForClassNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSClassDescriptionNeededForClassNotification", .linkage = .weak }) orelse missing("NSClassDescriptionNeededForClassNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSFileTypeForHFSTypeCode`.
pub fn fileTypeForHFSTypeCode(hfs_file_type_code: c_uint) ?foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(c_uint)) callconv(.c) objc.abi.Abi(?foundation.String), .{ .name = "NSFileTypeForHFSTypeCode", .linkage = .weak }) orelse missing("NSFileTypeForHFSTypeCode");
    return objc.abi.fromAbi(?foundation.String, function(objc.abi.toAbi(c_uint, hfs_file_type_code)));
}

/// `NSHFSTypeOfFile`.
pub fn hfsTypeOfFile(full_file_path: ?foundation.String) ?foundation.String {
    const function = @extern(?*const fn (objc.abi.Abi(?foundation.String)) callconv(.c) objc.abi.Abi(?foundation.String), .{ .name = "NSHFSTypeOfFile", .linkage = .weak }) orelse missing("NSHFSTypeOfFile");
    return objc.abi.fromAbi(?foundation.String, function(objc.abi.toAbi(?foundation.String, full_file_path)));
}

/// `NSOperationNotSupportedForKeyException`.
pub fn operationNotSupportedForKeyException() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSOperationNotSupportedForKeyException", .linkage = .weak }) orelse missing("NSOperationNotSupportedForKeyException");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSGrammarRange`.
pub fn grammarRange() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSGrammarRange", .linkage = .weak }) orelse missing("NSGrammarRange");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSGrammarUserDescription`.
pub fn grammarUserDescription() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSGrammarUserDescription", .linkage = .weak }) orelse missing("NSGrammarUserDescription");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSGrammarCorrections`.
pub fn grammarCorrections() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSGrammarCorrections", .linkage = .weak }) orelse missing("NSGrammarCorrections");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `NSUserNotificationDefaultSoundName`.
pub fn userNotificationDefaultSoundName() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "NSUserNotificationDefaultSoundName", .linkage = .weak }) orelse missing("NSUserNotificationDefaultSoundName");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

// Not generated:
//   NSDecimalRound()
//   NSDecimalNormalize: NSCalculationError
//   NSDecimalAdd: NSCalculationError
//   NSDecimalSubtract: NSCalculationError
//   NSDecimalMultiply: NSCalculationError
//   NSDecimalDivide: NSCalculationError
//   NSDecimalPower: NSCalculationError
//   NSDecimalMultiplyByPowerOf10: NSCalculationError
//   NSEnumerateHashTable: NSHashEnumerator
//   NSCreateHashTableWithZone()
//   NSCreateHashTable()
//   NSIntegerHashCallBacks: const NSHashTableCallBacks
//   NSNonOwnedPointerHashCallBacks: const NSHashTableCallBacks
//   NSNonRetainedObjectHashCallBacks: const NSHashTableCallBacks
//   NSObjectHashCallBacks: const NSHashTableCallBacks
//   NSOwnedObjectIdentityHashCallBacks: const NSHashTableCallBacks
//   NSOwnedPointerHashCallBacks: const NSHashTableCallBacks
//   NSPointerToStructHashCallBacks: const NSHashTableCallBacks
//   NSIntHashCallBacks: const NSHashTableCallBacks
//   NSEdgeInsetsZero: const NSEdgeInsets
//   NSEdgeInsetsEqual()
//   NSIntegralRectWithOptions()
//   NSDivideRect()
//   NSMapMember()
//   NSEnumerateMapTable: NSMapEnumerator
//   NSNextMapEnumeratorPair()
//   NSCreateMapTableWithZone()
//   NSCreateMapTable()
//   NSIntegerMapKeyCallBacks: const NSMapTableKeyCallBacks
//   NSNonOwnedPointerMapKeyCallBacks: const NSMapTableKeyCallBacks
//   NSNonOwnedPointerOrNullMapKeyCallBacks: const NSMapTableKeyCallBacks
//   NSNonRetainedObjectMapKeyCallBacks: const NSMapTableKeyCallBacks
//   NSObjectMapKeyCallBacks: const NSMapTableKeyCallBacks
//   NSOwnedPointerMapKeyCallBacks: const NSMapTableKeyCallBacks
//   NSIntMapKeyCallBacks: const NSMapTableKeyCallBacks
//   NSIntegerMapValueCallBacks: const NSMapTableValueCallBacks
//   NSNonOwnedPointerMapValueCallBacks: const NSMapTableValueCallBacks
//   NSObjectMapValueCallBacks: const NSMapTableValueCallBacks
//   NSNonRetainedObjectMapValueCallBacks: const NSMapTableValueCallBacks
//   NSOwnedPointerMapValueCallBacks: const NSMapTableValueCallBacks
//   NSIntMapValueCallBacks: const NSMapTableValueCallBacks
//   NSHFSTypeCodeFromFileType: OSType
