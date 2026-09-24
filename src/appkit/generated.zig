//! AppKit wrappers generated from the macOS SDK by `zig build generate`,
//! from the manifest in `tools/objc_gen/appkit.zig`. Do not edit: add to the
//! manifest and regenerate, or write a hand-made wrapper beside this file.

const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const cg = @import("../cg/cg.zig");

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

const framework = "AppKit";

/// `NSWindowStyleMask`.
pub const WindowStyleMask = packed struct(u64) {
    titled: bool = false,
    closable: bool = false,
    miniaturizable: bool = false,
    resizable: bool = false,
    utility_window: bool = false,
    _5: u1 = 0,
    doc_modal_window: bool = false,
    nonactivating_panel: bool = false,
    textured_background: bool = false,
    _9: u3 = 0,
    unified_title_and_toolbar: bool = false,
    hud_window: bool = false,
    full_screen: bool = false,
    full_size_content_view: bool = false,
    _16: u48 = 0,
    pub const borderless: WindowStyleMask = @fromBackingInt(0x0);
};

/// `NSBackingStoreType`.
pub const BackingStoreType = enum(objc.UInteger) {
    retained = 0,
    nonretained = 1,
    buffered = 2,
    _,
};

/// `NSWindowOrderingMode`.
pub const WindowOrderingMode = enum(objc.Integer) {
    above = 1,
    below = -1,
    out = 0,
    _,
};

/// `NSWindowCollectionBehavior`.
pub const WindowCollectionBehavior = packed struct(u64) {
    can_join_all_spaces: bool = false,
    move_to_active_space: bool = false,
    managed: bool = false,
    transient: bool = false,
    stationary: bool = false,
    participates_in_cycle: bool = false,
    ignores_cycle: bool = false,
    full_screen_primary: bool = false,
    full_screen_auxiliary: bool = false,
    full_screen_none: bool = false,
    _10: u1 = 0,
    full_screen_allows_tiling: bool = false,
    full_screen_disallows_tiling: bool = false,
    _13: u3 = 0,
    primary: bool = false,
    auxiliary: bool = false,
    can_join_all_applications: bool = false,
    _19: u45 = 0,
    pub const default: WindowCollectionBehavior = @fromBackingInt(0x0);
};

/// `NSWindowTitleVisibility`.
pub const WindowTitleVisibility = enum(objc.Integer) {
    visible = 0,
    hidden = 1,
    _,
};

/// `NSWindowButton`.
pub const WindowButton = enum(objc.UInteger) {
    close_button = 0,
    miniaturize_button = 1,
    zoom_button = 2,
    toolbar_button = 3,
    document_icon_button = 4,
    document_versions_button = 6,
    _,
};

/// `NSWindowTabbingMode`.
pub const WindowTabbingMode = enum(objc.Integer) {
    automatic = 0,
    preferred = 1,
    disallowed = 2,
    _,
};

/// `NSWindowToolbarStyle`.
pub const WindowToolbarStyle = enum(objc.Integer) {
    automatic = 0,
    expanded = 1,
    preference = 2,
    unified = 3,
    unified_compact = 4,
    _,
};

/// `NSWindowAnimationBehavior`.
pub const WindowAnimationBehavior = enum(objc.Integer) {
    default = 0,
    none = 2,
    document_window = 3,
    utility_window = 4,
    alert_panel = 5,
    _,
};

/// `NSWindowOcclusionState`.
pub const WindowOcclusionState = packed struct(u64) {
    _0: u1 = 0,
    visible: bool = false,
    _2: u62 = 0,
};

/// `NSWindowSharingType`.
pub const WindowSharingType = enum(objc.UInteger) {
    none = 0,
    read_only = 1,
    _,
};

/// `NSTitlebarSeparatorStyle`.
pub const TitlebarSeparatorStyle = enum(objc.Integer) {
    automatic = 0,
    none = 1,
    line = 2,
    shadow = 3,
    _,
};

/// `NSApplicationActivationPolicy`.
pub const ApplicationActivationPolicy = enum(objc.Integer) {
    regular = 0,
    accessory = 1,
    prohibited = 2,
    _,
};

/// `NSApplicationActivationOptions`.
pub const ApplicationActivationOptions = packed struct(u64) {
    all_windows: bool = false,
    ignoring_other_apps: bool = false,
    _2: u62 = 0,
};

/// `NSApplicationPresentationOptions`.
pub const ApplicationPresentationOptions = packed struct(u64) {
    auto_hide_dock: bool = false,
    hide_dock: bool = false,
    auto_hide_menu_bar: bool = false,
    hide_menu_bar: bool = false,
    disable_apple_menu: bool = false,
    disable_process_switching: bool = false,
    disable_force_quit: bool = false,
    disable_session_termination: bool = false,
    disable_hide_application: bool = false,
    disable_menu_bar_transparency: bool = false,
    full_screen: bool = false,
    auto_hide_toolbar: bool = false,
    disable_cursor_location_assistance: bool = false,
    _13: u2 = 0,
    disable_screen_corner_interactions: bool = false,
    _16: u48 = 0,
    pub const default: ApplicationPresentationOptions = @fromBackingInt(0x0);
};

/// `NSApplicationTerminateReply`.
pub const ApplicationTerminateReply = enum(objc.UInteger) {
    cancel = 0,
    now = 1,
    later = 2,
    _,
};

/// `NSApplicationOcclusionState`.
pub const ApplicationOcclusionState = packed struct(u64) {
    _0: u1 = 0,
    visible: bool = false,
    _2: u62 = 0,
};

/// `NSRequestUserAttentionType`.
pub const RequestUserAttentionType = enum(objc.UInteger) {
    critical_request = 0,
    informational_request = 10,
    _,
};

/// `NSEventType`.
pub const EventType = enum(objc.UInteger) {
    left_mouse_down = 1,
    left_mouse_up = 2,
    right_mouse_down = 3,
    right_mouse_up = 4,
    mouse_moved = 5,
    left_mouse_dragged = 6,
    right_mouse_dragged = 7,
    mouse_entered = 8,
    mouse_exited = 9,
    key_down = 10,
    key_up = 11,
    flags_changed = 12,
    app_kit_defined = 13,
    system_defined = 14,
    application_defined = 15,
    periodic = 16,
    cursor_update = 17,
    scroll_wheel = 22,
    tablet_point = 23,
    tablet_proximity = 24,
    other_mouse_down = 25,
    other_mouse_up = 26,
    other_mouse_dragged = 27,
    gesture = 29,
    magnify = 30,
    swipe = 31,
    rotate = 18,
    begin_gesture = 19,
    end_gesture = 20,
    smart_magnify = 32,
    quick_look = 33,
    pressure = 34,
    direct_touch = 37,
    change_mode = 38,
    mouse_cancelled = 40,
    _,
};

/// `NSEventMask`.
pub const EventMask = packed struct(u64) {
    _0: u1 = 0,
    left_mouse_down: bool = false,
    left_mouse_up: bool = false,
    right_mouse_down: bool = false,
    right_mouse_up: bool = false,
    mouse_moved: bool = false,
    left_mouse_dragged: bool = false,
    right_mouse_dragged: bool = false,
    mouse_entered: bool = false,
    mouse_exited: bool = false,
    key_down: bool = false,
    key_up: bool = false,
    flags_changed: bool = false,
    app_kit_defined: bool = false,
    system_defined: bool = false,
    application_defined: bool = false,
    periodic: bool = false,
    cursor_update: bool = false,
    rotate: bool = false,
    begin_gesture: bool = false,
    end_gesture: bool = false,
    _21: u1 = 0,
    scroll_wheel: bool = false,
    tablet_point: bool = false,
    tablet_proximity: bool = false,
    other_mouse_down: bool = false,
    other_mouse_up: bool = false,
    other_mouse_dragged: bool = false,
    _28: u1 = 0,
    gesture: bool = false,
    magnify: bool = false,
    swipe: bool = false,
    smart_magnify: bool = false,
    _33: u1 = 0,
    pressure: bool = false,
    _35: u2 = 0,
    direct_touch: bool = false,
    change_mode: bool = false,
    _39: u1 = 0,
    mouse_cancelled: bool = false,
    _41: u23 = 0,
    pub const any: EventMask = @fromBackingInt(0xffffffffffffffff);
};

/// `NSEventModifierFlags`.
pub const EventModifierFlags = packed struct(u64) {
    _0: u16 = 0,
    caps_lock: bool = false,
    shift: bool = false,
    control: bool = false,
    option: bool = false,
    command: bool = false,
    numeric_pad: bool = false,
    help: bool = false,
    function: bool = false,
    _24: u40 = 0,
    pub const device_independent_flags_mask: EventModifierFlags = @fromBackingInt(0xffff0000);
};

/// `NSEventPhase`.
pub const EventPhase = packed struct(u64) {
    began: bool = false,
    stationary: bool = false,
    changed: bool = false,
    ended: bool = false,
    cancelled: bool = false,
    may_begin: bool = false,
    _6: u58 = 0,
    pub const none: EventPhase = @fromBackingInt(0x0);
};

/// `NSEventSubtype`.
pub const EventSubtype = enum(c_short) {
    window_exposed = 0,
    application_activated = 1,
    application_deactivated = 2,
    window_moved = 4,
    screen_changed = 8,
    touch = 3,
    _,
    pub const power_off: EventSubtype = .application_activated;
    pub const mouse_event: EventSubtype = .window_exposed;
    pub const tablet_point: EventSubtype = .application_activated;
    pub const tablet_proximity: EventSubtype = .application_deactivated;
};

/// `NSEventButtonMask`.
pub const EventButtonMask = packed struct(u64) {
    tip: bool = false,
    lower_side: bool = false,
    upper_side: bool = false,
    _3: u61 = 0,
};

/// `NSPointingDeviceType`.
pub const PointingDeviceType = enum(objc.UInteger) {
    unknown = 0,
    pen = 1,
    cursor = 2,
    eraser = 3,
    _,
};

/// `NSPressureBehavior`.
pub const PressureBehavior = enum(objc.Integer) {
    unknown = -1,
    primary_default = 0,
    primary_click = 1,
    primary_generic = 2,
    primary_accelerator = 3,
    primary_deep_click = 5,
    primary_deep_drag = 6,
    _,
};

/// `NSAutoresizingMaskOptions`.
pub const AutoresizingMaskOptions = packed struct(u64) {
    min_x_margin: bool = false,
    width_sizable: bool = false,
    max_x_margin: bool = false,
    min_y_margin: bool = false,
    height_sizable: bool = false,
    max_y_margin: bool = false,
    _6: u58 = 0,
    pub const not_sizable: AutoresizingMaskOptions = @fromBackingInt(0x0);
};

/// `NSFocusRingType`.
pub const FocusRingType = enum(objc.UInteger) {
    default = 0,
    none = 1,
    exterior = 2,
    _,
};

/// `NSUserInterfaceLayoutDirection`.
pub const UserInterfaceLayoutDirection = enum(objc.Integer) {
    left_to_right = 0,
    right_to_left = 1,
    _,
};

/// `NSViewLayerContentsRedrawPolicy`.
pub const ViewLayerContentsRedrawPolicy = enum(objc.Integer) {
    never = 0,
    on_set_needs_display = 1,
    during_view_resize = 2,
    before_view_resize = 3,
    crossfade = 4,
    _,
};

/// `NSViewLayerContentsPlacement`.
pub const ViewLayerContentsPlacement = enum(objc.Integer) {
    scale_axes_independently = 0,
    scale_proportionally_to_fit = 1,
    scale_proportionally_to_fill = 2,
    center = 3,
    top = 4,
    top_right = 5,
    right = 6,
    bottom_right = 7,
    bottom = 8,
    bottom_left = 9,
    left = 10,
    top_left = 11,
    _,
};

/// `NSImageScaling`.
pub const ImageScaling = enum(objc.UInteger) {
    image_scale_proportionally_down = 0,
    image_scale_axes_independently = 1,
    image_scale_none = 2,
    image_scale_proportionally_up_or_down = 3,
    _,
    pub const scale_proportionally: ImageScaling = .image_scale_proportionally_down;
    pub const scale_to_fit: ImageScaling = .image_scale_axes_independently;
    pub const scale_none: ImageScaling = .image_scale_none;
};

/// `NSCompositingOperation`.
pub const CompositingOperation = enum(objc.UInteger) {
    clear = 0,
    copy = 1,
    source_over = 2,
    source_in = 3,
    source_out = 4,
    source_atop = 5,
    destination_over = 6,
    destination_in = 7,
    destination_out = 8,
    destination_atop = 9,
    xor = 10,
    plus_darker = 11,
    highlight = 12,
    plus_lighter = 13,
    multiply = 14,
    screen = 15,
    overlay = 16,
    darken = 17,
    lighten = 18,
    color_dodge = 19,
    color_burn = 20,
    soft_light = 21,
    hard_light = 22,
    difference = 23,
    exclusion = 24,
    hue = 25,
    saturation = 26,
    color = 27,
    luminosity = 28,
    _,
};

/// `NSMenuPresentationStyle`.
pub const MenuPresentationStyle = enum(objc.Integer) {
    regular = 0,
    palette = 1,
    _,
};

/// `NSMenuSelectionMode`.
pub const MenuSelectionMode = enum(objc.Integer) {
    automatic = 0,
    select_one = 1,
    select_any = 2,
    _,
};

/// `NSMenuProperties`.
pub const MenuProperties = packed struct(u64) {
    title: bool = false,
    attributed_title: bool = false,
    key_equivalent: bool = false,
    image: bool = false,
    enabled: bool = false,
    accessibility_description: bool = false,
    _6: u58 = 0,
};

/// `NSMenuItemImageVisibility`.
pub const MenuItemImageVisibility = enum(objc.Integer) {
    automatic = 0,
    visible = 1,
    hidden = 2,
    _,
};

/// `NSRectEdge`.
pub const RectEdge = enum(objc.UInteger) {
    rect_edge_min_x = 0,
    rect_edge_min_y = 1,
    rect_edge_max_x = 2,
    rect_edge_max_y = 3,
    _,
    pub const min_x_edge: RectEdge = .rect_edge_min_x;
    pub const min_y_edge: RectEdge = .rect_edge_min_y;
    pub const max_x_edge: RectEdge = .rect_edge_max_x;
    pub const max_y_edge: RectEdge = .rect_edge_max_y;
};

/// `NSWindowDepth`.
pub const WindowDepth = enum(i32) {
    twentyfour_bit_rgb = 520,
    sixtyfour_bit_rgb = 528,
    onehundredtwentyeight_bit_rgb = 544,
    _,
};

/// `NSAlignmentOptions`.
pub const AlignmentOptions = packed struct(u64) {
    min_x_inward: bool = false,
    min_y_inward: bool = false,
    max_x_inward: bool = false,
    max_y_inward: bool = false,
    width_inward: bool = false,
    height_inward: bool = false,
    _6: u2 = 0,
    min_x_outward: bool = false,
    min_y_outward: bool = false,
    max_x_outward: bool = false,
    max_y_outward: bool = false,
    width_outward: bool = false,
    height_outward: bool = false,
    _14: u2 = 0,
    min_x_nearest: bool = false,
    min_y_nearest: bool = false,
    max_x_nearest: bool = false,
    max_y_nearest: bool = false,
    width_nearest: bool = false,
    height_nearest: bool = false,
    _22: u41 = 0,
    rect_flipped: bool = false,
    pub const all_edges_inward: AlignmentOptions = @fromBackingInt(0xf);
    pub const all_edges_outward: AlignmentOptions = @fromBackingInt(0xf00);
    pub const all_edges_nearest: AlignmentOptions = @fromBackingInt(0xf0000);
};

/// `NSWindowUserTabbingPreference`.
pub const WindowUserTabbingPreference = enum(objc.Integer) {
    manual = 0,
    always = 1,
    in_full_screen = 2,
    _,
};

/// `NSWindowListOptions`.
pub const WindowListOptions = packed struct(u64) {
    ordered_front_to_back: bool = false,
    _1: u63 = 0,
};

/// `NSWindowNumberListOptions`.
pub const WindowNumberListOptions = packed struct(u64) {
    applications: bool = false,
    _1: u3 = 0,
    spaces: bool = false,
    _5: u59 = 0,
};

/// `NSSelectionDirection`.
pub const SelectionDirection = enum(objc.UInteger) {
    direct_selection = 0,
    selecting_next = 1,
    selecting_previous = 2,
    _,
};

/// `NSApplicationDelegateReply`.
pub const ApplicationDelegateReply = enum(objc.UInteger) {
    success = 0,
    cancel = 1,
    failure = 2,
    _,
};

/// `NSColorType`.
pub const ColorType = enum(objc.Integer) {
    component_based = 0,
    pattern = 1,
    catalog = 2,
    _,
};

/// `NSColorSystemEffect`.
pub const ColorSystemEffect = enum(objc.Integer) {
    none = 0,
    pressed = 1,
    deep_pressed = 2,
    disabled = 3,
    rollover = 4,
    _,
};

/// `NSControlTint`.
pub const ControlTint = enum(objc.UInteger) {
    default_control_tint = 0,
    blue_control_tint = 1,
    graphite_control_tint = 6,
    clear_control_tint = 7,
    _,
};

/// `NSImageResizingMode`.
pub const ImageResizingMode = enum(objc.Integer) {
    tile = 0,
    stretch = 1,
    _,
};

/// `NSImageCacheMode`.
pub const ImageCacheMode = enum(objc.UInteger) {
    default = 0,
    always = 1,
    by_size = 2,
    never = 3,
    _,
};

/// `NSTIFFCompression`.
pub const TIFFCompression = enum(objc.UInteger) {
    none = 1,
    ccittfax3 = 3,
    ccittfax4 = 4,
    lzw = 5,
    jpeg = 6,
    next = 32766,
    pack_bits = 32773,
    old_jpeg = 32865,
    _,
};

/// `NSDisplayGamut`.
pub const DisplayGamut = enum(objc.Integer) {
    srgb = 1,
    p3 = 2,
    _,
};

/// `NSEventGestureAxis`.
pub const EventGestureAxis = enum(objc.Integer) {
    none = 0,
    horizontal = 1,
    vertical = 2,
    _,
};

/// `NSEventSwipeTrackingOptions`.
pub const EventSwipeTrackingOptions = packed struct(u64) {
    lock_direction: bool = false,
    clamp_gesture_amount: bool = false,
    _2: u62 = 0,
};

/// `NSTouchPhase`.
pub const TouchPhase = packed struct(u64) {
    began: bool = false,
    moved: bool = false,
    stationary: bool = false,
    ended: bool = false,
    cancelled: bool = false,
    _5: u59 = 0,
    pub const touching: TouchPhase = @fromBackingInt(0x7);
    pub const any: TouchPhase = @fromBackingInt(0xffffffffffffffff);
};

/// `NSHorizontalDirections`.
pub const HorizontalDirections = packed struct(u64) {
    left: bool = false,
    right: bool = false,
    _2: u62 = 0,
    pub const all: HorizontalDirections = @fromBackingInt(0x3);
};

/// `NSVerticalDirections`.
pub const VerticalDirections = packed struct(u64) {
    up: bool = false,
    down: bool = false,
    _2: u62 = 0,
    pub const all: VerticalDirections = @fromBackingInt(0x3);
};

/// `NSCursorFrameResizePosition`.
pub const CursorFrameResizePosition = enum(objc.UInteger) {
    top = 1,
    left = 2,
    bottom = 4,
    right = 8,
    top_left = 3,
    top_right = 9,
    bottom_left = 6,
    bottom_right = 12,
    _,
};

/// `NSCursorFrameResizeDirections`.
pub const CursorFrameResizeDirections = packed struct(u64) {
    inward: bool = false,
    outward: bool = false,
    _2: u62 = 0,
    pub const all: CursorFrameResizeDirections = @fromBackingInt(0x3);
};

/// `NSScreenTouchCapabilities`.
pub const ScreenTouchCapabilities = packed struct(u64) {
    multi_touch: bool = false,
    _1: u63 = 0,
    pub const none: ScreenTouchCapabilities = @fromBackingInt(0x0);
};

/// `NSBitmapFormat`.
pub const BitmapFormat = packed struct(u64) {
    alpha_first: bool = false,
    alpha_nonpremultiplied: bool = false,
    floating_point_samples: bool = false,
    _3: u5 = 0,
    sixteen_bit_little_endian: bool = false,
    thirty_two_bit_little_endian: bool = false,
    sixteen_bit_big_endian: bool = false,
    thirty_two_bit_big_endian: bool = false,
    _12: u52 = 0,
};

/// `NSBitmapImageFileType`.
pub const BitmapImageFileType = enum(objc.UInteger) {
    tiff = 0,
    bmp = 1,
    gif = 2,
    jpeg = 3,
    png = 4,
    jpeg2000 = 5,
    _,
};

/// `NSImageRepLoadStatus`.
pub const ImageRepLoadStatus = enum(objc.Integer) {
    unknown_type = -1,
    reading_header = -2,
    will_need_all_data = -3,
    invalid_data = -4,
    unexpected_eof = -5,
    completed = -6,
    _,
};

/// `NSImageLayoutDirection`.
pub const ImageLayoutDirection = enum(objc.Integer) {
    unspecified = -1,
    left_to_right = 2,
    right_to_left = 3,
    _,
};

/// `NSColorRenderingIntent`.
pub const ColorRenderingIntent = enum(objc.Integer) {
    default = 0,
    absolute_colorimetric = 1,
    relative_colorimetric = 2,
    perceptual = 3,
    saturation = 4,
    _,
};

/// `NSResponder`, a subclass of `NSObject`.
pub const Responder = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSResponder";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSResponder`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSResponder init]`
    pub fn init(self: Self) Responder {
        return self.object.msgSend(Responder, "init", .{});
    }

    /// `-[NSResponder initWithCoder:]`
    pub fn initWithCoder(self: Self, coder: objc.Object) ?Responder {
        return self.object.msgSend(?Responder, "initWithCoder:", .{coder});
    }

    /// `-[NSResponder tryToPerform:with:]`
    pub fn tryToPerformWith(self: Self, action: objc.Sel, object_: ?objc.Object) bool {
        return self.object.msgSend(bool, "tryToPerform:with:", .{ action, object_ });
    }

    /// `-[NSResponder performKeyEquivalent:]`
    pub fn performKeyEquivalent(self: Self, event: Event) bool {
        return self.object.msgSend(bool, "performKeyEquivalent:", .{event});
    }

    /// `-[NSResponder validRequestorForSendType:returnType:]`
    pub fn validRequestorForSendTypeReturnType(self: Self, send_type: ?foundation.String, return_type: ?foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "validRequestorForSendType:returnType:", .{ send_type, return_type });
    }

    /// `-[NSResponder mouseDown:]`
    pub fn mouseDown(self: Self, event: Event) void {
        return self.object.msgSend(void, "mouseDown:", .{event});
    }

    /// `-[NSResponder rightMouseDown:]`
    pub fn rightMouseDown(self: Self, event: Event) void {
        return self.object.msgSend(void, "rightMouseDown:", .{event});
    }

    /// `-[NSResponder otherMouseDown:]`
    pub fn otherMouseDown(self: Self, event: Event) void {
        return self.object.msgSend(void, "otherMouseDown:", .{event});
    }

    /// `-[NSResponder mouseUp:]`
    pub fn mouseUp(self: Self, event: Event) void {
        return self.object.msgSend(void, "mouseUp:", .{event});
    }

    /// `-[NSResponder rightMouseUp:]`
    pub fn rightMouseUp(self: Self, event: Event) void {
        return self.object.msgSend(void, "rightMouseUp:", .{event});
    }

    /// `-[NSResponder otherMouseUp:]`
    pub fn otherMouseUp(self: Self, event: Event) void {
        return self.object.msgSend(void, "otherMouseUp:", .{event});
    }

    /// `-[NSResponder mouseMoved:]`
    pub fn mouseMoved(self: Self, event: Event) void {
        return self.object.msgSend(void, "mouseMoved:", .{event});
    }

    /// `-[NSResponder mouseDragged:]`
    pub fn mouseDragged(self: Self, event: Event) void {
        return self.object.msgSend(void, "mouseDragged:", .{event});
    }

    /// `-[NSResponder mouseCancelled:]`
    pub fn mouseCancelled(self: Self, event: Event) void {
        return self.object.msgSend(void, "mouseCancelled:", .{event});
    }

    /// `-[NSResponder scrollWheel:]`
    pub fn scrollWheel(self: Self, event: Event) void {
        return self.object.msgSend(void, "scrollWheel:", .{event});
    }

    /// `-[NSResponder rightMouseDragged:]`
    pub fn rightMouseDragged(self: Self, event: Event) void {
        return self.object.msgSend(void, "rightMouseDragged:", .{event});
    }

    /// `-[NSResponder otherMouseDragged:]`
    pub fn otherMouseDragged(self: Self, event: Event) void {
        return self.object.msgSend(void, "otherMouseDragged:", .{event});
    }

    /// `-[NSResponder mouseEntered:]`
    pub fn mouseEntered(self: Self, event: Event) void {
        return self.object.msgSend(void, "mouseEntered:", .{event});
    }

    /// `-[NSResponder mouseExited:]`
    pub fn mouseExited(self: Self, event: Event) void {
        return self.object.msgSend(void, "mouseExited:", .{event});
    }

    /// `-[NSResponder keyDown:]`
    pub fn keyDown(self: Self, event: Event) void {
        return self.object.msgSend(void, "keyDown:", .{event});
    }

    /// `-[NSResponder keyUp:]`
    pub fn keyUp(self: Self, event: Event) void {
        return self.object.msgSend(void, "keyUp:", .{event});
    }

    /// `-[NSResponder flagsChanged:]`
    pub fn flagsChanged(self: Self, event: Event) void {
        return self.object.msgSend(void, "flagsChanged:", .{event});
    }

    /// `-[NSResponder tabletPoint:]`
    pub fn tabletPoint(self: Self, event: Event) void {
        return self.object.msgSend(void, "tabletPoint:", .{event});
    }

    /// `-[NSResponder tabletProximity:]`
    pub fn tabletProximity(self: Self, event: Event) void {
        return self.object.msgSend(void, "tabletProximity:", .{event});
    }

    /// `-[NSResponder cursorUpdate:]`
    pub fn cursorUpdate(self: Self, event: Event) void {
        return self.object.msgSend(void, "cursorUpdate:", .{event});
    }

    /// `-[NSResponder magnifyWithEvent:]`
    pub fn magnifyWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "magnifyWithEvent:", .{event});
    }

    /// `-[NSResponder rotateWithEvent:]`
    pub fn rotateWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "rotateWithEvent:", .{event});
    }

    /// `-[NSResponder swipeWithEvent:]`
    pub fn swipeWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "swipeWithEvent:", .{event});
    }

    /// `-[NSResponder beginGestureWithEvent:]`
    pub fn beginGestureWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "beginGestureWithEvent:", .{event});
    }

    /// `-[NSResponder endGestureWithEvent:]`
    pub fn endGestureWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "endGestureWithEvent:", .{event});
    }

    /// `-[NSResponder smartMagnifyWithEvent:]`
    pub fn smartMagnifyWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "smartMagnifyWithEvent:", .{event});
    }

    /// `-[NSResponder changeModeWithEvent:]`
    pub fn changeModeWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "changeModeWithEvent:", .{event});
    }

    /// `-[NSResponder touchesBeganWithEvent:]`
    pub fn touchesBeganWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "touchesBeganWithEvent:", .{event});
    }

    /// `-[NSResponder touchesMovedWithEvent:]`
    pub fn touchesMovedWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "touchesMovedWithEvent:", .{event});
    }

    /// `-[NSResponder touchesEndedWithEvent:]`
    pub fn touchesEndedWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "touchesEndedWithEvent:", .{event});
    }

    /// `-[NSResponder touchesCancelledWithEvent:]`
    pub fn touchesCancelledWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "touchesCancelledWithEvent:", .{event});
    }

    /// `-[NSResponder quickLookWithEvent:]`
    pub fn quickLookWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "quickLookWithEvent:", .{event});
    }

    /// `-[NSResponder pressureChangeWithEvent:]`
    pub fn pressureChangeWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "pressureChangeWithEvent:", .{event});
    }

    /// `-[NSResponder contextMenuKeyDown:]`
    pub fn contextMenuKeyDown(self: Self, event: Event) void {
        return self.object.msgSend(void, "contextMenuKeyDown:", .{event});
    }

    /// `-[NSResponder noResponderFor:]`
    pub fn noResponderFor(self: Self, event_selector: objc.Sel) void {
        return self.object.msgSend(void, "noResponderFor:", .{event_selector});
    }

    /// `-[NSResponder becomeFirstResponder]`
    pub fn becomeFirstResponder(self: Self) bool {
        return self.object.msgSend(bool, "becomeFirstResponder", .{});
    }

    /// `-[NSResponder resignFirstResponder]`
    pub fn resignFirstResponder(self: Self) bool {
        return self.object.msgSend(bool, "resignFirstResponder", .{});
    }

    /// `-[NSResponder interpretKeyEvents:]`
    pub fn interpretKeyEvents(self: Self, event_array: foundation.Array(Event)) void {
        return self.object.msgSend(void, "interpretKeyEvents:", .{event_array});
    }

    /// `-[NSResponder flushBufferedKeyEvents]`
    pub fn flushBufferedKeyEvents(self: Self) void {
        return self.object.msgSend(void, "flushBufferedKeyEvents", .{});
    }

    /// `-[NSResponder showContextHelp:]`
    pub fn showContextHelp(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "showContextHelp:", .{sender});
    }

    /// `-[NSResponder helpRequested:]`
    pub fn helpRequested(self: Self, event_ptr: Event) void {
        return self.object.msgSend(void, "helpRequested:", .{event_ptr});
    }

    /// `-[NSResponder shouldBeTreatedAsInkEvent:]`
    pub fn shouldBeTreatedAsInkEvent(self: Self, event: Event) bool {
        return self.object.msgSend(bool, "shouldBeTreatedAsInkEvent:", .{event});
    }

    /// `-[NSResponder wantsScrollEventsForSwipeTrackingOnAxis:]`
    pub fn wantsScrollEventsForSwipeTrackingOnAxis(self: Self, axis: EventGestureAxis) bool {
        return self.object.msgSend(bool, "wantsScrollEventsForSwipeTrackingOnAxis:", .{axis});
    }

    /// `-[NSResponder wantsForwardedScrollEventsForAxis:]`
    pub fn wantsForwardedScrollEventsForAxis(self: Self, axis: EventGestureAxis) bool {
        return self.object.msgSend(bool, "wantsForwardedScrollEventsForAxis:", .{axis});
    }

    /// `-[NSResponder supplementalTargetForAction:sender:]`
    pub fn supplementalTargetForActionSender(self: Self, action: objc.Sel, sender: ?objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "supplementalTargetForAction:sender:", .{ action, sender });
    }

    /// `-[NSResponder nextResponder]`
    pub fn nextResponder(self: Self) ?Responder {
        return self.object.msgSend(?Responder, "nextResponder", .{});
    }

    /// `-[NSResponder setNextResponder:]`
    pub fn setNextResponder(self: Self, next_responder: ?Responder) void {
        return self.object.msgSend(void, "setNextResponder:", .{next_responder});
    }

    /// `-[NSResponder acceptsFirstResponder]`
    pub fn acceptsFirstResponder(self: Self) bool {
        return self.object.msgSend(bool, "acceptsFirstResponder", .{});
    }

    /// `-[NSResponder menu]`
    pub fn menu(self: Self) ?Menu {
        return self.object.msgSend(?Menu, "menu", .{});
    }

    /// `-[NSResponder setMenu:]`
    pub fn setMenu(self: Self, menu_: ?Menu) void {
        return self.object.msgSend(void, "setMenu:", .{menu_});
    }

    /// `-[NSResponder newWindowForTab:]`
    pub fn newWindowForTab(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "newWindowForTab:", .{sender});
    }
};

