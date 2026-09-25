//! ScreenCaptureKit wrappers generated from the macOS SDK by `zig build generate`,
//! from the manifest in `tools/objc_gen/screencapturekit.zig`. Do not edit: add to the
//! manifest and regenerate, or write a hand-made wrapper beside this file.

const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const cg = @import("../cg/cg.zig");
// Snake case, which no generated method is: `-[MTLTexture iosurface]`
// would otherwise hide it.
const io_surface = @import("../iosurface/iosurface.zig");
const core_video = @import("../corevideo/corevideo.zig");
const core_media = @import("../coremedia/coremedia.zig");

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

const framework = "ScreenCaptureKit";

/// Every constant and C function is linked weakly: one that a newer SDK
/// declares and the running macOS lacks leaves the program able to start,
/// and panics only if it is used.
fn missing(comptime name: []const u8) noreturn {
    @panic(name ++ " is not in this version of macOS");
}

/// `SCStreamOutputType`.
pub const StreamOutputType = enum(objc.Integer) {
    screen = 0,
    audio = 1,
    microphone = 2,
    _,
};

/// `SCFrameStatus`.
pub const FrameStatus = enum(objc.Integer) {
    complete = 0,
    idle = 1,
    blank = 2,
    suspended = 3,
    started = 4,
    stopped = 5,
    _,
};

/// `SCPresenterOverlayAlertSetting`.
pub const PresenterOverlayAlertSetting = enum(objc.Integer) {
    system = 0,
    never = 1,
    always = 2,
    _,
};

/// `SCStreamType`.
pub const StreamType = enum(objc.Integer) {
    window = 0,
    display = 1,
    _,
};

/// `SCCaptureResolutionType`.
pub const CaptureResolutionType = enum(objc.Integer) {
    automatic = 0,
    best = 1,
    nominal = 2,
    _,
};

/// `SCCaptureDynamicRange`.
pub const CaptureDynamicRange = enum(objc.Integer) {
    sdr = 0,
    hdr_local_display = 1,
    hdr_canonical_display = 2,
    _,
};

/// `SCStreamConfigurationPreset`.
pub const StreamConfigurationPreset = enum(objc.Integer) {
    stream_local_display = 0,
    stream_canonical_display = 1,
    screenshot_local_display = 2,
    screenshot_canonical_display = 3,
    recording_preserved_sdrhdr10 = 4,
    _,
};

/// `SCShareableContentStyle`.
pub const ShareableContentStyle = enum(objc.Integer) {
    none = 0,
    window = 1,
    display = 2,
    application = 3,
    _,
};

/// `SCContentSharingPickerMode`.
pub const ContentSharingPickerMode = packed struct(u64) {
    single_window: bool = false,
    multiple_windows: bool = false,
    single_application: bool = false,
    multiple_applications: bool = false,
    single_display: bool = false,
    _5: u59 = 0,
};

/// `SCScreenshotDisplayIntent`.
pub const ScreenshotDisplayIntent = enum(objc.Integer) {
    canonical = 0,
    local = 1,
    _,
};

/// `SCScreenshotDynamicRange`.
pub const ScreenshotDynamicRange = enum(objc.Integer) {
    sdr = 0,
    hdr = 1,
    sdr_and_hdr = 2,
    _,
};

/// `SCStreamErrorCode`.
pub const StreamErrorCode = enum(objc.Integer) {
    user_declined = -3801,
    failed_to_start = -3802,
    missing_entitlements = -3803,
    failed_application_connection_invalid = -3804,
    failed_application_connection_interrupted = -3805,
    failed_no_matching_application_context = -3806,
    attempt_to_start_stream_state = -3807,
    attempt_to_stop_stream_state = -3808,
    attempt_to_update_filter_state = -3809,
    attempt_to_config_state = -3810,
    internal_error = -3811,
    invalid_parameter = -3812,
    no_window_list = -3813,
    no_display_list = -3814,
    no_capture_source = -3815,
    removing_stream = -3816,
    user_stopped = -3817,
    failed_to_start_audio_capture = -3818,
    failed_to_stop_audio_capture = -3819,
    failed_to_start_microphone_capture = -3820,
    system_stopped_stream = -3821,
    insufficient_storage = -3822,
    not_supported = -3823,
    missing_background_mode = -3824,
    _,
};

/// `SCShareableContent`, a subclass of `NSObject`.
pub const ShareableContent = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCShareableContent";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCShareableContent alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCShareableContent`.
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

    /// `+[SCShareableContent getShareableContentWithCompletionHandler:]`
    pub fn getShareableContentWithCompletionHandler(completion_handler: objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "getShareableContentWithCompletionHandler:", .{completion_handler});
    }

    /// `+[SCShareableContent getCurrentProcessShareableContentWithCompletionHandler:]`
    pub fn getCurrentProcessShareableContentWithCompletionHandler(completion_handler: objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "getCurrentProcessShareableContentWithCompletionHandler:", .{completion_handler});
    }

    /// `+[SCShareableContent getShareableContentExcludingDesktopWindows:onScreenWindowsOnly:completionHandler:]`
    pub fn getShareableContentExcludingDesktopWindowsOnScreenWindowsOnlyCompletionHandler(exclude_desktop_windows: bool, on_screen_windows_only: bool, completion_handler: objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "getShareableContentExcludingDesktopWindows:onScreenWindowsOnly:completionHandler:", .{ exclude_desktop_windows, on_screen_windows_only, completion_handler });
    }

    /// `+[SCShareableContent getShareableContentExcludingDesktopWindows:onScreenWindowsOnlyBelowWindow:completionHandler:]`
    pub fn getShareableContentExcludingDesktopWindowsOnScreenWindowsOnlyBelowWindowCompletionHandler(exclude_desktop_windows: bool, window: Window, completion_handler: objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "getShareableContentExcludingDesktopWindows:onScreenWindowsOnlyBelowWindow:completionHandler:", .{ exclude_desktop_windows, window, completion_handler });
    }

    /// `+[SCShareableContent getShareableContentExcludingDesktopWindows:onScreenWindowsOnlyAboveWindow:completionHandler:]`
    pub fn getShareableContentExcludingDesktopWindowsOnScreenWindowsOnlyAboveWindowCompletionHandler(exclude_desktop_windows: bool, window: Window, completion_handler: objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "getShareableContentExcludingDesktopWindows:onScreenWindowsOnlyAboveWindow:completionHandler:", .{ exclude_desktop_windows, window, completion_handler });
    }

    /// `+[SCShareableContent infoForFilter:]`
    pub fn infoForFilter(filter: ContentFilter) ShareableContentInfo {
        return class().msgSend(ShareableContentInfo, "infoForFilter:", .{filter});
    }

    /// `-[SCShareableContent windows]`
    pub fn windows(self: Self) foundation.Array(Window) {
        return self.object.msgSend(foundation.Array(Window), "windows", .{});
    }

    /// `-[SCShareableContent displays]`
    pub fn displays(self: Self) foundation.Array(Display) {
        return self.object.msgSend(foundation.Array(Display), "displays", .{});
    }

    /// `-[SCShareableContent applications]`
    pub fn applications(self: Self) foundation.Array(RunningApplication) {
        return self.object.msgSend(foundation.Array(RunningApplication), "applications", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"+getShareableContentWithCompletionHandler:" = fn (objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void;
        pub const @"+getCurrentProcessShareableContentWithCompletionHandler:" = fn (objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void;
        pub const @"+getShareableContentExcludingDesktopWindows:onScreenWindowsOnly:completionHandler:" = fn (bool, bool, objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void;
        pub const @"+getShareableContentExcludingDesktopWindows:onScreenWindowsOnlyBelowWindow:completionHandler:" = fn (bool, Window, objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void;
        pub const @"+getShareableContentExcludingDesktopWindows:onScreenWindowsOnlyAboveWindow:completionHandler:" = fn (bool, Window, objc.BlockRef(fn (?ShareableContent, ?foundation.ErrorObject) void)) void;
        pub const @"+infoForFilter:" = fn (ContentFilter) ShareableContentInfo;
        pub const @"-windows" = fn () foundation.Array(Window);
        pub const @"-displays" = fn () foundation.Array(Display);
        pub const @"-applications" = fn () foundation.Array(RunningApplication);
    };
};

/// `SCShareableContentInfo`, a subclass of `NSObject`.
pub const ShareableContentInfo = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCShareableContentInfo";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCShareableContentInfo alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCShareableContentInfo`.
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

    /// `-[SCShareableContentInfo style]`
    pub fn style(self: Self) ShareableContentStyle {
        return self.object.msgSend(ShareableContentStyle, "style", .{});
    }

    /// `-[SCShareableContentInfo pointPixelScale]`
    pub fn pointPixelScale(self: Self) f32 {
        return self.object.msgSend(f32, "pointPixelScale", .{});
    }

    /// `-[SCShareableContentInfo contentRect]`
    pub fn contentRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "contentRect", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-style" = fn () ShareableContentStyle;
        pub const @"-pointPixelScale" = fn () f32;
        pub const @"-contentRect" = fn () cg.Rect;
    };
};

/// `SCDisplay`, a subclass of `NSObject`.
pub const Display = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCDisplay";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCDisplay alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCDisplay`.
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

    /// `-[SCDisplay displayID]`
    pub fn displayID(self: Self) u32 {
        return self.object.msgSend(u32, "displayID", .{});
    }

    /// `-[SCDisplay width]`
    pub fn width(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "width", .{});
    }

    /// `-[SCDisplay height]`
    pub fn height(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "height", .{});
    }

    /// `-[SCDisplay frame]`
    pub fn frame(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "frame", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-displayID" = fn () u32;
        pub const @"-width" = fn () objc.Integer;
        pub const @"-height" = fn () objc.Integer;
        pub const @"-frame" = fn () cg.Rect;
    };
};