/// `NSApplication`, a subclass of `NSResponder`.
pub const Application = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = Responder;
    pub const class_name = "NSApplication";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSApplication`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSApplication sendAction:to:from:]`
    pub fn sendActionToFrom(self: Self, action: objc.Sel, target: ?objc.Object, sender: ?objc.Object) bool {
        return self.object.msgSend(bool, "sendAction:to:from:", .{ action, target, sender });
    }

    /// `-[NSApplication targetForAction:]`
    pub fn targetForAction(self: Self, action: objc.Sel) ?objc.Object {
        return self.object.msgSend(?objc.Object, "targetForAction:", .{action});
    }

    /// `-[NSApplication targetForAction:to:from:]`
    pub fn targetForActionToFrom(self: Self, action: objc.Sel, target: ?objc.Object, sender: ?objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "targetForAction:to:from:", .{ action, target, sender });
    }

    /// `-[NSApplication tryToPerform:with:]`
    pub fn tryToPerformWith(self: Self, action: objc.Sel, object_: ?objc.Object) bool {
        return self.object.msgSend(bool, "tryToPerform:with:", .{ action, object_ });
    }

    /// `-[NSApplication validRequestorForSendType:returnType:]`
    pub fn validRequestorForSendTypeReturnType(self: Self, send_type: ?foundation.String, return_type: ?foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "validRequestorForSendType:returnType:", .{ send_type, return_type });
    }

    /// `-[NSApplication hide:]`
    pub fn hide(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "hide:", .{sender});
    }

    /// `-[NSApplication unhide:]`
    pub fn unhide(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "unhide:", .{sender});
    }

    /// `-[NSApplication unhideWithoutActivation]`
    pub fn unhideWithoutActivation(self: Self) void {
        return self.object.msgSend(void, "unhideWithoutActivation", .{});
    }

    /// `-[NSApplication windowWithWindowNumber:]`
    pub fn windowWithWindowNumber(self: Self, window_num: objc.Integer) ?Window {
        return self.object.msgSend(?Window, "windowWithWindowNumber:", .{window_num});
    }

    /// `-[NSApplication deactivate]`
    pub fn deactivate(self: Self) void {
        return self.object.msgSend(void, "deactivate", .{});
    }

    /// `-[NSApplication activateIgnoringOtherApps:]`
    pub fn activateIgnoringOtherApps(self: Self, ignore_other_apps: bool) void {
        return self.object.msgSend(void, "activateIgnoringOtherApps:", .{ignore_other_apps});
    }

    /// `-[NSApplication activate]`
    pub fn activate(self: Self) void {
        return self.object.msgSend(void, "activate", .{});
    }

    /// `-[NSApplication yieldActivationToApplication:]`
    pub fn yieldActivationToApplication(self: Self, application: RunningApplication) void {
        return self.object.msgSend(void, "yieldActivationToApplication:", .{application});
    }

    /// `-[NSApplication yieldActivationToApplicationWithBundleIdentifier:]`
    pub fn yieldActivationToApplicationWithBundleIdentifier(self: Self, bundle_identifier: foundation.String) void {
        return self.object.msgSend(void, "yieldActivationToApplicationWithBundleIdentifier:", .{bundle_identifier});
    }

    /// `-[NSApplication hideOtherApplications:]`
    pub fn hideOtherApplications(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "hideOtherApplications:", .{sender});
    }

    /// `-[NSApplication unhideAllApplications:]`
    pub fn unhideAllApplications(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "unhideAllApplications:", .{sender});
    }

    /// `-[NSApplication finishLaunching]`
    pub fn finishLaunching(self: Self) void {
        return self.object.msgSend(void, "finishLaunching", .{});
    }

    /// `-[NSApplication run]`
    pub fn run(self: Self) void {
        return self.object.msgSend(void, "run", .{});
    }

    /// `-[NSApplication runModalForWindow:]`
    pub fn runModalForWindow(self: Self, window: Window) objc.Integer {
        return self.object.msgSend(objc.Integer, "runModalForWindow:", .{window});
    }

    /// `-[NSApplication stop:]`
    pub fn stop(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "stop:", .{sender});
    }

    /// `-[NSApplication stopModal]`
    pub fn stopModal(self: Self) void {
        return self.object.msgSend(void, "stopModal", .{});
    }

    /// `-[NSApplication stopModalWithCode:]`
    pub fn stopModalWithCode(self: Self, return_code: objc.Integer) void {
        return self.object.msgSend(void, "stopModalWithCode:", .{return_code});
    }

    /// `-[NSApplication abortModal]`
    pub fn abortModal(self: Self) void {
        return self.object.msgSend(void, "abortModal", .{});
    }

    /// `-[NSApplication beginModalSessionForWindow:]`
    pub fn beginModalSessionForWindow(self: Self, window: Window) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "beginModalSessionForWindow:", .{window});
    }

    /// `-[NSApplication runModalSession:]`
    pub fn runModalSession(self: Self, session: ?*anyopaque) objc.Integer {
        return self.object.msgSend(objc.Integer, "runModalSession:", .{session});
    }

    /// `-[NSApplication endModalSession:]`
    pub fn endModalSession(self: Self, session: ?*anyopaque) void {
        return self.object.msgSend(void, "endModalSession:", .{session});
    }

    /// `-[NSApplication terminate:]`
    pub fn terminate(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "terminate:", .{sender});
    }

    /// `-[NSApplication requestUserAttention:]`
    pub fn requestUserAttention(self: Self, request_type: RequestUserAttentionType) objc.Integer {
        return self.object.msgSend(objc.Integer, "requestUserAttention:", .{request_type});
    }

    /// `-[NSApplication cancelUserAttentionRequest:]`
    pub fn cancelUserAttentionRequest(self: Self, request: objc.Integer) void {
        return self.object.msgSend(void, "cancelUserAttentionRequest:", .{request});
    }

    /// `-[NSApplication enumerateWindowsWithOptions:usingBlock:]`
    pub fn enumerateWindowsWithOptionsUsingBlock(self: Self, options: WindowListOptions, block: anytype) void {
        return self.object.msgSend(void, "enumerateWindowsWithOptions:usingBlock:", .{ options, block });
    }

    /// `-[NSApplication preventWindowOrdering]`
    pub fn preventWindowOrdering(self: Self) void {
        return self.object.msgSend(void, "preventWindowOrdering", .{});
    }

    /// `-[NSApplication setWindowsNeedUpdate:]`
    pub fn setWindowsNeedUpdate(self: Self, need_update: bool) void {
        return self.object.msgSend(void, "setWindowsNeedUpdate:", .{need_update});
    }

    /// `-[NSApplication updateWindows]`
    pub fn updateWindows(self: Self) void {
        return self.object.msgSend(void, "updateWindows", .{});
    }

    /// `-[NSApplication activationPolicy]`
    pub fn activationPolicy(self: Self) ApplicationActivationPolicy {
        return self.object.msgSend(ApplicationActivationPolicy, "activationPolicy", .{});
    }

    /// `-[NSApplication setActivationPolicy:]`
    pub fn setActivationPolicy(self: Self, activation_policy: ApplicationActivationPolicy) bool {
        return self.object.msgSend(bool, "setActivationPolicy:", .{activation_policy});
    }

    /// `-[NSApplication reportException:]`
    pub fn reportException(self: Self, exception: objc.Object) void {
        return self.object.msgSend(void, "reportException:", .{exception});
    }

    /// `+[NSApplication detachDrawingThread:toTarget:withObject:]`
    pub fn detachDrawingThreadToTargetWithObject(selector: objc.Sel, target: objc.Object, argument: ?objc.Object) void {
        return class().msgSend(void, "detachDrawingThread:toTarget:withObject:", .{ selector, target, argument });
    }

    /// `-[NSApplication replyToApplicationShouldTerminate:]`
    pub fn replyToApplicationShouldTerminate(self: Self, should_terminate: bool) void {
        return self.object.msgSend(void, "replyToApplicationShouldTerminate:", .{should_terminate});
    }

    /// `-[NSApplication replyToOpenOrPrint:]`
    pub fn replyToOpenOrPrint(self: Self, reply: ApplicationDelegateReply) void {
        return self.object.msgSend(void, "replyToOpenOrPrint:", .{reply});
    }

    /// `-[NSApplication orderFrontCharacterPalette:]`
    pub fn orderFrontCharacterPalette(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "orderFrontCharacterPalette:", .{sender});
    }

    /// `+[NSApplication sharedApplication]`
    pub fn sharedApplication() Application {
        return class().msgSend(Application, "sharedApplication", .{});
    }

    /// `-[NSApplication delegate]`
    pub fn delegate(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "delegate", .{});
    }

    /// `-[NSApplication setDelegate:]`
    pub fn setDelegate(self: Self, delegate_: ?objc.Object) void {
        return self.object.msgSend(void, "setDelegate:", .{delegate_});
    }

    /// `-[NSApplication mainWindow]`
    pub fn mainWindow(self: Self) ?Window {
        return self.object.msgSend(?Window, "mainWindow", .{});
    }

    /// `-[NSApplication keyWindow]`
    pub fn keyWindow(self: Self) ?Window {
        return self.object.msgSend(?Window, "keyWindow", .{});
    }

    /// `-[NSApplication isActive]`
    pub fn isActive(self: Self) bool {
        return self.object.msgSend(bool, "isActive", .{});
    }

    /// `-[NSApplication isHidden]`
    pub fn isHidden(self: Self) bool {
        return self.object.msgSend(bool, "isHidden", .{});
    }

    /// `-[NSApplication isRunning]`
    pub fn isRunning(self: Self) bool {
        return self.object.msgSend(bool, "isRunning", .{});
    }

    /// `-[NSApplication applicationShouldSuppressHighDynamicRangeContent]`
    pub fn applicationShouldSuppressHighDynamicRangeContent(self: Self) bool {
        return self.object.msgSend(bool, "applicationShouldSuppressHighDynamicRangeContent", .{});
    }

    /// `-[NSApplication modalWindow]`
    pub fn modalWindow(self: Self) ?Window {
        return self.object.msgSend(?Window, "modalWindow", .{});
    }

    /// `-[NSApplication windows]`
    pub fn windows(self: Self) foundation.Array(Window) {
        return self.object.msgSend(foundation.Array(Window), "windows", .{});
    }

    /// `-[NSApplication mainMenu]`
    pub fn mainMenu(self: Self) ?Menu {
        return self.object.msgSend(?Menu, "mainMenu", .{});
    }

    /// `-[NSApplication setMainMenu:]`
    pub fn setMainMenu(self: Self, main_menu: ?Menu) void {
        return self.object.msgSend(void, "setMainMenu:", .{main_menu});
    }

    /// `-[NSApplication helpMenu]`
    pub fn helpMenu(self: Self) ?Menu {
        return self.object.msgSend(?Menu, "helpMenu", .{});
    }

    /// `-[NSApplication setHelpMenu:]`
    pub fn setHelpMenu(self: Self, help_menu: ?Menu) void {
        return self.object.msgSend(void, "setHelpMenu:", .{help_menu});
    }

    /// `-[NSApplication applicationIconImage]`
    pub fn applicationIconImage(self: Self) Image {
        return self.object.msgSend(Image, "applicationIconImage", .{});
    }

    /// `-[NSApplication setApplicationIconImage:]`
    pub fn setApplicationIconImage(self: Self, application_icon_image: ?Image) void {
        return self.object.msgSend(void, "setApplicationIconImage:", .{application_icon_image});
    }

    /// `-[NSApplication dockTile]`
    pub fn dockTile(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "dockTile", .{});
    }

    /// `-[NSApplication presentationOptions]`
    pub fn presentationOptions(self: Self) ApplicationPresentationOptions {
        return self.object.msgSend(ApplicationPresentationOptions, "presentationOptions", .{});
    }

    /// `-[NSApplication setPresentationOptions:]`
    pub fn setPresentationOptions(self: Self, presentation_options: ApplicationPresentationOptions) void {
        return self.object.msgSend(void, "setPresentationOptions:", .{presentation_options});
    }

    /// `-[NSApplication currentSystemPresentationOptions]`
    pub fn currentSystemPresentationOptions(self: Self) ApplicationPresentationOptions {
        return self.object.msgSend(ApplicationPresentationOptions, "currentSystemPresentationOptions", .{});
    }

    /// `-[NSApplication occlusionState]`
    pub fn occlusionState(self: Self) ApplicationOcclusionState {
        return self.object.msgSend(ApplicationOcclusionState, "occlusionState", .{});
    }

    /// `-[NSApplication isProtectedDataAvailable]`
    pub fn isProtectedDataAvailable(self: Self) bool {
        return self.object.msgSend(bool, "isProtectedDataAvailable", .{});
    }

    /// `-[NSApplication userInterfaceLayoutDirection]`
    pub fn userInterfaceLayoutDirection(self: Self) UserInterfaceLayoutDirection {
        return self.object.msgSend(UserInterfaceLayoutDirection, "userInterfaceLayoutDirection", .{});
    }

    /// `-[NSApplication activateContextHelpMode:]`
    pub fn activateContextHelpMode(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "activateContextHelpMode:", .{sender});
    }

    /// `-[NSApplication showHelp:]`
    pub fn showHelp(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "showHelp:", .{sender});
    }

    /// `-[NSApplication arrangeInFront:]`
    pub fn arrangeInFront(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "arrangeInFront:", .{sender});
    }

    /// `-[NSApplication removeWindowsItem:]`
    pub fn removeWindowsItem(self: Self, win: Window) void {
        return self.object.msgSend(void, "removeWindowsItem:", .{win});
    }

    /// `-[NSApplication addWindowsItem:title:filename:]`
    pub fn addWindowsItemTitleFilename(self: Self, win: Window, string: foundation.String, is_filename: bool) void {
        return self.object.msgSend(void, "addWindowsItem:title:filename:", .{ win, string, is_filename });
    }

    /// `-[NSApplication changeWindowsItem:title:filename:]`
    pub fn changeWindowsItemTitleFilename(self: Self, win: Window, string: foundation.String, is_filename: bool) void {
        return self.object.msgSend(void, "changeWindowsItem:title:filename:", .{ win, string, is_filename });
    }

    /// `-[NSApplication updateWindowsItem:]`
    pub fn updateWindowsItem(self: Self, win: Window) void {
        return self.object.msgSend(void, "updateWindowsItem:", .{win});
    }

    /// `-[NSApplication miniaturizeAll:]`
    pub fn miniaturizeAll(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "miniaturizeAll:", .{sender});
    }

    /// `-[NSApplication windowsMenu]`
    pub fn windowsMenu(self: Self) ?Menu {
        return self.object.msgSend(?Menu, "windowsMenu", .{});
    }

    /// `-[NSApplication setWindowsMenu:]`
    pub fn setWindowsMenu(self: Self, windows_menu: ?Menu) void {
        return self.object.msgSend(void, "setWindowsMenu:", .{windows_menu});
    }

    /// `-[NSApplication restoreWindowWithIdentifier:state:completionHandler:]`
    pub fn restoreWindowWithIdentifierStateCompletionHandler(self: Self, identifier: ?foundation.String, state: objc.Object, completion_handler: anytype) bool {
        return self.object.msgSend(bool, "restoreWindowWithIdentifier:state:completionHandler:", .{ identifier, state, completion_handler });
    }

    /// `-[NSApplication orderFrontColorPanel:]`
    pub fn orderFrontColorPanel(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "orderFrontColorPanel:", .{sender});
    }

    /// `-[NSApplication sendEvent:]`
    pub fn sendEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "sendEvent:", .{event});
    }

    /// `-[NSApplication postEvent:atStart:]`
    pub fn postEventAtStart(self: Self, event: Event, at_start: bool) void {
        return self.object.msgSend(void, "postEvent:atStart:", .{ event, at_start });
    }

    /// `-[NSApplication nextEventMatchingMask:untilDate:inMode:dequeue:]`
    pub fn nextEventMatchingMaskUntilDateInModeDequeue(self: Self, mask: EventMask, expiration: ?objc.Object, mode: ?foundation.String, deq_flag: bool) ?Event {
        return self.object.msgSend(?Event, "nextEventMatchingMask:untilDate:inMode:dequeue:", .{ mask, expiration, mode, deq_flag });
    }

    /// `-[NSApplication discardEventsMatchingMask:beforeEvent:]`
    pub fn discardEventsMatchingMaskBeforeEvent(self: Self, mask: EventMask, last_event: ?Event) void {
        return self.object.msgSend(void, "discardEventsMatchingMask:beforeEvent:", .{ mask, last_event });
    }

    /// `-[NSApplication currentEvent]`
    pub fn currentEvent(self: Self) ?Event {
        return self.object.msgSend(?Event, "currentEvent", .{});
    }
};

/// `NSRunningApplication`, a subclass of `NSObject`.
pub const RunningApplication = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSRunningApplication";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSRunningApplication`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSRunningApplication hide]`
    pub fn hide(self: Self) bool {
        return self.object.msgSend(bool, "hide", .{});
    }

    /// `-[NSRunningApplication unhide]`
    pub fn unhide(self: Self) bool {
        return self.object.msgSend(bool, "unhide", .{});
    }

    /// `-[NSRunningApplication activateFromApplication:options:]`
    pub fn activateFromApplicationOptions(self: Self, application: RunningApplication, options: ApplicationActivationOptions) bool {
        return self.object.msgSend(bool, "activateFromApplication:options:", .{ application, options });
    }

    /// `-[NSRunningApplication activateWithOptions:]`
    pub fn activateWithOptions(self: Self, options: ApplicationActivationOptions) bool {
        return self.object.msgSend(bool, "activateWithOptions:", .{options});
    }

    /// `-[NSRunningApplication terminate]`
    pub fn terminate(self: Self) bool {
        return self.object.msgSend(bool, "terminate", .{});
    }

    /// `-[NSRunningApplication forceTerminate]`
    pub fn forceTerminate(self: Self) bool {
        return self.object.msgSend(bool, "forceTerminate", .{});
    }

    /// `+[NSRunningApplication runningApplicationsWithBundleIdentifier:]`
    pub fn runningApplicationsWithBundleIdentifier(bundle_identifier: foundation.String) foundation.Array(RunningApplication) {
        return class().msgSend(foundation.Array(RunningApplication), "runningApplicationsWithBundleIdentifier:", .{bundle_identifier});
    }

    /// `+[NSRunningApplication runningApplicationWithProcessIdentifier:]`
    pub fn runningApplicationWithProcessIdentifier(pid: c_int) ?RunningApplication {
        return class().msgSend(?RunningApplication, "runningApplicationWithProcessIdentifier:", .{pid});
    }

    /// `+[NSRunningApplication terminateAutomaticallyTerminableApplications]`
    pub fn terminateAutomaticallyTerminableApplications() void {
        return class().msgSend(void, "terminateAutomaticallyTerminableApplications", .{});
    }

    /// `-[NSRunningApplication isTerminated]`
    pub fn isTerminated(self: Self) bool {
        return self.object.msgSend(bool, "isTerminated", .{});
    }

    /// `-[NSRunningApplication isFinishedLaunching]`
    pub fn isFinishedLaunching(self: Self) bool {
        return self.object.msgSend(bool, "isFinishedLaunching", .{});
    }

    /// `-[NSRunningApplication isHidden]`
    pub fn isHidden(self: Self) bool {
        return self.object.msgSend(bool, "isHidden", .{});
    }

    /// `-[NSRunningApplication isActive]`
    pub fn isActive(self: Self) bool {
        return self.object.msgSend(bool, "isActive", .{});
    }

    /// `-[NSRunningApplication ownsMenuBar]`
    pub fn ownsMenuBar(self: Self) bool {
        return self.object.msgSend(bool, "ownsMenuBar", .{});
    }

    /// `-[NSRunningApplication activationPolicy]`
    pub fn activationPolicy(self: Self) ApplicationActivationPolicy {
        return self.object.msgSend(ApplicationActivationPolicy, "activationPolicy", .{});
    }

    /// `-[NSRunningApplication localizedName]`
    pub fn localizedName(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "localizedName", .{});
    }

    /// `-[NSRunningApplication bundleIdentifier]`
    pub fn bundleIdentifier(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "bundleIdentifier", .{});
    }

    /// `-[NSRunningApplication bundleURL]`
    pub fn bundleURL(self: Self) ?foundation.Url {
        return self.object.msgSend(?foundation.Url, "bundleURL", .{});
    }

    /// `-[NSRunningApplication executableURL]`
    pub fn executableURL(self: Self) ?foundation.Url {
        return self.object.msgSend(?foundation.Url, "executableURL", .{});
    }

    /// `-[NSRunningApplication processIdentifier]`
    pub fn processIdentifier(self: Self) c_int {
        return self.object.msgSend(c_int, "processIdentifier", .{});
    }

    /// `-[NSRunningApplication launchDate]`
    pub fn launchDate(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "launchDate", .{});
    }

    /// `-[NSRunningApplication icon]`
    pub fn icon(self: Self) ?Image {
        return self.object.msgSend(?Image, "icon", .{});
    }

    /// `-[NSRunningApplication executableArchitecture]`
    pub fn executableArchitecture(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "executableArchitecture", .{});
    }

    /// `+[NSRunningApplication currentApplication]`
    pub fn currentApplication() RunningApplication {
        return class().msgSend(RunningApplication, "currentApplication", .{});
    }
};

/// `NSWindow`, a subclass of `NSResponder`.
pub const Window = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = Responder;
    pub const class_name = "NSWindow";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSWindow`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `+[NSWindow frameRectForContentRect:styleMask:]`
    pub fn frameRectForContentRectStyleMask(c_rect: cg.Rect, style: WindowStyleMask) cg.Rect {
        return class().msgSend(cg.Rect, "frameRectForContentRect:styleMask:", .{ c_rect, style });
    }

    /// `+[NSWindow contentRectForFrameRect:styleMask:]`
    pub fn contentRectForFrameRectStyleMask(f_rect: cg.Rect, style: WindowStyleMask) cg.Rect {
        return class().msgSend(cg.Rect, "contentRectForFrameRect:styleMask:", .{ f_rect, style });
    }

    /// `+[NSWindow minFrameWidthWithTitle:styleMask:]`
    pub fn minFrameWidthWithTitleStyleMask(title_: foundation.String, style: WindowStyleMask) cg.Float {
        return class().msgSend(cg.Float, "minFrameWidthWithTitle:styleMask:", .{ title_, style });
    }

    /// `-[NSWindow frameRectForContentRect:]`
    pub fn frameRectForContentRect(self: Self, content_rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "frameRectForContentRect:", .{content_rect});
    }

    /// `-[NSWindow contentRectForFrameRect:]`
    pub fn contentRectForFrameRect(self: Self, frame_rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "contentRectForFrameRect:", .{frame_rect});
    }

    /// `-[NSWindow initWithContentRect:styleMask:backing:defer:]`
    pub fn initWithContentRectStyleMaskBackingDefer(self: Self, content_rect: cg.Rect, style: WindowStyleMask, backing_store_type: BackingStoreType, flag: bool) Window {
        return self.object.msgSend(Window, "initWithContentRect:styleMask:backing:defer:", .{ content_rect, style, backing_store_type, flag });
    }

    /// `-[NSWindow initWithContentRect:styleMask:backing:defer:screen:]`
    pub fn initWithContentRectStyleMaskBackingDeferScreen(self: Self, content_rect: cg.Rect, style: WindowStyleMask, backing_store_type: BackingStoreType, flag: bool, screen_: ?Screen) Window {
        return self.object.msgSend(Window, "initWithContentRect:styleMask:backing:defer:screen:", .{ content_rect, style, backing_store_type, flag, screen_ });
    }

    /// `-[NSWindow addTitlebarAccessoryViewController:]`
    pub fn addTitlebarAccessoryViewController(self: Self, child_view_controller: objc.Object) void {
        return self.object.msgSend(void, "addTitlebarAccessoryViewController:", .{child_view_controller});
    }

    /// `-[NSWindow insertTitlebarAccessoryViewController:atIndex:]`
    pub fn insertTitlebarAccessoryViewControllerAtIndex(self: Self, child_view_controller: objc.Object, index: objc.Integer) void {
        return self.object.msgSend(void, "insertTitlebarAccessoryViewController:atIndex:", .{ child_view_controller, index });
    }

    /// `-[NSWindow removeTitlebarAccessoryViewControllerAtIndex:]`
    pub fn removeTitlebarAccessoryViewControllerAtIndex(self: Self, index: objc.Integer) void {
        return self.object.msgSend(void, "removeTitlebarAccessoryViewControllerAtIndex:", .{index});
    }

    /// `-[NSWindow setTitleWithRepresentedFilename:]`
    pub fn setTitleWithRepresentedFilename(self: Self, filename: foundation.String) void {
        return self.object.msgSend(void, "setTitleWithRepresentedFilename:", .{filename});
    }

    /// `-[NSWindow fieldEditor:forObject:]`
    pub fn fieldEditorForObject(self: Self, create_flag: bool, object_: ?objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "fieldEditor:forObject:", .{ create_flag, object_ });
    }

    /// `-[NSWindow endEditingFor:]`
    pub fn endEditingFor(self: Self, object_: ?objc.Object) void {
        return self.object.msgSend(void, "endEditingFor:", .{object_});
    }

    /// `-[NSWindow constrainFrameRect:toScreen:]`
    pub fn constrainFrameRectToScreen(self: Self, frame_rect: cg.Rect, screen_: ?Screen) cg.Rect {
        return self.object.msgSend(cg.Rect, "constrainFrameRect:toScreen:", .{ frame_rect, screen_ });
    }

    /// `-[NSWindow setFrame:display:]`
    pub fn setFrameDisplay(self: Self, frame_rect: cg.Rect, flag: bool) void {
        return self.object.msgSend(void, "setFrame:display:", .{ frame_rect, flag });
    }

    /// `-[NSWindow setContentSize:]`
    pub fn setContentSize(self: Self, size: cg.Size) void {
        return self.object.msgSend(void, "setContentSize:", .{size});
    }

    /// `-[NSWindow setFrameOrigin:]`
    pub fn setFrameOrigin(self: Self, point: cg.Point) void {
        return self.object.msgSend(void, "setFrameOrigin:", .{point});
    }

    /// `-[NSWindow setFrameTopLeftPoint:]`
    pub fn setFrameTopLeftPoint(self: Self, point: cg.Point) void {
        return self.object.msgSend(void, "setFrameTopLeftPoint:", .{point});
    }

    /// `-[NSWindow cascadeTopLeftFromPoint:]`
    pub fn cascadeTopLeftFromPoint(self: Self, top_left_point: cg.Point) cg.Point {
        return self.object.msgSend(cg.Point, "cascadeTopLeftFromPoint:", .{top_left_point});
    }

    /// `-[NSWindow animationResizeTime:]`
    pub fn animationResizeTime(self: Self, new_frame: cg.Rect) f64 {
        return self.object.msgSend(f64, "animationResizeTime:", .{new_frame});
    }

    /// `-[NSWindow setFrame:display:animate:]`
    pub fn setFrameDisplayAnimate(self: Self, frame_rect: cg.Rect, display_flag: bool, animate_flag: bool) void {
        return self.object.msgSend(void, "setFrame:display:animate:", .{ frame_rect, display_flag, animate_flag });
    }

    /// `-[NSWindow displayIfNeeded]`
    pub fn displayIfNeeded(self: Self) void {
        return self.object.msgSend(void, "displayIfNeeded", .{});
    }

    /// `-[NSWindow display]`
    pub fn display(self: Self) void {
        return self.object.msgSend(void, "display", .{});
    }

    /// `-[NSWindow update]`
    pub fn update(self: Self) void {
        return self.object.msgSend(void, "update", .{});
    }

    /// `-[NSWindow makeFirstResponder:]`
    pub fn makeFirstResponder(self: Self, responder: ?Responder) bool {
        return self.object.msgSend(bool, "makeFirstResponder:", .{responder});
    }

    /// `-[NSWindow close]`
    pub fn close(self: Self) void {
        return self.object.msgSend(void, "close", .{});
    }

    /// `-[NSWindow miniaturize:]`
    pub fn miniaturize(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "miniaturize:", .{sender});
    }

    /// `-[NSWindow deminiaturize:]`
    pub fn deminiaturize(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "deminiaturize:", .{sender});
    }

    /// `-[NSWindow zoom:]`
    pub fn zoom(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "zoom:", .{sender});
    }

    /// `-[NSWindow tryToPerform:with:]`
    pub fn tryToPerformWith(self: Self, action: objc.Sel, object_: ?objc.Object) bool {
        return self.object.msgSend(bool, "tryToPerform:with:", .{ action, object_ });
    }

    /// `-[NSWindow validRequestorForSendType:returnType:]`
    pub fn validRequestorForSendTypeReturnType(self: Self, send_type: ?foundation.String, return_type: ?foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "validRequestorForSendType:returnType:", .{ send_type, return_type });
    }

    /// `-[NSWindow setContentBorderThickness:forEdge:]`
    pub fn setContentBorderThicknessForEdge(self: Self, thickness: cg.Float, edge: RectEdge) void {
        return self.object.msgSend(void, "setContentBorderThickness:forEdge:", .{ thickness, edge });
    }

    /// `-[NSWindow contentBorderThicknessForEdge:]`
    pub fn contentBorderThicknessForEdge(self: Self, edge: RectEdge) cg.Float {
        return self.object.msgSend(cg.Float, "contentBorderThicknessForEdge:", .{edge});
    }

    /// `-[NSWindow setAutorecalculatesContentBorderThickness:forEdge:]`
    pub fn setAutorecalculatesContentBorderThicknessForEdge(self: Self, flag: bool, edge: RectEdge) void {
        return self.object.msgSend(void, "setAutorecalculatesContentBorderThickness:forEdge:", .{ flag, edge });
    }

    /// `-[NSWindow autorecalculatesContentBorderThicknessForEdge:]`
    pub fn autorecalculatesContentBorderThicknessForEdge(self: Self, edge: RectEdge) bool {
        return self.object.msgSend(bool, "autorecalculatesContentBorderThicknessForEdge:", .{edge});
    }

    /// `-[NSWindow center]`
    pub fn center(self: Self) void {
        return self.object.msgSend(void, "center", .{});
    }

    /// `-[NSWindow makeKeyAndOrderFront:]`
    pub fn makeKeyAndOrderFront(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "makeKeyAndOrderFront:", .{sender});
    }

    /// `-[NSWindow orderFront:]`
    pub fn orderFront(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "orderFront:", .{sender});
    }

    /// `-[NSWindow orderBack:]`
    pub fn orderBack(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "orderBack:", .{sender});
    }

    /// `-[NSWindow orderOut:]`
    pub fn orderOut(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "orderOut:", .{sender});
    }

    /// `-[NSWindow orderWindow:relativeTo:]`
    pub fn orderWindowRelativeTo(self: Self, place: WindowOrderingMode, other_win: objc.Integer) void {
        return self.object.msgSend(void, "orderWindow:relativeTo:", .{ place, other_win });
    }

    /// `-[NSWindow orderFrontRegardless]`
    pub fn orderFrontRegardless(self: Self) void {
        return self.object.msgSend(void, "orderFrontRegardless", .{});
    }

    /// `-[NSWindow makeKeyWindow]`
    pub fn makeKeyWindow(self: Self) void {
        return self.object.msgSend(void, "makeKeyWindow", .{});
    }

    /// `-[NSWindow makeMainWindow]`
    pub fn makeMainWindow(self: Self) void {
        return self.object.msgSend(void, "makeMainWindow", .{});
    }

    /// `-[NSWindow becomeKeyWindow]`
    pub fn becomeKeyWindow(self: Self) void {
        return self.object.msgSend(void, "becomeKeyWindow", .{});
    }

    /// `-[NSWindow resignKeyWindow]`
    pub fn resignKeyWindow(self: Self) void {
        return self.object.msgSend(void, "resignKeyWindow", .{});
    }

    /// `-[NSWindow becomeMainWindow]`
    pub fn becomeMainWindow(self: Self) void {
        return self.object.msgSend(void, "becomeMainWindow", .{});
    }

    /// `-[NSWindow resignMainWindow]`
    pub fn resignMainWindow(self: Self) void {
        return self.object.msgSend(void, "resignMainWindow", .{});
    }

    /// `-[NSWindow convertRectToScreen:]`
    pub fn convertRectToScreen(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectToScreen:", .{rect});
    }

    /// `-[NSWindow convertRectFromScreen:]`
    pub fn convertRectFromScreen(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectFromScreen:", .{rect});
    }

    /// `-[NSWindow convertPointToScreen:]`
    pub fn convertPointToScreen(self: Self, point: cg.Point) cg.Point {
        return self.object.msgSend(cg.Point, "convertPointToScreen:", .{point});
    }

    /// `-[NSWindow convertPointFromScreen:]`
    pub fn convertPointFromScreen(self: Self, point: cg.Point) cg.Point {
        return self.object.msgSend(cg.Point, "convertPointFromScreen:", .{point});
    }

    /// `-[NSWindow convertRectToBacking:]`
    pub fn convertRectToBacking(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectToBacking:", .{rect});
    }

    /// `-[NSWindow convertRectFromBacking:]`
    pub fn convertRectFromBacking(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectFromBacking:", .{rect});
    }

    /// `-[NSWindow convertPointToBacking:]`
    pub fn convertPointToBacking(self: Self, point: cg.Point) cg.Point {
        return self.object.msgSend(cg.Point, "convertPointToBacking:", .{point});
    }

    /// `-[NSWindow convertPointFromBacking:]`
    pub fn convertPointFromBacking(self: Self, point: cg.Point) cg.Point {
        return self.object.msgSend(cg.Point, "convertPointFromBacking:", .{point});
    }

    /// `-[NSWindow backingAlignedRect:options:]`
    pub fn backingAlignedRectOptions(self: Self, rect: cg.Rect, options: AlignmentOptions) cg.Rect {
        return self.object.msgSend(cg.Rect, "backingAlignedRect:options:", .{ rect, options });
    }

    /// `-[NSWindow performClose:]`
    pub fn performClose(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "performClose:", .{sender});
    }

    /// `-[NSWindow performMiniaturize:]`
    pub fn performMiniaturize(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "performMiniaturize:", .{sender});
    }

    /// `-[NSWindow performZoom:]`
    pub fn performZoom(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "performZoom:", .{sender});
    }

    /// `-[NSWindow dataWithEPSInsideRect:]`
    pub fn dataWithEPSInsideRect(self: Self, rect: cg.Rect) foundation.Data {
        return self.object.msgSend(foundation.Data, "dataWithEPSInsideRect:", .{rect});
    }

    /// `-[NSWindow dataWithPDFInsideRect:]`
    pub fn dataWithPDFInsideRect(self: Self, rect: cg.Rect) foundation.Data {
        return self.object.msgSend(foundation.Data, "dataWithPDFInsideRect:", .{rect});
    }

    /// `-[NSWindow print:]`
    pub fn print(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "print:", .{sender});
    }

    /// `-[NSWindow setDynamicDepthLimit:]`
    pub fn setDynamicDepthLimit(self: Self, flag: bool) void {
        return self.object.msgSend(void, "setDynamicDepthLimit:", .{flag});
    }

    /// `-[NSWindow invalidateShadow]`
    pub fn invalidateShadow(self: Self) void {
        return self.object.msgSend(void, "invalidateShadow", .{});
    }

    /// `-[NSWindow toggleFullScreen:]`
    pub fn toggleFullScreen(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "toggleFullScreen:", .{sender});
    }

    /// `-[NSWindow setFrameFromString:]`
    pub fn setFrameFromString(self: Self, string: ?foundation.String) void {
        return self.object.msgSend(void, "setFrameFromString:", .{string});
    }

    /// `-[NSWindow saveFrameUsingName:]`
    pub fn saveFrameUsingName(self: Self, name: ?foundation.String) void {
        return self.object.msgSend(void, "saveFrameUsingName:", .{name});
    }

    /// `-[NSWindow setFrameUsingName:force:]`
    pub fn setFrameUsingNameForce(self: Self, name: ?foundation.String, force: bool) bool {
        return self.object.msgSend(bool, "setFrameUsingName:force:", .{ name, force });
    }

    /// `-[NSWindow setFrameUsingName:]`
    pub fn setFrameUsingName(self: Self, name: ?foundation.String) bool {
        return self.object.msgSend(bool, "setFrameUsingName:", .{name});
    }

    /// `-[NSWindow setFrameAutosaveName:]`
    pub fn setFrameAutosaveName(self: Self, name: ?foundation.String) bool {
        return self.object.msgSend(bool, "setFrameAutosaveName:", .{name});
    }

    /// `+[NSWindow removeFrameUsingName:]`
    pub fn removeFrameUsingName(name: ?foundation.String) void {
        return class().msgSend(void, "removeFrameUsingName:", .{name});
    }

    /// `-[NSWindow beginSheet:completionHandler:]`
    pub fn beginSheetCompletionHandler(self: Self, sheet_window: Window, handler: anytype) void {
        return self.object.msgSend(void, "beginSheet:completionHandler:", .{ sheet_window, handler });
    }

    /// `-[NSWindow beginCriticalSheet:completionHandler:]`
    pub fn beginCriticalSheetCompletionHandler(self: Self, sheet_window: Window, handler: anytype) void {
        return self.object.msgSend(void, "beginCriticalSheet:completionHandler:", .{ sheet_window, handler });
    }

    /// `-[NSWindow endSheet:]`
    pub fn endSheet(self: Self, sheet_window: Window) void {
        return self.object.msgSend(void, "endSheet:", .{sheet_window});
    }

    /// `-[NSWindow endSheet:returnCode:]`
    pub fn endSheetReturnCode(self: Self, sheet_window: Window, return_code: objc.Integer) void {
        return self.object.msgSend(void, "endSheet:returnCode:", .{ sheet_window, return_code });
    }

    /// `+[NSWindow standardWindowButton:forStyleMask:]`
    pub fn standardWindowButtonForStyleMask(b: WindowButton, style_mask: WindowStyleMask) ?objc.Object {
        return class().msgSend(?objc.Object, "standardWindowButton:forStyleMask:", .{ b, style_mask });
    }

    /// `-[NSWindow standardWindowButton:]`
    pub fn standardWindowButton(self: Self, b: WindowButton) ?objc.Object {
        return self.object.msgSend(?objc.Object, "standardWindowButton:", .{b});
    }

    /// `-[NSWindow addChildWindow:ordered:]`
    pub fn addChildWindowOrdered(self: Self, child_win: Window, place: WindowOrderingMode) void {
        return self.object.msgSend(void, "addChildWindow:ordered:", .{ child_win, place });
    }

    /// `-[NSWindow removeChildWindow:]`
    pub fn removeChildWindow(self: Self, child_win: Window) void {
        return self.object.msgSend(void, "removeChildWindow:", .{child_win});
    }

    /// `-[NSWindow canRepresentDisplayGamut:]`
    pub fn canRepresentDisplayGamut(self: Self, display_gamut: DisplayGamut) bool {
        return self.object.msgSend(bool, "canRepresentDisplayGamut:", .{display_gamut});
    }

    /// `+[NSWindow windowNumbersWithOptions:]`
    pub fn windowNumbersWithOptions(options: WindowNumberListOptions) ?foundation.Array(foundation.Number) {
        return class().msgSend(?foundation.Array(foundation.Number), "windowNumbersWithOptions:", .{options});
    }

    /// `+[NSWindow windowNumberAtPoint:belowWindowWithWindowNumber:]`
    pub fn windowNumberAtPointBelowWindowWithWindowNumber(point: cg.Point, window_number: objc.Integer) objc.Integer {
        return class().msgSend(objc.Integer, "windowNumberAtPoint:belowWindowWithWindowNumber:", .{ point, window_number });
    }

    /// `+[NSWindow windowWithContentViewController:]`
    pub fn windowWithContentViewController(content_view_controller: objc.Object) Window {
        return class().msgSend(Window, "windowWithContentViewController:", .{content_view_controller});
    }

    /// `-[NSWindow performWindowDragWithEvent:]`
    pub fn performWindowDragWithEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "performWindowDragWithEvent:", .{event});
    }

    /// `-[NSWindow selectNextKeyView:]`
    pub fn selectNextKeyView(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "selectNextKeyView:", .{sender});
    }

    /// `-[NSWindow selectPreviousKeyView:]`
    pub fn selectPreviousKeyView(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "selectPreviousKeyView:", .{sender});
    }

    /// `-[NSWindow selectKeyViewFollowingView:]`
    pub fn selectKeyViewFollowingView(self: Self, view: View) void {
        return self.object.msgSend(void, "selectKeyViewFollowingView:", .{view});
    }

    /// `-[NSWindow selectKeyViewPrecedingView:]`
    pub fn selectKeyViewPrecedingView(self: Self, view: View) void {
        return self.object.msgSend(void, "selectKeyViewPrecedingView:", .{view});
    }

    /// `-[NSWindow disableKeyEquivalentForDefaultButtonCell]`
    pub fn disableKeyEquivalentForDefaultButtonCell(self: Self) void {
        return self.object.msgSend(void, "disableKeyEquivalentForDefaultButtonCell", .{});
    }

    /// `-[NSWindow enableKeyEquivalentForDefaultButtonCell]`
    pub fn enableKeyEquivalentForDefaultButtonCell(self: Self) void {
        return self.object.msgSend(void, "enableKeyEquivalentForDefaultButtonCell", .{});
    }

    /// `-[NSWindow recalculateKeyViewLoop]`
    pub fn recalculateKeyViewLoop(self: Self) void {
        return self.object.msgSend(void, "recalculateKeyViewLoop", .{});
    }

    /// `-[NSWindow toggleToolbarShown:]`
    pub fn toggleToolbarShown(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "toggleToolbarShown:", .{sender});
    }

    /// `-[NSWindow runToolbarCustomizationPalette:]`
    pub fn runToolbarCustomizationPalette(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "runToolbarCustomizationPalette:", .{sender});
    }

    /// `-[NSWindow selectNextTab:]`
    pub fn selectNextTab(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "selectNextTab:", .{sender});
    }

    /// `-[NSWindow selectPreviousTab:]`
    pub fn selectPreviousTab(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "selectPreviousTab:", .{sender});
    }

    /// `-[NSWindow moveTabToNewWindow:]`
    pub fn moveTabToNewWindow(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "moveTabToNewWindow:", .{sender});
    }

    /// `-[NSWindow mergeAllWindows:]`
    pub fn mergeAllWindows(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "mergeAllWindows:", .{sender});
    }

    /// `-[NSWindow toggleTabBar:]`
    pub fn toggleTabBar(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "toggleTabBar:", .{sender});
    }

    /// `-[NSWindow toggleTabOverview:]`
    pub fn toggleTabOverview(self: Self, sender: ?objc.Object) void {
        return self.object.msgSend(void, "toggleTabOverview:", .{sender});
    }

    /// `-[NSWindow addTabbedWindow:ordered:]`
    pub fn addTabbedWindowOrdered(self: Self, window: Window, ordered: WindowOrderingMode) void {
        return self.object.msgSend(void, "addTabbedWindow:ordered:", .{ window, ordered });
    }

    /// `-[NSWindow transferWindowSharingToWindow:completionHandler:]`
    pub fn transferWindowSharingToWindowCompletionHandler(self: Self, window: Window, completion_handler: anytype) void {
        return self.object.msgSend(void, "transferWindowSharingToWindow:completionHandler:", .{ window, completion_handler });
    }

    /// `-[NSWindow requestSharingOfWindow:completionHandler:]`
    pub fn requestSharingOfWindowCompletionHandler(self: Self, window: Window, completion_handler: anytype) void {
        return self.object.msgSend(void, "requestSharingOfWindow:completionHandler:", .{ window, completion_handler });
    }

    /// `-[NSWindow requestSharingOfWindowUsingPreview:title:completionHandler:]`
    pub fn requestSharingOfWindowUsingPreviewTitleCompletionHandler(self: Self, image: Image, title_: foundation.String, completion_handler: anytype) void {
        return self.object.msgSend(void, "requestSharingOfWindowUsingPreview:title:completionHandler:", .{ image, title_, completion_handler });
    }

    /// `+[NSWindow defaultDepthLimit]`
    pub fn defaultDepthLimit() WindowDepth {
        return class().msgSend(WindowDepth, "defaultDepthLimit", .{});
    }

    /// `-[NSWindow title]`
    pub fn title(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "title", .{});
    }

    /// `-[NSWindow setTitle:]`
    pub fn setTitle(self: Self, title_: foundation.String) void {
        return self.object.msgSend(void, "setTitle:", .{title_});
    }

    /// `-[NSWindow subtitle]`
    pub fn subtitle(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "subtitle", .{});
    }

    /// `-[NSWindow setSubtitle:]`
    pub fn setSubtitle(self: Self, subtitle_: ?foundation.String) void {
        return self.object.msgSend(void, "setSubtitle:", .{subtitle_});
    }

    /// `-[NSWindow titleVisibility]`
    pub fn titleVisibility(self: Self) WindowTitleVisibility {
        return self.object.msgSend(WindowTitleVisibility, "titleVisibility", .{});
    }

    /// `-[NSWindow setTitleVisibility:]`
    pub fn setTitleVisibility(self: Self, title_visibility: WindowTitleVisibility) void {
        return self.object.msgSend(void, "setTitleVisibility:", .{title_visibility});
    }

    /// `-[NSWindow titlebarAppearsTransparent]`
    pub fn titlebarAppearsTransparent(self: Self) bool {
        return self.object.msgSend(bool, "titlebarAppearsTransparent", .{});
    }

    /// `-[NSWindow setTitlebarAppearsTransparent:]`
    pub fn setTitlebarAppearsTransparent(self: Self, titlebar_appears_transparent: bool) void {
        return self.object.msgSend(void, "setTitlebarAppearsTransparent:", .{titlebar_appears_transparent});
    }

    /// `-[NSWindow toolbarStyle]`
    pub fn toolbarStyle(self: Self) WindowToolbarStyle {
        return self.object.msgSend(WindowToolbarStyle, "toolbarStyle", .{});
    }

    /// `-[NSWindow setToolbarStyle:]`
    pub fn setToolbarStyle(self: Self, toolbar_style: WindowToolbarStyle) void {
        return self.object.msgSend(void, "setToolbarStyle:", .{toolbar_style});
    }

    /// `-[NSWindow contentLayoutRect]`
    pub fn contentLayoutRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "contentLayoutRect", .{});
    }

    /// `-[NSWindow contentLayoutGuide]`
    pub fn contentLayoutGuide(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "contentLayoutGuide", .{});
    }

    /// `-[NSWindow titlebarAccessoryViewControllers]`
    pub fn titlebarAccessoryViewControllers(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "titlebarAccessoryViewControllers", .{});
    }

    /// `-[NSWindow setTitlebarAccessoryViewControllers:]`
    pub fn setTitlebarAccessoryViewControllers(self: Self, titlebar_accessory_view_controllers: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setTitlebarAccessoryViewControllers:", .{titlebar_accessory_view_controllers});
    }

    /// `-[NSWindow representedURL]`
    pub fn representedURL(self: Self) ?foundation.Url {
        return self.object.msgSend(?foundation.Url, "representedURL", .{});
    }

    /// `-[NSWindow setRepresentedURL:]`
    pub fn setRepresentedURL(self: Self, represented_url: ?foundation.Url) void {
        return self.object.msgSend(void, "setRepresentedURL:", .{represented_url});
    }

    /// `-[NSWindow representedFilename]`
    pub fn representedFilename(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "representedFilename", .{});
    }

    /// `-[NSWindow setRepresentedFilename:]`
    pub fn setRepresentedFilename(self: Self, represented_filename: foundation.String) void {
        return self.object.msgSend(void, "setRepresentedFilename:", .{represented_filename});
    }

    /// `-[NSWindow isExcludedFromWindowsMenu]`
    pub fn isExcludedFromWindowsMenu(self: Self) bool {
        return self.object.msgSend(bool, "isExcludedFromWindowsMenu", .{});
    }

    /// `-[NSWindow setExcludedFromWindowsMenu:]`
    pub fn setExcludedFromWindowsMenu(self: Self, excluded_from_windows_menu: bool) void {
        return self.object.msgSend(void, "setExcludedFromWindowsMenu:", .{excluded_from_windows_menu});
    }

    /// `-[NSWindow contentView]`
    pub fn contentView(self: Self) ?View {
        return self.object.msgSend(?View, "contentView", .{});
    }

    /// `-[NSWindow setContentView:]`
    pub fn setContentView(self: Self, content_view: ?View) void {
        return self.object.msgSend(void, "setContentView:", .{content_view});
    }

    /// `-[NSWindow delegate]`
    pub fn delegate(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "delegate", .{});
    }

    /// `-[NSWindow setDelegate:]`
    pub fn setDelegate(self: Self, delegate_: ?objc.Object) void {
        return self.object.msgSend(void, "setDelegate:", .{delegate_});
    }

    /// `-[NSWindow windowNumber]`
    pub fn windowNumber(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "windowNumber", .{});
    }

    /// `-[NSWindow styleMask]`
    pub fn styleMask(self: Self) WindowStyleMask {
        return self.object.msgSend(WindowStyleMask, "styleMask", .{});
    }

    /// `-[NSWindow setStyleMask:]`
    pub fn setStyleMask(self: Self, style_mask: WindowStyleMask) void {
        return self.object.msgSend(void, "setStyleMask:", .{style_mask});
    }

    /// `-[NSWindow cascadingReferenceFrame]`
    pub fn cascadingReferenceFrame(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "cascadingReferenceFrame", .{});
    }

    /// `-[NSWindow frame]`
    pub fn frame(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "frame", .{});
    }

    /// `-[NSWindow inLiveResize]`
    pub fn inLiveResize(self: Self) bool {
        return self.object.msgSend(bool, "inLiveResize", .{});
    }

    /// `-[NSWindow resizeIncrements]`
    pub fn resizeIncrements(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "resizeIncrements", .{});
    }

    /// `-[NSWindow setResizeIncrements:]`
    pub fn setResizeIncrements(self: Self, resize_increments: cg.Size) void {
        return self.object.msgSend(void, "setResizeIncrements:", .{resize_increments});
    }

    /// `-[NSWindow aspectRatio]`
    pub fn aspectRatio(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "aspectRatio", .{});
    }

    /// `-[NSWindow setAspectRatio:]`
    pub fn setAspectRatio(self: Self, aspect_ratio: cg.Size) void {
        return self.object.msgSend(void, "setAspectRatio:", .{aspect_ratio});
    }

    /// `-[NSWindow contentResizeIncrements]`
    pub fn contentResizeIncrements(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "contentResizeIncrements", .{});
    }

    /// `-[NSWindow setContentResizeIncrements:]`
    pub fn setContentResizeIncrements(self: Self, content_resize_increments: cg.Size) void {
        return self.object.msgSend(void, "setContentResizeIncrements:", .{content_resize_increments});
    }

    /// `-[NSWindow contentAspectRatio]`
    pub fn contentAspectRatio(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "contentAspectRatio", .{});
    }

    /// `-[NSWindow setContentAspectRatio:]`
    pub fn setContentAspectRatio(self: Self, content_aspect_ratio: cg.Size) void {
        return self.object.msgSend(void, "setContentAspectRatio:", .{content_aspect_ratio});
    }

    /// `-[NSWindow viewsNeedDisplay]`
    pub fn viewsNeedDisplay(self: Self) bool {
        return self.object.msgSend(bool, "viewsNeedDisplay", .{});
    }

    /// `-[NSWindow setViewsNeedDisplay:]`
    pub fn setViewsNeedDisplay(self: Self, views_need_display: bool) void {
        return self.object.msgSend(void, "setViewsNeedDisplay:", .{views_need_display});
    }

    /// `-[NSWindow preservesContentDuringLiveResize]`
    pub fn preservesContentDuringLiveResize(self: Self) bool {
        return self.object.msgSend(bool, "preservesContentDuringLiveResize", .{});
    }

    /// `-[NSWindow setPreservesContentDuringLiveResize:]`
    pub fn setPreservesContentDuringLiveResize(self: Self, preserves_content_during_live_resize: bool) void {
        return self.object.msgSend(void, "setPreservesContentDuringLiveResize:", .{preserves_content_during_live_resize});
    }

    /// `-[NSWindow firstResponder]`
    pub fn firstResponder(self: Self) ?Responder {
        return self.object.msgSend(?Responder, "firstResponder", .{});
    }

    /// `-[NSWindow resizeFlags]`
    pub fn resizeFlags(self: Self) EventModifierFlags {
        return self.object.msgSend(EventModifierFlags, "resizeFlags", .{});
    }

    /// `-[NSWindow isReleasedWhenClosed]`
    pub fn isReleasedWhenClosed(self: Self) bool {
        return self.object.msgSend(bool, "isReleasedWhenClosed", .{});
    }

    /// `-[NSWindow setReleasedWhenClosed:]`
    pub fn setReleasedWhenClosed(self: Self, released_when_closed: bool) void {
        return self.object.msgSend(void, "setReleasedWhenClosed:", .{released_when_closed});
    }

    /// `-[NSWindow isZoomed]`
    pub fn isZoomed(self: Self) bool {
        return self.object.msgSend(bool, "isZoomed", .{});
    }

    /// `-[NSWindow isMiniaturized]`
    pub fn isMiniaturized(self: Self) bool {
        return self.object.msgSend(bool, "isMiniaturized", .{});
    }

    /// `-[NSWindow backgroundColor]`
    pub fn backgroundColor(self: Self) Color {
        return self.object.msgSend(Color, "backgroundColor", .{});
    }

    /// `-[NSWindow setBackgroundColor:]`
    pub fn setBackgroundColor(self: Self, background_color: ?Color) void {
        return self.object.msgSend(void, "setBackgroundColor:", .{background_color});
    }

    /// `-[NSWindow isMovable]`
    pub fn isMovable(self: Self) bool {
        return self.object.msgSend(bool, "isMovable", .{});
    }

    /// `-[NSWindow setMovable:]`
    pub fn setMovable(self: Self, movable: bool) void {
        return self.object.msgSend(void, "setMovable:", .{movable});
    }

    /// `-[NSWindow isMovableByWindowBackground]`
    pub fn isMovableByWindowBackground(self: Self) bool {
        return self.object.msgSend(bool, "isMovableByWindowBackground", .{});
    }

    /// `-[NSWindow setMovableByWindowBackground:]`
    pub fn setMovableByWindowBackground(self: Self, movable_by_window_background: bool) void {
        return self.object.msgSend(void, "setMovableByWindowBackground:", .{movable_by_window_background});
    }

    /// `-[NSWindow hidesOnDeactivate]`
    pub fn hidesOnDeactivate(self: Self) bool {
        return self.object.msgSend(bool, "hidesOnDeactivate", .{});
    }

    /// `-[NSWindow setHidesOnDeactivate:]`
    pub fn setHidesOnDeactivate(self: Self, hides_on_deactivate: bool) void {
        return self.object.msgSend(void, "setHidesOnDeactivate:", .{hides_on_deactivate});
    }

    /// `-[NSWindow canHide]`
    pub fn canHide(self: Self) bool {
        return self.object.msgSend(bool, "canHide", .{});
    }

    /// `-[NSWindow setCanHide:]`
    pub fn setCanHide(self: Self, can_hide: bool) void {
        return self.object.msgSend(void, "setCanHide:", .{can_hide});
    }

    /// `-[NSWindow miniwindowImage]`
    pub fn miniwindowImage(self: Self) ?Image {
        return self.object.msgSend(?Image, "miniwindowImage", .{});
    }

    /// `-[NSWindow setMiniwindowImage:]`
    pub fn setMiniwindowImage(self: Self, miniwindow_image: ?Image) void {
        return self.object.msgSend(void, "setMiniwindowImage:", .{miniwindow_image});
    }

    /// `-[NSWindow miniwindowTitle]`
    pub fn miniwindowTitle(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "miniwindowTitle", .{});
    }

    /// `-[NSWindow setMiniwindowTitle:]`
    pub fn setMiniwindowTitle(self: Self, miniwindow_title: ?foundation.String) void {
        return self.object.msgSend(void, "setMiniwindowTitle:", .{miniwindow_title});
    }

    /// `-[NSWindow dockTile]`
    pub fn dockTile(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "dockTile", .{});
    }

    /// `-[NSWindow isDocumentEdited]`
    pub fn isDocumentEdited(self: Self) bool {
        return self.object.msgSend(bool, "isDocumentEdited", .{});
    }

    /// `-[NSWindow setDocumentEdited:]`
    pub fn setDocumentEdited(self: Self, document_edited: bool) void {
        return self.object.msgSend(void, "setDocumentEdited:", .{document_edited});
    }

    /// `-[NSWindow isVisible]`
    pub fn isVisible(self: Self) bool {
        return self.object.msgSend(bool, "isVisible", .{});
    }

    /// `-[NSWindow isKeyWindow]`
    pub fn isKeyWindow(self: Self) bool {
        return self.object.msgSend(bool, "isKeyWindow", .{});
    }

    /// `-[NSWindow isMainWindow]`
    pub fn isMainWindow(self: Self) bool {
        return self.object.msgSend(bool, "isMainWindow", .{});
    }

    /// `-[NSWindow canBecomeKeyWindow]`
    pub fn canBecomeKeyWindow(self: Self) bool {
        return self.object.msgSend(bool, "canBecomeKeyWindow", .{});
    }

    /// `-[NSWindow canBecomeMainWindow]`
    pub fn canBecomeMainWindow(self: Self) bool {
        return self.object.msgSend(bool, "canBecomeMainWindow", .{});
    }

    /// `-[NSWindow worksWhenModal]`
    pub fn worksWhenModal(self: Self) bool {
        return self.object.msgSend(bool, "worksWhenModal", .{});
    }

    /// `-[NSWindow preventsApplicationTerminationWhenModal]`
    pub fn preventsApplicationTerminationWhenModal(self: Self) bool {
        return self.object.msgSend(bool, "preventsApplicationTerminationWhenModal", .{});
    }

    /// `-[NSWindow setPreventsApplicationTerminationWhenModal:]`
    pub fn setPreventsApplicationTerminationWhenModal(self: Self, prevents_application_termination_when_modal: bool) void {
        return self.object.msgSend(void, "setPreventsApplicationTerminationWhenModal:", .{prevents_application_termination_when_modal});
    }

    /// `-[NSWindow backingScaleFactor]`
    pub fn backingScaleFactor(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "backingScaleFactor", .{});
    }

    /// `-[NSWindow allowsToolTipsWhenApplicationIsInactive]`
    pub fn allowsToolTipsWhenApplicationIsInactive(self: Self) bool {
        return self.object.msgSend(bool, "allowsToolTipsWhenApplicationIsInactive", .{});
    }

    /// `-[NSWindow setAllowsToolTipsWhenApplicationIsInactive:]`
    pub fn setAllowsToolTipsWhenApplicationIsInactive(self: Self, allows_tool_tips_when_application_is_inactive: bool) void {
        return self.object.msgSend(void, "setAllowsToolTipsWhenApplicationIsInactive:", .{allows_tool_tips_when_application_is_inactive});
    }

    /// `-[NSWindow backingType]`
    pub fn backingType(self: Self) BackingStoreType {
        return self.object.msgSend(BackingStoreType, "backingType", .{});
    }

    /// `-[NSWindow setBackingType:]`
    pub fn setBackingType(self: Self, backing_type: BackingStoreType) void {
        return self.object.msgSend(void, "setBackingType:", .{backing_type});
    }

    /// `-[NSWindow level]`
    pub fn level(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "level", .{});
    }

    /// `-[NSWindow setLevel:]`
    pub fn setLevel(self: Self, level_: objc.Integer) void {
        return self.object.msgSend(void, "setLevel:", .{level_});
    }

    /// `-[NSWindow depthLimit]`
    pub fn depthLimit(self: Self) WindowDepth {
        return self.object.msgSend(WindowDepth, "depthLimit", .{});
    }

    /// `-[NSWindow setDepthLimit:]`
    pub fn setDepthLimit(self: Self, depth_limit: WindowDepth) void {
        return self.object.msgSend(void, "setDepthLimit:", .{depth_limit});
    }

    /// `-[NSWindow hasDynamicDepthLimit]`
    pub fn hasDynamicDepthLimit(self: Self) bool {
        return self.object.msgSend(bool, "hasDynamicDepthLimit", .{});
    }

    /// `-[NSWindow screen]`
    pub fn screen(self: Self) ?Screen {
        return self.object.msgSend(?Screen, "screen", .{});
    }

    /// `-[NSWindow deepestScreen]`
    pub fn deepestScreen(self: Self) ?Screen {
        return self.object.msgSend(?Screen, "deepestScreen", .{});
    }

    /// `-[NSWindow hasShadow]`
    pub fn hasShadow(self: Self) bool {
        return self.object.msgSend(bool, "hasShadow", .{});
    }

    /// `-[NSWindow setHasShadow:]`
    pub fn setHasShadow(self: Self, has_shadow: bool) void {
        return self.object.msgSend(void, "setHasShadow:", .{has_shadow});
    }

    /// `-[NSWindow alphaValue]`
    pub fn alphaValue(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "alphaValue", .{});
    }

    /// `-[NSWindow setAlphaValue:]`
    pub fn setAlphaValue(self: Self, alpha_value: cg.Float) void {
        return self.object.msgSend(void, "setAlphaValue:", .{alpha_value});
    }

    /// `-[NSWindow isOpaque]`
    pub fn isOpaque(self: Self) bool {
        return self.object.msgSend(bool, "isOpaque", .{});
    }

    /// `-[NSWindow setOpaque:]`
    pub fn setOpaque(self: Self, @"opaque": bool) void {
        return self.object.msgSend(void, "setOpaque:", .{@"opaque"});
    }

    /// `-[NSWindow sharingType]`
    pub fn sharingType(self: Self) WindowSharingType {
        return self.object.msgSend(WindowSharingType, "sharingType", .{});
    }

    /// `-[NSWindow setSharingType:]`
    pub fn setSharingType(self: Self, sharing_type: WindowSharingType) void {
        return self.object.msgSend(void, "setSharingType:", .{sharing_type});
    }

    /// `-[NSWindow allowsConcurrentViewDrawing]`
    pub fn allowsConcurrentViewDrawing(self: Self) bool {
        return self.object.msgSend(bool, "allowsConcurrentViewDrawing", .{});
    }

    /// `-[NSWindow setAllowsConcurrentViewDrawing:]`
    pub fn setAllowsConcurrentViewDrawing(self: Self, allows_concurrent_view_drawing: bool) void {
        return self.object.msgSend(void, "setAllowsConcurrentViewDrawing:", .{allows_concurrent_view_drawing});
    }

    /// `-[NSWindow displaysWhenScreenProfileChanges]`
    pub fn displaysWhenScreenProfileChanges(self: Self) bool {
        return self.object.msgSend(bool, "displaysWhenScreenProfileChanges", .{});
    }

    /// `-[NSWindow setDisplaysWhenScreenProfileChanges:]`
    pub fn setDisplaysWhenScreenProfileChanges(self: Self, displays_when_screen_profile_changes: bool) void {
        return self.object.msgSend(void, "setDisplaysWhenScreenProfileChanges:", .{displays_when_screen_profile_changes});
    }

    /// `-[NSWindow canBecomeVisibleWithoutLogin]`
    pub fn canBecomeVisibleWithoutLogin(self: Self) bool {
        return self.object.msgSend(bool, "canBecomeVisibleWithoutLogin", .{});
    }

    /// `-[NSWindow setCanBecomeVisibleWithoutLogin:]`
    pub fn setCanBecomeVisibleWithoutLogin(self: Self, can_become_visible_without_login: bool) void {
        return self.object.msgSend(void, "setCanBecomeVisibleWithoutLogin:", .{can_become_visible_without_login});
    }

    /// `-[NSWindow collectionBehavior]`
    pub fn collectionBehavior(self: Self) WindowCollectionBehavior {
        return self.object.msgSend(WindowCollectionBehavior, "collectionBehavior", .{});
    }

    /// `-[NSWindow setCollectionBehavior:]`
    pub fn setCollectionBehavior(self: Self, collection_behavior: WindowCollectionBehavior) void {
        return self.object.msgSend(void, "setCollectionBehavior:", .{collection_behavior});
    }

    /// `-[NSWindow animationBehavior]`
    pub fn animationBehavior(self: Self) WindowAnimationBehavior {
        return self.object.msgSend(WindowAnimationBehavior, "animationBehavior", .{});
    }

    /// `-[NSWindow setAnimationBehavior:]`
    pub fn setAnimationBehavior(self: Self, animation_behavior: WindowAnimationBehavior) void {
        return self.object.msgSend(void, "setAnimationBehavior:", .{animation_behavior});
    }

    /// `-[NSWindow isOnActiveSpace]`
    pub fn isOnActiveSpace(self: Self) bool {
        return self.object.msgSend(bool, "isOnActiveSpace", .{});
    }

    /// `-[NSWindow stringWithSavedFrame]`
    pub fn stringWithSavedFrame(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "stringWithSavedFrame", .{});
    }

    /// `-[NSWindow frameAutosaveName]`
    pub fn frameAutosaveName(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "frameAutosaveName", .{});
    }

    /// `-[NSWindow minSize]`
    pub fn minSize(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "minSize", .{});
    }

    /// `-[NSWindow setMinSize:]`
    pub fn setMinSize(self: Self, min_size: cg.Size) void {
        return self.object.msgSend(void, "setMinSize:", .{min_size});
    }

    /// `-[NSWindow maxSize]`
    pub fn maxSize(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "maxSize", .{});
    }

    /// `-[NSWindow setMaxSize:]`
    pub fn setMaxSize(self: Self, max_size: cg.Size) void {
        return self.object.msgSend(void, "setMaxSize:", .{max_size});
    }

    /// `-[NSWindow contentMinSize]`
    pub fn contentMinSize(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "contentMinSize", .{});
    }

    /// `-[NSWindow setContentMinSize:]`
    pub fn setContentMinSize(self: Self, content_min_size: cg.Size) void {
        return self.object.msgSend(void, "setContentMinSize:", .{content_min_size});
    }

    /// `-[NSWindow contentMaxSize]`
    pub fn contentMaxSize(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "contentMaxSize", .{});
    }

    /// `-[NSWindow setContentMaxSize:]`
    pub fn setContentMaxSize(self: Self, content_max_size: cg.Size) void {
        return self.object.msgSend(void, "setContentMaxSize:", .{content_max_size});
    }

    /// `-[NSWindow minFullScreenContentSize]`
    pub fn minFullScreenContentSize(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "minFullScreenContentSize", .{});
    }

    /// `-[NSWindow setMinFullScreenContentSize:]`
    pub fn setMinFullScreenContentSize(self: Self, min_full_screen_content_size: cg.Size) void {
        return self.object.msgSend(void, "setMinFullScreenContentSize:", .{min_full_screen_content_size});
    }

    /// `-[NSWindow maxFullScreenContentSize]`
    pub fn maxFullScreenContentSize(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "maxFullScreenContentSize", .{});
    }

    /// `-[NSWindow setMaxFullScreenContentSize:]`
    pub fn setMaxFullScreenContentSize(self: Self, max_full_screen_content_size: cg.Size) void {
        return self.object.msgSend(void, "setMaxFullScreenContentSize:", .{max_full_screen_content_size});
    }

    /// `-[NSWindow deviceDescription]`
    pub fn deviceDescription(self: Self) foundation.Dictionary(objc.Object, objc.Object) {
        return self.object.msgSend(foundation.Dictionary(objc.Object, objc.Object), "deviceDescription", .{});
    }

    /// `-[NSWindow windowController]`
    pub fn windowController(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "windowController", .{});
    }

    /// `-[NSWindow setWindowController:]`
    pub fn setWindowController(self: Self, window_controller: ?objc.Object) void {
        return self.object.msgSend(void, "setWindowController:", .{window_controller});
    }

    /// `-[NSWindow sheets]`
    pub fn sheets(self: Self) ?foundation.Array(Window) {
        return self.object.msgSend(?foundation.Array(Window), "sheets", .{});
    }

    /// `-[NSWindow attachedSheet]`
    pub fn attachedSheet(self: Self) ?Window {
        return self.object.msgSend(?Window, "attachedSheet", .{});
    }

    /// `-[NSWindow isSheet]`
    pub fn isSheet(self: Self) bool {
        return self.object.msgSend(bool, "isSheet", .{});
    }

    /// `-[NSWindow sheetParent]`
    pub fn sheetParent(self: Self) ?Window {
        return self.object.msgSend(?Window, "sheetParent", .{});
    }

    /// `-[NSWindow childWindows]`
    pub fn childWindows(self: Self) ?foundation.Array(Window) {
        return self.object.msgSend(?foundation.Array(Window), "childWindows", .{});
    }

    /// `-[NSWindow parentWindow]`
    pub fn parentWindow(self: Self) ?Window {
        return self.object.msgSend(?Window, "parentWindow", .{});
    }

    /// `-[NSWindow setParentWindow:]`
    pub fn setParentWindow(self: Self, parent_window: ?Window) void {
        return self.object.msgSend(void, "setParentWindow:", .{parent_window});
    }

    /// `-[NSWindow appearanceSource]`
    pub fn appearanceSource(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "appearanceSource", .{});
    }

    /// `-[NSWindow setAppearanceSource:]`
    pub fn setAppearanceSource(self: Self, appearance_source: ?objc.Object) void {
        return self.object.msgSend(void, "setAppearanceSource:", .{appearance_source});
    }

    /// `-[NSWindow colorSpace]`
    pub fn colorSpace(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "colorSpace", .{});
    }

    /// `-[NSWindow setColorSpace:]`
    pub fn setColorSpace(self: Self, color_space: ?objc.Object) void {
        return self.object.msgSend(void, "setColorSpace:", .{color_space});
    }

    /// `-[NSWindow occlusionState]`
    pub fn occlusionState(self: Self) WindowOcclusionState {
        return self.object.msgSend(WindowOcclusionState, "occlusionState", .{});
    }

    /// `-[NSWindow titlebarSeparatorStyle]`
    pub fn titlebarSeparatorStyle(self: Self) TitlebarSeparatorStyle {
        return self.object.msgSend(TitlebarSeparatorStyle, "titlebarSeparatorStyle", .{});
    }

    /// `-[NSWindow setTitlebarSeparatorStyle:]`
    pub fn setTitlebarSeparatorStyle(self: Self, titlebar_separator_style: TitlebarSeparatorStyle) void {
        return self.object.msgSend(void, "setTitlebarSeparatorStyle:", .{titlebar_separator_style});
    }

    /// `-[NSWindow contentViewController]`
    pub fn contentViewController(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "contentViewController", .{});
    }

    /// `-[NSWindow setContentViewController:]`
    pub fn setContentViewController(self: Self, content_view_controller: ?objc.Object) void {
        return self.object.msgSend(void, "setContentViewController:", .{content_view_controller});
    }

    /// `-[NSWindow initialFirstResponder]`
    pub fn initialFirstResponder(self: Self) ?View {
        return self.object.msgSend(?View, "initialFirstResponder", .{});
    }

    /// `-[NSWindow setInitialFirstResponder:]`
    pub fn setInitialFirstResponder(self: Self, initial_first_responder: ?View) void {
        return self.object.msgSend(void, "setInitialFirstResponder:", .{initial_first_responder});
    }

    /// `-[NSWindow keyViewSelectionDirection]`
    pub fn keyViewSelectionDirection(self: Self) SelectionDirection {
        return self.object.msgSend(SelectionDirection, "keyViewSelectionDirection", .{});
    }

    /// `-[NSWindow defaultButtonCell]`
    pub fn defaultButtonCell(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "defaultButtonCell", .{});
    }

    /// `-[NSWindow setDefaultButtonCell:]`
    pub fn setDefaultButtonCell(self: Self, default_button_cell: ?objc.Object) void {
        return self.object.msgSend(void, "setDefaultButtonCell:", .{default_button_cell});
    }

    /// `-[NSWindow autorecalculatesKeyViewLoop]`
    pub fn autorecalculatesKeyViewLoop(self: Self) bool {
        return self.object.msgSend(bool, "autorecalculatesKeyViewLoop", .{});
    }

    /// `-[NSWindow setAutorecalculatesKeyViewLoop:]`
    pub fn setAutorecalculatesKeyViewLoop(self: Self, autorecalculates_key_view_loop: bool) void {
        return self.object.msgSend(void, "setAutorecalculatesKeyViewLoop:", .{autorecalculates_key_view_loop});
    }

    /// `-[NSWindow toolbar]`
    pub fn toolbar(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "toolbar", .{});
    }

    /// `-[NSWindow setToolbar:]`
    pub fn setToolbar(self: Self, toolbar_: ?objc.Object) void {
        return self.object.msgSend(void, "setToolbar:", .{toolbar_});
    }

    /// `-[NSWindow showsToolbarButton]`
    pub fn showsToolbarButton(self: Self) bool {
        return self.object.msgSend(bool, "showsToolbarButton", .{});
    }

    /// `-[NSWindow setShowsToolbarButton:]`
    pub fn setShowsToolbarButton(self: Self, shows_toolbar_button: bool) void {
        return self.object.msgSend(void, "setShowsToolbarButton:", .{shows_toolbar_button});
    }

    /// `+[NSWindow allowsAutomaticWindowTabbing]`
    pub fn allowsAutomaticWindowTabbing() bool {
        return class().msgSend(bool, "allowsAutomaticWindowTabbing", .{});
    }

    /// `+[NSWindow setAllowsAutomaticWindowTabbing:]`
    pub fn setAllowsAutomaticWindowTabbing(allows_automatic_window_tabbing: bool) void {
        return class().msgSend(void, "setAllowsAutomaticWindowTabbing:", .{allows_automatic_window_tabbing});
    }

    /// `+[NSWindow userTabbingPreference]`
    pub fn userTabbingPreference() WindowUserTabbingPreference {
        return class().msgSend(WindowUserTabbingPreference, "userTabbingPreference", .{});
    }

    /// `-[NSWindow tabbingMode]`
    pub fn tabbingMode(self: Self) WindowTabbingMode {
        return self.object.msgSend(WindowTabbingMode, "tabbingMode", .{});
    }

    /// `-[NSWindow setTabbingMode:]`
    pub fn setTabbingMode(self: Self, tabbing_mode: WindowTabbingMode) void {
        return self.object.msgSend(void, "setTabbingMode:", .{tabbing_mode});
    }

    /// `-[NSWindow tabbingIdentifier]`
    pub fn tabbingIdentifier(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "tabbingIdentifier", .{});
    }

    /// `-[NSWindow setTabbingIdentifier:]`
    pub fn setTabbingIdentifier(self: Self, tabbing_identifier: ?foundation.String) void {
        return self.object.msgSend(void, "setTabbingIdentifier:", .{tabbing_identifier});
    }

    /// `-[NSWindow tabbedWindows]`
    pub fn tabbedWindows(self: Self) ?foundation.Array(Window) {
        return self.object.msgSend(?foundation.Array(Window), "tabbedWindows", .{});
    }

    /// `-[NSWindow tab]`
    pub fn tab(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "tab", .{});
    }

    /// `-[NSWindow tabGroup]`
    pub fn tabGroup(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "tabGroup", .{});
    }

    /// `-[NSWindow hasActiveWindowSharingSession]`
    pub fn hasActiveWindowSharingSession(self: Self) bool {
        return self.object.msgSend(bool, "hasActiveWindowSharingSession", .{});
    }

    /// `-[NSWindow windowTitlebarLayoutDirection]`
    pub fn windowTitlebarLayoutDirection(self: Self) UserInterfaceLayoutDirection {
        return self.object.msgSend(UserInterfaceLayoutDirection, "windowTitlebarLayoutDirection", .{});
    }

    /// `-[NSWindow trackEventsMatchingMask:timeout:mode:handler:]`
    pub fn trackEventsMatchingMaskTimeoutModeHandler(self: Self, mask: EventMask, timeout: f64, mode: ?foundation.String, tracking_handler: anytype) void {
        return self.object.msgSend(void, "trackEventsMatchingMask:timeout:mode:handler:", .{ mask, timeout, mode, tracking_handler });
    }

    /// `-[NSWindow nextEventMatchingMask:]`
    pub fn nextEventMatchingMask(self: Self, mask: EventMask) ?Event {
        return self.object.msgSend(?Event, "nextEventMatchingMask:", .{mask});
    }

    /// `-[NSWindow nextEventMatchingMask:untilDate:inMode:dequeue:]`
    pub fn nextEventMatchingMaskUntilDateInModeDequeue(self: Self, mask: EventMask, expiration: ?objc.Object, mode: ?foundation.String, deq_flag: bool) ?Event {
        return self.object.msgSend(?Event, "nextEventMatchingMask:untilDate:inMode:dequeue:", .{ mask, expiration, mode, deq_flag });
    }

    /// `-[NSWindow discardEventsMatchingMask:beforeEvent:]`
    pub fn discardEventsMatchingMaskBeforeEvent(self: Self, mask: EventMask, last_event: ?Event) void {
        return self.object.msgSend(void, "discardEventsMatchingMask:beforeEvent:", .{ mask, last_event });
    }

    /// `-[NSWindow postEvent:atStart:]`
    pub fn postEventAtStart(self: Self, event: Event, flag: bool) void {
        return self.object.msgSend(void, "postEvent:atStart:", .{ event, flag });
    }

    /// `-[NSWindow sendEvent:]`
    pub fn sendEvent(self: Self, event: Event) void {
        return self.object.msgSend(void, "sendEvent:", .{event});
    }

    /// `-[NSWindow currentEvent]`
    pub fn currentEvent(self: Self) ?Event {
        return self.object.msgSend(?Event, "currentEvent", .{});
    }

    /// `-[NSWindow acceptsMouseMovedEvents]`
    pub fn acceptsMouseMovedEvents(self: Self) bool {
        return self.object.msgSend(bool, "acceptsMouseMovedEvents", .{});
    }

    /// `-[NSWindow setAcceptsMouseMovedEvents:]`
    pub fn setAcceptsMouseMovedEvents(self: Self, accepts_mouse_moved_events: bool) void {
        return self.object.msgSend(void, "setAcceptsMouseMovedEvents:", .{accepts_mouse_moved_events});
    }

    /// `-[NSWindow ignoresMouseEvents]`
    pub fn ignoresMouseEvents(self: Self) bool {
        return self.object.msgSend(bool, "ignoresMouseEvents", .{});
    }

    /// `-[NSWindow setIgnoresMouseEvents:]`
    pub fn setIgnoresMouseEvents(self: Self, ignores_mouse_events: bool) void {
        return self.object.msgSend(void, "setIgnoresMouseEvents:", .{ignores_mouse_events});
    }

    /// `-[NSWindow mouseLocationOutsideOfEventStream]`
    pub fn mouseLocationOutsideOfEventStream(self: Self) cg.Point {
        return self.object.msgSend(cg.Point, "mouseLocationOutsideOfEventStream", .{});
    }

    /// `-[NSWindow disableCursorRects]`
    pub fn disableCursorRects(self: Self) void {
        return self.object.msgSend(void, "disableCursorRects", .{});
    }

    /// `-[NSWindow enableCursorRects]`
    pub fn enableCursorRects(self: Self) void {
        return self.object.msgSend(void, "enableCursorRects", .{});
    }

    /// `-[NSWindow discardCursorRects]`
    pub fn discardCursorRects(self: Self) void {
        return self.object.msgSend(void, "discardCursorRects", .{});
    }

    /// `-[NSWindow invalidateCursorRectsForView:]`
    pub fn invalidateCursorRectsForView(self: Self, view: View) void {
        return self.object.msgSend(void, "invalidateCursorRectsForView:", .{view});
    }

    /// `-[NSWindow resetCursorRects]`
    pub fn resetCursorRects(self: Self) void {
        return self.object.msgSend(void, "resetCursorRects", .{});
    }

    /// `-[NSWindow areCursorRectsEnabled]`
    pub fn areCursorRectsEnabled(self: Self) bool {
        return self.object.msgSend(bool, "areCursorRectsEnabled", .{});
    }
};

/// `NSView`, a subclass of `NSResponder`.
pub const View = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = Responder;
    pub const class_name = "NSView";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSView`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSView initWithFrame:]`
    pub fn initWithFrame(self: Self, frame_rect: cg.Rect) View {
        return self.object.msgSend(View, "initWithFrame:", .{frame_rect});
    }

    /// `-[NSView initWithCoder:]`
    pub fn initWithCoder(self: Self, coder: objc.Object) ?View {
        return self.object.msgSend(?View, "initWithCoder:", .{coder});
    }

    /// `-[NSView isDescendantOf:]`
    pub fn isDescendantOf(self: Self, view: View) bool {
        return self.object.msgSend(bool, "isDescendantOf:", .{view});
    }

    /// `-[NSView ancestorSharedWithView:]`
    pub fn ancestorSharedWithView(self: Self, view: View) ?View {
        return self.object.msgSend(?View, "ancestorSharedWithView:", .{view});
    }

    /// `-[NSView getRectsBeingDrawn:count:]`
    pub fn getRectsBeingDrawnCount(self: Self, rects: ?*objc.abi.Id, count: ?*objc.Integer) void {
        return self.object.msgSend(void, "getRectsBeingDrawn:count:", .{ rects, count });
    }

    /// `-[NSView needsToDrawRect:]`
    pub fn needsToDrawRect(self: Self, rect: cg.Rect) bool {
        return self.object.msgSend(bool, "needsToDrawRect:", .{rect});
    }

    /// `-[NSView viewDidHide]`
    pub fn viewDidHide(self: Self) void {
        return self.object.msgSend(void, "viewDidHide", .{});
    }

    /// `-[NSView viewDidUnhide]`
    pub fn viewDidUnhide(self: Self) void {
        return self.object.msgSend(void, "viewDidUnhide", .{});
    }

    /// `-[NSView addSubview:]`
    pub fn addSubview(self: Self, view: View) void {
        return self.object.msgSend(void, "addSubview:", .{view});
    }

    /// `-[NSView addSubview:positioned:relativeTo:]`
    pub fn addSubviewPositionedRelativeTo(self: Self, view: View, place: WindowOrderingMode, other_view: ?View) void {
        return self.object.msgSend(void, "addSubview:positioned:relativeTo:", .{ view, place, other_view });
    }

    /// `-[NSView viewWillMoveToWindow:]`
    pub fn viewWillMoveToWindow(self: Self, new_window: ?Window) void {
        return self.object.msgSend(void, "viewWillMoveToWindow:", .{new_window});
    }

    /// `-[NSView viewDidMoveToWindow]`
    pub fn viewDidMoveToWindow(self: Self) void {
        return self.object.msgSend(void, "viewDidMoveToWindow", .{});
    }

    /// `-[NSView viewWillMoveToSuperview:]`
    pub fn viewWillMoveToSuperview(self: Self, new_superview: ?View) void {
        return self.object.msgSend(void, "viewWillMoveToSuperview:", .{new_superview});
    }

    /// `-[NSView viewDidMoveToSuperview]`
    pub fn viewDidMoveToSuperview(self: Self) void {
        return self.object.msgSend(void, "viewDidMoveToSuperview", .{});
    }

    /// `-[NSView didAddSubview:]`
    pub fn didAddSubview(self: Self, subview: View) void {
        return self.object.msgSend(void, "didAddSubview:", .{subview});
    }

    /// `-[NSView willRemoveSubview:]`
    pub fn willRemoveSubview(self: Self, subview: View) void {
        return self.object.msgSend(void, "willRemoveSubview:", .{subview});
    }

    /// `-[NSView removeFromSuperview]`
    pub fn removeFromSuperview(self: Self) void {
        return self.object.msgSend(void, "removeFromSuperview", .{});
    }

    /// `-[NSView replaceSubview:with:]`
    pub fn replaceSubviewWith(self: Self, old_view: View, new_view: View) void {
        return self.object.msgSend(void, "replaceSubview:with:", .{ old_view, new_view });
    }

    /// `-[NSView removeFromSuperviewWithoutNeedingDisplay]`
    pub fn removeFromSuperviewWithoutNeedingDisplay(self: Self) void {
        return self.object.msgSend(void, "removeFromSuperviewWithoutNeedingDisplay", .{});
    }

    /// `-[NSView viewDidChangeBackingProperties]`
    pub fn viewDidChangeBackingProperties(self: Self) void {
        return self.object.msgSend(void, "viewDidChangeBackingProperties", .{});
    }

    /// `-[NSView resizeSubviewsWithOldSize:]`
    pub fn resizeSubviewsWithOldSize(self: Self, old_size: cg.Size) void {
        return self.object.msgSend(void, "resizeSubviewsWithOldSize:", .{old_size});
    }

    /// `-[NSView resizeWithOldSuperviewSize:]`
    pub fn resizeWithOldSuperviewSize(self: Self, old_size: cg.Size) void {
        return self.object.msgSend(void, "resizeWithOldSuperviewSize:", .{old_size});
    }

    /// `-[NSView setFrameOrigin:]`
    pub fn setFrameOrigin(self: Self, new_origin: cg.Point) void {
        return self.object.msgSend(void, "setFrameOrigin:", .{new_origin});
    }

    /// `-[NSView setFrameSize:]`
    pub fn setFrameSize(self: Self, new_size: cg.Size) void {
        return self.object.msgSend(void, "setFrameSize:", .{new_size});
    }

    /// `-[NSView setBoundsOrigin:]`
    pub fn setBoundsOrigin(self: Self, new_origin: cg.Point) void {
        return self.object.msgSend(void, "setBoundsOrigin:", .{new_origin});
    }

    /// `-[NSView setBoundsSize:]`
    pub fn setBoundsSize(self: Self, new_size: cg.Size) void {
        return self.object.msgSend(void, "setBoundsSize:", .{new_size});
    }

    /// `-[NSView translateOriginToPoint:]`
    pub fn translateOriginToPoint(self: Self, translation: cg.Point) void {
        return self.object.msgSend(void, "translateOriginToPoint:", .{translation});
    }

    /// `-[NSView scaleUnitSquareToSize:]`
    pub fn scaleUnitSquareToSize(self: Self, new_unit_size: cg.Size) void {
        return self.object.msgSend(void, "scaleUnitSquareToSize:", .{new_unit_size});
    }

    /// `-[NSView rotateByAngle:]`
    pub fn rotateByAngle(self: Self, angle: cg.Float) void {
        return self.object.msgSend(void, "rotateByAngle:", .{angle});
    }

    /// `-[NSView convertPoint:fromView:]`
    pub fn convertPointFromView(self: Self, point: cg.Point, view: ?View) cg.Point {
        return self.object.msgSend(cg.Point, "convertPoint:fromView:", .{ point, view });
    }

    /// `-[NSView convertPoint:toView:]`
    pub fn convertPointToView(self: Self, point: cg.Point, view: ?View) cg.Point {
        return self.object.msgSend(cg.Point, "convertPoint:toView:", .{ point, view });
    }

    /// `-[NSView convertSize:fromView:]`
    pub fn convertSizeFromView(self: Self, size: cg.Size, view: ?View) cg.Size {
        return self.object.msgSend(cg.Size, "convertSize:fromView:", .{ size, view });
    }

    /// `-[NSView convertSize:toView:]`
    pub fn convertSizeToView(self: Self, size: cg.Size, view: ?View) cg.Size {
        return self.object.msgSend(cg.Size, "convertSize:toView:", .{ size, view });
    }

    /// `-[NSView convertRect:fromView:]`
    pub fn convertRectFromView(self: Self, rect: cg.Rect, view: ?View) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRect:fromView:", .{ rect, view });
    }

    /// `-[NSView convertRect:toView:]`
    pub fn convertRectToView(self: Self, rect: cg.Rect, view: ?View) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRect:toView:", .{ rect, view });
    }

    /// `-[NSView backingAlignedRect:options:]`
    pub fn backingAlignedRectOptions(self: Self, rect: cg.Rect, options: AlignmentOptions) cg.Rect {
        return self.object.msgSend(cg.Rect, "backingAlignedRect:options:", .{ rect, options });
    }

    /// `-[NSView centerScanRect:]`
    pub fn centerScanRect(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "centerScanRect:", .{rect});
    }

    /// `-[NSView convertPointToBacking:]`
    pub fn convertPointToBacking(self: Self, point: cg.Point) cg.Point {
        return self.object.msgSend(cg.Point, "convertPointToBacking:", .{point});
    }

    /// `-[NSView convertPointFromBacking:]`
    pub fn convertPointFromBacking(self: Self, point: cg.Point) cg.Point {
        return self.object.msgSend(cg.Point, "convertPointFromBacking:", .{point});
    }

    /// `-[NSView convertSizeToBacking:]`
    pub fn convertSizeToBacking(self: Self, size: cg.Size) cg.Size {
        return self.object.msgSend(cg.Size, "convertSizeToBacking:", .{size});
    }

    /// `-[NSView convertSizeFromBacking:]`
    pub fn convertSizeFromBacking(self: Self, size: cg.Size) cg.Size {
        return self.object.msgSend(cg.Size, "convertSizeFromBacking:", .{size});
    }

    /// `-[NSView convertRectToBacking:]`
    pub fn convertRectToBacking(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectToBacking:", .{rect});
    }

    /// `-[NSView convertRectFromBacking:]`
    pub fn convertRectFromBacking(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectFromBacking:", .{rect});
    }

    /// `-[NSView convertPointToLayer:]`
    pub fn convertPointToLayer(self: Self, point: cg.Point) cg.Point {
        return self.object.msgSend(cg.Point, "convertPointToLayer:", .{point});
    }

    /// `-[NSView convertPointFromLayer:]`
    pub fn convertPointFromLayer(self: Self, point: cg.Point) cg.Point {
        return self.object.msgSend(cg.Point, "convertPointFromLayer:", .{point});
    }

    /// `-[NSView convertSizeToLayer:]`
    pub fn convertSizeToLayer(self: Self, size: cg.Size) cg.Size {
        return self.object.msgSend(cg.Size, "convertSizeToLayer:", .{size});
    }

    /// `-[NSView convertSizeFromLayer:]`
    pub fn convertSizeFromLayer(self: Self, size: cg.Size) cg.Size {
        return self.object.msgSend(cg.Size, "convertSizeFromLayer:", .{size});
    }

    /// `-[NSView convertRectToLayer:]`
    pub fn convertRectToLayer(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectToLayer:", .{rect});
    }

    /// `-[NSView convertRectFromLayer:]`
    pub fn convertRectFromLayer(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectFromLayer:", .{rect});
    }

    /// `-[NSView setNeedsDisplayInRect:]`
    pub fn setNeedsDisplayInRect(self: Self, invalid_rect: cg.Rect) void {
        return self.object.msgSend(void, "setNeedsDisplayInRect:", .{invalid_rect});
    }

    /// `-[NSView lockFocus]`
    pub fn lockFocus(self: Self) void {
        return self.object.msgSend(void, "lockFocus", .{});
    }

    /// `-[NSView unlockFocus]`
    pub fn unlockFocus(self: Self) void {
        return self.object.msgSend(void, "unlockFocus", .{});
    }

    /// `-[NSView lockFocusIfCanDraw]`
    pub fn lockFocusIfCanDraw(self: Self) bool {
        return self.object.msgSend(bool, "lockFocusIfCanDraw", .{});
    }

    /// `-[NSView lockFocusIfCanDrawInContext:]`
    pub fn lockFocusIfCanDrawInContext(self: Self, context: GraphicsContext) bool {
        return self.object.msgSend(bool, "lockFocusIfCanDrawInContext:", .{context});
    }

    /// `-[NSView display]`
    pub fn display(self: Self) void {
        return self.object.msgSend(void, "display", .{});
    }

    /// `-[NSView displayIfNeeded]`
    pub fn displayIfNeeded(self: Self) void {
        return self.object.msgSend(void, "displayIfNeeded", .{});
    }

    /// `-[NSView displayIfNeededIgnoringOpacity]`
    pub fn displayIfNeededIgnoringOpacity(self: Self) void {
        return self.object.msgSend(void, "displayIfNeededIgnoringOpacity", .{});
    }

    /// `-[NSView displayRect:]`
    pub fn displayRect(self: Self, rect: cg.Rect) void {
        return self.object.msgSend(void, "displayRect:", .{rect});
    }

    /// `-[NSView displayIfNeededInRect:]`
    pub fn displayIfNeededInRect(self: Self, rect: cg.Rect) void {
        return self.object.msgSend(void, "displayIfNeededInRect:", .{rect});
    }

    /// `-[NSView displayRectIgnoringOpacity:]`
    pub fn displayRectIgnoringOpacity(self: Self, rect: cg.Rect) void {
        return self.object.msgSend(void, "displayRectIgnoringOpacity:", .{rect});
    }

    /// `-[NSView displayIfNeededInRectIgnoringOpacity:]`
    pub fn displayIfNeededInRectIgnoringOpacity(self: Self, rect: cg.Rect) void {
        return self.object.msgSend(void, "displayIfNeededInRectIgnoringOpacity:", .{rect});
    }

    /// `-[NSView drawRect:]`
    pub fn drawRect(self: Self, dirty_rect: cg.Rect) void {
        return self.object.msgSend(void, "drawRect:", .{dirty_rect});
    }

    /// `-[NSView displayRectIgnoringOpacity:inContext:]`
    pub fn displayRectIgnoringOpacityInContext(self: Self, rect: cg.Rect, context: GraphicsContext) void {
        return self.object.msgSend(void, "displayRectIgnoringOpacity:inContext:", .{ rect, context });
    }

    /// `-[NSView bitmapImageRepForCachingDisplayInRect:]`
    pub fn bitmapImageRepForCachingDisplayInRect(self: Self, rect: cg.Rect) ?BitmapImageRep {
        return self.object.msgSend(?BitmapImageRep, "bitmapImageRepForCachingDisplayInRect:", .{rect});
    }

    /// `-[NSView cacheDisplayInRect:toBitmapImageRep:]`
    pub fn cacheDisplayInRectToBitmapImageRep(self: Self, rect: cg.Rect, bitmap_image_rep: BitmapImageRep) void {
        return self.object.msgSend(void, "cacheDisplayInRect:toBitmapImageRep:", .{ rect, bitmap_image_rep });
    }

    /// `-[NSView viewWillDraw]`
    pub fn viewWillDraw(self: Self) void {
        return self.object.msgSend(void, "viewWillDraw", .{});
    }

    /// `-[NSView scrollPoint:]`
    pub fn scrollPoint(self: Self, point: cg.Point) void {
        return self.object.msgSend(void, "scrollPoint:", .{point});
    }

    /// `-[NSView scrollRectToVisible:]`
    pub fn scrollRectToVisible(self: Self, rect: cg.Rect) bool {
        return self.object.msgSend(bool, "scrollRectToVisible:", .{rect});
    }

    /// `-[NSView autoscroll:]`
    pub fn autoscroll(self: Self, event: Event) bool {
        return self.object.msgSend(bool, "autoscroll:", .{event});
    }

    /// `-[NSView adjustScroll:]`
    pub fn adjustScroll(self: Self, new_visible: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "adjustScroll:", .{new_visible});
    }

    /// `-[NSView scrollRect:by:]`
    pub fn scrollRectBy(self: Self, rect: cg.Rect, delta: cg.Size) void {
        return self.object.msgSend(void, "scrollRect:by:", .{ rect, delta });
    }

    /// `-[NSView translateRectsNeedingDisplayInRect:by:]`
    pub fn translateRectsNeedingDisplayInRectBy(self: Self, clip_rect: cg.Rect, delta: cg.Size) void {
        return self.object.msgSend(void, "translateRectsNeedingDisplayInRect:by:", .{ clip_rect, delta });
    }

    /// `-[NSView hitTest:]`
    pub fn hitTest(self: Self, point: cg.Point) ?View {
        return self.object.msgSend(?View, "hitTest:", .{point});
    }

    /// `-[NSView mouse:inRect:]`
    pub fn mouseInRect(self: Self, point: cg.Point, rect: cg.Rect) bool {
        return self.object.msgSend(bool, "mouse:inRect:", .{ point, rect });
    }

    /// `-[NSView viewWithTag:]`
    pub fn viewWithTag(self: Self, tag_: objc.Integer) ?View {
        return self.object.msgSend(?View, "viewWithTag:", .{tag_});
    }

    /// `-[NSView performKeyEquivalent:]`
    pub fn performKeyEquivalent(self: Self, event: Event) bool {
        return self.object.msgSend(bool, "performKeyEquivalent:", .{event});
    }

    /// `-[NSView acceptsFirstMouse:]`
    pub fn acceptsFirstMouse(self: Self, event: ?Event) bool {
        return self.object.msgSend(bool, "acceptsFirstMouse:", .{event});
    }

    /// `-[NSView shouldDelayWindowOrderingForEvent:]`
    pub fn shouldDelayWindowOrderingForEvent(self: Self, event: Event) bool {
        return self.object.msgSend(bool, "shouldDelayWindowOrderingForEvent:", .{event});
    }

    /// `-[NSView makeBackingLayer]`
    pub fn makeBackingLayer(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "makeBackingLayer", .{});
    }

    /// `-[NSView updateLayer]`
    pub fn updateLayer(self: Self) void {
        return self.object.msgSend(void, "updateLayer", .{});
    }

    /// `-[NSView layoutSubtreeIfNeeded]`
    pub fn layoutSubtreeIfNeeded(self: Self) void {
        return self.object.msgSend(void, "layoutSubtreeIfNeeded", .{});
    }

    /// `-[NSView layout]`
    pub fn layout(self: Self) void {
        return self.object.msgSend(void, "layout", .{});
    }

    /// `-[NSView menuForEvent:]`
    pub fn menuForEvent(self: Self, event: Event) ?Menu {
        return self.object.msgSend(?Menu, "menuForEvent:", .{event});
    }

    /// `-[NSView willOpenMenu:withEvent:]`
    pub fn willOpenMenuWithEvent(self: Self, menu: Menu, event: Event) void {
        return self.object.msgSend(void, "willOpenMenu:withEvent:", .{ menu, event });
    }

    /// `-[NSView didCloseMenu:withEvent:]`
    pub fn didCloseMenuWithEvent(self: Self, menu: Menu, event: ?Event) void {
        return self.object.msgSend(void, "didCloseMenu:withEvent:", .{ menu, event });
    }

    /// `-[NSView addToolTipRect:owner:userData:]`
    pub fn addToolTipRectOwnerUserData(self: Self, rect: cg.Rect, owner: objc.Object, data: ?*anyopaque) objc.Integer {
        return self.object.msgSend(objc.Integer, "addToolTipRect:owner:userData:", .{ rect, owner, data });
    }

    /// `-[NSView removeToolTip:]`
    pub fn removeToolTip(self: Self, tag_: objc.Integer) void {
        return self.object.msgSend(void, "removeToolTip:", .{tag_});
    }

    /// `-[NSView removeAllToolTips]`
    pub fn removeAllToolTips(self: Self) void {
        return self.object.msgSend(void, "removeAllToolTips", .{});
    }

    /// `-[NSView viewWillStartLiveResize]`
    pub fn viewWillStartLiveResize(self: Self) void {
        return self.object.msgSend(void, "viewWillStartLiveResize", .{});
    }

    /// `-[NSView viewDidEndLiveResize]`
    pub fn viewDidEndLiveResize(self: Self) void {
        return self.object.msgSend(void, "viewDidEndLiveResize", .{});
    }

    /// `-[NSView getRectsExposedDuringLiveResize:count:]`
    pub fn getRectsExposedDuringLiveResizeCount(self: Self, exposed_rects: ?*cg.Rect, count: ?*objc.Integer) void {
        return self.object.msgSend(void, "getRectsExposedDuringLiveResize:count:", .{ exposed_rects, count });
    }

    /// `-[NSView rectForSmartMagnificationAtPoint:inRect:]`
    pub fn rectForSmartMagnificationAtPointInRect(self: Self, location: cg.Point, visible_rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "rectForSmartMagnificationAtPoint:inRect:", .{ location, visible_rect });
    }

    /// `-[NSView prepareForReuse]`
    pub fn prepareForReuse(self: Self) void {
        return self.object.msgSend(void, "prepareForReuse", .{});
    }

    /// `-[NSView prepareContentInRect:]`
    pub fn prepareContentInRect(self: Self, rect: cg.Rect) void {
        return self.object.msgSend(void, "prepareContentInRect:", .{rect});
    }

    /// `-[NSView viewDidChangeEffectiveAppearance]`
    pub fn viewDidChangeEffectiveAppearance(self: Self) void {
        return self.object.msgSend(void, "viewDidChangeEffectiveAppearance", .{});
    }

    /// `-[NSView window]`
    pub fn window(self: Self) ?Window {
        return self.object.msgSend(?Window, "window", .{});
    }

    /// `-[NSView superview]`
    pub fn superview(self: Self) ?View {
        return self.object.msgSend(?View, "superview", .{});
    }

    /// `-[NSView subviews]`
    pub fn subviews(self: Self) foundation.Array(View) {
        return self.object.msgSend(foundation.Array(View), "subviews", .{});
    }

    /// `-[NSView setSubviews:]`
    pub fn setSubviews(self: Self, subviews_: foundation.Array(View)) void {
        return self.object.msgSend(void, "setSubviews:", .{subviews_});
    }

    /// `-[NSView opaqueAncestor]`
    pub fn opaqueAncestor(self: Self) ?View {
        return self.object.msgSend(?View, "opaqueAncestor", .{});
    }

    /// `-[NSView isHidden]`
    pub fn isHidden(self: Self) bool {
        return self.object.msgSend(bool, "isHidden", .{});
    }

    /// `-[NSView setHidden:]`
    pub fn setHidden(self: Self, hidden: bool) void {
        return self.object.msgSend(void, "setHidden:", .{hidden});
    }

    /// `-[NSView isHiddenOrHasHiddenAncestor]`
    pub fn isHiddenOrHasHiddenAncestor(self: Self) bool {
        return self.object.msgSend(bool, "isHiddenOrHasHiddenAncestor", .{});
    }

    /// `-[NSView wantsDefaultClipping]`
    pub fn wantsDefaultClipping(self: Self) bool {
        return self.object.msgSend(bool, "wantsDefaultClipping", .{});
    }

    /// `-[NSView postsFrameChangedNotifications]`
    pub fn postsFrameChangedNotifications(self: Self) bool {
        return self.object.msgSend(bool, "postsFrameChangedNotifications", .{});
    }

    /// `-[NSView setPostsFrameChangedNotifications:]`
    pub fn setPostsFrameChangedNotifications(self: Self, posts_frame_changed_notifications: bool) void {
        return self.object.msgSend(void, "setPostsFrameChangedNotifications:", .{posts_frame_changed_notifications});
    }

    /// `-[NSView autoresizesSubviews]`
    pub fn autoresizesSubviews(self: Self) bool {
        return self.object.msgSend(bool, "autoresizesSubviews", .{});
    }

    /// `-[NSView setAutoresizesSubviews:]`
    pub fn setAutoresizesSubviews(self: Self, autoresizes_subviews: bool) void {
        return self.object.msgSend(void, "setAutoresizesSubviews:", .{autoresizes_subviews});
    }

    /// `-[NSView autoresizingMask]`
    pub fn autoresizingMask(self: Self) AutoresizingMaskOptions {
        return self.object.msgSend(AutoresizingMaskOptions, "autoresizingMask", .{});
    }

    /// `-[NSView setAutoresizingMask:]`
    pub fn setAutoresizingMask(self: Self, autoresizing_mask: AutoresizingMaskOptions) void {
        return self.object.msgSend(void, "setAutoresizingMask:", .{autoresizing_mask});
    }

    /// `-[NSView frame]`
    pub fn frame(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "frame", .{});
    }

    /// `-[NSView setFrame:]`
    pub fn setFrame(self: Self, frame_: cg.Rect) void {
        return self.object.msgSend(void, "setFrame:", .{frame_});
    }

    /// `-[NSView frameRotation]`
    pub fn frameRotation(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "frameRotation", .{});
    }

    /// `-[NSView setFrameRotation:]`
    pub fn setFrameRotation(self: Self, frame_rotation: cg.Float) void {
        return self.object.msgSend(void, "setFrameRotation:", .{frame_rotation});
    }

    /// `-[NSView frameCenterRotation]`
    pub fn frameCenterRotation(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "frameCenterRotation", .{});
    }

    /// `-[NSView setFrameCenterRotation:]`
    pub fn setFrameCenterRotation(self: Self, frame_center_rotation: cg.Float) void {
        return self.object.msgSend(void, "setFrameCenterRotation:", .{frame_center_rotation});
    }

    /// `-[NSView boundsRotation]`
    pub fn boundsRotation(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "boundsRotation", .{});
    }

    /// `-[NSView setBoundsRotation:]`
    pub fn setBoundsRotation(self: Self, bounds_rotation: cg.Float) void {
        return self.object.msgSend(void, "setBoundsRotation:", .{bounds_rotation});
    }

    /// `-[NSView bounds]`
    pub fn bounds(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "bounds", .{});
    }

    /// `-[NSView setBounds:]`
    pub fn setBounds(self: Self, bounds_: cg.Rect) void {
        return self.object.msgSend(void, "setBounds:", .{bounds_});
    }

    /// `-[NSView isFlipped]`
    pub fn isFlipped(self: Self) bool {
        return self.object.msgSend(bool, "isFlipped", .{});
    }

    /// `-[NSView isRotatedFromBase]`
    pub fn isRotatedFromBase(self: Self) bool {
        return self.object.msgSend(bool, "isRotatedFromBase", .{});
    }

    /// `-[NSView isRotatedOrScaledFromBase]`
    pub fn isRotatedOrScaledFromBase(self: Self) bool {
        return self.object.msgSend(bool, "isRotatedOrScaledFromBase", .{});
    }

    /// `-[NSView isOpaque]`
    pub fn isOpaque(self: Self) bool {
        return self.object.msgSend(bool, "isOpaque", .{});
    }

    /// `-[NSView canDrawConcurrently]`
    pub fn canDrawConcurrently(self: Self) bool {
        return self.object.msgSend(bool, "canDrawConcurrently", .{});
    }

    /// `-[NSView setCanDrawConcurrently:]`
    pub fn setCanDrawConcurrently(self: Self, can_draw_concurrently: bool) void {
        return self.object.msgSend(void, "setCanDrawConcurrently:", .{can_draw_concurrently});
    }

    /// `-[NSView canDraw]`
    pub fn canDraw(self: Self) bool {
        return self.object.msgSend(bool, "canDraw", .{});
    }

    /// `-[NSView needsDisplay]`
    pub fn needsDisplay(self: Self) bool {
        return self.object.msgSend(bool, "needsDisplay", .{});
    }

    /// `-[NSView setNeedsDisplay:]`
    pub fn setNeedsDisplay(self: Self, needs_display: bool) void {
        return self.object.msgSend(void, "setNeedsDisplay:", .{needs_display});
    }

    /// `+[NSView focusView]`
    pub fn focusView() ?View {
        return class().msgSend(?View, "focusView", .{});
    }

    /// `-[NSView visibleRect]`
    pub fn visibleRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "visibleRect", .{});
    }

    /// `-[NSView tag]`
    pub fn tag(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "tag", .{});
    }

    /// `-[NSView needsPanelToBecomeKey]`
    pub fn needsPanelToBecomeKey(self: Self) bool {
        return self.object.msgSend(bool, "needsPanelToBecomeKey", .{});
    }

    /// `-[NSView mouseDownCanMoveWindow]`
    pub fn mouseDownCanMoveWindow(self: Self) bool {
        return self.object.msgSend(bool, "mouseDownCanMoveWindow", .{});
    }

    /// `-[NSView acceptsTouchEvents]`
    pub fn acceptsTouchEvents(self: Self) bool {
        return self.object.msgSend(bool, "acceptsTouchEvents", .{});
    }

    /// `-[NSView setAcceptsTouchEvents:]`
    pub fn setAcceptsTouchEvents(self: Self, accepts_touch_events: bool) void {
        return self.object.msgSend(void, "setAcceptsTouchEvents:", .{accepts_touch_events});
    }

    /// `-[NSView wantsRestingTouches]`
    pub fn wantsRestingTouches(self: Self) bool {
        return self.object.msgSend(bool, "wantsRestingTouches", .{});
    }

    /// `-[NSView setWantsRestingTouches:]`
    pub fn setWantsRestingTouches(self: Self, wants_resting_touches: bool) void {
        return self.object.msgSend(void, "setWantsRestingTouches:", .{wants_resting_touches});
    }

    /// `-[NSView layerContentsRedrawPolicy]`
    pub fn layerContentsRedrawPolicy(self: Self) ViewLayerContentsRedrawPolicy {
        return self.object.msgSend(ViewLayerContentsRedrawPolicy, "layerContentsRedrawPolicy", .{});
    }

    /// `-[NSView setLayerContentsRedrawPolicy:]`
    pub fn setLayerContentsRedrawPolicy(self: Self, layer_contents_redraw_policy: ViewLayerContentsRedrawPolicy) void {
        return self.object.msgSend(void, "setLayerContentsRedrawPolicy:", .{layer_contents_redraw_policy});
    }

    /// `-[NSView layerContentsPlacement]`
    pub fn layerContentsPlacement(self: Self) ViewLayerContentsPlacement {
        return self.object.msgSend(ViewLayerContentsPlacement, "layerContentsPlacement", .{});
    }

    /// `-[NSView setLayerContentsPlacement:]`
    pub fn setLayerContentsPlacement(self: Self, layer_contents_placement: ViewLayerContentsPlacement) void {
        return self.object.msgSend(void, "setLayerContentsPlacement:", .{layer_contents_placement});
    }

    /// `-[NSView wantsLayer]`
    pub fn wantsLayer(self: Self) bool {
        return self.object.msgSend(bool, "wantsLayer", .{});
    }

    /// `-[NSView setWantsLayer:]`
    pub fn setWantsLayer(self: Self, wants_layer: bool) void {
        return self.object.msgSend(void, "setWantsLayer:", .{wants_layer});
    }

    /// `-[NSView layer]`
    pub fn layer(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "layer", .{});
    }

    /// `-[NSView setLayer:]`
    pub fn setLayer(self: Self, layer_: ?objc.Object) void {
        return self.object.msgSend(void, "setLayer:", .{layer_});
    }

    /// `-[NSView wantsUpdateLayer]`
    pub fn wantsUpdateLayer(self: Self) bool {
        return self.object.msgSend(bool, "wantsUpdateLayer", .{});
    }

    /// `-[NSView canDrawSubviewsIntoLayer]`
    pub fn canDrawSubviewsIntoLayer(self: Self) bool {
        return self.object.msgSend(bool, "canDrawSubviewsIntoLayer", .{});
    }

    /// `-[NSView setCanDrawSubviewsIntoLayer:]`
    pub fn setCanDrawSubviewsIntoLayer(self: Self, can_draw_subviews_into_layer: bool) void {
        return self.object.msgSend(void, "setCanDrawSubviewsIntoLayer:", .{can_draw_subviews_into_layer});
    }

    /// `-[NSView needsLayout]`
    pub fn needsLayout(self: Self) bool {
        return self.object.msgSend(bool, "needsLayout", .{});
    }

    /// `-[NSView setNeedsLayout:]`
    pub fn setNeedsLayout(self: Self, needs_layout: bool) void {
        return self.object.msgSend(void, "setNeedsLayout:", .{needs_layout});
    }

    /// `-[NSView alphaValue]`
    pub fn alphaValue(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "alphaValue", .{});
    }

    /// `-[NSView setAlphaValue:]`
    pub fn setAlphaValue(self: Self, alpha_value: cg.Float) void {
        return self.object.msgSend(void, "setAlphaValue:", .{alpha_value});
    }

    /// `-[NSView layerUsesCoreImageFilters]`
    pub fn layerUsesCoreImageFilters(self: Self) bool {
        return self.object.msgSend(bool, "layerUsesCoreImageFilters", .{});
    }

    /// `-[NSView setLayerUsesCoreImageFilters:]`
    pub fn setLayerUsesCoreImageFilters(self: Self, layer_uses_core_image_filters: bool) void {
        return self.object.msgSend(void, "setLayerUsesCoreImageFilters:", .{layer_uses_core_image_filters});
    }

    /// `-[NSView backgroundFilters]`
    pub fn backgroundFilters(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "backgroundFilters", .{});
    }

    /// `-[NSView setBackgroundFilters:]`
    pub fn setBackgroundFilters(self: Self, background_filters: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setBackgroundFilters:", .{background_filters});
    }

    /// `-[NSView compositingFilter]`
    pub fn compositingFilter(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "compositingFilter", .{});
    }

    /// `-[NSView setCompositingFilter:]`
    pub fn setCompositingFilter(self: Self, compositing_filter: ?objc.Object) void {
        return self.object.msgSend(void, "setCompositingFilter:", .{compositing_filter});
    }

    /// `-[NSView contentFilters]`
    pub fn contentFilters(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "contentFilters", .{});
    }

    /// `-[NSView setContentFilters:]`
    pub fn setContentFilters(self: Self, content_filters: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setContentFilters:", .{content_filters});
    }

    /// `-[NSView shadow]`
    pub fn shadow(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "shadow", .{});
    }

    /// `-[NSView setShadow:]`
    pub fn setShadow(self: Self, shadow_: ?objc.Object) void {
        return self.object.msgSend(void, "setShadow:", .{shadow_});
    }

    /// `-[NSView clipsToBounds]`
    pub fn clipsToBounds(self: Self) bool {
        return self.object.msgSend(bool, "clipsToBounds", .{});
    }

    /// `-[NSView setClipsToBounds:]`
    pub fn setClipsToBounds(self: Self, clips_to_bounds: bool) void {
        return self.object.msgSend(void, "setClipsToBounds:", .{clips_to_bounds});
    }

    /// `-[NSView postsBoundsChangedNotifications]`
    pub fn postsBoundsChangedNotifications(self: Self) bool {
        return self.object.msgSend(bool, "postsBoundsChangedNotifications", .{});
    }

    /// `-[NSView setPostsBoundsChangedNotifications:]`
    pub fn setPostsBoundsChangedNotifications(self: Self, posts_bounds_changed_notifications: bool) void {
        return self.object.msgSend(void, "setPostsBoundsChangedNotifications:", .{posts_bounds_changed_notifications});
    }

    /// `-[NSView enclosingScrollView]`
    pub fn enclosingScrollView(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "enclosingScrollView", .{});
    }

    /// `+[NSView defaultMenu]`
    pub fn defaultMenu() ?Menu {
        return class().msgSend(?Menu, "defaultMenu", .{});
    }

    /// `-[NSView toolTip]`
    pub fn toolTip(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "toolTip", .{});
    }

    /// `-[NSView setToolTip:]`
    pub fn setToolTip(self: Self, tool_tip: ?foundation.String) void {
        return self.object.msgSend(void, "setToolTip:", .{tool_tip});
    }

    /// `-[NSView inLiveResize]`
    pub fn inLiveResize(self: Self) bool {
        return self.object.msgSend(bool, "inLiveResize", .{});
    }

    /// `-[NSView preservesContentDuringLiveResize]`
    pub fn preservesContentDuringLiveResize(self: Self) bool {
        return self.object.msgSend(bool, "preservesContentDuringLiveResize", .{});
    }

    /// `-[NSView rectPreservedDuringLiveResize]`
    pub fn rectPreservedDuringLiveResize(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "rectPreservedDuringLiveResize", .{});
    }

    /// `-[NSView inputContext]`
    pub fn inputContext(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "inputContext", .{});
    }

    /// `-[NSView userInterfaceLayoutDirection]`
    pub fn userInterfaceLayoutDirection(self: Self) UserInterfaceLayoutDirection {
        return self.object.msgSend(UserInterfaceLayoutDirection, "userInterfaceLayoutDirection", .{});
    }

    /// `-[NSView setUserInterfaceLayoutDirection:]`
    pub fn setUserInterfaceLayoutDirection(self: Self, user_interface_layout_direction: UserInterfaceLayoutDirection) void {
        return self.object.msgSend(void, "setUserInterfaceLayoutDirection:", .{user_interface_layout_direction});
    }

    /// `+[NSView isCompatibleWithResponsiveScrolling]`
    pub fn isCompatibleWithResponsiveScrolling() bool {
        return class().msgSend(bool, "isCompatibleWithResponsiveScrolling", .{});
    }

    /// `-[NSView preparedContentRect]`
    pub fn preparedContentRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "preparedContentRect", .{});
    }

    /// `-[NSView setPreparedContentRect:]`
    pub fn setPreparedContentRect(self: Self, prepared_content_rect: cg.Rect) void {
        return self.object.msgSend(void, "setPreparedContentRect:", .{prepared_content_rect});
    }

    /// `-[NSView allowsVibrancy]`
    pub fn allowsVibrancy(self: Self) bool {
        return self.object.msgSend(bool, "allowsVibrancy", .{});
    }

    /// `-[NSView viewDidChangeEffectiveCornerRadii]`
    pub fn viewDidChangeEffectiveCornerRadii(self: Self) void {
        return self.object.msgSend(void, "viewDidChangeEffectiveCornerRadii", .{});
    }

    /// `-[NSView invalidateCornerConfiguration]`
    pub fn invalidateCornerConfiguration(self: Self) void {
        return self.object.msgSend(void, "invalidateCornerConfiguration", .{});
    }

    /// `-[NSView cornerConfiguration]`
    pub fn cornerConfiguration(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "cornerConfiguration", .{});
    }

    /// `-[NSView effectiveCornerRadii]`
    pub fn effectiveCornerRadii(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "effectiveCornerRadii", .{});
    }

    /// `-[NSView enclosingMenuItem]`
    pub fn enclosingMenuItem(self: Self) ?MenuItem {
        return self.object.msgSend(?MenuItem, "enclosingMenuItem", .{});
    }

    // Not generated:
    //   -[NSView sortSubviewsUsingFunction:context:]: NSComparisonResult (* _Nonnull)(__kindof NSView * _Nonnull, __kindof NSView * _Nonnull, void * _Nullable)
};

/// `NSScreen`, a subclass of `NSObject`.
pub const Screen = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSScreen";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSScreen`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSScreen canRepresentDisplayGamut:]`
    pub fn canRepresentDisplayGamut(self: Self, display_gamut: DisplayGamut) bool {
        return self.object.msgSend(bool, "canRepresentDisplayGamut:", .{display_gamut});
    }

    /// `-[NSScreen convertRectToBacking:]`
    pub fn convertRectToBacking(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectToBacking:", .{rect});
    }

    /// `-[NSScreen convertRectFromBacking:]`
    pub fn convertRectFromBacking(self: Self, rect: cg.Rect) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRectFromBacking:", .{rect});
    }

    /// `-[NSScreen backingAlignedRect:options:]`
    pub fn backingAlignedRectOptions(self: Self, rect: cg.Rect, options: AlignmentOptions) cg.Rect {
        return self.object.msgSend(cg.Rect, "backingAlignedRect:options:", .{ rect, options });
    }

    /// `+[NSScreen screens]`
    pub fn screens() foundation.Array(Screen) {
        return class().msgSend(foundation.Array(Screen), "screens", .{});
    }

    /// `+[NSScreen mainScreen]`
    pub fn mainScreen() ?Screen {
        return class().msgSend(?Screen, "mainScreen", .{});
    }

    /// `+[NSScreen deepestScreen]`
    pub fn deepestScreen() ?Screen {
        return class().msgSend(?Screen, "deepestScreen", .{});
    }

    /// `+[NSScreen screensHaveSeparateSpaces]`
    pub fn screensHaveSeparateSpaces() bool {
        return class().msgSend(bool, "screensHaveSeparateSpaces", .{});
    }

    /// `-[NSScreen depth]`
    pub fn depth(self: Self) WindowDepth {
        return self.object.msgSend(WindowDepth, "depth", .{});
    }

    /// `-[NSScreen frame]`
    pub fn frame(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "frame", .{});
    }

    /// `-[NSScreen visibleFrame]`
    pub fn visibleFrame(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "visibleFrame", .{});
    }

    /// `-[NSScreen deviceDescription]`
    pub fn deviceDescription(self: Self) foundation.Dictionary(objc.Object, objc.Object) {
        return self.object.msgSend(foundation.Dictionary(objc.Object, objc.Object), "deviceDescription", .{});
    }

    /// `-[NSScreen colorSpace]`
    pub fn colorSpace(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "colorSpace", .{});
    }

    /// `-[NSScreen supportedWindowDepths]`
    pub fn supportedWindowDepths(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "supportedWindowDepths", .{});
    }

    /// `-[NSScreen backingScaleFactor]`
    pub fn backingScaleFactor(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "backingScaleFactor", .{});
    }

    /// `-[NSScreen localizedName]`
    pub fn localizedName(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "localizedName", .{});
    }

    /// `-[NSScreen auxiliaryTopLeftArea]`
    pub fn auxiliaryTopLeftArea(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "auxiliaryTopLeftArea", .{});
    }

    /// `-[NSScreen auxiliaryTopRightArea]`
    pub fn auxiliaryTopRightArea(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "auxiliaryTopRightArea", .{});
    }

    /// `-[NSScreen CGDirectDisplayID]`
    pub fn CGDirectDisplayID(self: Self) u32 {
        return self.object.msgSend(u32, "CGDirectDisplayID", .{});
    }

    /// `-[NSScreen touchCapabilities]`
    pub fn touchCapabilities(self: Self) ScreenTouchCapabilities {
        return self.object.msgSend(ScreenTouchCapabilities, "touchCapabilities", .{});
    }

    // Not generated:
    //   -[NSScreen safeAreaInsets]: NSEdgeInsets
};

/// `NSColor`, a subclass of `NSObject`.
pub const Color = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSColor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSColor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSColor init]`
    pub fn init(self: Self) Color {
        return self.object.msgSend(Color, "init", .{});
    }

    /// `-[NSColor initWithCoder:]`
    pub fn initWithCoder(self: Self, coder: objc.Object) ?Color {
        return self.object.msgSend(?Color, "initWithCoder:", .{coder});
    }

    /// `+[NSColor colorWithColorSpace:components:count:]`
    pub fn colorWithColorSpaceComponentsCount(space: objc.Object, components: ?*const cg.Float, number_of_components: objc.Integer) Color {
        return class().msgSend(Color, "colorWithColorSpace:components:count:", .{ space, components, number_of_components });
    }

    /// `+[NSColor colorWithSRGBRed:green:blue:alpha:]`
    pub fn colorWithSRGBRedGreenBlueAlpha(red: cg.Float, green: cg.Float, blue: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithSRGBRed:green:blue:alpha:", .{ red, green, blue, alpha });
    }

    /// `+[NSColor colorWithGenericGamma22White:alpha:]`
    pub fn colorWithGenericGamma22WhiteAlpha(white: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithGenericGamma22White:alpha:", .{ white, alpha });
    }

    /// `+[NSColor colorWithDisplayP3Red:green:blue:alpha:]`
    pub fn colorWithDisplayP3RedGreenBlueAlpha(red: cg.Float, green: cg.Float, blue: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithDisplayP3Red:green:blue:alpha:", .{ red, green, blue, alpha });
    }

    /// `+[NSColor colorWithWhite:alpha:]`
    pub fn colorWithWhiteAlpha(white: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithWhite:alpha:", .{ white, alpha });
    }

    /// `+[NSColor colorWithRed:green:blue:alpha:]`
    pub fn colorWithRedGreenBlueAlpha(red: cg.Float, green: cg.Float, blue: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithRed:green:blue:alpha:", .{ red, green, blue, alpha });
    }

    /// `+[NSColor colorWithHue:saturation:brightness:alpha:]`
    pub fn colorWithHueSaturationBrightnessAlpha(hue: cg.Float, saturation: cg.Float, brightness: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithHue:saturation:brightness:alpha:", .{ hue, saturation, brightness, alpha });
    }

    /// `+[NSColor colorWithColorSpace:hue:saturation:brightness:alpha:]`
    pub fn colorWithColorSpaceHueSaturationBrightnessAlpha(space: objc.Object, hue: cg.Float, saturation: cg.Float, brightness: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithColorSpace:hue:saturation:brightness:alpha:", .{ space, hue, saturation, brightness, alpha });
    }

    /// `+[NSColor colorWithCatalogName:colorName:]`
    pub fn colorWithCatalogNameColorName(list_name: ?foundation.String, color_name: ?foundation.String) ?Color {
        return class().msgSend(?Color, "colorWithCatalogName:colorName:", .{ list_name, color_name });
    }

    /// `+[NSColor colorNamed:bundle:]`
    pub fn colorNamedBundle(name: ?foundation.String, bundle: ?objc.Object) ?Color {
        return class().msgSend(?Color, "colorNamed:bundle:", .{ name, bundle });
    }

    /// `+[NSColor colorNamed:]`
    pub fn colorNamed(name: ?foundation.String) ?Color {
        return class().msgSend(?Color, "colorNamed:", .{name});
    }

    /// `+[NSColor colorWithName:dynamicProvider:]`
    pub fn colorWithNameDynamicProvider(color_name: ?foundation.String, dynamic_provider: anytype) Color {
        return class().msgSend(Color, "colorWithName:dynamicProvider:", .{ color_name, dynamic_provider });
    }

    /// `+[NSColor colorWithDeviceWhite:alpha:]`
    pub fn colorWithDeviceWhiteAlpha(white: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithDeviceWhite:alpha:", .{ white, alpha });
    }

    /// `+[NSColor colorWithDeviceRed:green:blue:alpha:]`
    pub fn colorWithDeviceRedGreenBlueAlpha(red: cg.Float, green: cg.Float, blue: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithDeviceRed:green:blue:alpha:", .{ red, green, blue, alpha });
    }

    /// `+[NSColor colorWithDeviceHue:saturation:brightness:alpha:]`
    pub fn colorWithDeviceHueSaturationBrightnessAlpha(hue: cg.Float, saturation: cg.Float, brightness: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithDeviceHue:saturation:brightness:alpha:", .{ hue, saturation, brightness, alpha });
    }

    /// `+[NSColor colorWithDeviceCyan:magenta:yellow:black:alpha:]`
    pub fn colorWithDeviceCyanMagentaYellowBlackAlpha(cyan: cg.Float, magenta: cg.Float, yellow: cg.Float, black: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithDeviceCyan:magenta:yellow:black:alpha:", .{ cyan, magenta, yellow, black, alpha });
    }

    /// `+[NSColor colorWithCalibratedWhite:alpha:]`
    pub fn colorWithCalibratedWhiteAlpha(white: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithCalibratedWhite:alpha:", .{ white, alpha });
    }

    /// `+[NSColor colorWithCalibratedRed:green:blue:alpha:]`
    pub fn colorWithCalibratedRedGreenBlueAlpha(red: cg.Float, green: cg.Float, blue: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithCalibratedRed:green:blue:alpha:", .{ red, green, blue, alpha });
    }

    /// `+[NSColor colorWithCalibratedHue:saturation:brightness:alpha:]`
    pub fn colorWithCalibratedHueSaturationBrightnessAlpha(hue: cg.Float, saturation: cg.Float, brightness: cg.Float, alpha: cg.Float) Color {
        return class().msgSend(Color, "colorWithCalibratedHue:saturation:brightness:alpha:", .{ hue, saturation, brightness, alpha });
    }

    /// `+[NSColor colorWithPatternImage:]`
    pub fn colorWithPatternImage(image: Image) Color {
        return class().msgSend(Color, "colorWithPatternImage:", .{image});
    }

    /// `-[NSColor colorUsingType:]`
    pub fn colorUsingType(self: Self, type_: ColorType) ?Color {
        return self.object.msgSend(?Color, "colorUsingType:", .{type_});
    }

    /// `-[NSColor colorUsingColorSpace:]`
    pub fn colorUsingColorSpace(self: Self, space: objc.Object) ?Color {
        return self.object.msgSend(?Color, "colorUsingColorSpace:", .{space});
    }

    /// `+[NSColor colorWithRed:green:blue:alpha:exposure:]`
    pub fn colorWithRedGreenBlueAlphaExposure(red: cg.Float, green: cg.Float, blue: cg.Float, alpha: cg.Float, exposure: cg.Float) Color {
        return class().msgSend(Color, "colorWithRed:green:blue:alpha:exposure:", .{ red, green, blue, alpha, exposure });
    }

    /// `+[NSColor colorWithRed:green:blue:alpha:linearExposure:]`
    pub fn colorWithRedGreenBlueAlphaLinearExposure(red: cg.Float, green: cg.Float, blue: cg.Float, alpha: cg.Float, linear_exposure: cg.Float) Color {
        return class().msgSend(Color, "colorWithRed:green:blue:alpha:linearExposure:", .{ red, green, blue, alpha, linear_exposure });
    }

    /// `-[NSColor colorByApplyingContentHeadroom:]`
    pub fn colorByApplyingContentHeadroom(self: Self, content_headroom: cg.Float) Color {
        return self.object.msgSend(Color, "colorByApplyingContentHeadroom:", .{content_headroom});
    }

    /// `+[NSColor colorForControlTint:]`
    pub fn colorForControlTint(control_tint: ControlTint) Color {
        return class().msgSend(Color, "colorForControlTint:", .{control_tint});
    }

    /// `-[NSColor highlightWithLevel:]`
    pub fn highlightWithLevel(self: Self, val: cg.Float) ?Color {
        return self.object.msgSend(?Color, "highlightWithLevel:", .{val});
    }

    /// `-[NSColor shadowWithLevel:]`
    pub fn shadowWithLevel(self: Self, val: cg.Float) ?Color {
        return self.object.msgSend(?Color, "shadowWithLevel:", .{val});
    }

    /// `-[NSColor colorWithSystemEffect:]`
    pub fn colorWithSystemEffect(self: Self, system_effect: ColorSystemEffect) Color {
        return self.object.msgSend(Color, "colorWithSystemEffect:", .{system_effect});
    }

    /// `-[NSColor set]`
    pub fn set(self: Self) void {
        return self.object.msgSend(void, "set", .{});
    }

    /// `-[NSColor setFill]`
    pub fn setFill(self: Self) void {
        return self.object.msgSend(void, "setFill", .{});
    }

    /// `-[NSColor setStroke]`
    pub fn setStroke(self: Self) void {
        return self.object.msgSend(void, "setStroke", .{});
    }

    /// `-[NSColor blendedColorWithFraction:ofColor:]`
    pub fn blendedColorWithFractionOfColor(self: Self, fraction: cg.Float, color: Color) ?Color {
        return self.object.msgSend(?Color, "blendedColorWithFraction:ofColor:", .{ fraction, color });
    }

    /// `-[NSColor colorWithAlphaComponent:]`
    pub fn colorWithAlphaComponent(self: Self, alpha: cg.Float) Color {
        return self.object.msgSend(Color, "colorWithAlphaComponent:", .{alpha});
    }

    /// `-[NSColor getRed:green:blue:alpha:]`
    pub fn getRedGreenBlueAlpha(self: Self, red: ?*cg.Float, green: ?*cg.Float, blue: ?*cg.Float, alpha: ?*cg.Float) void {
        return self.object.msgSend(void, "getRed:green:blue:alpha:", .{ red, green, blue, alpha });
    }

    /// `-[NSColor getHue:saturation:brightness:alpha:]`
    pub fn getHueSaturationBrightnessAlpha(self: Self, hue: ?*cg.Float, saturation: ?*cg.Float, brightness: ?*cg.Float, alpha: ?*cg.Float) void {
        return self.object.msgSend(void, "getHue:saturation:brightness:alpha:", .{ hue, saturation, brightness, alpha });
    }

    /// `-[NSColor getWhite:alpha:]`
    pub fn getWhiteAlpha(self: Self, white: ?*cg.Float, alpha: ?*cg.Float) void {
        return self.object.msgSend(void, "getWhite:alpha:", .{ white, alpha });
    }

    /// `-[NSColor getCyan:magenta:yellow:black:alpha:]`
    pub fn getCyanMagentaYellowBlackAlpha(self: Self, cyan: ?*cg.Float, magenta: ?*cg.Float, yellow: ?*cg.Float, black: ?*cg.Float, alpha: ?*cg.Float) void {
        return self.object.msgSend(void, "getCyan:magenta:yellow:black:alpha:", .{ cyan, magenta, yellow, black, alpha });
    }

    /// `-[NSColor getComponents:]`
    pub fn getComponents(self: Self, components: ?*cg.Float) void {
        return self.object.msgSend(void, "getComponents:", .{components});
    }

    /// `+[NSColor colorFromPasteboard:]`
    pub fn colorFromPasteboard(paste_board: objc.Object) ?Color {
        return class().msgSend(?Color, "colorFromPasteboard:", .{paste_board});
    }

    /// `-[NSColor writeToPasteboard:]`
    pub fn writeToPasteboard(self: Self, paste_board: objc.Object) void {
        return self.object.msgSend(void, "writeToPasteboard:", .{paste_board});
    }

    /// `-[NSColor drawSwatchInRect:]`
    pub fn drawSwatchInRect(self: Self, rect: cg.Rect) void {
        return self.object.msgSend(void, "drawSwatchInRect:", .{rect});
    }

    /// `+[NSColor colorWithCGColor:]`
    pub fn colorWithCGColor(cg_color: ?*anyopaque) ?Color {
        return class().msgSend(?Color, "colorWithCGColor:", .{cg_color});
    }

    /// `-[NSColor type]`
    pub fn @"type"(self: Self) ColorType {
        return self.object.msgSend(ColorType, "type", .{});
    }

    /// `-[NSColor standardDynamicRangeColor]`
    pub fn standardDynamicRangeColor(self: Self) ?Color {
        return self.object.msgSend(?Color, "standardDynamicRangeColor", .{});
    }

    /// `+[NSColor blackColor]`
    pub fn blackColor() Color {
        return class().msgSend(Color, "blackColor", .{});
    }

    /// `+[NSColor darkGrayColor]`
    pub fn darkGrayColor() Color {
        return class().msgSend(Color, "darkGrayColor", .{});
    }

    /// `+[NSColor lightGrayColor]`
    pub fn lightGrayColor() Color {
        return class().msgSend(Color, "lightGrayColor", .{});
    }

    /// `+[NSColor whiteColor]`
    pub fn whiteColor() Color {
        return class().msgSend(Color, "whiteColor", .{});
    }

    /// `+[NSColor grayColor]`
    pub fn grayColor() Color {
        return class().msgSend(Color, "grayColor", .{});
    }

    /// `+[NSColor redColor]`
    pub fn redColor() Color {
        return class().msgSend(Color, "redColor", .{});
    }

    /// `+[NSColor greenColor]`
    pub fn greenColor() Color {
        return class().msgSend(Color, "greenColor", .{});
    }

    /// `+[NSColor blueColor]`
    pub fn blueColor() Color {
        return class().msgSend(Color, "blueColor", .{});
    }

    /// `+[NSColor cyanColor]`
    pub fn cyanColor() Color {
        return class().msgSend(Color, "cyanColor", .{});
    }

    /// `+[NSColor yellowColor]`
    pub fn yellowColor() Color {
        return class().msgSend(Color, "yellowColor", .{});
    }

    /// `+[NSColor magentaColor]`
    pub fn magentaColor() Color {
        return class().msgSend(Color, "magentaColor", .{});
    }

    /// `+[NSColor orangeColor]`
    pub fn orangeColor() Color {
        return class().msgSend(Color, "orangeColor", .{});
    }

    /// `+[NSColor purpleColor]`
    pub fn purpleColor() Color {
        return class().msgSend(Color, "purpleColor", .{});
    }

    /// `+[NSColor brownColor]`
    pub fn brownColor() Color {
        return class().msgSend(Color, "brownColor", .{});
    }

    /// `+[NSColor clearColor]`
    pub fn clearColor() Color {
        return class().msgSend(Color, "clearColor", .{});
    }

    /// `+[NSColor labelColor]`
    pub fn labelColor() ?Color {
        return class().msgSend(?Color, "labelColor", .{});
    }

    /// `+[NSColor secondaryLabelColor]`
    pub fn secondaryLabelColor() ?Color {
        return class().msgSend(?Color, "secondaryLabelColor", .{});
    }

    /// `+[NSColor tertiaryLabelColor]`
    pub fn tertiaryLabelColor() ?Color {
        return class().msgSend(?Color, "tertiaryLabelColor", .{});
    }

    /// `+[NSColor quaternaryLabelColor]`
    pub fn quaternaryLabelColor() ?Color {
        return class().msgSend(?Color, "quaternaryLabelColor", .{});
    }

    /// `+[NSColor quinaryLabelColor]`
    pub fn quinaryLabelColor() ?Color {
        return class().msgSend(?Color, "quinaryLabelColor", .{});
    }

    /// `+[NSColor linkColor]`
    pub fn linkColor() ?Color {
        return class().msgSend(?Color, "linkColor", .{});
    }

    /// `+[NSColor placeholderTextColor]`
    pub fn placeholderTextColor() ?Color {
        return class().msgSend(?Color, "placeholderTextColor", .{});
    }

    /// `+[NSColor windowFrameTextColor]`
    pub fn windowFrameTextColor() Color {
        return class().msgSend(Color, "windowFrameTextColor", .{});
    }

    /// `+[NSColor selectedMenuItemTextColor]`
    pub fn selectedMenuItemTextColor() Color {
        return class().msgSend(Color, "selectedMenuItemTextColor", .{});
    }

    /// `+[NSColor alternateSelectedControlTextColor]`
    pub fn alternateSelectedControlTextColor() Color {
        return class().msgSend(Color, "alternateSelectedControlTextColor", .{});
    }

    /// `+[NSColor headerTextColor]`
    pub fn headerTextColor() Color {
        return class().msgSend(Color, "headerTextColor", .{});
    }

    /// `+[NSColor separatorColor]`
    pub fn separatorColor() ?Color {
        return class().msgSend(?Color, "separatorColor", .{});
    }

    /// `+[NSColor gridColor]`
    pub fn gridColor() Color {
        return class().msgSend(Color, "gridColor", .{});
    }

    /// `+[NSColor windowBackgroundColor]`
    pub fn windowBackgroundColor() Color {
        return class().msgSend(Color, "windowBackgroundColor", .{});
    }

    /// `+[NSColor underPageBackgroundColor]`
    pub fn underPageBackgroundColor() ?Color {
        return class().msgSend(?Color, "underPageBackgroundColor", .{});
    }

    /// `+[NSColor controlBackgroundColor]`
    pub fn controlBackgroundColor() Color {
        return class().msgSend(Color, "controlBackgroundColor", .{});
    }

    /// `+[NSColor selectedContentBackgroundColor]`
    pub fn selectedContentBackgroundColor() ?Color {
        return class().msgSend(?Color, "selectedContentBackgroundColor", .{});
    }

    /// `+[NSColor unemphasizedSelectedContentBackgroundColor]`
    pub fn unemphasizedSelectedContentBackgroundColor() ?Color {
        return class().msgSend(?Color, "unemphasizedSelectedContentBackgroundColor", .{});
    }

    /// `+[NSColor alternatingContentBackgroundColors]`
    pub fn alternatingContentBackgroundColors() ?foundation.Array(Color) {
        return class().msgSend(?foundation.Array(Color), "alternatingContentBackgroundColors", .{});
    }

    /// `+[NSColor findHighlightColor]`
    pub fn findHighlightColor() ?Color {
        return class().msgSend(?Color, "findHighlightColor", .{});
    }

    /// `+[NSColor textColor]`
    pub fn textColor() Color {
        return class().msgSend(Color, "textColor", .{});
    }

    /// `+[NSColor textBackgroundColor]`
    pub fn textBackgroundColor() Color {
        return class().msgSend(Color, "textBackgroundColor", .{});
    }

    /// `+[NSColor textInsertionPointColor]`
    pub fn textInsertionPointColor() ?Color {
        return class().msgSend(?Color, "textInsertionPointColor", .{});
    }

    /// `+[NSColor selectedTextColor]`
    pub fn selectedTextColor() Color {
        return class().msgSend(Color, "selectedTextColor", .{});
    }

    /// `+[NSColor selectedTextBackgroundColor]`
    pub fn selectedTextBackgroundColor() Color {
        return class().msgSend(Color, "selectedTextBackgroundColor", .{});
    }

    /// `+[NSColor unemphasizedSelectedTextBackgroundColor]`
    pub fn unemphasizedSelectedTextBackgroundColor() ?Color {
        return class().msgSend(?Color, "unemphasizedSelectedTextBackgroundColor", .{});
    }

    /// `+[NSColor unemphasizedSelectedTextColor]`
    pub fn unemphasizedSelectedTextColor() ?Color {
        return class().msgSend(?Color, "unemphasizedSelectedTextColor", .{});
    }

    /// `+[NSColor controlColor]`
    pub fn controlColor() Color {
        return class().msgSend(Color, "controlColor", .{});
    }

    /// `+[NSColor controlTextColor]`
    pub fn controlTextColor() Color {
        return class().msgSend(Color, "controlTextColor", .{});
    }

    /// `+[NSColor selectedControlColor]`
    pub fn selectedControlColor() Color {
        return class().msgSend(Color, "selectedControlColor", .{});
    }

    /// `+[NSColor selectedControlTextColor]`
    pub fn selectedControlTextColor() Color {
        return class().msgSend(Color, "selectedControlTextColor", .{});
    }

    /// `+[NSColor disabledControlTextColor]`
    pub fn disabledControlTextColor() Color {
        return class().msgSend(Color, "disabledControlTextColor", .{});
    }

    /// `+[NSColor keyboardFocusIndicatorColor]`
    pub fn keyboardFocusIndicatorColor() Color {
        return class().msgSend(Color, "keyboardFocusIndicatorColor", .{});
    }

    /// `+[NSColor scrubberTexturedBackgroundColor]`
    pub fn scrubberTexturedBackgroundColor() ?Color {
        return class().msgSend(?Color, "scrubberTexturedBackgroundColor", .{});
    }

    /// `+[NSColor systemRedColor]`
    pub fn systemRedColor() ?Color {
        return class().msgSend(?Color, "systemRedColor", .{});
    }

    /// `+[NSColor systemGreenColor]`
    pub fn systemGreenColor() ?Color {
        return class().msgSend(?Color, "systemGreenColor", .{});
    }

    /// `+[NSColor systemBlueColor]`
    pub fn systemBlueColor() ?Color {
        return class().msgSend(?Color, "systemBlueColor", .{});
    }

    /// `+[NSColor systemOrangeColor]`
    pub fn systemOrangeColor() ?Color {
        return class().msgSend(?Color, "systemOrangeColor", .{});
    }

    /// `+[NSColor systemYellowColor]`
    pub fn systemYellowColor() ?Color {
        return class().msgSend(?Color, "systemYellowColor", .{});
    }

    /// `+[NSColor systemBrownColor]`
    pub fn systemBrownColor() ?Color {
        return class().msgSend(?Color, "systemBrownColor", .{});
    }

    /// `+[NSColor systemPinkColor]`
    pub fn systemPinkColor() ?Color {
        return class().msgSend(?Color, "systemPinkColor", .{});
    }

    /// `+[NSColor systemPurpleColor]`
    pub fn systemPurpleColor() ?Color {
        return class().msgSend(?Color, "systemPurpleColor", .{});
    }

    /// `+[NSColor systemGrayColor]`
    pub fn systemGrayColor() ?Color {
        return class().msgSend(?Color, "systemGrayColor", .{});
    }

    /// `+[NSColor systemTealColor]`
    pub fn systemTealColor() ?Color {
        return class().msgSend(?Color, "systemTealColor", .{});
    }

    /// `+[NSColor systemIndigoColor]`
    pub fn systemIndigoColor() ?Color {
        return class().msgSend(?Color, "systemIndigoColor", .{});
    }

    /// `+[NSColor systemMintColor]`
    pub fn systemMintColor() ?Color {
        return class().msgSend(?Color, "systemMintColor", .{});
    }

    /// `+[NSColor systemCyanColor]`
    pub fn systemCyanColor() ?Color {
        return class().msgSend(?Color, "systemCyanColor", .{});
    }

    /// `+[NSColor systemFillColor]`
    pub fn systemFillColor() ?Color {
        return class().msgSend(?Color, "systemFillColor", .{});
    }

    /// `+[NSColor secondarySystemFillColor]`
    pub fn secondarySystemFillColor() ?Color {
        return class().msgSend(?Color, "secondarySystemFillColor", .{});
    }

    /// `+[NSColor tertiarySystemFillColor]`
    pub fn tertiarySystemFillColor() ?Color {
        return class().msgSend(?Color, "tertiarySystemFillColor", .{});
    }

    /// `+[NSColor quaternarySystemFillColor]`
    pub fn quaternarySystemFillColor() ?Color {
        return class().msgSend(?Color, "quaternarySystemFillColor", .{});
    }

    /// `+[NSColor quinarySystemFillColor]`
    pub fn quinarySystemFillColor() ?Color {
        return class().msgSend(?Color, "quinarySystemFillColor", .{});
    }

    /// `+[NSColor controlAccentColor]`
    pub fn controlAccentColor() ?Color {
        return class().msgSend(?Color, "controlAccentColor", .{});
    }

    /// `+[NSColor currentControlTint]`
    pub fn currentControlTint() ControlTint {
        return class().msgSend(ControlTint, "currentControlTint", .{});
    }

    /// `+[NSColor highlightColor]`
    pub fn highlightColor() Color {
        return class().msgSend(Color, "highlightColor", .{});
    }

    /// `+[NSColor shadowColor]`
    pub fn shadowColor() Color {
        return class().msgSend(Color, "shadowColor", .{});
    }

    /// `-[NSColor catalogNameComponent]`
    pub fn catalogNameComponent(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "catalogNameComponent", .{});
    }

    /// `-[NSColor colorNameComponent]`
    pub fn colorNameComponent(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "colorNameComponent", .{});
    }

    /// `-[NSColor localizedCatalogNameComponent]`
    pub fn localizedCatalogNameComponent(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "localizedCatalogNameComponent", .{});
    }

    /// `-[NSColor localizedColorNameComponent]`
    pub fn localizedColorNameComponent(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "localizedColorNameComponent", .{});
    }

    /// `-[NSColor redComponent]`
    pub fn redComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "redComponent", .{});
    }

    /// `-[NSColor greenComponent]`
    pub fn greenComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "greenComponent", .{});
    }

    /// `-[NSColor blueComponent]`
    pub fn blueComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "blueComponent", .{});
    }

    /// `-[NSColor hueComponent]`
    pub fn hueComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "hueComponent", .{});
    }

    /// `-[NSColor saturationComponent]`
    pub fn saturationComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "saturationComponent", .{});
    }

    /// `-[NSColor brightnessComponent]`
    pub fn brightnessComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "brightnessComponent", .{});
    }

    /// `-[NSColor whiteComponent]`
    pub fn whiteComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "whiteComponent", .{});
    }

    /// `-[NSColor cyanComponent]`
    pub fn cyanComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "cyanComponent", .{});
    }

    /// `-[NSColor magentaComponent]`
    pub fn magentaComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "magentaComponent", .{});
    }

    /// `-[NSColor yellowComponent]`
    pub fn yellowComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "yellowComponent", .{});
    }

    /// `-[NSColor blackComponent]`
    pub fn blackComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "blackComponent", .{});
    }

    /// `-[NSColor colorSpace]`
    pub fn colorSpace(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "colorSpace", .{});
    }

    /// `-[NSColor numberOfComponents]`
    pub fn numberOfComponents(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "numberOfComponents", .{});
    }

    /// `-[NSColor patternImage]`
    pub fn patternImage(self: Self) Image {
        return self.object.msgSend(Image, "patternImage", .{});
    }

    /// `-[NSColor alphaComponent]`
    pub fn alphaComponent(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "alphaComponent", .{});
    }

    /// `-[NSColor linearExposure]`
    pub fn linearExposure(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "linearExposure", .{});
    }

    /// `-[NSColor CGColor]`
    pub fn CGColor(self: Self) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "CGColor", .{});
    }

    /// `+[NSColor ignoresAlpha]`
    pub fn ignoresAlpha() bool {
        return class().msgSend(bool, "ignoresAlpha", .{});
    }

    /// `+[NSColor setIgnoresAlpha:]`
    pub fn setIgnoresAlpha(ignores_alpha: bool) void {
        return class().msgSend(void, "setIgnoresAlpha:", .{ignores_alpha});
    }
};