/// `SCWindow`, a subclass of `NSObject`.
pub const Window = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCWindow";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCWindow alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCWindow`.
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

    /// `-[SCWindow windowID]`
    pub fn windowID(self: Self) c_uint {
        return self.object.msgSend(c_uint, "windowID", .{});
    }

    /// `-[SCWindow frame]`
    pub fn frame(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "frame", .{});
    }

    /// `-[SCWindow title]`
    pub fn title(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "title", .{});
    }

    /// `-[SCWindow windowLayer]`
    pub fn windowLayer(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "windowLayer", .{});
    }

    /// `-[SCWindow owningApplication]`
    pub fn owningApplication(self: Self) ?RunningApplication {
        return self.object.msgSend(?RunningApplication, "owningApplication", .{});
    }

    /// `-[SCWindow isOnScreen]`
    pub fn isOnScreen(self: Self) bool {
        return self.object.msgSend(bool, "isOnScreen", .{});
    }

    /// `-[SCWindow isActive]`
    pub fn isActive(self: Self) bool {
        return self.object.msgSend(bool, "isActive", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-windowID" = fn () c_uint;
        pub const @"-frame" = fn () cg.Rect;
        pub const @"-title" = fn () ?foundation.String;
        pub const @"-windowLayer" = fn () objc.Integer;
        pub const @"-owningApplication" = fn () ?RunningApplication;
        pub const @"-isOnScreen" = fn () bool;
        pub const @"-isActive" = fn () bool;
    };
};

/// `SCRunningApplication`, a subclass of `NSObject`.
pub const RunningApplication = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCRunningApplication";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCRunningApplication alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCRunningApplication`.
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

    /// `-[SCRunningApplication bundleIdentifier]`
    pub fn bundleIdentifier(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "bundleIdentifier", .{});
    }

    /// `-[SCRunningApplication applicationName]`
    pub fn applicationName(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "applicationName", .{});
    }

    /// `-[SCRunningApplication processID]`
    pub fn processID(self: Self) c_int {
        return self.object.msgSend(c_int, "processID", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-bundleIdentifier" = fn () foundation.String;
        pub const @"-applicationName" = fn () foundation.String;
        pub const @"-processID" = fn () c_int;
    };
};

/// `SCContentFilter`, a subclass of `NSObject`.
pub const ContentFilter = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCContentFilter";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCContentFilter alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCContentFilter`.
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

    /// `-[SCContentFilter initWithDesktopIndependentWindow:]`
    pub fn initWithDesktopIndependentWindow(self: Self, window: Window) ContentFilter {
        return self.object.msgSend(ContentFilter, "initWithDesktopIndependentWindow:", .{window});
    }

    /// `-[SCContentFilter initWithDisplay:excludingWindows:]`
    pub fn initWithDisplayExcludingWindows(self: Self, display: Display, excluded: foundation.Array(Window)) ContentFilter {
        return self.object.msgSend(ContentFilter, "initWithDisplay:excludingWindows:", .{ display, excluded });
    }

    /// `-[SCContentFilter initWithDisplay:includingWindows:]`
    pub fn initWithDisplayIncludingWindows(self: Self, display: Display, included_windows: foundation.Array(Window)) ContentFilter {
        return self.object.msgSend(ContentFilter, "initWithDisplay:includingWindows:", .{ display, included_windows });
    }

    /// `-[SCContentFilter initWithDisplay:includingApplications:exceptingWindows:]`
    pub fn initWithDisplayIncludingApplicationsExceptingWindows(self: Self, display: Display, applications: foundation.Array(RunningApplication), excepting_windows: foundation.Array(Window)) ContentFilter {
        return self.object.msgSend(ContentFilter, "initWithDisplay:includingApplications:exceptingWindows:", .{ display, applications, excepting_windows });
    }

    /// `-[SCContentFilter initWithDisplay:excludingApplications:exceptingWindows:]`
    pub fn initWithDisplayExcludingApplicationsExceptingWindows(self: Self, display: Display, applications: foundation.Array(RunningApplication), excepting_windows: foundation.Array(Window)) ContentFilter {
        return self.object.msgSend(ContentFilter, "initWithDisplay:excludingApplications:exceptingWindows:", .{ display, applications, excepting_windows });
    }

    /// `-[SCContentFilter streamType]`
    pub fn streamType(self: Self) StreamType {
        return self.object.msgSend(StreamType, "streamType", .{});
    }

    /// `-[SCContentFilter style]`
    pub fn style(self: Self) ShareableContentStyle {
        return self.object.msgSend(ShareableContentStyle, "style", .{});
    }

    /// `-[SCContentFilter pointPixelScale]`
    pub fn pointPixelScale(self: Self) f32 {
        return self.object.msgSend(f32, "pointPixelScale", .{});
    }

    /// `-[SCContentFilter contentRect]`
    pub fn contentRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "contentRect", .{});
    }

    /// `-[SCContentFilter includeMenuBar]`
    pub fn includeMenuBar(self: Self) bool {
        return self.object.msgSend(bool, "includeMenuBar", .{});
    }

    /// `-[SCContentFilter setIncludeMenuBar:]`
    pub fn setIncludeMenuBar(self: Self, include_menu_bar: bool) void {
        return self.object.msgSend(void, "setIncludeMenuBar:", .{include_menu_bar});
    }

    /// `-[SCContentFilter includedDisplays]`
    pub fn includedDisplays(self: Self) foundation.Array(Display) {
        return self.object.msgSend(foundation.Array(Display), "includedDisplays", .{});
    }

    /// `-[SCContentFilter includedApplications]`
    pub fn includedApplications(self: Self) foundation.Array(RunningApplication) {
        return self.object.msgSend(foundation.Array(RunningApplication), "includedApplications", .{});
    }

    /// `-[SCContentFilter includedWindows]`
    pub fn includedWindows(self: Self) foundation.Array(Window) {
        return self.object.msgSend(foundation.Array(Window), "includedWindows", .{});
    }

    /// `-[SCContentFilter isMicrophoneEnabled]`
    pub fn isMicrophoneEnabled(self: Self) bool {
        return self.object.msgSend(bool, "isMicrophoneEnabled", .{});
    }

    /// `-[SCContentFilter isCameraEnabled]`
    pub fn isCameraEnabled(self: Self) bool {
        return self.object.msgSend(bool, "isCameraEnabled", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-initWithDesktopIndependentWindow:" = fn (Window) ContentFilter;
        pub const @"-initWithDisplay:excludingWindows:" = fn (Display, foundation.Array(Window)) ContentFilter;
        pub const @"-initWithDisplay:includingWindows:" = fn (Display, foundation.Array(Window)) ContentFilter;
        pub const @"-initWithDisplay:includingApplications:exceptingWindows:" = fn (Display, foundation.Array(RunningApplication), foundation.Array(Window)) ContentFilter;
        pub const @"-initWithDisplay:excludingApplications:exceptingWindows:" = fn (Display, foundation.Array(RunningApplication), foundation.Array(Window)) ContentFilter;
        pub const @"-streamType" = fn () StreamType;
        pub const @"-style" = fn () ShareableContentStyle;
        pub const @"-pointPixelScale" = fn () f32;
        pub const @"-contentRect" = fn () cg.Rect;
        pub const @"-includeMenuBar" = fn () bool;
        pub const @"-setIncludeMenuBar:" = fn (bool) void;
        pub const @"-includedDisplays" = fn () foundation.Array(Display);
        pub const @"-includedApplications" = fn () foundation.Array(RunningApplication);
        pub const @"-includedWindows" = fn () foundation.Array(Window);
        pub const @"-isMicrophoneEnabled" = fn () bool;
        pub const @"-isCameraEnabled" = fn () bool;
    };
};