/// `NSEvent`, a subclass of `NSObject`.
pub const Event = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSEvent";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSEvent`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSEvent charactersByApplyingModifiers:]`
    pub fn charactersByApplyingModifiers(self: Self, modifiers: EventModifierFlags) ?foundation.String {
        return self.object.msgSend(?foundation.String, "charactersByApplyingModifiers:", .{modifiers});
    }

    /// `+[NSEvent eventWithEventRef:]`
    pub fn eventWithEventRef(event_ref: ?*const anyopaque) ?Event {
        return class().msgSend(?Event, "eventWithEventRef:", .{event_ref});
    }

    /// `+[NSEvent eventWithCGEvent:]`
    pub fn eventWithCGEvent(cg_event: ?*anyopaque) ?Event {
        return class().msgSend(?Event, "eventWithCGEvent:", .{cg_event});
    }

    /// `-[NSEvent touchesMatchingPhase:inView:]`
    pub fn touchesMatchingPhaseInView(self: Self, phase_: TouchPhase, view: ?View) objc.Object {
        return self.object.msgSend(objc.Object, "touchesMatchingPhase:inView:", .{ phase_, view });
    }

    /// `-[NSEvent allTouches]`
    pub fn allTouches(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "allTouches", .{});
    }

    /// `-[NSEvent touchesForView:]`
    pub fn touchesForView(self: Self, view: View) objc.Object {
        return self.object.msgSend(objc.Object, "touchesForView:", .{view});
    }

    /// `-[NSEvent coalescedTouchesForTouch:]`
    pub fn coalescedTouchesForTouch(self: Self, touch: objc.Object) foundation.Array(objc.Object) {
        return self.object.msgSend(foundation.Array(objc.Object), "coalescedTouchesForTouch:", .{touch});
    }

    /// `-[NSEvent trackSwipeEventWithOptions:dampenAmountThresholdMin:max:usingHandler:]`
    pub fn trackSwipeEventWithOptionsDampenAmountThresholdMinMaxUsingHandler(self: Self, options: EventSwipeTrackingOptions, min_dampen_threshold: cg.Float, max_dampen_threshold: cg.Float, tracking_handler: anytype) void {
        return self.object.msgSend(void, "trackSwipeEventWithOptions:dampenAmountThresholdMin:max:usingHandler:", .{ options, min_dampen_threshold, max_dampen_threshold, tracking_handler });
    }

    /// `+[NSEvent startPeriodicEventsAfterDelay:withPeriod:]`
    pub fn startPeriodicEventsAfterDelayWithPeriod(delay: f64, period: f64) void {
        return class().msgSend(void, "startPeriodicEventsAfterDelay:withPeriod:", .{ delay, period });
    }

    /// `+[NSEvent stopPeriodicEvents]`
    pub fn stopPeriodicEvents() void {
        return class().msgSend(void, "stopPeriodicEvents", .{});
    }

    /// `+[NSEvent mouseEventWithType:location:modifierFlags:timestamp:windowNumber:context:eventNumber:clickCount:pressure:]`
    pub fn mouseEventWithTypeLocationModifierFlagsTimestampWindowNumberContextEventNumberClickCountPressure(type_: EventType, location: cg.Point, flags: EventModifierFlags, time: f64, w_num: objc.Integer, unused_pass_nil: ?GraphicsContext, e_num: objc.Integer, c_num: objc.Integer, pressure_: f32) ?Event {
        return class().msgSend(?Event, "mouseEventWithType:location:modifierFlags:timestamp:windowNumber:context:eventNumber:clickCount:pressure:", .{ type_, location, flags, time, w_num, unused_pass_nil, e_num, c_num, pressure_ });
    }

    /// `+[NSEvent keyEventWithType:location:modifierFlags:timestamp:windowNumber:context:characters:charactersIgnoringModifiers:isARepeat:keyCode:]`
    pub fn keyEventWithTypeLocationModifierFlagsTimestampWindowNumberContextCharactersCharactersIgnoringModifiersIsARepeatKeyCode(type_: EventType, location: cg.Point, flags: EventModifierFlags, time: f64, w_num: objc.Integer, unused_pass_nil: ?GraphicsContext, keys: foundation.String, ukeys: foundation.String, flag: bool, code: c_ushort) ?Event {
        return class().msgSend(?Event, "keyEventWithType:location:modifierFlags:timestamp:windowNumber:context:characters:charactersIgnoringModifiers:isARepeat:keyCode:", .{ type_, location, flags, time, w_num, unused_pass_nil, keys, ukeys, flag, code });
    }

    /// `+[NSEvent enterExitEventWithType:location:modifierFlags:timestamp:windowNumber:context:eventNumber:trackingNumber:userData:]`
    pub fn enterExitEventWithTypeLocationModifierFlagsTimestampWindowNumberContextEventNumberTrackingNumberUserData(type_: EventType, location: cg.Point, flags: EventModifierFlags, time: f64, w_num: objc.Integer, unused_pass_nil: ?GraphicsContext, e_num: objc.Integer, t_num: objc.Integer, data: ?*anyopaque) ?Event {
        return class().msgSend(?Event, "enterExitEventWithType:location:modifierFlags:timestamp:windowNumber:context:eventNumber:trackingNumber:userData:", .{ type_, location, flags, time, w_num, unused_pass_nil, e_num, t_num, data });
    }

    /// `+[NSEvent otherEventWithType:location:modifierFlags:timestamp:windowNumber:context:subtype:data1:data2:]`
    pub fn otherEventWithTypeLocationModifierFlagsTimestampWindowNumberContextSubtypeData1Data2(type_: EventType, location: cg.Point, flags: EventModifierFlags, time: f64, w_num: objc.Integer, unused_pass_nil: ?GraphicsContext, subtype_: c_short, d1: objc.Integer, d2: objc.Integer) ?Event {
        return class().msgSend(?Event, "otherEventWithType:location:modifierFlags:timestamp:windowNumber:context:subtype:data1:data2:", .{ type_, location, flags, time, w_num, unused_pass_nil, subtype_, d1, d2 });
    }

    /// `+[NSEvent addGlobalMonitorForEventsMatchingMask:handler:]`
    pub fn addGlobalMonitorForEventsMatchingMaskHandler(mask: EventMask, block: anytype) ?objc.Object {
        return class().msgSend(?objc.Object, "addGlobalMonitorForEventsMatchingMask:handler:", .{ mask, block });
    }

    /// `+[NSEvent addLocalMonitorForEventsMatchingMask:handler:]`
    pub fn addLocalMonitorForEventsMatchingMaskHandler(mask: EventMask, block: anytype) ?objc.Object {
        return class().msgSend(?objc.Object, "addLocalMonitorForEventsMatchingMask:handler:", .{ mask, block });
    }

    /// `+[NSEvent removeMonitor:]`
    pub fn removeMonitor(event_monitor: objc.Object) void {
        return class().msgSend(void, "removeMonitor:", .{event_monitor});
    }

    /// `-[NSEvent type]`
    pub fn @"type"(self: Self) EventType {
        return self.object.msgSend(EventType, "type", .{});
    }

    /// `-[NSEvent modifierFlags]`
    pub fn modifierFlags(self: Self) EventModifierFlags {
        return self.object.msgSend(EventModifierFlags, "modifierFlags", .{});
    }

    /// `-[NSEvent timestamp]`
    pub fn timestamp(self: Self) f64 {
        return self.object.msgSend(f64, "timestamp", .{});
    }

    /// `-[NSEvent window]`
    pub fn window(self: Self) ?Window {
        return self.object.msgSend(?Window, "window", .{});
    }

    /// `-[NSEvent windowNumber]`
    pub fn windowNumber(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "windowNumber", .{});
    }

    /// `-[NSEvent context]`
    pub fn context(self: Self) ?GraphicsContext {
        return self.object.msgSend(?GraphicsContext, "context", .{});
    }

    /// `-[NSEvent clickCount]`
    pub fn clickCount(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "clickCount", .{});
    }

    /// `-[NSEvent buttonNumber]`
    pub fn buttonNumber(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "buttonNumber", .{});
    }

    /// `-[NSEvent eventNumber]`
    pub fn eventNumber(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "eventNumber", .{});
    }

    /// `-[NSEvent pressure]`
    pub fn pressure(self: Self) f32 {
        return self.object.msgSend(f32, "pressure", .{});
    }

    /// `-[NSEvent locationInWindow]`
    pub fn locationInWindow(self: Self) cg.Point {
        return self.object.msgSend(cg.Point, "locationInWindow", .{});
    }

    /// `-[NSEvent deltaX]`
    pub fn deltaX(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "deltaX", .{});
    }

    /// `-[NSEvent deltaY]`
    pub fn deltaY(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "deltaY", .{});
    }

    /// `-[NSEvent deltaZ]`
    pub fn deltaZ(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "deltaZ", .{});
    }

    /// `-[NSEvent hasPreciseScrollingDeltas]`
    pub fn hasPreciseScrollingDeltas(self: Self) bool {
        return self.object.msgSend(bool, "hasPreciseScrollingDeltas", .{});
    }

    /// `-[NSEvent scrollingDeltaX]`
    pub fn scrollingDeltaX(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "scrollingDeltaX", .{});
    }

    /// `-[NSEvent scrollingDeltaY]`
    pub fn scrollingDeltaY(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "scrollingDeltaY", .{});
    }

    /// `-[NSEvent momentumPhase]`
    pub fn momentumPhase(self: Self) EventPhase {
        return self.object.msgSend(EventPhase, "momentumPhase", .{});
    }

    /// `-[NSEvent isDirectionInvertedFromDevice]`
    pub fn isDirectionInvertedFromDevice(self: Self) bool {
        return self.object.msgSend(bool, "isDirectionInvertedFromDevice", .{});
    }

    /// `-[NSEvent characters]`
    pub fn characters(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "characters", .{});
    }

    /// `-[NSEvent charactersIgnoringModifiers]`
    pub fn charactersIgnoringModifiers(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "charactersIgnoringModifiers", .{});
    }

    /// `-[NSEvent isARepeat]`
    pub fn isARepeat(self: Self) bool {
        return self.object.msgSend(bool, "isARepeat", .{});
    }

    /// `-[NSEvent keyCode]`
    pub fn keyCode(self: Self) c_ushort {
        return self.object.msgSend(c_ushort, "keyCode", .{});
    }

    /// `-[NSEvent trackingNumber]`
    pub fn trackingNumber(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "trackingNumber", .{});
    }

    /// `-[NSEvent userData]`
    pub fn userData(self: Self) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "userData", .{});
    }

    /// `-[NSEvent trackingArea]`
    pub fn trackingArea(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "trackingArea", .{});
    }

    /// `-[NSEvent subtype]`
    pub fn subtype(self: Self) EventSubtype {
        return self.object.msgSend(EventSubtype, "subtype", .{});
    }

    /// `-[NSEvent data1]`
    pub fn data1(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "data1", .{});
    }

    /// `-[NSEvent data2]`
    pub fn data2(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "data2", .{});
    }

    /// `-[NSEvent eventRef]`
    pub fn eventRef(self: Self) ?*const anyopaque {
        return self.object.msgSend(?*const anyopaque, "eventRef", .{});
    }

    /// `-[NSEvent CGEvent]`
    pub fn CGEvent(self: Self) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "CGEvent", .{});
    }

    /// `+[NSEvent isMouseCoalescingEnabled]`
    pub fn isMouseCoalescingEnabled() bool {
        return class().msgSend(bool, "isMouseCoalescingEnabled", .{});
    }

    /// `+[NSEvent setMouseCoalescingEnabled:]`
    pub fn setMouseCoalescingEnabled(mouse_coalescing_enabled: bool) void {
        return class().msgSend(void, "setMouseCoalescingEnabled:", .{mouse_coalescing_enabled});
    }

    /// `-[NSEvent magnification]`
    pub fn magnification(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "magnification", .{});
    }

    /// `-[NSEvent deviceID]`
    pub fn deviceID(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "deviceID", .{});
    }

    /// `-[NSEvent rotation]`
    pub fn rotation(self: Self) f32 {
        return self.object.msgSend(f32, "rotation", .{});
    }

    /// `-[NSEvent absoluteX]`
    pub fn absoluteX(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "absoluteX", .{});
    }

    /// `-[NSEvent absoluteY]`
    pub fn absoluteY(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "absoluteY", .{});
    }

    /// `-[NSEvent absoluteZ]`
    pub fn absoluteZ(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "absoluteZ", .{});
    }

    /// `-[NSEvent buttonMask]`
    pub fn buttonMask(self: Self) EventButtonMask {
        return self.object.msgSend(EventButtonMask, "buttonMask", .{});
    }

    /// `-[NSEvent tilt]`
    pub fn tilt(self: Self) cg.Point {
        return self.object.msgSend(cg.Point, "tilt", .{});
    }

    /// `-[NSEvent tangentialPressure]`
    pub fn tangentialPressure(self: Self) f32 {
        return self.object.msgSend(f32, "tangentialPressure", .{});
    }

    /// `-[NSEvent vendorDefined]`
    pub fn vendorDefined(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "vendorDefined", .{});
    }

    /// `-[NSEvent vendorID]`
    pub fn vendorID(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "vendorID", .{});
    }

    /// `-[NSEvent tabletID]`
    pub fn tabletID(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "tabletID", .{});
    }

    /// `-[NSEvent pointingDeviceID]`
    pub fn pointingDeviceID(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "pointingDeviceID", .{});
    }

    /// `-[NSEvent systemTabletID]`
    pub fn systemTabletID(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "systemTabletID", .{});
    }

    /// `-[NSEvent vendorPointingDeviceType]`
    pub fn vendorPointingDeviceType(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "vendorPointingDeviceType", .{});
    }

    /// `-[NSEvent pointingDeviceSerialNumber]`
    pub fn pointingDeviceSerialNumber(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "pointingDeviceSerialNumber", .{});
    }

    /// `-[NSEvent uniqueID]`
    pub fn uniqueID(self: Self) c_ulonglong {
        return self.object.msgSend(c_ulonglong, "uniqueID", .{});
    }

    /// `-[NSEvent capabilityMask]`
    pub fn capabilityMask(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "capabilityMask", .{});
    }

    /// `-[NSEvent pointingDeviceType]`
    pub fn pointingDeviceType(self: Self) PointingDeviceType {
        return self.object.msgSend(PointingDeviceType, "pointingDeviceType", .{});
    }

    /// `-[NSEvent isEnteringProximity]`
    pub fn isEnteringProximity(self: Self) bool {
        return self.object.msgSend(bool, "isEnteringProximity", .{});
    }

    /// `-[NSEvent phase]`
    pub fn phase(self: Self) EventPhase {
        return self.object.msgSend(EventPhase, "phase", .{});
    }

    /// `-[NSEvent stage]`
    pub fn stage(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "stage", .{});
    }

    /// `-[NSEvent stageTransition]`
    pub fn stageTransition(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "stageTransition", .{});
    }

    /// `-[NSEvent associatedEventsMask]`
    pub fn associatedEventsMask(self: Self) EventMask {
        return self.object.msgSend(EventMask, "associatedEventsMask", .{});
    }

    /// `-[NSEvent pressureBehavior]`
    pub fn pressureBehavior(self: Self) PressureBehavior {
        return self.object.msgSend(PressureBehavior, "pressureBehavior", .{});
    }

    /// `+[NSEvent isTouchSwipeNavigationEnabled]`
    pub fn isTouchSwipeNavigationEnabled() bool {
        return class().msgSend(bool, "isTouchSwipeNavigationEnabled", .{});
    }

    /// `+[NSEvent isSwipeTrackingFromScrollEventsEnabled]`
    pub fn isSwipeTrackingFromScrollEventsEnabled() bool {
        return class().msgSend(bool, "isSwipeTrackingFromScrollEventsEnabled", .{});
    }

    /// `+[NSEvent mouseLocation]`
    pub fn mouseLocation() cg.Point {
        return class().msgSend(cg.Point, "mouseLocation", .{});
    }

    /// `+[NSEvent modifierFlags]`
    pub fn classModifierFlags() EventModifierFlags {
        return class().msgSend(EventModifierFlags, "modifierFlags", .{});
    }

    /// `+[NSEvent pressedMouseButtons]`
    pub fn pressedMouseButtons() objc.UInteger {
        return class().msgSend(objc.UInteger, "pressedMouseButtons", .{});
    }

    /// `+[NSEvent doubleClickInterval]`
    pub fn doubleClickInterval() f64 {
        return class().msgSend(f64, "doubleClickInterval", .{});
    }

    /// `+[NSEvent keyRepeatDelay]`
    pub fn keyRepeatDelay() f64 {
        return class().msgSend(f64, "keyRepeatDelay", .{});
    }

    /// `+[NSEvent keyRepeatInterval]`
    pub fn keyRepeatInterval() f64 {
        return class().msgSend(f64, "keyRepeatInterval", .{});
    }
};

/// `NSMenu`, a subclass of `NSObject`.
pub const Menu = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSMenu";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSMenu`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSMenu initWithTitle:]`
    pub fn initWithTitle(self: Self, title_: foundation.String) Menu {
        return self.object.msgSend(Menu, "initWithTitle:", .{title_});
    }

    /// `-[NSMenu initWithCoder:]`
    pub fn initWithCoder(self: Self, coder: objc.Object) Menu {
        return self.object.msgSend(Menu, "initWithCoder:", .{coder});
    }

    /// `+[NSMenu popUpContextMenu:withEvent:forView:]`
    pub fn popUpContextMenuWithEventForView(menu: Menu, event: Event, view: View) void {
        return class().msgSend(void, "popUpContextMenu:withEvent:forView:", .{ menu, event, view });
    }

    /// `+[NSMenu popUpContextMenu:withEvent:forView:withFont:]`
    pub fn popUpContextMenuWithEventForViewWithFont(menu: Menu, event: Event, view: View, font_: ?objc.Object) void {
        return class().msgSend(void, "popUpContextMenu:withEvent:forView:withFont:", .{ menu, event, view, font_ });
    }

    /// `-[NSMenu popUpMenuPositioningItem:atLocation:inView:]`
    pub fn popUpMenuPositioningItemAtLocationInView(self: Self, item: ?MenuItem, location: cg.Point, view: ?View) bool {
        return self.object.msgSend(bool, "popUpMenuPositioningItem:atLocation:inView:", .{ item, location, view });
    }

    /// `+[NSMenu setMenuBarVisible:]`
    pub fn setMenuBarVisible(visible: bool) void {
        return class().msgSend(void, "setMenuBarVisible:", .{visible});
    }

    /// `+[NSMenu menuBarVisible]`
    pub fn menuBarVisible() bool {
        return class().msgSend(bool, "menuBarVisible", .{});
    }

    /// `-[NSMenu insertItem:atIndex:]`
    pub fn insertItemAtIndex(self: Self, new_item: MenuItem, index: objc.Integer) void {
        return self.object.msgSend(void, "insertItem:atIndex:", .{ new_item, index });
    }

    /// `-[NSMenu addItem:]`
    pub fn addItem(self: Self, new_item: MenuItem) void {
        return self.object.msgSend(void, "addItem:", .{new_item});
    }

    /// `-[NSMenu insertItemWithTitle:action:keyEquivalent:atIndex:]`
    pub fn insertItemWithTitleActionKeyEquivalentAtIndex(self: Self, string: foundation.String, selector: ?objc.Sel, char_code: foundation.String, index: objc.Integer) MenuItem {
        return self.object.msgSend(MenuItem, "insertItemWithTitle:action:keyEquivalent:atIndex:", .{ string, selector, char_code, index });
    }

    /// `-[NSMenu addItemWithTitle:action:keyEquivalent:]`
    pub fn addItemWithTitleActionKeyEquivalent(self: Self, string: foundation.String, selector: ?objc.Sel, char_code: foundation.String) MenuItem {
        return self.object.msgSend(MenuItem, "addItemWithTitle:action:keyEquivalent:", .{ string, selector, char_code });
    }

    /// `-[NSMenu removeItemAtIndex:]`
    pub fn removeItemAtIndex(self: Self, index: objc.Integer) void {
        return self.object.msgSend(void, "removeItemAtIndex:", .{index});
    }

    /// `-[NSMenu removeItem:]`
    pub fn removeItem(self: Self, item: MenuItem) void {
        return self.object.msgSend(void, "removeItem:", .{item});
    }

    /// `-[NSMenu setSubmenu:forItem:]`
    pub fn setSubmenuForItem(self: Self, menu: ?Menu, item: MenuItem) void {
        return self.object.msgSend(void, "setSubmenu:forItem:", .{ menu, item });
    }

    /// `-[NSMenu removeAllItems]`
    pub fn removeAllItems(self: Self) void {
        return self.object.msgSend(void, "removeAllItems", .{});
    }

    /// `-[NSMenu itemAtIndex:]`
    pub fn itemAtIndex(self: Self, index: objc.Integer) ?MenuItem {
        return self.object.msgSend(?MenuItem, "itemAtIndex:", .{index});
    }

    /// `-[NSMenu indexOfItem:]`
    pub fn indexOfItem(self: Self, item: MenuItem) objc.Integer {
        return self.object.msgSend(objc.Integer, "indexOfItem:", .{item});
    }

    /// `-[NSMenu indexOfItemWithTitle:]`
    pub fn indexOfItemWithTitle(self: Self, title_: foundation.String) objc.Integer {
        return self.object.msgSend(objc.Integer, "indexOfItemWithTitle:", .{title_});
    }

    /// `-[NSMenu indexOfItemWithTag:]`
    pub fn indexOfItemWithTag(self: Self, tag: objc.Integer) objc.Integer {
        return self.object.msgSend(objc.Integer, "indexOfItemWithTag:", .{tag});
    }

    /// `-[NSMenu indexOfItemWithRepresentedObject:]`
    pub fn indexOfItemWithRepresentedObject(self: Self, object_: ?objc.Object) objc.Integer {
        return self.object.msgSend(objc.Integer, "indexOfItemWithRepresentedObject:", .{object_});
    }

    /// `-[NSMenu indexOfItemWithSubmenu:]`
    pub fn indexOfItemWithSubmenu(self: Self, submenu: ?Menu) objc.Integer {
        return self.object.msgSend(objc.Integer, "indexOfItemWithSubmenu:", .{submenu});
    }

    /// `-[NSMenu indexOfItemWithTarget:andAction:]`
    pub fn indexOfItemWithTargetAndAction(self: Self, target: ?objc.Object, action_selector: ?objc.Sel) objc.Integer {
        return self.object.msgSend(objc.Integer, "indexOfItemWithTarget:andAction:", .{ target, action_selector });
    }

    /// `-[NSMenu itemWithTitle:]`
    pub fn itemWithTitle(self: Self, title_: foundation.String) ?MenuItem {
        return self.object.msgSend(?MenuItem, "itemWithTitle:", .{title_});
    }

    /// `-[NSMenu itemWithTag:]`
    pub fn itemWithTag(self: Self, tag: objc.Integer) ?MenuItem {
        return self.object.msgSend(?MenuItem, "itemWithTag:", .{tag});
    }

    /// `-[NSMenu update]`
    pub fn update(self: Self) void {
        return self.object.msgSend(void, "update", .{});
    }

    /// `-[NSMenu performKeyEquivalent:]`
    pub fn performKeyEquivalent(self: Self, event: Event) bool {
        return self.object.msgSend(bool, "performKeyEquivalent:", .{event});
    }

    /// `-[NSMenu itemChanged:]`
    pub fn itemChanged(self: Self, item: MenuItem) void {
        return self.object.msgSend(void, "itemChanged:", .{item});
    }

    /// `-[NSMenu performActionForItemAtIndex:]`
    pub fn performActionForItemAtIndex(self: Self, index: objc.Integer) void {
        return self.object.msgSend(void, "performActionForItemAtIndex:", .{index});
    }

    /// `-[NSMenu cancelTracking]`
    pub fn cancelTracking(self: Self) void {
        return self.object.msgSend(void, "cancelTracking", .{});
    }

    /// `-[NSMenu cancelTrackingWithoutAnimation]`
    pub fn cancelTrackingWithoutAnimation(self: Self) void {
        return self.object.msgSend(void, "cancelTrackingWithoutAnimation", .{});
    }

    /// `-[NSMenu title]`
    pub fn title(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "title", .{});
    }

    /// `-[NSMenu setTitle:]`
    pub fn setTitle(self: Self, title_: foundation.String) void {
        return self.object.msgSend(void, "setTitle:", .{title_});
    }

    /// `-[NSMenu supermenu]`
    pub fn supermenu(self: Self) ?Menu {
        return self.object.msgSend(?Menu, "supermenu", .{});
    }

    /// `-[NSMenu setSupermenu:]`
    pub fn setSupermenu(self: Self, supermenu_: ?Menu) void {
        return self.object.msgSend(void, "setSupermenu:", .{supermenu_});
    }

    /// `-[NSMenu itemArray]`
    pub fn itemArray(self: Self) foundation.Array(MenuItem) {
        return self.object.msgSend(foundation.Array(MenuItem), "itemArray", .{});
    }

    /// `-[NSMenu setItemArray:]`
    pub fn setItemArray(self: Self, item_array: foundation.Array(MenuItem)) void {
        return self.object.msgSend(void, "setItemArray:", .{item_array});
    }

    /// `-[NSMenu numberOfItems]`
    pub fn numberOfItems(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "numberOfItems", .{});
    }

    /// `-[NSMenu autoenablesItems]`
    pub fn autoenablesItems(self: Self) bool {
        return self.object.msgSend(bool, "autoenablesItems", .{});
    }

    /// `-[NSMenu setAutoenablesItems:]`
    pub fn setAutoenablesItems(self: Self, autoenables_items: bool) void {
        return self.object.msgSend(void, "setAutoenablesItems:", .{autoenables_items});
    }

    /// `-[NSMenu delegate]`
    pub fn delegate(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "delegate", .{});
    }

    /// `-[NSMenu setDelegate:]`
    pub fn setDelegate(self: Self, delegate_: ?objc.Object) void {
        return self.object.msgSend(void, "setDelegate:", .{delegate_});
    }

    /// `-[NSMenu menuBarHeight]`
    pub fn menuBarHeight(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "menuBarHeight", .{});
    }

    /// `-[NSMenu highlightedItem]`
    pub fn highlightedItem(self: Self) ?MenuItem {
        return self.object.msgSend(?MenuItem, "highlightedItem", .{});
    }

    /// `-[NSMenu minimumWidth]`
    pub fn minimumWidth(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "minimumWidth", .{});
    }

    /// `-[NSMenu setMinimumWidth:]`
    pub fn setMinimumWidth(self: Self, minimum_width: cg.Float) void {
        return self.object.msgSend(void, "setMinimumWidth:", .{minimum_width});
    }

    /// `-[NSMenu size]`
    pub fn size(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "size", .{});
    }

    /// `-[NSMenu font]`
    pub fn font(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "font", .{});
    }

    /// `-[NSMenu setFont:]`
    pub fn setFont(self: Self, font_: ?objc.Object) void {
        return self.object.msgSend(void, "setFont:", .{font_});
    }

    /// `-[NSMenu allowsContextMenuPlugIns]`
    pub fn allowsContextMenuPlugIns(self: Self) bool {
        return self.object.msgSend(bool, "allowsContextMenuPlugIns", .{});
    }

    /// `-[NSMenu setAllowsContextMenuPlugIns:]`
    pub fn setAllowsContextMenuPlugIns(self: Self, allows_context_menu_plug_ins: bool) void {
        return self.object.msgSend(void, "setAllowsContextMenuPlugIns:", .{allows_context_menu_plug_ins});
    }

    /// `-[NSMenu automaticallyInsertsWritingToolsItems]`
    pub fn automaticallyInsertsWritingToolsItems(self: Self) bool {
        return self.object.msgSend(bool, "automaticallyInsertsWritingToolsItems", .{});
    }

    /// `-[NSMenu setAutomaticallyInsertsWritingToolsItems:]`
    pub fn setAutomaticallyInsertsWritingToolsItems(self: Self, automatically_inserts_writing_tools_items: bool) void {
        return self.object.msgSend(void, "setAutomaticallyInsertsWritingToolsItems:", .{automatically_inserts_writing_tools_items});
    }

    /// `-[NSMenu showsStateColumn]`
    pub fn showsStateColumn(self: Self) bool {
        return self.object.msgSend(bool, "showsStateColumn", .{});
    }

    /// `-[NSMenu setShowsStateColumn:]`
    pub fn setShowsStateColumn(self: Self, shows_state_column: bool) void {
        return self.object.msgSend(void, "setShowsStateColumn:", .{shows_state_column});
    }

    /// `-[NSMenu userInterfaceLayoutDirection]`
    pub fn userInterfaceLayoutDirection(self: Self) UserInterfaceLayoutDirection {
        return self.object.msgSend(UserInterfaceLayoutDirection, "userInterfaceLayoutDirection", .{});
    }

    /// `-[NSMenu setUserInterfaceLayoutDirection:]`
    pub fn setUserInterfaceLayoutDirection(self: Self, user_interface_layout_direction: UserInterfaceLayoutDirection) void {
        return self.object.msgSend(void, "setUserInterfaceLayoutDirection:", .{user_interface_layout_direction});
    }

    /// `-[NSMenu propertiesToUpdate]`
    pub fn propertiesToUpdate(self: Self) MenuProperties {
        return self.object.msgSend(MenuProperties, "propertiesToUpdate", .{});
    }
};