/// `SCStreamConfiguration`, a subclass of `NSObject`.
pub const StreamConfiguration = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCStreamConfiguration";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCStreamConfiguration alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCStreamConfiguration`.
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

    /// `+[SCStreamConfiguration streamConfigurationWithPreset:]`
    pub fn streamConfigurationWithPreset(preset: StreamConfigurationPreset) StreamConfiguration {
        return class().msgSend(StreamConfiguration, "streamConfigurationWithPreset:", .{preset});
    }

    /// `-[SCStreamConfiguration width]`
    pub fn width(self: Self) usize {
        return self.object.msgSend(usize, "width", .{});
    }

    /// `-[SCStreamConfiguration setWidth:]`
    pub fn setWidth(self: Self, width_: usize) void {
        return self.object.msgSend(void, "setWidth:", .{width_});
    }

    /// `-[SCStreamConfiguration height]`
    pub fn height(self: Self) usize {
        return self.object.msgSend(usize, "height", .{});
    }

    /// `-[SCStreamConfiguration setHeight:]`
    pub fn setHeight(self: Self, height_: usize) void {
        return self.object.msgSend(void, "setHeight:", .{height_});
    }

    /// `-[SCStreamConfiguration minimumFrameInterval]`
    pub fn minimumFrameInterval(self: Self) core_media.Time {
        return self.object.msgSend(core_media.Time, "minimumFrameInterval", .{});
    }

    /// `-[SCStreamConfiguration setMinimumFrameInterval:]`
    pub fn setMinimumFrameInterval(self: Self, minimum_frame_interval: core_media.Time) void {
        return self.object.msgSend(void, "setMinimumFrameInterval:", .{minimum_frame_interval});
    }

    /// `-[SCStreamConfiguration pixelFormat]`
    pub fn pixelFormat(self: Self) c_uint {
        return self.object.msgSend(c_uint, "pixelFormat", .{});
    }

    /// `-[SCStreamConfiguration setPixelFormat:]`
    pub fn setPixelFormat(self: Self, pixel_format: c_uint) void {
        return self.object.msgSend(void, "setPixelFormat:", .{pixel_format});
    }

    /// `-[SCStreamConfiguration scalesToFit]`
    pub fn scalesToFit(self: Self) bool {
        return self.object.msgSend(bool, "scalesToFit", .{});
    }

    /// `-[SCStreamConfiguration setScalesToFit:]`
    pub fn setScalesToFit(self: Self, scales_to_fit: bool) void {
        return self.object.msgSend(void, "setScalesToFit:", .{scales_to_fit});
    }

    /// `-[SCStreamConfiguration preservesAspectRatio]`
    pub fn preservesAspectRatio(self: Self) bool {
        return self.object.msgSend(bool, "preservesAspectRatio", .{});
    }

    /// `-[SCStreamConfiguration setPreservesAspectRatio:]`
    pub fn setPreservesAspectRatio(self: Self, preserves_aspect_ratio: bool) void {
        return self.object.msgSend(void, "setPreservesAspectRatio:", .{preserves_aspect_ratio});
    }

    /// `-[SCStreamConfiguration streamName]`
    pub fn streamName(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "streamName", .{});
    }

    /// `-[SCStreamConfiguration setStreamName:]`
    pub fn setStreamName(self: Self, stream_name: ?foundation.String) void {
        return self.object.msgSend(void, "setStreamName:", .{stream_name});
    }

    /// `-[SCStreamConfiguration showsCursor]`
    pub fn showsCursor(self: Self) bool {
        return self.object.msgSend(bool, "showsCursor", .{});
    }

    /// `-[SCStreamConfiguration setShowsCursor:]`
    pub fn setShowsCursor(self: Self, shows_cursor: bool) void {
        return self.object.msgSend(void, "setShowsCursor:", .{shows_cursor});
    }

    /// `-[SCStreamConfiguration showMouseClicks]`
    pub fn showMouseClicks(self: Self) bool {
        return self.object.msgSend(bool, "showMouseClicks", .{});
    }

    /// `-[SCStreamConfiguration setShowMouseClicks:]`
    pub fn setShowMouseClicks(self: Self, show_mouse_clicks: bool) void {
        return self.object.msgSend(void, "setShowMouseClicks:", .{show_mouse_clicks});
    }

    /// `-[SCStreamConfiguration backgroundColor]`
    pub fn backgroundColor(self: Self) cg.Color {
        return self.object.msgSend(cg.Color, "backgroundColor", .{});
    }

    /// `-[SCStreamConfiguration setBackgroundColor:]`
    pub fn setBackgroundColor(self: Self, background_color: cg.Color) void {
        return self.object.msgSend(void, "setBackgroundColor:", .{background_color});
    }

    /// `-[SCStreamConfiguration sourceRect]`
    pub fn sourceRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "sourceRect", .{});
    }

    /// `-[SCStreamConfiguration setSourceRect:]`
    pub fn setSourceRect(self: Self, source_rect: cg.Rect) void {
        return self.object.msgSend(void, "setSourceRect:", .{source_rect});
    }

    /// `-[SCStreamConfiguration destinationRect]`
    pub fn destinationRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "destinationRect", .{});
    }

    /// `-[SCStreamConfiguration setDestinationRect:]`
    pub fn setDestinationRect(self: Self, destination_rect: cg.Rect) void {
        return self.object.msgSend(void, "setDestinationRect:", .{destination_rect});
    }

    /// `-[SCStreamConfiguration queueDepth]`
    pub fn queueDepth(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "queueDepth", .{});
    }

    /// `-[SCStreamConfiguration setQueueDepth:]`
    pub fn setQueueDepth(self: Self, queue_depth: objc.Integer) void {
        return self.object.msgSend(void, "setQueueDepth:", .{queue_depth});
    }

    /// `-[SCStreamConfiguration colorMatrix]`
    pub fn colorMatrix(self: Self) ?*const anyopaque {
        return self.object.msgSend(?*const anyopaque, "colorMatrix", .{});
    }

    /// `-[SCStreamConfiguration setColorMatrix:]`
    pub fn setColorMatrix(self: Self, color_matrix: ?*const anyopaque) void {
        return self.object.msgSend(void, "setColorMatrix:", .{color_matrix});
    }

    /// `-[SCStreamConfiguration colorSpaceName]`
    pub fn colorSpaceName(self: Self) ?*const anyopaque {
        return self.object.msgSend(?*const anyopaque, "colorSpaceName", .{});
    }

    /// `-[SCStreamConfiguration setColorSpaceName:]`
    pub fn setColorSpaceName(self: Self, color_space_name: ?*const anyopaque) void {
        return self.object.msgSend(void, "setColorSpaceName:", .{color_space_name});
    }

    /// `-[SCStreamConfiguration capturesAudio]`
    pub fn capturesAudio(self: Self) bool {
        return self.object.msgSend(bool, "capturesAudio", .{});
    }

    /// `-[SCStreamConfiguration setCapturesAudio:]`
    pub fn setCapturesAudio(self: Self, captures_audio: bool) void {
        return self.object.msgSend(void, "setCapturesAudio:", .{captures_audio});
    }

    /// `-[SCStreamConfiguration sampleRate]`
    pub fn sampleRate(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "sampleRate", .{});
    }

    /// `-[SCStreamConfiguration setSampleRate:]`
    pub fn setSampleRate(self: Self, sample_rate: objc.Integer) void {
        return self.object.msgSend(void, "setSampleRate:", .{sample_rate});
    }

    /// `-[SCStreamConfiguration channelCount]`
    pub fn channelCount(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "channelCount", .{});
    }

    /// `-[SCStreamConfiguration setChannelCount:]`
    pub fn setChannelCount(self: Self, channel_count: objc.Integer) void {
        return self.object.msgSend(void, "setChannelCount:", .{channel_count});
    }

    /// `-[SCStreamConfiguration excludesCurrentProcessAudio]`
    pub fn excludesCurrentProcessAudio(self: Self) bool {
        return self.object.msgSend(bool, "excludesCurrentProcessAudio", .{});
    }

    /// `-[SCStreamConfiguration setExcludesCurrentProcessAudio:]`
    pub fn setExcludesCurrentProcessAudio(self: Self, excludes_current_process_audio: bool) void {
        return self.object.msgSend(void, "setExcludesCurrentProcessAudio:", .{excludes_current_process_audio});
    }

    /// `-[SCStreamConfiguration ignoreShadowsDisplay]`
    pub fn ignoreShadowsDisplay(self: Self) bool {
        return self.object.msgSend(bool, "ignoreShadowsDisplay", .{});
    }

    /// `-[SCStreamConfiguration setIgnoreShadowsDisplay:]`
    pub fn setIgnoreShadowsDisplay(self: Self, ignore_shadows_display: bool) void {
        return self.object.msgSend(void, "setIgnoreShadowsDisplay:", .{ignore_shadows_display});
    }

    /// `-[SCStreamConfiguration ignoreShadowsSingleWindow]`
    pub fn ignoreShadowsSingleWindow(self: Self) bool {
        return self.object.msgSend(bool, "ignoreShadowsSingleWindow", .{});
    }

    /// `-[SCStreamConfiguration setIgnoreShadowsSingleWindow:]`
    pub fn setIgnoreShadowsSingleWindow(self: Self, ignore_shadows_single_window: bool) void {
        return self.object.msgSend(void, "setIgnoreShadowsSingleWindow:", .{ignore_shadows_single_window});
    }

    /// `-[SCStreamConfiguration captureResolution]`
    pub fn captureResolution(self: Self) CaptureResolutionType {
        return self.object.msgSend(CaptureResolutionType, "captureResolution", .{});
    }

    /// `-[SCStreamConfiguration setCaptureResolution:]`
    pub fn setCaptureResolution(self: Self, capture_resolution: CaptureResolutionType) void {
        return self.object.msgSend(void, "setCaptureResolution:", .{capture_resolution});
    }

    /// `-[SCStreamConfiguration capturesShadowsOnly]`
    pub fn capturesShadowsOnly(self: Self) bool {
        return self.object.msgSend(bool, "capturesShadowsOnly", .{});
    }

    /// `-[SCStreamConfiguration setCapturesShadowsOnly:]`
    pub fn setCapturesShadowsOnly(self: Self, captures_shadows_only: bool) void {
        return self.object.msgSend(void, "setCapturesShadowsOnly:", .{captures_shadows_only});
    }

    /// `-[SCStreamConfiguration shouldBeOpaque]`
    pub fn shouldBeOpaque(self: Self) bool {
        return self.object.msgSend(bool, "shouldBeOpaque", .{});
    }

    /// `-[SCStreamConfiguration setShouldBeOpaque:]`
    pub fn setShouldBeOpaque(self: Self, should_be_opaque: bool) void {
        return self.object.msgSend(void, "setShouldBeOpaque:", .{should_be_opaque});
    }

    /// `-[SCStreamConfiguration ignoreGlobalClipDisplay]`
    pub fn ignoreGlobalClipDisplay(self: Self) bool {
        return self.object.msgSend(bool, "ignoreGlobalClipDisplay", .{});
    }

    /// `-[SCStreamConfiguration setIgnoreGlobalClipDisplay:]`
    pub fn setIgnoreGlobalClipDisplay(self: Self, ignore_global_clip_display: bool) void {
        return self.object.msgSend(void, "setIgnoreGlobalClipDisplay:", .{ignore_global_clip_display});
    }

    /// `-[SCStreamConfiguration ignoreGlobalClipSingleWindow]`
    pub fn ignoreGlobalClipSingleWindow(self: Self) bool {
        return self.object.msgSend(bool, "ignoreGlobalClipSingleWindow", .{});
    }

    /// `-[SCStreamConfiguration setIgnoreGlobalClipSingleWindow:]`
    pub fn setIgnoreGlobalClipSingleWindow(self: Self, ignore_global_clip_single_window: bool) void {
        return self.object.msgSend(void, "setIgnoreGlobalClipSingleWindow:", .{ignore_global_clip_single_window});
    }

    /// `-[SCStreamConfiguration presenterOverlayPrivacyAlertSetting]`
    pub fn presenterOverlayPrivacyAlertSetting(self: Self) PresenterOverlayAlertSetting {
        return self.object.msgSend(PresenterOverlayAlertSetting, "presenterOverlayPrivacyAlertSetting", .{});
    }

    /// `-[SCStreamConfiguration setPresenterOverlayPrivacyAlertSetting:]`
    pub fn setPresenterOverlayPrivacyAlertSetting(self: Self, presenter_overlay_privacy_alert_setting: PresenterOverlayAlertSetting) void {
        return self.object.msgSend(void, "setPresenterOverlayPrivacyAlertSetting:", .{presenter_overlay_privacy_alert_setting});
    }

    /// `-[SCStreamConfiguration includeChildWindows]`
    pub fn includeChildWindows(self: Self) bool {
        return self.object.msgSend(bool, "includeChildWindows", .{});
    }

    /// `-[SCStreamConfiguration setIncludeChildWindows:]`
    pub fn setIncludeChildWindows(self: Self, include_child_windows: bool) void {
        return self.object.msgSend(void, "setIncludeChildWindows:", .{include_child_windows});
    }

    /// `-[SCStreamConfiguration captureMicrophone]`
    pub fn captureMicrophone(self: Self) bool {
        return self.object.msgSend(bool, "captureMicrophone", .{});
    }

    /// `-[SCStreamConfiguration setCaptureMicrophone:]`
    pub fn setCaptureMicrophone(self: Self, capture_microphone: bool) void {
        return self.object.msgSend(void, "setCaptureMicrophone:", .{capture_microphone});
    }

    /// `-[SCStreamConfiguration microphoneCaptureDeviceID]`
    pub fn microphoneCaptureDeviceID(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "microphoneCaptureDeviceID", .{});
    }

    /// `-[SCStreamConfiguration setMicrophoneCaptureDeviceID:]`
    pub fn setMicrophoneCaptureDeviceID(self: Self, microphone_capture_device_id: ?foundation.String) void {
        return self.object.msgSend(void, "setMicrophoneCaptureDeviceID:", .{microphone_capture_device_id});
    }

    /// `-[SCStreamConfiguration captureDynamicRange]`
    pub fn captureDynamicRange(self: Self) CaptureDynamicRange {
        return self.object.msgSend(CaptureDynamicRange, "captureDynamicRange", .{});
    }

    /// `-[SCStreamConfiguration setCaptureDynamicRange:]`
    pub fn setCaptureDynamicRange(self: Self, capture_dynamic_range: CaptureDynamicRange) void {
        return self.object.msgSend(void, "setCaptureDynamicRange:", .{capture_dynamic_range});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"+streamConfigurationWithPreset:" = fn (StreamConfigurationPreset) StreamConfiguration;
        pub const @"-width" = fn () usize;
        pub const @"-setWidth:" = fn (usize) void;
        pub const @"-height" = fn () usize;
        pub const @"-setHeight:" = fn (usize) void;
        pub const @"-minimumFrameInterval" = fn () core_media.Time;
        pub const @"-setMinimumFrameInterval:" = fn (core_media.Time) void;
        pub const @"-pixelFormat" = fn () c_uint;
        pub const @"-setPixelFormat:" = fn (c_uint) void;
        pub const @"-scalesToFit" = fn () bool;
        pub const @"-setScalesToFit:" = fn (bool) void;
        pub const @"-preservesAspectRatio" = fn () bool;
        pub const @"-setPreservesAspectRatio:" = fn (bool) void;
        pub const @"-streamName" = fn () ?foundation.String;
        pub const @"-setStreamName:" = fn (?foundation.String) void;
        pub const @"-showsCursor" = fn () bool;
        pub const @"-setShowsCursor:" = fn (bool) void;
        pub const @"-showMouseClicks" = fn () bool;
        pub const @"-setShowMouseClicks:" = fn (bool) void;
        pub const @"-backgroundColor" = fn () cg.Color;
        pub const @"-setBackgroundColor:" = fn (cg.Color) void;
        pub const @"-sourceRect" = fn () cg.Rect;
        pub const @"-setSourceRect:" = fn (cg.Rect) void;
        pub const @"-destinationRect" = fn () cg.Rect;
        pub const @"-setDestinationRect:" = fn (cg.Rect) void;
        pub const @"-queueDepth" = fn () objc.Integer;
        pub const @"-setQueueDepth:" = fn (objc.Integer) void;
        pub const @"-colorMatrix" = fn () ?*const anyopaque;
        pub const @"-setColorMatrix:" = fn (?*const anyopaque) void;
        pub const @"-colorSpaceName" = fn () ?*const anyopaque;
        pub const @"-setColorSpaceName:" = fn (?*const anyopaque) void;
        pub const @"-capturesAudio" = fn () bool;
        pub const @"-setCapturesAudio:" = fn (bool) void;
        pub const @"-sampleRate" = fn () objc.Integer;
        pub const @"-setSampleRate:" = fn (objc.Integer) void;
        pub const @"-channelCount" = fn () objc.Integer;
        pub const @"-setChannelCount:" = fn (objc.Integer) void;
        pub const @"-excludesCurrentProcessAudio" = fn () bool;
        pub const @"-setExcludesCurrentProcessAudio:" = fn (bool) void;
        pub const @"-ignoreShadowsDisplay" = fn () bool;
        pub const @"-setIgnoreShadowsDisplay:" = fn (bool) void;
        pub const @"-ignoreShadowsSingleWindow" = fn () bool;
        pub const @"-setIgnoreShadowsSingleWindow:" = fn (bool) void;
        pub const @"-captureResolution" = fn () CaptureResolutionType;
        pub const @"-setCaptureResolution:" = fn (CaptureResolutionType) void;
        pub const @"-capturesShadowsOnly" = fn () bool;
        pub const @"-setCapturesShadowsOnly:" = fn (bool) void;
        pub const @"-shouldBeOpaque" = fn () bool;
        pub const @"-setShouldBeOpaque:" = fn (bool) void;
        pub const @"-ignoreGlobalClipDisplay" = fn () bool;
        pub const @"-setIgnoreGlobalClipDisplay:" = fn (bool) void;
        pub const @"-ignoreGlobalClipSingleWindow" = fn () bool;
        pub const @"-setIgnoreGlobalClipSingleWindow:" = fn (bool) void;
        pub const @"-presenterOverlayPrivacyAlertSetting" = fn () PresenterOverlayAlertSetting;
        pub const @"-setPresenterOverlayPrivacyAlertSetting:" = fn (PresenterOverlayAlertSetting) void;
        pub const @"-includeChildWindows" = fn () bool;
        pub const @"-setIncludeChildWindows:" = fn (bool) void;
        pub const @"-captureMicrophone" = fn () bool;
        pub const @"-setCaptureMicrophone:" = fn (bool) void;
        pub const @"-microphoneCaptureDeviceID" = fn () ?foundation.String;
        pub const @"-setMicrophoneCaptureDeviceID:" = fn (?foundation.String) void;
        pub const @"-captureDynamicRange" = fn () CaptureDynamicRange;
        pub const @"-setCaptureDynamicRange:" = fn (CaptureDynamicRange) void;
    };
};