/// `NSMenuItem`, a subclass of `NSObject`.
pub const MenuItem = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSMenuItem";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSMenuItem`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `+[NSMenuItem separatorItem]`
    pub fn separatorItem() MenuItem {
        return class().msgSend(MenuItem, "separatorItem", .{});
    }

    /// `+[NSMenuItem sectionHeaderWithTitle:]`
    pub fn sectionHeaderWithTitle(title_: foundation.String) MenuItem {
        return class().msgSend(MenuItem, "sectionHeaderWithTitle:", .{title_});
    }

    /// `-[NSMenuItem initWithTitle:action:keyEquivalent:]`
    pub fn initWithTitleActionKeyEquivalent(self: Self, string: foundation.String, selector: ?objc.Sel, char_code: foundation.String) MenuItem {
        return self.object.msgSend(MenuItem, "initWithTitle:action:keyEquivalent:", .{ string, selector, char_code });
    }

    /// `-[NSMenuItem initWithCoder:]`
    pub fn initWithCoder(self: Self, coder: objc.Object) MenuItem {
        return self.object.msgSend(MenuItem, "initWithCoder:", .{coder});
    }

    /// `+[NSMenuItem usesUserKeyEquivalents]`
    pub fn usesUserKeyEquivalents() bool {
        return class().msgSend(bool, "usesUserKeyEquivalents", .{});
    }

    /// `+[NSMenuItem setUsesUserKeyEquivalents:]`
    pub fn setUsesUserKeyEquivalents(uses_user_key_equivalents: bool) void {
        return class().msgSend(void, "setUsesUserKeyEquivalents:", .{uses_user_key_equivalents});
    }

    /// `+[NSMenuItem writingToolsItems]`
    pub fn writingToolsItems() ?foundation.Array(MenuItem) {
        return class().msgSend(?foundation.Array(MenuItem), "writingToolsItems", .{});
    }

    /// `-[NSMenuItem menu]`
    pub fn menu(self: Self) ?Menu {
        return self.object.msgSend(?Menu, "menu", .{});
    }

    /// `-[NSMenuItem setMenu:]`
    pub fn setMenu(self: Self, menu_: ?Menu) void {
        return self.object.msgSend(void, "setMenu:", .{menu_});
    }

    /// `-[NSMenuItem hasSubmenu]`
    pub fn hasSubmenu(self: Self) bool {
        return self.object.msgSend(bool, "hasSubmenu", .{});
    }

    /// `-[NSMenuItem submenu]`
    pub fn submenu(self: Self) ?Menu {
        return self.object.msgSend(?Menu, "submenu", .{});
    }

    /// `-[NSMenuItem setSubmenu:]`
    pub fn setSubmenu(self: Self, submenu_: ?Menu) void {
        return self.object.msgSend(void, "setSubmenu:", .{submenu_});
    }

    /// `-[NSMenuItem parentItem]`
    pub fn parentItem(self: Self) ?MenuItem {
        return self.object.msgSend(?MenuItem, "parentItem", .{});
    }

    /// `-[NSMenuItem title]`
    pub fn title(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "title", .{});
    }

    /// `-[NSMenuItem setTitle:]`
    pub fn setTitle(self: Self, title_: foundation.String) void {
        return self.object.msgSend(void, "setTitle:", .{title_});
    }

    /// `-[NSMenuItem attributedTitle]`
    pub fn attributedTitle(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "attributedTitle", .{});
    }

    /// `-[NSMenuItem setAttributedTitle:]`
    pub fn setAttributedTitle(self: Self, attributed_title: ?objc.Object) void {
        return self.object.msgSend(void, "setAttributedTitle:", .{attributed_title});
    }

    /// `-[NSMenuItem subtitle]`
    pub fn subtitle(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "subtitle", .{});
    }

    /// `-[NSMenuItem setSubtitle:]`
    pub fn setSubtitle(self: Self, subtitle_: ?foundation.String) void {
        return self.object.msgSend(void, "setSubtitle:", .{subtitle_});
    }

    /// `-[NSMenuItem isSeparatorItem]`
    pub fn isSeparatorItem(self: Self) bool {
        return self.object.msgSend(bool, "isSeparatorItem", .{});
    }

    /// `-[NSMenuItem isSectionHeader]`
    pub fn isSectionHeader(self: Self) bool {
        return self.object.msgSend(bool, "isSectionHeader", .{});
    }

    /// `-[NSMenuItem keyEquivalent]`
    pub fn keyEquivalent(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "keyEquivalent", .{});
    }

    /// `-[NSMenuItem setKeyEquivalent:]`
    pub fn setKeyEquivalent(self: Self, key_equivalent: foundation.String) void {
        return self.object.msgSend(void, "setKeyEquivalent:", .{key_equivalent});
    }

    /// `-[NSMenuItem keyEquivalentModifierMask]`
    pub fn keyEquivalentModifierMask(self: Self) EventModifierFlags {
        return self.object.msgSend(EventModifierFlags, "keyEquivalentModifierMask", .{});
    }

    /// `-[NSMenuItem setKeyEquivalentModifierMask:]`
    pub fn setKeyEquivalentModifierMask(self: Self, key_equivalent_modifier_mask: EventModifierFlags) void {
        return self.object.msgSend(void, "setKeyEquivalentModifierMask:", .{key_equivalent_modifier_mask});
    }

    /// `-[NSMenuItem userKeyEquivalent]`
    pub fn userKeyEquivalent(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "userKeyEquivalent", .{});
    }

    /// `-[NSMenuItem allowsKeyEquivalentWhenHidden]`
    pub fn allowsKeyEquivalentWhenHidden(self: Self) bool {
        return self.object.msgSend(bool, "allowsKeyEquivalentWhenHidden", .{});
    }

    /// `-[NSMenuItem setAllowsKeyEquivalentWhenHidden:]`
    pub fn setAllowsKeyEquivalentWhenHidden(self: Self, allows_key_equivalent_when_hidden: bool) void {
        return self.object.msgSend(void, "setAllowsKeyEquivalentWhenHidden:", .{allows_key_equivalent_when_hidden});
    }

    /// `-[NSMenuItem allowsAutomaticKeyEquivalentLocalization]`
    pub fn allowsAutomaticKeyEquivalentLocalization(self: Self) bool {
        return self.object.msgSend(bool, "allowsAutomaticKeyEquivalentLocalization", .{});
    }

    /// `-[NSMenuItem setAllowsAutomaticKeyEquivalentLocalization:]`
    pub fn setAllowsAutomaticKeyEquivalentLocalization(self: Self, allows_automatic_key_equivalent_localization: bool) void {
        return self.object.msgSend(void, "setAllowsAutomaticKeyEquivalentLocalization:", .{allows_automatic_key_equivalent_localization});
    }

    /// `-[NSMenuItem allowsAutomaticKeyEquivalentMirroring]`
    pub fn allowsAutomaticKeyEquivalentMirroring(self: Self) bool {
        return self.object.msgSend(bool, "allowsAutomaticKeyEquivalentMirroring", .{});
    }

    /// `-[NSMenuItem setAllowsAutomaticKeyEquivalentMirroring:]`
    pub fn setAllowsAutomaticKeyEquivalentMirroring(self: Self, allows_automatic_key_equivalent_mirroring: bool) void {
        return self.object.msgSend(void, "setAllowsAutomaticKeyEquivalentMirroring:", .{allows_automatic_key_equivalent_mirroring});
    }

    /// `-[NSMenuItem image]`
    pub fn image(self: Self) ?Image {
        return self.object.msgSend(?Image, "image", .{});
    }

    /// `-[NSMenuItem setImage:]`
    pub fn setImage(self: Self, image_: ?Image) void {
        return self.object.msgSend(void, "setImage:", .{image_});
    }

    /// `-[NSMenuItem preferredImageVisibility]`
    pub fn preferredImageVisibility(self: Self) MenuItemImageVisibility {
        return self.object.msgSend(MenuItemImageVisibility, "preferredImageVisibility", .{});
    }

    /// `-[NSMenuItem setPreferredImageVisibility:]`
    pub fn setPreferredImageVisibility(self: Self, preferred_image_visibility: MenuItemImageVisibility) void {
        return self.object.msgSend(void, "setPreferredImageVisibility:", .{preferred_image_visibility});
    }

    /// `-[NSMenuItem state]`
    pub fn state(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "state", .{});
    }

    /// `-[NSMenuItem setState:]`
    pub fn setState(self: Self, state_: objc.Integer) void {
        return self.object.msgSend(void, "setState:", .{state_});
    }

    /// `-[NSMenuItem onStateImage]`
    pub fn onStateImage(self: Self) Image {
        return self.object.msgSend(Image, "onStateImage", .{});
    }

    /// `-[NSMenuItem setOnStateImage:]`
    pub fn setOnStateImage(self: Self, on_state_image: ?Image) void {
        return self.object.msgSend(void, "setOnStateImage:", .{on_state_image});
    }

    /// `-[NSMenuItem offStateImage]`
    pub fn offStateImage(self: Self) ?Image {
        return self.object.msgSend(?Image, "offStateImage", .{});
    }

    /// `-[NSMenuItem setOffStateImage:]`
    pub fn setOffStateImage(self: Self, off_state_image: ?Image) void {
        return self.object.msgSend(void, "setOffStateImage:", .{off_state_image});
    }

    /// `-[NSMenuItem mixedStateImage]`
    pub fn mixedStateImage(self: Self) Image {
        return self.object.msgSend(Image, "mixedStateImage", .{});
    }

    /// `-[NSMenuItem setMixedStateImage:]`
    pub fn setMixedStateImage(self: Self, mixed_state_image: ?Image) void {
        return self.object.msgSend(void, "setMixedStateImage:", .{mixed_state_image});
    }

    /// `-[NSMenuItem isEnabled]`
    pub fn isEnabled(self: Self) bool {
        return self.object.msgSend(bool, "isEnabled", .{});
    }

    /// `-[NSMenuItem setEnabled:]`
    pub fn setEnabled(self: Self, enabled: bool) void {
        return self.object.msgSend(void, "setEnabled:", .{enabled});
    }

    /// `-[NSMenuItem isAlternate]`
    pub fn isAlternate(self: Self) bool {
        return self.object.msgSend(bool, "isAlternate", .{});
    }

    /// `-[NSMenuItem setAlternate:]`
    pub fn setAlternate(self: Self, alternate: bool) void {
        return self.object.msgSend(void, "setAlternate:", .{alternate});
    }

    /// `-[NSMenuItem indentationLevel]`
    pub fn indentationLevel(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "indentationLevel", .{});
    }

    /// `-[NSMenuItem setIndentationLevel:]`
    pub fn setIndentationLevel(self: Self, indentation_level: objc.Integer) void {
        return self.object.msgSend(void, "setIndentationLevel:", .{indentation_level});
    }

    /// `-[NSMenuItem target]`
    pub fn target(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "target", .{});
    }

    /// `-[NSMenuItem setTarget:]`
    pub fn setTarget(self: Self, target_: ?objc.Object) void {
        return self.object.msgSend(void, "setTarget:", .{target_});
    }

    /// `-[NSMenuItem action]`
    pub fn action(self: Self) ?objc.Sel {
        return self.object.msgSend(?objc.Sel, "action", .{});
    }

    /// `-[NSMenuItem setAction:]`
    pub fn setAction(self: Self, action_: ?objc.Sel) void {
        return self.object.msgSend(void, "setAction:", .{action_});
    }

    /// `-[NSMenuItem tag]`
    pub fn tag(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "tag", .{});
    }

    /// `-[NSMenuItem setTag:]`
    pub fn setTag(self: Self, tag_: objc.Integer) void {
        return self.object.msgSend(void, "setTag:", .{tag_});
    }

    /// `-[NSMenuItem representedObject]`
    pub fn representedObject(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "representedObject", .{});
    }

    /// `-[NSMenuItem setRepresentedObject:]`
    pub fn setRepresentedObject(self: Self, represented_object: ?objc.Object) void {
        return self.object.msgSend(void, "setRepresentedObject:", .{represented_object});
    }

    /// `-[NSMenuItem view]`
    pub fn view(self: Self) ?View {
        return self.object.msgSend(?View, "view", .{});
    }

    /// `-[NSMenuItem setView:]`
    pub fn setView(self: Self, view_: ?View) void {
        return self.object.msgSend(void, "setView:", .{view_});
    }

    /// `-[NSMenuItem isHighlighted]`
    pub fn isHighlighted(self: Self) bool {
        return self.object.msgSend(bool, "isHighlighted", .{});
    }

    /// `-[NSMenuItem isHidden]`
    pub fn isHidden(self: Self) bool {
        return self.object.msgSend(bool, "isHidden", .{});
    }

    /// `-[NSMenuItem setHidden:]`
    pub fn setHidden(self: Self, hidden: bool) void {
        return self.object.msgSend(void, "setHidden:", .{hidden});
    }

    /// `-[NSMenuItem isHiddenOrHasHiddenAncestor]`
    pub fn isHiddenOrHasHiddenAncestor(self: Self) bool {
        return self.object.msgSend(bool, "isHiddenOrHasHiddenAncestor", .{});
    }

    /// `-[NSMenuItem toolTip]`
    pub fn toolTip(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "toolTip", .{});
    }

    /// `-[NSMenuItem setToolTip:]`
    pub fn setToolTip(self: Self, tool_tip: ?foundation.String) void {
        return self.object.msgSend(void, "setToolTip:", .{tool_tip});
    }

    /// `-[NSMenuItem badge]`
    pub fn badge(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "badge", .{});
    }

    /// `-[NSMenuItem setBadge:]`
    pub fn setBadge(self: Self, badge_: ?objc.Object) void {
        return self.object.msgSend(void, "setBadge:", .{badge_});
    }
};

/// `NSImage`, a subclass of `NSObject`.
pub const Image = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSImage";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSImage`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `+[NSImage imageNamed:]`
    pub fn imageNamed(name_: ?foundation.String) ?Image {
        return class().msgSend(?Image, "imageNamed:", .{name_});
    }

    /// `+[NSImage imageWithSystemSymbolName:accessibilityDescription:]`
    pub fn imageWithSystemSymbolNameAccessibilityDescription(name_: foundation.String, description: ?foundation.String) ?Image {
        return class().msgSend(?Image, "imageWithSystemSymbolName:accessibilityDescription:", .{ name_, description });
    }

    /// `+[NSImage imageWithSystemSymbolName:variableValue:accessibilityDescription:]`
    pub fn imageWithSystemSymbolNameVariableValueAccessibilityDescription(name_: foundation.String, value: f64, description: ?foundation.String) ?Image {
        return class().msgSend(?Image, "imageWithSystemSymbolName:variableValue:accessibilityDescription:", .{ name_, value, description });
    }

    /// `+[NSImage imageWithSymbolName:variableValue:]`
    pub fn imageWithSymbolNameVariableValue(name_: foundation.String, value: f64) ?Image {
        return class().msgSend(?Image, "imageWithSymbolName:variableValue:", .{ name_, value });
    }

    /// `+[NSImage imageWithSymbolName:bundle:variableValue:]`
    pub fn imageWithSymbolNameBundleVariableValue(name_: foundation.String, bundle: ?objc.Object, value: f64) ?Image {
        return class().msgSend(?Image, "imageWithSymbolName:bundle:variableValue:", .{ name_, bundle, value });
    }

    /// `-[NSImage initWithSize:]`
    pub fn initWithSize(self: Self, size_: cg.Size) Image {
        return self.object.msgSend(Image, "initWithSize:", .{size_});
    }

    /// `-[NSImage initWithCoder:]`
    pub fn initWithCoder(self: Self, coder: objc.Object) Image {
        return self.object.msgSend(Image, "initWithCoder:", .{coder});
    }

    /// `-[NSImage initWithData:]`
    pub fn initWithData(self: Self, data: foundation.Data) ?Image {
        return self.object.msgSend(?Image, "initWithData:", .{data});
    }

    /// `-[NSImage initWithContentsOfFile:]`
    pub fn initWithContentsOfFile(self: Self, file_name: foundation.String) ?Image {
        return self.object.msgSend(?Image, "initWithContentsOfFile:", .{file_name});
    }

    /// `-[NSImage initWithContentsOfURL:]`
    pub fn initWithContentsOfURL(self: Self, url: foundation.Url) ?Image {
        return self.object.msgSend(?Image, "initWithContentsOfURL:", .{url});
    }

    /// `-[NSImage initByReferencingFile:]`
    pub fn initByReferencingFile(self: Self, file_name: foundation.String) ?Image {
        return self.object.msgSend(?Image, "initByReferencingFile:", .{file_name});
    }

    /// `-[NSImage initByReferencingURL:]`
    pub fn initByReferencingURL(self: Self, url: foundation.Url) Image {
        return self.object.msgSend(Image, "initByReferencingURL:", .{url});
    }

    /// `-[NSImage initWithPasteboard:]`
    pub fn initWithPasteboard(self: Self, pasteboard: objc.Object) ?Image {
        return self.object.msgSend(?Image, "initWithPasteboard:", .{pasteboard});
    }

    /// `-[NSImage initWithDataIgnoringOrientation:]`
    pub fn initWithDataIgnoringOrientation(self: Self, data: foundation.Data) ?Image {
        return self.object.msgSend(?Image, "initWithDataIgnoringOrientation:", .{data});
    }

    /// `+[NSImage imageWithSize:flipped:drawingHandler:]`
    pub fn imageWithSizeFlippedDrawingHandler(size_: cg.Size, drawing_handler_should_be_called_with_flipped_context: bool, drawing_handler: anytype) Image {
        return class().msgSend(Image, "imageWithSize:flipped:drawingHandler:", .{ size_, drawing_handler_should_be_called_with_flipped_context, drawing_handler });
    }

    /// `-[NSImage setName:]`
    pub fn setName(self: Self, string: ?foundation.String) bool {
        return self.object.msgSend(bool, "setName:", .{string});
    }

    /// `-[NSImage name]`
    pub fn name(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "name", .{});
    }

    /// `-[NSImage drawAtPoint:fromRect:operation:fraction:]`
    pub fn drawAtPointFromRectOperationFraction(self: Self, point: cg.Point, from_rect: cg.Rect, op: CompositingOperation, delta: cg.Float) void {
        return self.object.msgSend(void, "drawAtPoint:fromRect:operation:fraction:", .{ point, from_rect, op, delta });
    }

    /// `-[NSImage drawInRect:fromRect:operation:fraction:]`
    pub fn drawInRectFromRectOperationFraction(self: Self, rect: cg.Rect, from_rect: cg.Rect, op: CompositingOperation, delta: cg.Float) void {
        return self.object.msgSend(void, "drawInRect:fromRect:operation:fraction:", .{ rect, from_rect, op, delta });
    }

    /// `-[NSImage drawInRect:fromRect:operation:fraction:respectFlipped:hints:]`
    pub fn drawInRectFromRectOperationFractionRespectFlippedHints(self: Self, dst_space_portion_rect: cg.Rect, src_space_portion_rect: cg.Rect, op: CompositingOperation, requested_alpha: cg.Float, respect_context_is_flipped: bool, hints: ?foundation.Dictionary(objc.Object, objc.Object)) void {
        return self.object.msgSend(void, "drawInRect:fromRect:operation:fraction:respectFlipped:hints:", .{ dst_space_portion_rect, src_space_portion_rect, op, requested_alpha, respect_context_is_flipped, hints });
    }

    /// `-[NSImage drawRepresentation:inRect:]`
    pub fn drawRepresentationInRect(self: Self, image_rep: ImageRep, rect: cg.Rect) bool {
        return self.object.msgSend(bool, "drawRepresentation:inRect:", .{ image_rep, rect });
    }

    /// `-[NSImage drawInRect:]`
    pub fn drawInRect(self: Self, rect: cg.Rect) void {
        return self.object.msgSend(void, "drawInRect:", .{rect});
    }

    /// `-[NSImage recache]`
    pub fn recache(self: Self) void {
        return self.object.msgSend(void, "recache", .{});
    }

    /// `-[NSImage TIFFRepresentationUsingCompression:factor:]`
    pub fn TIFFRepresentationUsingCompressionFactor(self: Self, comp: TIFFCompression, factor: f32) ?foundation.Data {
        return self.object.msgSend(?foundation.Data, "TIFFRepresentationUsingCompression:factor:", .{ comp, factor });
    }

    /// `-[NSImage addRepresentations:]`
    pub fn addRepresentations(self: Self, image_reps: foundation.Array(ImageRep)) void {
        return self.object.msgSend(void, "addRepresentations:", .{image_reps});
    }

    /// `-[NSImage addRepresentation:]`
    pub fn addRepresentation(self: Self, image_rep: ImageRep) void {
        return self.object.msgSend(void, "addRepresentation:", .{image_rep});
    }

    /// `-[NSImage removeRepresentation:]`
    pub fn removeRepresentation(self: Self, image_rep: ImageRep) void {
        return self.object.msgSend(void, "removeRepresentation:", .{image_rep});
    }

    /// `+[NSImage canInitWithPasteboard:]`
    pub fn canInitWithPasteboard(pasteboard: objc.Object) bool {
        return class().msgSend(bool, "canInitWithPasteboard:", .{pasteboard});
    }

    /// `-[NSImage initWithCGImage:size:]`
    pub fn initWithCGImageSize(self: Self, cg_image: ?*anyopaque, size_: cg.Size) Image {
        return self.object.msgSend(Image, "initWithCGImage:size:", .{ cg_image, size_ });
    }

    /// `-[NSImage CGImageForProposedRect:context:hints:]`
    pub fn CGImageForProposedRectContextHints(self: Self, proposed_dest_rect: ?*cg.Rect, reference_context: ?GraphicsContext, hints: ?foundation.Dictionary(objc.Object, objc.Object)) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "CGImageForProposedRect:context:hints:", .{ proposed_dest_rect, reference_context, hints });
    }

    /// `-[NSImage bestRepresentationForRect:context:hints:]`
    pub fn bestRepresentationForRectContextHints(self: Self, rect: cg.Rect, reference_context: ?GraphicsContext, hints: ?foundation.Dictionary(objc.Object, objc.Object)) ?ImageRep {
        return self.object.msgSend(?ImageRep, "bestRepresentationForRect:context:hints:", .{ rect, reference_context, hints });
    }

    /// `-[NSImage hitTestRect:withImageDestinationRect:context:hints:flipped:]`
    pub fn hitTestRectWithImageDestinationRectContextHintsFlipped(self: Self, test_rect_dest_space: cg.Rect, image_rect_dest_space: cg.Rect, context: ?GraphicsContext, hints: ?foundation.Dictionary(objc.Object, objc.Object), flipped: bool) bool {
        return self.object.msgSend(bool, "hitTestRect:withImageDestinationRect:context:hints:flipped:", .{ test_rect_dest_space, image_rect_dest_space, context, hints, flipped });
    }

    /// `-[NSImage recommendedLayerContentsScale:]`
    pub fn recommendedLayerContentsScale(self: Self, preferred_contents_scale: cg.Float) cg.Float {
        return self.object.msgSend(cg.Float, "recommendedLayerContentsScale:", .{preferred_contents_scale});
    }

    /// `-[NSImage layerContentsForContentsScale:]`
    pub fn layerContentsForContentsScale(self: Self, layer_contents_scale: cg.Float) objc.Object {
        return self.object.msgSend(objc.Object, "layerContentsForContentsScale:", .{layer_contents_scale});
    }

    /// `-[NSImage imageWithSymbolConfiguration:]`
    pub fn imageWithSymbolConfiguration(self: Self, configuration: objc.Object) ?Image {
        return self.object.msgSend(?Image, "imageWithSymbolConfiguration:", .{configuration});
    }

    /// `-[NSImage imageWithLocale:]`
    pub fn imageWithLocale(self: Self, locale_: ?objc.Object) Image {
        return self.object.msgSend(Image, "imageWithLocale:", .{locale_});
    }

    /// `-[NSImage size]`
    pub fn size(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "size", .{});
    }

    /// `-[NSImage setSize:]`
    pub fn setSize(self: Self, size_: cg.Size) void {
        return self.object.msgSend(void, "setSize:", .{size_});
    }

    /// `-[NSImage backgroundColor]`
    pub fn backgroundColor(self: Self) Color {
        return self.object.msgSend(Color, "backgroundColor", .{});
    }

    /// `-[NSImage setBackgroundColor:]`
    pub fn setBackgroundColor(self: Self, background_color: Color) void {
        return self.object.msgSend(void, "setBackgroundColor:", .{background_color});
    }

    /// `-[NSImage usesEPSOnResolutionMismatch]`
    pub fn usesEPSOnResolutionMismatch(self: Self) bool {
        return self.object.msgSend(bool, "usesEPSOnResolutionMismatch", .{});
    }

    /// `-[NSImage setUsesEPSOnResolutionMismatch:]`
    pub fn setUsesEPSOnResolutionMismatch(self: Self, uses_eps_on_resolution_mismatch: bool) void {
        return self.object.msgSend(void, "setUsesEPSOnResolutionMismatch:", .{uses_eps_on_resolution_mismatch});
    }

    /// `-[NSImage prefersColorMatch]`
    pub fn prefersColorMatch(self: Self) bool {
        return self.object.msgSend(bool, "prefersColorMatch", .{});
    }

    /// `-[NSImage setPrefersColorMatch:]`
    pub fn setPrefersColorMatch(self: Self, prefers_color_match: bool) void {
        return self.object.msgSend(void, "setPrefersColorMatch:", .{prefers_color_match});
    }

    /// `-[NSImage matchesOnMultipleResolution]`
    pub fn matchesOnMultipleResolution(self: Self) bool {
        return self.object.msgSend(bool, "matchesOnMultipleResolution", .{});
    }

    /// `-[NSImage setMatchesOnMultipleResolution:]`
    pub fn setMatchesOnMultipleResolution(self: Self, matches_on_multiple_resolution: bool) void {
        return self.object.msgSend(void, "setMatchesOnMultipleResolution:", .{matches_on_multiple_resolution});
    }

    /// `-[NSImage matchesOnlyOnBestFittingAxis]`
    pub fn matchesOnlyOnBestFittingAxis(self: Self) bool {
        return self.object.msgSend(bool, "matchesOnlyOnBestFittingAxis", .{});
    }

    /// `-[NSImage setMatchesOnlyOnBestFittingAxis:]`
    pub fn setMatchesOnlyOnBestFittingAxis(self: Self, matches_only_on_best_fitting_axis: bool) void {
        return self.object.msgSend(void, "setMatchesOnlyOnBestFittingAxis:", .{matches_only_on_best_fitting_axis});
    }

    /// `-[NSImage TIFFRepresentation]`
    pub fn TIFFRepresentation(self: Self) ?foundation.Data {
        return self.object.msgSend(?foundation.Data, "TIFFRepresentation", .{});
    }

    /// `-[NSImage representations]`
    pub fn representations(self: Self) foundation.Array(ImageRep) {
        return self.object.msgSend(foundation.Array(ImageRep), "representations", .{});
    }

    /// `-[NSImage isValid]`
    pub fn isValid(self: Self) bool {
        return self.object.msgSend(bool, "isValid", .{});
    }

    /// `-[NSImage delegate]`
    pub fn delegate(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "delegate", .{});
    }

    /// `-[NSImage setDelegate:]`
    pub fn setDelegate(self: Self, delegate_: ?objc.Object) void {
        return self.object.msgSend(void, "setDelegate:", .{delegate_});
    }

    /// `+[NSImage imageTypes]`
    pub fn imageTypes() ?foundation.Array(foundation.String) {
        return class().msgSend(?foundation.Array(foundation.String), "imageTypes", .{});
    }

    /// `+[NSImage imageUnfilteredTypes]`
    pub fn imageUnfilteredTypes() ?foundation.Array(foundation.String) {
        return class().msgSend(?foundation.Array(foundation.String), "imageUnfilteredTypes", .{});
    }

    /// `-[NSImage cacheMode]`
    pub fn cacheMode(self: Self) ImageCacheMode {
        return self.object.msgSend(ImageCacheMode, "cacheMode", .{});
    }

    /// `-[NSImage setCacheMode:]`
    pub fn setCacheMode(self: Self, cache_mode: ImageCacheMode) void {
        return self.object.msgSend(void, "setCacheMode:", .{cache_mode});
    }

    /// `-[NSImage alignmentRect]`
    pub fn alignmentRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "alignmentRect", .{});
    }

    /// `-[NSImage setAlignmentRect:]`
    pub fn setAlignmentRect(self: Self, alignment_rect: cg.Rect) void {
        return self.object.msgSend(void, "setAlignmentRect:", .{alignment_rect});
    }

    /// `-[NSImage isTemplate]`
    pub fn isTemplate(self: Self) bool {
        return self.object.msgSend(bool, "isTemplate", .{});
    }

    /// `-[NSImage setTemplate:]`
    pub fn setTemplate(self: Self, template: bool) void {
        return self.object.msgSend(void, "setTemplate:", .{template});
    }

    /// `-[NSImage accessibilityDescription]`
    pub fn accessibilityDescription(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "accessibilityDescription", .{});
    }

    /// `-[NSImage setAccessibilityDescription:]`
    pub fn setAccessibilityDescription(self: Self, accessibility_description: ?foundation.String) void {
        return self.object.msgSend(void, "setAccessibilityDescription:", .{accessibility_description});
    }

    /// `-[NSImage resizingMode]`
    pub fn resizingMode(self: Self) ImageResizingMode {
        return self.object.msgSend(ImageResizingMode, "resizingMode", .{});
    }

    /// `-[NSImage setResizingMode:]`
    pub fn setResizingMode(self: Self, resizing_mode: ImageResizingMode) void {
        return self.object.msgSend(void, "setResizingMode:", .{resizing_mode});
    }

    /// `-[NSImage symbolConfiguration]`
    pub fn symbolConfiguration(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "symbolConfiguration", .{});
    }

    /// `-[NSImage locale]`
    pub fn locale(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "locale", .{});
    }

    // Not generated:
    //   -[NSImage capInsets]: NSEdgeInsets
    //   -[NSImage setCapInsets:]: NSEdgeInsets
};