/// `SCStream`, a subclass of `NSObject`.
pub const Stream = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCStream";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCStream alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCStream`.
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

    /// `-[SCStream initWithFilter:configuration:delegate:]`
    pub fn initWithFilterConfigurationDelegate(self: Self, content_filter: ContentFilter, stream_config: StreamConfiguration, delegate: ?StreamDelegate) Stream {
        return self.object.msgSend(Stream, "initWithFilter:configuration:delegate:", .{ content_filter, stream_config, delegate });
    }

    /// `-[SCStream addStreamOutput:type:sampleHandlerQueue:error:]`
    pub fn addStreamOutputTypeSampleHandlerQueueError(self: Self, output: StreamOutput, @"type": StreamOutputType, sample_handler_queue: ?objc.Object, @"error": ?*objc.abi.Id) bool {
        return self.object.msgSend(bool, "addStreamOutput:type:sampleHandlerQueue:error:", .{ output, @"type", sample_handler_queue, @"error" });
    }

    /// `-[SCStream removeStreamOutput:type:error:]`
    pub fn removeStreamOutputTypeError(self: Self, output: StreamOutput, @"type": StreamOutputType, @"error": ?*objc.abi.Id) bool {
        return self.object.msgSend(bool, "removeStreamOutput:type:error:", .{ output, @"type", @"error" });
    }

    /// `-[SCStream updateContentFilter:completionHandler:]`
    pub fn updateContentFilterCompletionHandler(self: Self, content_filter: ContentFilter, completion_handler: ?objc.BlockRef(fn (?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "updateContentFilter:completionHandler:", .{ content_filter, completion_handler });
    }

    /// `-[SCStream updateConfiguration:completionHandler:]`
    pub fn updateConfigurationCompletionHandler(self: Self, stream_config: StreamConfiguration, completion_handler: ?objc.BlockRef(fn (?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "updateConfiguration:completionHandler:", .{ stream_config, completion_handler });
    }

    /// `-[SCStream startCaptureWithCompletionHandler:]`
    pub fn startCaptureWithCompletionHandler(self: Self, completion_handler: ?objc.BlockRef(fn (?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "startCaptureWithCompletionHandler:", .{completion_handler});
    }

    /// `-[SCStream stopCaptureWithCompletionHandler:]`
    pub fn stopCaptureWithCompletionHandler(self: Self, completion_handler: ?objc.BlockRef(fn (?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "stopCaptureWithCompletionHandler:", .{completion_handler});
    }

    /// `-[SCStream addRecordingOutput:error:]`
    pub fn addRecordingOutputError(self: Self, recording_output: RecordingOutput, @"error": ?*objc.abi.Id) bool {
        return self.object.msgSend(bool, "addRecordingOutput:error:", .{ recording_output, @"error" });
    }

    /// `-[SCStream removeRecordingOutput:error:]`
    pub fn removeRecordingOutputError(self: Self, recording_output: RecordingOutput, @"error": ?*objc.abi.Id) bool {
        return self.object.msgSend(bool, "removeRecordingOutput:error:", .{ recording_output, @"error" });
    }

    /// `-[SCStream addClipBufferingOutput:error:]`
    pub fn addClipBufferingOutputError(self: Self, clip_buffering_output: objc.Object, @"error": ?*objc.abi.Id) bool {
        return self.object.msgSend(bool, "addClipBufferingOutput:error:", .{ clip_buffering_output, @"error" });
    }

    /// `-[SCStream removeClipBufferingOutput:error:]`
    pub fn removeClipBufferingOutputError(self: Self, clip_buffering_output: objc.Object, @"error": ?*objc.abi.Id) bool {
        return self.object.msgSend(bool, "removeClipBufferingOutput:error:", .{ clip_buffering_output, @"error" });
    }

    /// `-[SCStream addVideoEffectOutput:error:]`
    pub fn addVideoEffectOutputError(self: Self, video_effect_output: objc.Object, @"error": ?*objc.abi.Id) bool {
        return self.object.msgSend(bool, "addVideoEffectOutput:error:", .{ video_effect_output, @"error" });
    }

    /// `-[SCStream removeVideoEffectOutput:error:]`
    pub fn removeVideoEffectOutputError(self: Self, video_effect_output: objc.Object, @"error": ?*objc.abi.Id) bool {
        return self.object.msgSend(bool, "removeVideoEffectOutput:error:", .{ video_effect_output, @"error" });
    }

    /// `-[SCStream synchronizationClock]`
    pub fn synchronizationClock(self: Self) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "synchronizationClock", .{});
    }

    /// `-[SCStream isCapturing]`
    pub fn isCapturing(self: Self) bool {
        return self.object.msgSend(bool, "isCapturing", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-initWithFilter:configuration:delegate:" = fn (ContentFilter, StreamConfiguration, ?StreamDelegate) Stream;
        pub const @"-addStreamOutput:type:sampleHandlerQueue:error:" = fn (StreamOutput, StreamOutputType, ?objc.Object, ?*objc.abi.Id) bool;
        pub const @"-removeStreamOutput:type:error:" = fn (StreamOutput, StreamOutputType, ?*objc.abi.Id) bool;
        pub const @"-updateContentFilter:completionHandler:" = fn (ContentFilter, ?objc.BlockRef(fn (?foundation.ErrorObject) void)) void;
        pub const @"-updateConfiguration:completionHandler:" = fn (StreamConfiguration, ?objc.BlockRef(fn (?foundation.ErrorObject) void)) void;
        pub const @"-startCaptureWithCompletionHandler:" = fn (?objc.BlockRef(fn (?foundation.ErrorObject) void)) void;
        pub const @"-stopCaptureWithCompletionHandler:" = fn (?objc.BlockRef(fn (?foundation.ErrorObject) void)) void;
        pub const @"-addRecordingOutput:error:" = fn (RecordingOutput, ?*objc.abi.Id) bool;
        pub const @"-removeRecordingOutput:error:" = fn (RecordingOutput, ?*objc.abi.Id) bool;
        pub const @"-addClipBufferingOutput:error:" = fn (objc.Object, ?*objc.abi.Id) bool;
        pub const @"-removeClipBufferingOutput:error:" = fn (objc.Object, ?*objc.abi.Id) bool;
        pub const @"-addVideoEffectOutput:error:" = fn (objc.Object, ?*objc.abi.Id) bool;
        pub const @"-removeVideoEffectOutput:error:" = fn (objc.Object, ?*objc.abi.Id) bool;
        pub const @"-synchronizationClock" = fn () ?*anyopaque;
        pub const @"-isCapturing" = fn () bool;
    };
};

/// `SCScreenshotManager`, a subclass of `NSObject`.
pub const ScreenshotManager = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCScreenshotManager";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCScreenshotManager alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCScreenshotManager`.
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

    /// `+[SCScreenshotManager captureSampleBufferWithFilter:configuration:completionHandler:]`
    pub fn captureSampleBufferWithFilterConfigurationCompletionHandler(content_filter: ContentFilter, config: StreamConfiguration, completion_handler: ?objc.BlockRef(fn (?core_media.SampleBuffer, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "captureSampleBufferWithFilter:configuration:completionHandler:", .{ content_filter, config, completion_handler });
    }

    /// `+[SCScreenshotManager captureImageWithFilter:configuration:completionHandler:]`
    pub fn captureImageWithFilterConfigurationCompletionHandler(content_filter: ContentFilter, config: StreamConfiguration, completion_handler: ?objc.BlockRef(fn (?cg.Image, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "captureImageWithFilter:configuration:completionHandler:", .{ content_filter, config, completion_handler });
    }

    /// `+[SCScreenshotManager captureImageInRect:completionHandler:]`
    pub fn captureImageInRectCompletionHandler(rect: cg.Rect, completion_handler: ?objc.BlockRef(fn (?cg.Image, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "captureImageInRect:completionHandler:", .{ rect, completion_handler });
    }

    /// `+[SCScreenshotManager captureScreenshotWithFilter:configuration:completionHandler:]`
    pub fn captureScreenshotWithFilterConfigurationCompletionHandler(content_filter: ContentFilter, config: ScreenshotConfiguration, completion_handler: ?objc.BlockRef(fn (?ScreenshotOutput, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "captureScreenshotWithFilter:configuration:completionHandler:", .{ content_filter, config, completion_handler });
    }

    /// `+[SCScreenshotManager captureScreenshotWithRect:configuration:completionHandler:]`
    pub fn captureScreenshotWithRectConfigurationCompletionHandler(rect: cg.Rect, config: ScreenshotConfiguration, completion_handler: ?objc.BlockRef(fn (?ScreenshotOutput, ?foundation.ErrorObject) void)) void {
        return class().msgSend(void, "captureScreenshotWithRect:configuration:completionHandler:", .{ rect, config, completion_handler });
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"+captureSampleBufferWithFilter:configuration:completionHandler:" = fn (ContentFilter, StreamConfiguration, ?objc.BlockRef(fn (?core_media.SampleBuffer, ?foundation.ErrorObject) void)) void;
        pub const @"+captureImageWithFilter:configuration:completionHandler:" = fn (ContentFilter, StreamConfiguration, ?objc.BlockRef(fn (?cg.Image, ?foundation.ErrorObject) void)) void;
        pub const @"+captureImageInRect:completionHandler:" = fn (cg.Rect, ?objc.BlockRef(fn (?cg.Image, ?foundation.ErrorObject) void)) void;
        pub const @"+captureScreenshotWithFilter:configuration:completionHandler:" = fn (ContentFilter, ScreenshotConfiguration, ?objc.BlockRef(fn (?ScreenshotOutput, ?foundation.ErrorObject) void)) void;
        pub const @"+captureScreenshotWithRect:configuration:completionHandler:" = fn (cg.Rect, ScreenshotConfiguration, ?objc.BlockRef(fn (?ScreenshotOutput, ?foundation.ErrorObject) void)) void;
    };
};

/// `SCScreenshotConfiguration`, a subclass of `NSObject`.
pub const ScreenshotConfiguration = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCScreenshotConfiguration";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCScreenshotConfiguration alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCScreenshotConfiguration`.
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

    /// `-[SCScreenshotConfiguration width]`
    pub fn width(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "width", .{});
    }

    /// `-[SCScreenshotConfiguration setWidth:]`
    pub fn setWidth(self: Self, width_: objc.Integer) void {
        return self.object.msgSend(void, "setWidth:", .{width_});
    }

    /// `-[SCScreenshotConfiguration height]`
    pub fn height(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "height", .{});
    }

    /// `-[SCScreenshotConfiguration setHeight:]`
    pub fn setHeight(self: Self, height_: objc.Integer) void {
        return self.object.msgSend(void, "setHeight:", .{height_});
    }

    /// `-[SCScreenshotConfiguration showsCursor]`
    pub fn showsCursor(self: Self) bool {
        return self.object.msgSend(bool, "showsCursor", .{});
    }

    /// `-[SCScreenshotConfiguration setShowsCursor:]`
    pub fn setShowsCursor(self: Self, shows_cursor: bool) void {
        return self.object.msgSend(void, "setShowsCursor:", .{shows_cursor});
    }

    /// `-[SCScreenshotConfiguration sourceRect]`
    pub fn sourceRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "sourceRect", .{});
    }

    /// `-[SCScreenshotConfiguration setSourceRect:]`
    pub fn setSourceRect(self: Self, source_rect: cg.Rect) void {
        return self.object.msgSend(void, "setSourceRect:", .{source_rect});
    }

    /// `-[SCScreenshotConfiguration destinationRect]`
    pub fn destinationRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "destinationRect", .{});
    }

    /// `-[SCScreenshotConfiguration setDestinationRect:]`
    pub fn setDestinationRect(self: Self, destination_rect: cg.Rect) void {
        return self.object.msgSend(void, "setDestinationRect:", .{destination_rect});
    }

    /// `-[SCScreenshotConfiguration ignoreShadows]`
    pub fn ignoreShadows(self: Self) bool {
        return self.object.msgSend(bool, "ignoreShadows", .{});
    }

    /// `-[SCScreenshotConfiguration setIgnoreShadows:]`
    pub fn setIgnoreShadows(self: Self, ignore_shadows: bool) void {
        return self.object.msgSend(void, "setIgnoreShadows:", .{ignore_shadows});
    }

    /// `-[SCScreenshotConfiguration ignoreClipping]`
    pub fn ignoreClipping(self: Self) bool {
        return self.object.msgSend(bool, "ignoreClipping", .{});
    }

    /// `-[SCScreenshotConfiguration setIgnoreClipping:]`
    pub fn setIgnoreClipping(self: Self, ignore_clipping: bool) void {
        return self.object.msgSend(void, "setIgnoreClipping:", .{ignore_clipping});
    }

    /// `-[SCScreenshotConfiguration includeChildWindows]`
    pub fn includeChildWindows(self: Self) bool {
        return self.object.msgSend(bool, "includeChildWindows", .{});
    }

    /// `-[SCScreenshotConfiguration setIncludeChildWindows:]`
    pub fn setIncludeChildWindows(self: Self, include_child_windows: bool) void {
        return self.object.msgSend(void, "setIncludeChildWindows:", .{include_child_windows});
    }

    /// `-[SCScreenshotConfiguration displayIntent]`
    pub fn displayIntent(self: Self) ScreenshotDisplayIntent {
        return self.object.msgSend(ScreenshotDisplayIntent, "displayIntent", .{});
    }

    /// `-[SCScreenshotConfiguration setDisplayIntent:]`
    pub fn setDisplayIntent(self: Self, display_intent: ScreenshotDisplayIntent) void {
        return self.object.msgSend(void, "setDisplayIntent:", .{display_intent});
    }

    /// `-[SCScreenshotConfiguration dynamicRange]`
    pub fn dynamicRange(self: Self) ScreenshotDynamicRange {
        return self.object.msgSend(ScreenshotDynamicRange, "dynamicRange", .{});
    }

    /// `-[SCScreenshotConfiguration setDynamicRange:]`
    pub fn setDynamicRange(self: Self, dynamic_range: ScreenshotDynamicRange) void {
        return self.object.msgSend(void, "setDynamicRange:", .{dynamic_range});
    }

    /// `-[SCScreenshotConfiguration contentType]`
    pub fn contentType(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "contentType", .{});
    }

    /// `-[SCScreenshotConfiguration setContentType:]`
    pub fn setContentType(self: Self, content_type: objc.Object) void {
        return self.object.msgSend(void, "setContentType:", .{content_type});
    }

    /// `-[SCScreenshotConfiguration fileURL]`
    pub fn fileURL(self: Self) ?foundation.Url {
        return self.object.msgSend(?foundation.Url, "fileURL", .{});
    }

    /// `-[SCScreenshotConfiguration setFileURL:]`
    pub fn setFileURL(self: Self, file_url: ?foundation.Url) void {
        return self.object.msgSend(void, "setFileURL:", .{file_url});
    }

    /// `+[SCScreenshotConfiguration supportedContentTypes]`
    pub fn supportedContentTypes() foundation.Array(objc.Object) {
        return class().msgSend(foundation.Array(objc.Object), "supportedContentTypes", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-width" = fn () objc.Integer;
        pub const @"-setWidth:" = fn (objc.Integer) void;
        pub const @"-height" = fn () objc.Integer;
        pub const @"-setHeight:" = fn (objc.Integer) void;
        pub const @"-showsCursor" = fn () bool;
        pub const @"-setShowsCursor:" = fn (bool) void;
        pub const @"-sourceRect" = fn () cg.Rect;
        pub const @"-setSourceRect:" = fn (cg.Rect) void;
        pub const @"-destinationRect" = fn () cg.Rect;
        pub const @"-setDestinationRect:" = fn (cg.Rect) void;
        pub const @"-ignoreShadows" = fn () bool;
        pub const @"-setIgnoreShadows:" = fn (bool) void;
        pub const @"-ignoreClipping" = fn () bool;
        pub const @"-setIgnoreClipping:" = fn (bool) void;
        pub const @"-includeChildWindows" = fn () bool;
        pub const @"-setIncludeChildWindows:" = fn (bool) void;
        pub const @"-displayIntent" = fn () ScreenshotDisplayIntent;
        pub const @"-setDisplayIntent:" = fn (ScreenshotDisplayIntent) void;
        pub const @"-dynamicRange" = fn () ScreenshotDynamicRange;
        pub const @"-setDynamicRange:" = fn (ScreenshotDynamicRange) void;
        pub const @"-contentType" = fn () objc.Object;
        pub const @"-setContentType:" = fn (objc.Object) void;
        pub const @"-fileURL" = fn () ?foundation.Url;
        pub const @"-setFileURL:" = fn (?foundation.Url) void;
        pub const @"+supportedContentTypes" = fn () foundation.Array(objc.Object);
    };
};

/// `SCScreenshotOutput`, a subclass of `NSObject`.
pub const ScreenshotOutput = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCScreenshotOutput";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCScreenshotOutput alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCScreenshotOutput`.
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

    /// `-[SCScreenshotOutput sdrImage]`
    pub fn sdrImage(self: Self) ?cg.Image {
        return self.object.msgSend(?cg.Image, "sdrImage", .{});
    }

    /// `-[SCScreenshotOutput setSdrImage:]`
    pub fn setSdrImage(self: Self, sdr_image: ?cg.Image) void {
        return self.object.msgSend(void, "setSdrImage:", .{sdr_image});
    }

    /// `-[SCScreenshotOutput hdrImage]`
    pub fn hdrImage(self: Self) ?cg.Image {
        return self.object.msgSend(?cg.Image, "hdrImage", .{});
    }

    /// `-[SCScreenshotOutput setHdrImage:]`
    pub fn setHdrImage(self: Self, hdr_image: ?cg.Image) void {
        return self.object.msgSend(void, "setHdrImage:", .{hdr_image});
    }

    /// `-[SCScreenshotOutput fileURL]`
    pub fn fileURL(self: Self) ?foundation.Url {
        return self.object.msgSend(?foundation.Url, "fileURL", .{});
    }

    /// `-[SCScreenshotOutput setFileURL:]`
    pub fn setFileURL(self: Self, file_url: ?foundation.Url) void {
        return self.object.msgSend(void, "setFileURL:", .{file_url});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-sdrImage" = fn () ?cg.Image;
        pub const @"-setSdrImage:" = fn (?cg.Image) void;
        pub const @"-hdrImage" = fn () ?cg.Image;
        pub const @"-setHdrImage:" = fn (?cg.Image) void;
        pub const @"-fileURL" = fn () ?foundation.Url;
        pub const @"-setFileURL:" = fn (?foundation.Url) void;
    };
};