/// `NSCursor`, a subclass of `NSObject`.
pub const Cursor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSCursor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSCursor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSCursor initWithImage:hotSpot:]`
    pub fn initWithImageHotSpot(self: Self, new_image: Image, point: cg.Point) Cursor {
        return self.object.msgSend(Cursor, "initWithImage:hotSpot:", .{ new_image, point });
    }

    /// `-[NSCursor initWithCoder:]`
    pub fn initWithCoder(self: Self, coder: objc.Object) Cursor {
        return self.object.msgSend(Cursor, "initWithCoder:", .{coder});
    }

    /// `+[NSCursor hide]`
    pub fn hide() void {
        return class().msgSend(void, "hide", .{});
    }

    /// `+[NSCursor unhide]`
    pub fn unhide() void {
        return class().msgSend(void, "unhide", .{});
    }

    /// `+[NSCursor setHiddenUntilMouseMoves:]`
    pub fn setHiddenUntilMouseMoves(flag: bool) void {
        return class().msgSend(void, "setHiddenUntilMouseMoves:", .{flag});
    }

    /// `+[NSCursor pop]`
    pub fn pop() void {
        return class().msgSend(void, "pop", .{});
    }

    /// `-[NSCursor pop]`
    pub fn pop_(self: Self) void {
        return self.object.msgSend(void, "pop", .{});
    }

    /// `-[NSCursor push]`
    pub fn push(self: Self) void {
        return self.object.msgSend(void, "push", .{});
    }

    /// `-[NSCursor set]`
    pub fn set(self: Self) void {
        return self.object.msgSend(void, "set", .{});
    }

    /// `+[NSCursor columnResizeCursorInDirections:]`
    pub fn columnResizeCursorInDirections(directions: HorizontalDirections) Cursor {
        return class().msgSend(Cursor, "columnResizeCursorInDirections:", .{directions});
    }

    /// `+[NSCursor rowResizeCursorInDirections:]`
    pub fn rowResizeCursorInDirections(directions: VerticalDirections) Cursor {
        return class().msgSend(Cursor, "rowResizeCursorInDirections:", .{directions});
    }

    /// `+[NSCursor frameResizeCursorFromPosition:inDirections:]`
    pub fn frameResizeCursorFromPositionInDirections(position: CursorFrameResizePosition, directions: CursorFrameResizeDirections) Cursor {
        return class().msgSend(Cursor, "frameResizeCursorFromPosition:inDirections:", .{ position, directions });
    }

    /// `-[NSCursor image]`
    pub fn image(self: Self) Image {
        return self.object.msgSend(Image, "image", .{});
    }

    /// `-[NSCursor hotSpot]`
    pub fn hotSpot(self: Self) cg.Point {
        return self.object.msgSend(cg.Point, "hotSpot", .{});
    }

    /// `+[NSCursor currentCursor]`
    pub fn currentCursor() Cursor {
        return class().msgSend(Cursor, "currentCursor", .{});
    }

    /// `+[NSCursor arrowCursor]`
    pub fn arrowCursor() Cursor {
        return class().msgSend(Cursor, "arrowCursor", .{});
    }

    /// `+[NSCursor crosshairCursor]`
    pub fn crosshairCursor() Cursor {
        return class().msgSend(Cursor, "crosshairCursor", .{});
    }

    /// `+[NSCursor disappearingItemCursor]`
    pub fn disappearingItemCursor() Cursor {
        return class().msgSend(Cursor, "disappearingItemCursor", .{});
    }

    /// `+[NSCursor operationNotAllowedCursor]`
    pub fn operationNotAllowedCursor() ?Cursor {
        return class().msgSend(?Cursor, "operationNotAllowedCursor", .{});
    }

    /// `+[NSCursor dragLinkCursor]`
    pub fn dragLinkCursor() ?Cursor {
        return class().msgSend(?Cursor, "dragLinkCursor", .{});
    }

    /// `+[NSCursor dragCopyCursor]`
    pub fn dragCopyCursor() ?Cursor {
        return class().msgSend(?Cursor, "dragCopyCursor", .{});
    }

    /// `+[NSCursor contextualMenuCursor]`
    pub fn contextualMenuCursor() ?Cursor {
        return class().msgSend(?Cursor, "contextualMenuCursor", .{});
    }

    /// `+[NSCursor pointingHandCursor]`
    pub fn pointingHandCursor() Cursor {
        return class().msgSend(Cursor, "pointingHandCursor", .{});
    }

    /// `+[NSCursor closedHandCursor]`
    pub fn closedHandCursor() Cursor {
        return class().msgSend(Cursor, "closedHandCursor", .{});
    }

    /// `+[NSCursor openHandCursor]`
    pub fn openHandCursor() Cursor {
        return class().msgSend(Cursor, "openHandCursor", .{});
    }

    /// `+[NSCursor IBeamCursor]`
    pub fn IBeamCursor() Cursor {
        return class().msgSend(Cursor, "IBeamCursor", .{});
    }

    /// `+[NSCursor IBeamCursorForVerticalLayout]`
    pub fn IBeamCursorForVerticalLayout() ?Cursor {
        return class().msgSend(?Cursor, "IBeamCursorForVerticalLayout", .{});
    }

    /// `+[NSCursor zoomInCursor]`
    pub fn zoomInCursor() ?Cursor {
        return class().msgSend(?Cursor, "zoomInCursor", .{});
    }

    /// `+[NSCursor zoomOutCursor]`
    pub fn zoomOutCursor() ?Cursor {
        return class().msgSend(?Cursor, "zoomOutCursor", .{});
    }

    /// `+[NSCursor columnResizeCursor]`
    pub fn columnResizeCursor() ?Cursor {
        return class().msgSend(?Cursor, "columnResizeCursor", .{});
    }

    /// `+[NSCursor rowResizeCursor]`
    pub fn rowResizeCursor() ?Cursor {
        return class().msgSend(?Cursor, "rowResizeCursor", .{});
    }
};

/// `NSGraphicsContext`, a subclass of `NSObject`.
pub const GraphicsContext = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSGraphicsContext";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSGraphicsContext`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `+[NSGraphicsContext graphicsContextWithAttributes:]`
    pub fn graphicsContextWithAttributes(attributes_: foundation.Dictionary(objc.Object, objc.Object)) ?GraphicsContext {
        return class().msgSend(?GraphicsContext, "graphicsContextWithAttributes:", .{attributes_});
    }

    /// `+[NSGraphicsContext graphicsContextWithBitmapImageRep:]`
    pub fn graphicsContextWithBitmapImageRep(bitmap_rep: BitmapImageRep) ?GraphicsContext {
        return class().msgSend(?GraphicsContext, "graphicsContextWithBitmapImageRep:", .{bitmap_rep});
    }

    /// `+[NSGraphicsContext graphicsContextWithCGContext:flipped:]`
    pub fn graphicsContextWithCGContextFlipped(graphics_port: ?*anyopaque, initial_flipped_state: bool) GraphicsContext {
        return class().msgSend(GraphicsContext, "graphicsContextWithCGContext:flipped:", .{ graphics_port, initial_flipped_state });
    }

    /// `+[NSGraphicsContext currentContextDrawingToScreen]`
    pub fn currentContextDrawingToScreen() bool {
        return class().msgSend(bool, "currentContextDrawingToScreen", .{});
    }

    /// `+[NSGraphicsContext saveGraphicsState]`
    pub fn saveGraphicsState() void {
        return class().msgSend(void, "saveGraphicsState", .{});
    }

    /// `+[NSGraphicsContext restoreGraphicsState]`
    pub fn restoreGraphicsState() void {
        return class().msgSend(void, "restoreGraphicsState", .{});
    }

    /// `-[NSGraphicsContext saveGraphicsState]`
    pub fn saveGraphicsState_(self: Self) void {
        return self.object.msgSend(void, "saveGraphicsState", .{});
    }

    /// `-[NSGraphicsContext restoreGraphicsState]`
    pub fn restoreGraphicsState_(self: Self) void {
        return self.object.msgSend(void, "restoreGraphicsState", .{});
    }

    /// `-[NSGraphicsContext flushGraphics]`
    pub fn flushGraphics(self: Self) void {
        return self.object.msgSend(void, "flushGraphics", .{});
    }

    /// `+[NSGraphicsContext currentContext]`
    pub fn currentContext() ?GraphicsContext {
        return class().msgSend(?GraphicsContext, "currentContext", .{});
    }

    /// `+[NSGraphicsContext setCurrentContext:]`
    pub fn setCurrentContext(current_context: ?GraphicsContext) void {
        return class().msgSend(void, "setCurrentContext:", .{current_context});
    }

    /// `-[NSGraphicsContext attributes]`
    pub fn attributes(self: Self) ?foundation.Dictionary(objc.Object, objc.Object) {
        return self.object.msgSend(?foundation.Dictionary(objc.Object, objc.Object), "attributes", .{});
    }

    /// `-[NSGraphicsContext isDrawingToScreen]`
    pub fn isDrawingToScreen(self: Self) bool {
        return self.object.msgSend(bool, "isDrawingToScreen", .{});
    }

    /// `-[NSGraphicsContext CGContext]`
    pub fn CGContext(self: Self) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "CGContext", .{});
    }

    /// `-[NSGraphicsContext isFlipped]`
    pub fn isFlipped(self: Self) bool {
        return self.object.msgSend(bool, "isFlipped", .{});
    }

    /// `-[NSGraphicsContext shouldAntialias]`
    pub fn shouldAntialias(self: Self) bool {
        return self.object.msgSend(bool, "shouldAntialias", .{});
    }

    /// `-[NSGraphicsContext setShouldAntialias:]`
    pub fn setShouldAntialias(self: Self, should_antialias: bool) void {
        return self.object.msgSend(void, "setShouldAntialias:", .{should_antialias});
    }

    /// `-[NSGraphicsContext patternPhase]`
    pub fn patternPhase(self: Self) cg.Point {
        return self.object.msgSend(cg.Point, "patternPhase", .{});
    }

    /// `-[NSGraphicsContext setPatternPhase:]`
    pub fn setPatternPhase(self: Self, pattern_phase: cg.Point) void {
        return self.object.msgSend(void, "setPatternPhase:", .{pattern_phase});
    }

    /// `-[NSGraphicsContext compositingOperation]`
    pub fn compositingOperation(self: Self) CompositingOperation {
        return self.object.msgSend(CompositingOperation, "compositingOperation", .{});
    }

    /// `-[NSGraphicsContext setCompositingOperation:]`
    pub fn setCompositingOperation(self: Self, compositing_operation: CompositingOperation) void {
        return self.object.msgSend(void, "setCompositingOperation:", .{compositing_operation});
    }

    /// `-[NSGraphicsContext colorRenderingIntent]`
    pub fn colorRenderingIntent(self: Self) ColorRenderingIntent {
        return self.object.msgSend(ColorRenderingIntent, "colorRenderingIntent", .{});
    }

    /// `-[NSGraphicsContext setColorRenderingIntent:]`
    pub fn setColorRenderingIntent(self: Self, color_rendering_intent: ColorRenderingIntent) void {
        return self.object.msgSend(void, "setColorRenderingIntent:", .{color_rendering_intent});
    }

    /// `+[NSGraphicsContext setGraphicsState:]`
    pub fn setGraphicsState(g_state: objc.Integer) void {
        return class().msgSend(void, "setGraphicsState:", .{g_state});
    }

    /// `-[NSGraphicsContext focusStack]`
    pub fn focusStack(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "focusStack", .{});
    }

    /// `-[NSGraphicsContext setFocusStack:]`
    pub fn setFocusStack(self: Self, stack: ?objc.Object) void {
        return self.object.msgSend(void, "setFocusStack:", .{stack});
    }

    /// `+[NSGraphicsContext graphicsContextWithGraphicsPort:flipped:]`
    pub fn graphicsContextWithGraphicsPortFlipped(graphics_port: ?*anyopaque, initial_flipped_state: bool) GraphicsContext {
        return class().msgSend(GraphicsContext, "graphicsContextWithGraphicsPort:flipped:", .{ graphics_port, initial_flipped_state });
    }

    /// `+[NSGraphicsContext graphicsContextWithWindow:]`
    pub fn graphicsContextWithWindow(window: Window) GraphicsContext {
        return class().msgSend(GraphicsContext, "graphicsContextWithWindow:", .{window});
    }

    /// `-[NSGraphicsContext graphicsPort]`
    pub fn graphicsPort(self: Self) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "graphicsPort", .{});
    }

    // Not generated:
    //   -[NSGraphicsContext imageInterpolation]: NSImageInterpolation
    //   -[NSGraphicsContext setImageInterpolation:]: NSImageInterpolation
};

/// `NSImageRep`, a subclass of `NSObject`.
pub const ImageRep = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "NSImageRep";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSImageRep`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSImageRep init]`
    pub fn init(self: Self) ImageRep {
        return self.object.msgSend(ImageRep, "init", .{});
    }

    /// `-[NSImageRep initWithCoder:]`
    pub fn initWithCoder(self: Self, coder: objc.Object) ?ImageRep {
        return self.object.msgSend(?ImageRep, "initWithCoder:", .{coder});
    }

    /// `-[NSImageRep draw]`
    pub fn draw(self: Self) bool {
        return self.object.msgSend(bool, "draw", .{});
    }

    /// `-[NSImageRep drawAtPoint:]`
    pub fn drawAtPoint(self: Self, point: cg.Point) bool {
        return self.object.msgSend(bool, "drawAtPoint:", .{point});
    }

    /// `-[NSImageRep drawInRect:]`
    pub fn drawInRect(self: Self, rect: cg.Rect) bool {
        return self.object.msgSend(bool, "drawInRect:", .{rect});
    }

    /// `-[NSImageRep drawInRect:fromRect:operation:fraction:respectFlipped:hints:]`
    pub fn drawInRectFromRectOperationFractionRespectFlippedHints(self: Self, dst_space_portion_rect: cg.Rect, src_space_portion_rect: cg.Rect, op: CompositingOperation, requested_alpha: cg.Float, respect_context_is_flipped: bool, hints: ?foundation.Dictionary(objc.Object, objc.Object)) bool {
        return self.object.msgSend(bool, "drawInRect:fromRect:operation:fraction:respectFlipped:hints:", .{ dst_space_portion_rect, src_space_portion_rect, op, requested_alpha, respect_context_is_flipped, hints });
    }

    /// `+[NSImageRep registerImageRepClass:]`
    pub fn registerImageRepClass(image_rep_class: objc.Class) void {
        return class().msgSend(void, "registerImageRepClass:", .{image_rep_class});
    }

    /// `+[NSImageRep unregisterImageRepClass:]`
    pub fn unregisterImageRepClass(image_rep_class: objc.Class) void {
        return class().msgSend(void, "unregisterImageRepClass:", .{image_rep_class});
    }

    /// `+[NSImageRep imageRepClassForFileType:]`
    pub fn imageRepClassForFileType(@"type": foundation.String) ?objc.Class {
        return class().msgSend(?objc.Class, "imageRepClassForFileType:", .{@"type"});
    }

    /// `+[NSImageRep imageRepClassForPasteboardType:]`
    pub fn imageRepClassForPasteboardType(@"type": ?foundation.String) ?objc.Class {
        return class().msgSend(?objc.Class, "imageRepClassForPasteboardType:", .{@"type"});
    }

    /// `+[NSImageRep imageRepClassForType:]`
    pub fn imageRepClassForType(@"type": foundation.String) ?objc.Class {
        return class().msgSend(?objc.Class, "imageRepClassForType:", .{@"type"});
    }

    /// `+[NSImageRep imageRepClassForData:]`
    pub fn imageRepClassForData(data: foundation.Data) ?objc.Class {
        return class().msgSend(?objc.Class, "imageRepClassForData:", .{data});
    }

    /// `+[NSImageRep canInitWithData:]`
    pub fn canInitWithData(data: foundation.Data) bool {
        return class().msgSend(bool, "canInitWithData:", .{data});
    }

    /// `+[NSImageRep imageUnfilteredFileTypes]`
    pub fn imageUnfilteredFileTypes() foundation.Array(foundation.String) {
        return class().msgSend(foundation.Array(foundation.String), "imageUnfilteredFileTypes", .{});
    }

    /// `+[NSImageRep imageUnfilteredPasteboardTypes]`
    pub fn imageUnfilteredPasteboardTypes() foundation.Array(objc.Object) {
        return class().msgSend(foundation.Array(objc.Object), "imageUnfilteredPasteboardTypes", .{});
    }

    /// `+[NSImageRep imageFileTypes]`
    pub fn imageFileTypes() foundation.Array(foundation.String) {
        return class().msgSend(foundation.Array(foundation.String), "imageFileTypes", .{});
    }

    /// `+[NSImageRep imagePasteboardTypes]`
    pub fn imagePasteboardTypes() foundation.Array(objc.Object) {
        return class().msgSend(foundation.Array(objc.Object), "imagePasteboardTypes", .{});
    }

    /// `+[NSImageRep canInitWithPasteboard:]`
    pub fn canInitWithPasteboard(pasteboard: objc.Object) bool {
        return class().msgSend(bool, "canInitWithPasteboard:", .{pasteboard});
    }

    /// `+[NSImageRep imageRepsWithContentsOfFile:]`
    pub fn imageRepsWithContentsOfFile(filename: foundation.String) ?foundation.Array(ImageRep) {
        return class().msgSend(?foundation.Array(ImageRep), "imageRepsWithContentsOfFile:", .{filename});
    }

    /// `+[NSImageRep imageRepWithContentsOfFile:]`
    pub fn imageRepWithContentsOfFile(filename: foundation.String) ?ImageRep {
        return class().msgSend(?ImageRep, "imageRepWithContentsOfFile:", .{filename});
    }

    /// `+[NSImageRep imageRepsWithContentsOfURL:]`
    pub fn imageRepsWithContentsOfURL(url: foundation.Url) ?foundation.Array(ImageRep) {
        return class().msgSend(?foundation.Array(ImageRep), "imageRepsWithContentsOfURL:", .{url});
    }

    /// `+[NSImageRep imageRepWithContentsOfURL:]`
    pub fn imageRepWithContentsOfURL(url: foundation.Url) ?ImageRep {
        return class().msgSend(?ImageRep, "imageRepWithContentsOfURL:", .{url});
    }

    /// `+[NSImageRep imageRepsWithPasteboard:]`
    pub fn imageRepsWithPasteboard(pasteboard: objc.Object) ?foundation.Array(ImageRep) {
        return class().msgSend(?foundation.Array(ImageRep), "imageRepsWithPasteboard:", .{pasteboard});
    }

    /// `+[NSImageRep imageRepWithPasteboard:]`
    pub fn imageRepWithPasteboard(pasteboard: objc.Object) ?ImageRep {
        return class().msgSend(?ImageRep, "imageRepWithPasteboard:", .{pasteboard});
    }

    /// `-[NSImageRep CGImageForProposedRect:context:hints:]`
    pub fn CGImageForProposedRectContextHints(self: Self, proposed_dest_rect: ?*cg.Rect, context: ?GraphicsContext, hints: ?foundation.Dictionary(objc.Object, objc.Object)) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "CGImageForProposedRect:context:hints:", .{ proposed_dest_rect, context, hints });
    }

    /// `-[NSImageRep size]`
    pub fn size(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "size", .{});
    }

    /// `-[NSImageRep setSize:]`
    pub fn setSize(self: Self, size_: cg.Size) void {
        return self.object.msgSend(void, "setSize:", .{size_});
    }

    /// `-[NSImageRep hasAlpha]`
    pub fn hasAlpha(self: Self) bool {
        return self.object.msgSend(bool, "hasAlpha", .{});
    }

    /// `-[NSImageRep setAlpha:]`
    pub fn setAlpha(self: Self, alpha: bool) void {
        return self.object.msgSend(void, "setAlpha:", .{alpha});
    }

    /// `-[NSImageRep isOpaque]`
    pub fn isOpaque(self: Self) bool {
        return self.object.msgSend(bool, "isOpaque", .{});
    }

    /// `-[NSImageRep setOpaque:]`
    pub fn setOpaque(self: Self, @"opaque": bool) void {
        return self.object.msgSend(void, "setOpaque:", .{@"opaque"});
    }

    /// `-[NSImageRep colorSpaceName]`
    pub fn colorSpaceName(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "colorSpaceName", .{});
    }

    /// `-[NSImageRep setColorSpaceName:]`
    pub fn setColorSpaceName(self: Self, color_space_name: ?foundation.String) void {
        return self.object.msgSend(void, "setColorSpaceName:", .{color_space_name});
    }

    /// `-[NSImageRep bitsPerSample]`
    pub fn bitsPerSample(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "bitsPerSample", .{});
    }

    /// `-[NSImageRep setBitsPerSample:]`
    pub fn setBitsPerSample(self: Self, bits_per_sample: objc.Integer) void {
        return self.object.msgSend(void, "setBitsPerSample:", .{bits_per_sample});
    }

    /// `-[NSImageRep pixelsWide]`
    pub fn pixelsWide(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "pixelsWide", .{});
    }

    /// `-[NSImageRep setPixelsWide:]`
    pub fn setPixelsWide(self: Self, pixels_wide: objc.Integer) void {
        return self.object.msgSend(void, "setPixelsWide:", .{pixels_wide});
    }

    /// `-[NSImageRep pixelsHigh]`
    pub fn pixelsHigh(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "pixelsHigh", .{});
    }

    /// `-[NSImageRep setPixelsHigh:]`
    pub fn setPixelsHigh(self: Self, pixels_high: objc.Integer) void {
        return self.object.msgSend(void, "setPixelsHigh:", .{pixels_high});
    }

    /// `-[NSImageRep layoutDirection]`
    pub fn layoutDirection(self: Self) ImageLayoutDirection {
        return self.object.msgSend(ImageLayoutDirection, "layoutDirection", .{});
    }

    /// `-[NSImageRep setLayoutDirection:]`
    pub fn setLayoutDirection(self: Self, layout_direction: ImageLayoutDirection) void {
        return self.object.msgSend(void, "setLayoutDirection:", .{layout_direction});
    }

    /// `+[NSImageRep registeredImageRepClasses]`
    pub fn registeredImageRepClasses() foundation.Array(objc.Object) {
        return class().msgSend(foundation.Array(objc.Object), "registeredImageRepClasses", .{});
    }

    /// `+[NSImageRep imageUnfilteredTypes]`
    pub fn imageUnfilteredTypes() ?foundation.Array(foundation.String) {
        return class().msgSend(?foundation.Array(foundation.String), "imageUnfilteredTypes", .{});
    }

    /// `+[NSImageRep imageTypes]`
    pub fn imageTypes() ?foundation.Array(foundation.String) {
        return class().msgSend(?foundation.Array(foundation.String), "imageTypes", .{});
    }
};

/// `NSBitmapImageRep`, a subclass of `NSImageRep`.
pub const BitmapImageRep = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = ImageRep;
    pub const class_name = "NSBitmapImageRep";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// An object that came from elsewhere, taken to be a `NSBitmapImageRep`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
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

    /// `-[NSBitmapImageRep initWithFocusedViewRect:]`
    pub fn initWithFocusedViewRect(self: Self, rect: cg.Rect) ?BitmapImageRep {
        return self.object.msgSend(?BitmapImageRep, "initWithFocusedViewRect:", .{rect});
    }

    /// `-[NSBitmapImageRep initWithCGImage:]`
    pub fn initWithCGImage(self: Self, cg_image: ?*anyopaque) BitmapImageRep {
        return self.object.msgSend(BitmapImageRep, "initWithCGImage:", .{cg_image});
    }

    /// `-[NSBitmapImageRep initWithCIImage:]`
    pub fn initWithCIImage(self: Self, ci_image: objc.Object) BitmapImageRep {
        return self.object.msgSend(BitmapImageRep, "initWithCIImage:", .{ci_image});
    }

    /// `+[NSBitmapImageRep imageRepsWithData:]`
    pub fn imageRepsWithData(data: foundation.Data) foundation.Array(ImageRep) {
        return class().msgSend(foundation.Array(ImageRep), "imageRepsWithData:", .{data});
    }

    /// `+[NSBitmapImageRep imageRepWithData:]`
    pub fn imageRepWithData(data: foundation.Data) ?BitmapImageRep {
        return class().msgSend(?BitmapImageRep, "imageRepWithData:", .{data});
    }

    /// `-[NSBitmapImageRep initWithData:]`
    pub fn initWithData(self: Self, data: foundation.Data) ?BitmapImageRep {
        return self.object.msgSend(?BitmapImageRep, "initWithData:", .{data});
    }

    /// `-[NSBitmapImageRep getCompression:factor:]`
    pub fn getCompressionFactor(self: Self, compression: ?objc.Object, factor: ?*f32) void {
        return self.object.msgSend(void, "getCompression:factor:", .{ compression, factor });
    }

    /// `-[NSBitmapImageRep setCompression:factor:]`
    pub fn setCompressionFactor(self: Self, compression: TIFFCompression, factor: f32) void {
        return self.object.msgSend(void, "setCompression:factor:", .{ compression, factor });
    }

    /// `-[NSBitmapImageRep TIFFRepresentationUsingCompression:factor:]`
    pub fn TIFFRepresentationUsingCompressionFactor(self: Self, comp: TIFFCompression, factor: f32) ?foundation.Data {
        return self.object.msgSend(?foundation.Data, "TIFFRepresentationUsingCompression:factor:", .{ comp, factor });
    }

    /// `+[NSBitmapImageRep TIFFRepresentationOfImageRepsInArray:]`
    pub fn TIFFRepresentationOfImageRepsInArray(array: foundation.Array(ImageRep)) ?foundation.Data {
        return class().msgSend(?foundation.Data, "TIFFRepresentationOfImageRepsInArray:", .{array});
    }

    /// `+[NSBitmapImageRep TIFFRepresentationOfImageRepsInArray:usingCompression:factor:]`
    pub fn TIFFRepresentationOfImageRepsInArrayUsingCompressionFactor(array: foundation.Array(ImageRep), comp: TIFFCompression, factor: f32) ?foundation.Data {
        return class().msgSend(?foundation.Data, "TIFFRepresentationOfImageRepsInArray:usingCompression:factor:", .{ array, comp, factor });
    }

    /// `+[NSBitmapImageRep getTIFFCompressionTypes:count:]`
    pub fn getTIFFCompressionTypesCount(list: ?*objc.abi.Id, num_types: ?*objc.Integer) void {
        return class().msgSend(void, "getTIFFCompressionTypes:count:", .{ list, num_types });
    }

    /// `+[NSBitmapImageRep localizedNameForTIFFCompressionType:]`
    pub fn localizedNameForTIFFCompressionType(compression: TIFFCompression) ?foundation.String {
        return class().msgSend(?foundation.String, "localizedNameForTIFFCompressionType:", .{compression});
    }

    /// `-[NSBitmapImageRep canBeCompressedUsing:]`
    pub fn canBeCompressedUsing(self: Self, compression: TIFFCompression) bool {
        return self.object.msgSend(bool, "canBeCompressedUsing:", .{compression});
    }

    /// `-[NSBitmapImageRep colorizeByMappingGray:toColor:blackMapping:whiteMapping:]`
    pub fn colorizeByMappingGrayToColorBlackMappingWhiteMapping(self: Self, mid_point: cg.Float, mid_point_color: ?Color, shadow_color: ?Color, light_color: ?Color) void {
        return self.object.msgSend(void, "colorizeByMappingGray:toColor:blackMapping:whiteMapping:", .{ mid_point, mid_point_color, shadow_color, light_color });
    }

    /// `-[NSBitmapImageRep initForIncrementalLoad]`
    pub fn initForIncrementalLoad(self: Self) BitmapImageRep {
        return self.object.msgSend(BitmapImageRep, "initForIncrementalLoad", .{});
    }

    /// `-[NSBitmapImageRep incrementalLoadFromData:complete:]`
    pub fn incrementalLoadFromDataComplete(self: Self, data: foundation.Data, complete: bool) objc.Integer {
        return self.object.msgSend(objc.Integer, "incrementalLoadFromData:complete:", .{ data, complete });
    }

    /// `-[NSBitmapImageRep setColor:atX:y:]`
    pub fn setColorAtXY(self: Self, color: Color, x: objc.Integer, y: objc.Integer) void {
        return self.object.msgSend(void, "setColor:atX:y:", .{ color, x, y });
    }

    /// `-[NSBitmapImageRep colorAtX:y:]`
    pub fn colorAtXY(self: Self, x: objc.Integer, y: objc.Integer) ?Color {
        return self.object.msgSend(?Color, "colorAtX:y:", .{ x, y });
    }

    /// `-[NSBitmapImageRep getPixel:atX:y:]`
    pub fn getPixelAtXY(self: Self, p: ?*objc.UInteger, x: objc.Integer, y: objc.Integer) void {
        return self.object.msgSend(void, "getPixel:atX:y:", .{ p, x, y });
    }

    /// `-[NSBitmapImageRep setPixel:atX:y:]`
    pub fn setPixelAtXY(self: Self, p: ?*objc.UInteger, x: objc.Integer, y: objc.Integer) void {
        return self.object.msgSend(void, "setPixel:atX:y:", .{ p, x, y });
    }

    /// `-[NSBitmapImageRep bitmapImageRepByConvertingToColorSpace:renderingIntent:]`
    pub fn bitmapImageRepByConvertingToColorSpaceRenderingIntent(self: Self, target_space: objc.Object, rendering_intent: ColorRenderingIntent) ?BitmapImageRep {
        return self.object.msgSend(?BitmapImageRep, "bitmapImageRepByConvertingToColorSpace:renderingIntent:", .{ target_space, rendering_intent });
    }

    /// `-[NSBitmapImageRep bitmapImageRepByRetaggingWithColorSpace:]`
    pub fn bitmapImageRepByRetaggingWithColorSpace(self: Self, new_space: objc.Object) ?BitmapImageRep {
        return self.object.msgSend(?BitmapImageRep, "bitmapImageRepByRetaggingWithColorSpace:", .{new_space});
    }

    /// `-[NSBitmapImageRep bitmapData]`
    pub fn bitmapData(self: Self) ?[*]u8 {
        return self.object.msgSend(?[*]u8, "bitmapData", .{});
    }

    /// `-[NSBitmapImageRep isPlanar]`
    pub fn isPlanar(self: Self) bool {
        return self.object.msgSend(bool, "isPlanar", .{});
    }

    /// `-[NSBitmapImageRep samplesPerPixel]`
    pub fn samplesPerPixel(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "samplesPerPixel", .{});
    }

    /// `-[NSBitmapImageRep bitsPerPixel]`
    pub fn bitsPerPixel(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "bitsPerPixel", .{});
    }

    /// `-[NSBitmapImageRep bytesPerRow]`
    pub fn bytesPerRow(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "bytesPerRow", .{});
    }

    /// `-[NSBitmapImageRep bytesPerPlane]`
    pub fn bytesPerPlane(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "bytesPerPlane", .{});
    }

    /// `-[NSBitmapImageRep numberOfPlanes]`
    pub fn numberOfPlanes(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "numberOfPlanes", .{});
    }

    /// `-[NSBitmapImageRep bitmapFormat]`
    pub fn bitmapFormat(self: Self) BitmapFormat {
        return self.object.msgSend(BitmapFormat, "bitmapFormat", .{});
    }

    /// `-[NSBitmapImageRep TIFFRepresentation]`
    pub fn TIFFRepresentation(self: Self) ?foundation.Data {
        return self.object.msgSend(?foundation.Data, "TIFFRepresentation", .{});
    }

    /// `-[NSBitmapImageRep CGImage]`
    pub fn CGImage(self: Self) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "CGImage", .{});
    }

    /// `-[NSBitmapImageRep colorSpace]`
    pub fn colorSpace(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "colorSpace", .{});
    }

    /// `+[NSBitmapImageRep representationOfImageRepsInArray:usingType:properties:]`
    pub fn representationOfImageRepsInArrayUsingTypeProperties(image_reps: foundation.Array(ImageRep), storage_type: BitmapImageFileType, properties: foundation.Dictionary(objc.Object, objc.Object)) ?foundation.Data {
        return class().msgSend(?foundation.Data, "representationOfImageRepsInArray:usingType:properties:", .{ image_reps, storage_type, properties });
    }

    /// `-[NSBitmapImageRep representationUsingType:properties:]`
    pub fn representationUsingTypeProperties(self: Self, storage_type: BitmapImageFileType, properties: foundation.Dictionary(objc.Object, objc.Object)) ?foundation.Data {
        return self.object.msgSend(?foundation.Data, "representationUsingType:properties:", .{ storage_type, properties });
    }

    /// `-[NSBitmapImageRep setProperty:withValue:]`
    pub fn setPropertyWithValue(self: Self, property: ?foundation.String, value: ?objc.Object) void {
        return self.object.msgSend(void, "setProperty:withValue:", .{ property, value });
    }

    /// `-[NSBitmapImageRep valueForProperty:]`
    pub fn valueForProperty(self: Self, property: ?foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "valueForProperty:", .{property});
    }

    // Not generated:
    //   -[NSBitmapImageRep initWithBitmapDataPlanes:pixelsWide:pixelsHigh:bitsPerSample:samplesPerPixel:hasAlpha:isPlanar:colorSpaceName:bytesPerRow:bitsPerPixel:]: unsigned char * _Nullable * _Nullable
    //   -[NSBitmapImageRep initWithBitmapDataPlanes:pixelsWide:pixelsHigh:bitsPerSample:samplesPerPixel:hasAlpha:isPlanar:colorSpaceName:bitmapFormat:bytesPerRow:bitsPerPixel:]: unsigned char * _Nullable * _Nullable
    //   -[NSBitmapImageRep getBitmapDataPlanes:]: unsigned char * _Nullable * _Nonnull
};