/// `SCRecordingOutput`, a subclass of `NSObject`.
pub const RecordingOutput = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCRecordingOutput";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCRecordingOutput alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCRecordingOutput`.
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

    /// `-[SCRecordingOutput initWithConfiguration:delegate:]`
    pub fn initWithConfigurationDelegate(self: Self, recording_output_configuration: RecordingOutputConfiguration, delegate: RecordingOutputDelegate) RecordingOutput {
        return self.object.msgSend(RecordingOutput, "initWithConfiguration:delegate:", .{ recording_output_configuration, delegate });
    }

    /// `-[SCRecordingOutput recordedDuration]`
    pub fn recordedDuration(self: Self) core_media.Time {
        return self.object.msgSend(core_media.Time, "recordedDuration", .{});
    }

    /// `-[SCRecordingOutput recordedFileSize]`
    pub fn recordedFileSize(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "recordedFileSize", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-initWithConfiguration:delegate:" = fn (RecordingOutputConfiguration, RecordingOutputDelegate) RecordingOutput;
        pub const @"-recordedDuration" = fn () core_media.Time;
        pub const @"-recordedFileSize" = fn () objc.Integer;
    };
};

/// `SCRecordingOutputConfiguration`, a subclass of `NSObject`.
pub const RecordingOutputConfiguration = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCRecordingOutputConfiguration";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCRecordingOutputConfiguration alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCRecordingOutputConfiguration`.
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

    /// `-[SCRecordingOutputConfiguration outputURL]`
    pub fn outputURL(self: Self) foundation.Url {
        return self.object.msgSend(foundation.Url, "outputURL", .{});
    }

    /// `-[SCRecordingOutputConfiguration setOutputURL:]`
    pub fn setOutputURL(self: Self, output_url: foundation.Url) void {
        return self.object.msgSend(void, "setOutputURL:", .{output_url});
    }

    /// `-[SCRecordingOutputConfiguration videoCodecType]`
    pub fn videoCodecType(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "videoCodecType", .{});
    }

    /// `-[SCRecordingOutputConfiguration setVideoCodecType:]`
    pub fn setVideoCodecType(self: Self, video_codec_type: ?foundation.String) void {
        return self.object.msgSend(void, "setVideoCodecType:", .{video_codec_type});
    }

    /// `-[SCRecordingOutputConfiguration outputFileType]`
    pub fn outputFileType(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "outputFileType", .{});
    }

    /// `-[SCRecordingOutputConfiguration setOutputFileType:]`
    pub fn setOutputFileType(self: Self, output_file_type: ?foundation.String) void {
        return self.object.msgSend(void, "setOutputFileType:", .{output_file_type});
    }

    /// `-[SCRecordingOutputConfiguration availableVideoCodecTypes]`
    pub fn availableVideoCodecTypes(self: Self) foundation.Array(objc.Object) {
        return self.object.msgSend(foundation.Array(objc.Object), "availableVideoCodecTypes", .{});
    }

    /// `-[SCRecordingOutputConfiguration availableOutputFileTypes]`
    pub fn availableOutputFileTypes(self: Self) foundation.Array(objc.Object) {
        return self.object.msgSend(foundation.Array(objc.Object), "availableOutputFileTypes", .{});
    }

    /// `-[SCRecordingOutputConfiguration mixesAudioWithMicrophone]`
    pub fn mixesAudioWithMicrophone(self: Self) bool {
        return self.object.msgSend(bool, "mixesAudioWithMicrophone", .{});
    }

    /// `-[SCRecordingOutputConfiguration setMixesAudioWithMicrophone:]`
    pub fn setMixesAudioWithMicrophone(self: Self, mixes_audio_with_microphone: bool) void {
        return self.object.msgSend(void, "setMixesAudioWithMicrophone:", .{mixes_audio_with_microphone});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-outputURL" = fn () foundation.Url;
        pub const @"-setOutputURL:" = fn (foundation.Url) void;
        pub const @"-videoCodecType" = fn () ?foundation.String;
        pub const @"-setVideoCodecType:" = fn (?foundation.String) void;
        pub const @"-outputFileType" = fn () ?foundation.String;
        pub const @"-setOutputFileType:" = fn (?foundation.String) void;
        pub const @"-availableVideoCodecTypes" = fn () foundation.Array(objc.Object);
        pub const @"-availableOutputFileTypes" = fn () foundation.Array(objc.Object);
        pub const @"-mixesAudioWithMicrophone" = fn () bool;
        pub const @"-setMixesAudioWithMicrophone:" = fn (bool) void;
    };
};

/// `SCContentSharingPicker`, a subclass of `NSObject`.
pub const ContentSharingPicker = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCContentSharingPicker";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCContentSharingPicker alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCContentSharingPicker`.
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

    /// `-[SCContentSharingPicker addObserver:]`
    pub fn addObserver(self: Self, observer: ContentSharingPickerObserver) void {
        return self.object.msgSend(void, "addObserver:", .{observer});
    }

    /// `-[SCContentSharingPicker removeObserver:]`
    pub fn removeObserver(self: Self, observer: ContentSharingPickerObserver) void {
        return self.object.msgSend(void, "removeObserver:", .{observer});
    }

    /// `-[SCContentSharingPicker setConfiguration:forStream:]`
    pub fn setConfigurationForStream(self: Self, picker_config: ?ContentSharingPickerConfiguration, stream: Stream) void {
        return self.object.msgSend(void, "setConfiguration:forStream:", .{ picker_config, stream });
    }

    /// `-[SCContentSharingPicker present]`
    pub fn present(self: Self) void {
        return self.object.msgSend(void, "present", .{});
    }

    /// `-[SCContentSharingPicker presentPickerUsingContentStyle:]`
    pub fn presentPickerUsingContentStyle(self: Self, content_style: ShareableContentStyle) void {
        return self.object.msgSend(void, "presentPickerUsingContentStyle:", .{content_style});
    }

    /// `-[SCContentSharingPicker presentPickerForStream:]`
    pub fn presentPickerForStream(self: Self, stream: Stream) void {
        return self.object.msgSend(void, "presentPickerForStream:", .{stream});
    }

    /// `-[SCContentSharingPicker presentPickerForStream:usingContentStyle:]`
    pub fn presentPickerForStreamUsingContentStyle(self: Self, stream: Stream, content_style: ShareableContentStyle) void {
        return self.object.msgSend(void, "presentPickerForStream:usingContentStyle:", .{ stream, content_style });
    }

    /// `-[SCContentSharingPicker presentPickerForCurrentApplication]`
    pub fn presentPickerForCurrentApplication(self: Self) void {
        return self.object.msgSend(void, "presentPickerForCurrentApplication", .{});
    }

    /// `+[SCContentSharingPicker sharedPicker]`
    pub fn sharedPicker() ContentSharingPicker {
        return class().msgSend(ContentSharingPicker, "sharedPicker", .{});
    }

    /// `-[SCContentSharingPicker defaultConfiguration]`
    pub fn defaultConfiguration(self: Self) ContentSharingPickerConfiguration {
        return self.object.msgSend(ContentSharingPickerConfiguration, "defaultConfiguration", .{});
    }

    /// `-[SCContentSharingPicker setDefaultConfiguration:]`
    pub fn setDefaultConfiguration(self: Self, default_configuration: ContentSharingPickerConfiguration) void {
        return self.object.msgSend(void, "setDefaultConfiguration:", .{default_configuration});
    }

    /// `-[SCContentSharingPicker maximumStreamCount]`
    pub fn maximumStreamCount(self: Self) ?foundation.Number {
        return self.object.msgSend(?foundation.Number, "maximumStreamCount", .{});
    }

    /// `-[SCContentSharingPicker setMaximumStreamCount:]`
    pub fn setMaximumStreamCount(self: Self, maximum_stream_count: ?foundation.Number) void {
        return self.object.msgSend(void, "setMaximumStreamCount:", .{maximum_stream_count});
    }

    /// `-[SCContentSharingPicker isActive]`
    pub fn isActive(self: Self) bool {
        return self.object.msgSend(bool, "isActive", .{});
    }

    /// `-[SCContentSharingPicker setActive:]`
    pub fn setActive(self: Self, active: bool) void {
        return self.object.msgSend(void, "setActive:", .{active});
    }

    /// `-[SCContentSharingPicker isAvailable]`
    pub fn isAvailable(self: Self) bool {
        return self.object.msgSend(bool, "isAvailable", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-addObserver:" = fn (ContentSharingPickerObserver) void;
        pub const @"-removeObserver:" = fn (ContentSharingPickerObserver) void;
        pub const @"-setConfiguration:forStream:" = fn (?ContentSharingPickerConfiguration, Stream) void;
        pub const @"-present" = fn () void;
        pub const @"-presentPickerUsingContentStyle:" = fn (ShareableContentStyle) void;
        pub const @"-presentPickerForStream:" = fn (Stream) void;
        pub const @"-presentPickerForStream:usingContentStyle:" = fn (Stream, ShareableContentStyle) void;
        pub const @"-presentPickerForCurrentApplication" = fn () void;
        pub const @"+sharedPicker" = fn () ContentSharingPicker;
        pub const @"-defaultConfiguration" = fn () ContentSharingPickerConfiguration;
        pub const @"-setDefaultConfiguration:" = fn (ContentSharingPickerConfiguration) void;
        pub const @"-maximumStreamCount" = fn () ?foundation.Number;
        pub const @"-setMaximumStreamCount:" = fn (?foundation.Number) void;
        pub const @"-isActive" = fn () bool;
        pub const @"-setActive:" = fn (bool) void;
        pub const @"-isAvailable" = fn () bool;
    };
};

/// `SCContentSharingPickerConfiguration`, a subclass of `NSObject`.
pub const ContentSharingPickerConfiguration = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "SCContentSharingPickerConfiguration";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[SCContentSharingPickerConfiguration alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `SCContentSharingPickerConfiguration`.
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

    /// `-[SCContentSharingPickerConfiguration allowedPickerModes]`
    pub fn allowedPickerModes(self: Self) ContentSharingPickerMode {
        return self.object.msgSend(ContentSharingPickerMode, "allowedPickerModes", .{});
    }

    /// `-[SCContentSharingPickerConfiguration setAllowedPickerModes:]`
    pub fn setAllowedPickerModes(self: Self, allowed_picker_modes: ContentSharingPickerMode) void {
        return self.object.msgSend(void, "setAllowedPickerModes:", .{allowed_picker_modes});
    }

    /// `-[SCContentSharingPickerConfiguration excludedWindowIDs]`
    pub fn excludedWindowIDs(self: Self) foundation.Array(foundation.Number) {
        return self.object.msgSend(foundation.Array(foundation.Number), "excludedWindowIDs", .{});
    }

    /// `-[SCContentSharingPickerConfiguration setExcludedWindowIDs:]`
    pub fn setExcludedWindowIDs(self: Self, excluded_window_i_ds: foundation.Array(foundation.Number)) void {
        return self.object.msgSend(void, "setExcludedWindowIDs:", .{excluded_window_i_ds});
    }

    /// `-[SCContentSharingPickerConfiguration excludedBundleIDs]`
    pub fn excludedBundleIDs(self: Self) foundation.Array(foundation.String) {
        return self.object.msgSend(foundation.Array(foundation.String), "excludedBundleIDs", .{});
    }

    /// `-[SCContentSharingPickerConfiguration setExcludedBundleIDs:]`
    pub fn setExcludedBundleIDs(self: Self, excluded_bundle_i_ds: foundation.Array(foundation.String)) void {
        return self.object.msgSend(void, "setExcludedBundleIDs:", .{excluded_bundle_i_ds});
    }

    /// `-[SCContentSharingPickerConfiguration allowsChangingSelectedContent]`
    pub fn allowsChangingSelectedContent(self: Self) bool {
        return self.object.msgSend(bool, "allowsChangingSelectedContent", .{});
    }

    /// `-[SCContentSharingPickerConfiguration setAllowsChangingSelectedContent:]`
    pub fn setAllowsChangingSelectedContent(self: Self, allows_changing_selected_content: bool) void {
        return self.object.msgSend(void, "setAllowsChangingSelectedContent:", .{allows_changing_selected_content});
    }

    /// `-[SCContentSharingPickerConfiguration showsMicrophoneControl]`
    pub fn showsMicrophoneControl(self: Self) bool {
        return self.object.msgSend(bool, "showsMicrophoneControl", .{});
    }

    /// `-[SCContentSharingPickerConfiguration setShowsMicrophoneControl:]`
    pub fn setShowsMicrophoneControl(self: Self, shows_microphone_control: bool) void {
        return self.object.msgSend(void, "setShowsMicrophoneControl:", .{shows_microphone_control});
    }

    /// `-[SCContentSharingPickerConfiguration showsCameraControl]`
    pub fn showsCameraControl(self: Self) bool {
        return self.object.msgSend(bool, "showsCameraControl", .{});
    }

    /// `-[SCContentSharingPickerConfiguration setShowsCameraControl:]`
    pub fn setShowsCameraControl(self: Self, shows_camera_control: bool) void {
        return self.object.msgSend(void, "setShowsCameraControl:", .{shows_camera_control});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-allowedPickerModes" = fn () ContentSharingPickerMode;
        pub const @"-setAllowedPickerModes:" = fn (ContentSharingPickerMode) void;
        pub const @"-excludedWindowIDs" = fn () foundation.Array(foundation.Number);
        pub const @"-setExcludedWindowIDs:" = fn (foundation.Array(foundation.Number)) void;
        pub const @"-excludedBundleIDs" = fn () foundation.Array(foundation.String);
        pub const @"-setExcludedBundleIDs:" = fn (foundation.Array(foundation.String)) void;
        pub const @"-allowsChangingSelectedContent" = fn () bool;
        pub const @"-setAllowsChangingSelectedContent:" = fn (bool) void;
        pub const @"-showsMicrophoneControl" = fn () bool;
        pub const @"-setShowsMicrophoneControl:" = fn (bool) void;
        pub const @"-showsCameraControl" = fn () bool;
        pub const @"-setShowsCameraControl:" = fn (bool) void;
    };
};

/// An object conforming to `SCStreamOutput`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const StreamOutput = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "SCStreamOutput";

    /// An object that came from elsewhere, taken to conform to `SCStreamOutput`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
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

    /// `-[SCStreamOutput stream:didOutputSampleBuffer:ofType:]`
    pub fn streamDidOutputSampleBufferOfType(self: Self, stream: Stream, sample_buffer: core_media.SampleBuffer, @"type": StreamOutputType) void {
        return self.object.msgSend(void, "stream:didOutputSampleBuffer:ofType:", .{ stream, sample_buffer, @"type" });
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-stream:didOutputSampleBuffer:ofType:" = fn (Stream, core_media.SampleBuffer, StreamOutputType) void;
    };
};

/// An object conforming to `SCStreamDelegate`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const StreamDelegate = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "SCStreamDelegate";

    /// An object that came from elsewhere, taken to conform to `SCStreamDelegate`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
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

    /// `-[SCStreamDelegate stream:didStopWithError:]`
    pub fn streamDidStopWithError(self: Self, stream: Stream, @"error": foundation.ErrorObject) void {
        return self.object.msgSend(void, "stream:didStopWithError:", .{ stream, @"error" });
    }

    /// `-[SCStreamDelegate outputVideoEffectDidStartForStream:]`
    pub fn outputVideoEffectDidStartForStream(self: Self, stream: Stream) void {
        return self.object.msgSend(void, "outputVideoEffectDidStartForStream:", .{stream});
    }

    /// `-[SCStreamDelegate outputVideoEffectDidStopForStream:]`
    pub fn outputVideoEffectDidStopForStream(self: Self, stream: Stream) void {
        return self.object.msgSend(void, "outputVideoEffectDidStopForStream:", .{stream});
    }

    /// `-[SCStreamDelegate outputVideoEffectDidFailForStream:withError:]`
    pub fn outputVideoEffectDidFailForStreamWithError(self: Self, stream: Stream, @"error": foundation.ErrorObject) void {
        return self.object.msgSend(void, "outputVideoEffectDidFailForStream:withError:", .{ stream, @"error" });
    }

    /// `-[SCStreamDelegate streamDidBecomeActive:]`
    pub fn streamDidBecomeActive(self: Self, stream: Stream) void {
        return self.object.msgSend(void, "streamDidBecomeActive:", .{stream});
    }

    /// `-[SCStreamDelegate streamDidBecomeInactive:]`
    pub fn streamDidBecomeInactive(self: Self, stream: Stream) void {
        return self.object.msgSend(void, "streamDidBecomeInactive:", .{stream});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-stream:didStopWithError:" = fn (Stream, foundation.ErrorObject) void;
        pub const @"-outputVideoEffectDidStartForStream:" = fn (Stream) void;
        pub const @"-outputVideoEffectDidStopForStream:" = fn (Stream) void;
        pub const @"-outputVideoEffectDidFailForStream:withError:" = fn (Stream, foundation.ErrorObject) void;
        pub const @"-streamDidBecomeActive:" = fn (Stream) void;
        pub const @"-streamDidBecomeInactive:" = fn (Stream) void;
    };
};

/// An object conforming to `SCRecordingOutputDelegate`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const RecordingOutputDelegate = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "SCRecordingOutputDelegate";

    /// An object that came from elsewhere, taken to conform to `SCRecordingOutputDelegate`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
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

    /// `-[SCRecordingOutputDelegate recordingOutputDidStartRecording:]`
    pub fn recordingOutputDidStartRecording(self: Self, recording_output: RecordingOutput) void {
        return self.object.msgSend(void, "recordingOutputDidStartRecording:", .{recording_output});
    }

    /// `-[SCRecordingOutputDelegate recordingOutput:didFailWithError:]`
    pub fn recordingOutputDidFailWithError(self: Self, recording_output: RecordingOutput, @"error": foundation.ErrorObject) void {
        return self.object.msgSend(void, "recordingOutput:didFailWithError:", .{ recording_output, @"error" });
    }

    /// `-[SCRecordingOutputDelegate recordingOutputDidFinishRecording:]`
    pub fn recordingOutputDidFinishRecording(self: Self, recording_output: RecordingOutput) void {
        return self.object.msgSend(void, "recordingOutputDidFinishRecording:", .{recording_output});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-recordingOutputDidStartRecording:" = fn (RecordingOutput) void;
        pub const @"-recordingOutput:didFailWithError:" = fn (RecordingOutput, foundation.ErrorObject) void;
        pub const @"-recordingOutputDidFinishRecording:" = fn (RecordingOutput) void;
    };
};

/// An object conforming to `SCContentSharingPickerObserver`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const ContentSharingPickerObserver = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "SCContentSharingPickerObserver";

    /// An object that came from elsewhere, taken to conform to `SCContentSharingPickerObserver`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
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

    /// `-[SCContentSharingPickerObserver contentSharingPicker:didCancelForStream:]`
    pub fn contentSharingPickerDidCancelForStream(self: Self, picker: ContentSharingPicker, stream: ?Stream) void {
        return self.object.msgSend(void, "contentSharingPicker:didCancelForStream:", .{ picker, stream });
    }

    /// `-[SCContentSharingPickerObserver contentSharingPicker:didUpdateWithFilter:forStream:]`
    pub fn contentSharingPickerDidUpdateWithFilterForStream(self: Self, picker: ContentSharingPicker, filter: ContentFilter, stream: ?Stream) void {
        return self.object.msgSend(void, "contentSharingPicker:didUpdateWithFilter:forStream:", .{ picker, filter, stream });
    }

    /// `-[SCContentSharingPickerObserver contentSharingPickerStartDidFailWithError:]`
    pub fn contentSharingPickerStartDidFailWithError(self: Self, @"error": foundation.ErrorObject) void {
        return self.object.msgSend(void, "contentSharingPickerStartDidFailWithError:", .{@"error"});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-contentSharingPicker:didCancelForStream:" = fn (ContentSharingPicker, ?Stream) void;
        pub const @"-contentSharingPicker:didUpdateWithFilter:forStream:" = fn (ContentSharingPicker, ContentFilter, ?Stream) void;
        pub const @"-contentSharingPickerStartDidFailWithError:" = fn (foundation.ErrorObject) void;
    };
};

// -- constants and functions -----------------------------------------------

/// `SCStreamFrameInfoStatus`.
pub fn streamFrameInfoStatus() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoStatus", .linkage = .weak }) orelse missing("SCStreamFrameInfoStatus");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamFrameInfoDisplayTime`.
pub fn streamFrameInfoDisplayTime() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoDisplayTime", .linkage = .weak }) orelse missing("SCStreamFrameInfoDisplayTime");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamFrameInfoScaleFactor`.
pub fn streamFrameInfoScaleFactor() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoScaleFactor", .linkage = .weak }) orelse missing("SCStreamFrameInfoScaleFactor");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamFrameInfoContentScale`.
pub fn streamFrameInfoContentScale() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoContentScale", .linkage = .weak }) orelse missing("SCStreamFrameInfoContentScale");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamFrameInfoContentRect`.
pub fn streamFrameInfoContentRect() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoContentRect", .linkage = .weak }) orelse missing("SCStreamFrameInfoContentRect");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamFrameInfoDirtyRects`.
pub fn streamFrameInfoDirtyRects() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoDirtyRects", .linkage = .weak }) orelse missing("SCStreamFrameInfoDirtyRects");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamFrameInfoScreenRect`.
pub fn streamFrameInfoScreenRect() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoScreenRect", .linkage = .weak }) orelse missing("SCStreamFrameInfoScreenRect");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamFrameInfoBoundingRect`.
pub fn streamFrameInfoBoundingRect() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoBoundingRect", .linkage = .weak }) orelse missing("SCStreamFrameInfoBoundingRect");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamFrameInfoPresenterOverlayContentRect`.
pub fn streamFrameInfoPresenterOverlayContentRect() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoPresenterOverlayContentRect", .linkage = .weak }) orelse missing("SCStreamFrameInfoPresenterOverlayContentRect");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamFrameInfoVideoOrientation`.
pub fn streamFrameInfoVideoOrientation() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamFrameInfoVideoOrientation", .linkage = .weak }) orelse missing("SCStreamFrameInfoVideoOrientation");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `SCStreamErrorDomain`.
pub fn streamErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "SCStreamErrorDomain", .linkage = .weak }) orelse missing("SCStreamErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}
