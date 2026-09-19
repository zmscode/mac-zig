//! Reading PDFs. Writing one is `Context.initPdfFile`.
//!
//! CoreGraphics reads PDF as pages to be drawn, not as text to be
//! extracted: a `Page` goes into a context like an image does. That is
//! enough to render, thumbnail or rasterise a document, and it is what this
//! module covers.
//!
//! ## Pages are numbered from one
//!
//! `Document.page(1)` is the first page, not `page(0)`. This is
//! CoreGraphics' own numbering and changing it here would make every
//! CoreGraphics document and example wrong, so it is kept -- and
//! `pageCount` bounds are checked so that an off-by-one is a `null` rather
//! than a crash.

const std = @import("std");
const raw = @import("cg_raw");
const errors = @import("errors.zig");
const cf = @import("cf.zig");
const geometry = @import("geometry.zig");
const image_mod = @import("image.zig");

const Error = errors.Error;
const Rect = geometry.Rect;
const AffineTransform = geometry.AffineTransform;
const DataProvider = image_mod.DataProvider;

/// The nested rectangles a PDF page defines. `.media` is the paper,
/// `.crop` is what a viewer shows, and the rest matter for print.
pub const Box = enum(i32) {
    media = 0,
    crop = 1,
    bleed = 2,
    trim = 3,
    art = 4,
    _,
};

pub const Document = struct {
    handle: *raw.struct_CGPDFDocument,

    pub fn initFile(path: []const u8) Error!Document {
        const url = try cf.Url.initFilePath(path);
        defer url.deinit();

        const created = raw.CGPDFDocumentCreateWithURL(url.toRaw());
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn initProvider(provider: DataProvider) Error!Document {
        const created = raw.CGPDFDocumentCreateWithProvider(provider.toRaw());
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn initData(data: cf.Data) Error!Document {
        const provider = try DataProvider.initData(data);
        defer provider.deinit();
        return initProvider(provider);
    }

    pub fn deinit(self: Document) void {
        raw.CGPDFDocumentRelease(self.handle);
    }

    pub fn retain(self: Document) Document {
        return .{ .handle = raw.CGPDFDocumentRetain(self.handle).? };
    }

    pub inline fn toRaw(self: Document) raw.CGPDFDocumentRef {
        return self.handle;
    }

    pub fn pageCount(self: Document) usize {
        return raw.CGPDFDocumentGetNumberOfPages(self.handle);
    }

    /// The page at `number`, counting from **1**. Null when `number` is 0
    /// or past the end.
    ///
    /// The page is borrowed from the document -- it stays valid as long as
    /// the document does, and must not be released.
    pub fn page(self: Document, number: usize) ?Page {
        if (number == 0 or number > self.pageCount()) return null;
        return Page.fromRaw(raw.CGPDFDocumentGetPage(self.handle, number));
    }

    /// Walks the pages in order, so the 1-based numbering never has to be
    /// written out.
    pub fn pages(self: Document) PageIterator {
        return .{ .document = self, .next_number = 1 };
    }

    pub const PageIterator = struct {
        document: Document,
        next_number: usize,

        pub fn next(self: *PageIterator) ?Page {
            const found = self.document.page(self.next_number) orelse return null;
            self.next_number += 1;
            return found;
        }
    };

    pub const Version = struct {
        major: u32,
        minor: u32,

        pub fn format(self: Version, writer: *std.Io.Writer) std.Io.Writer.Error!void {
            try writer.print("{d}.{d}", .{ self.major, self.minor });
        }
    };

    pub fn version(self: Document) Version {
        var major: c_int = 0;
        var minor: c_int = 0;
        raw.CGPDFDocumentGetVersion(self.handle, &major, &minor);
        return .{
            .major = @intCast(@max(major, 0)),
            .minor = @intCast(@max(minor, 0)),
        };
    }

    pub fn isEncrypted(self: Document) bool {
        return raw.CGPDFDocumentIsEncrypted(self.handle);
    }

    /// True once the document can be read -- either it was never encrypted
    /// or `unlock` succeeded.
    pub fn isUnlocked(self: Document) bool {
        return raw.CGPDFDocumentIsUnlocked(self.handle);
    }

    /// Tries `password`. An encrypted document reports a page count of
    /// zero until this succeeds.
    pub fn unlock(self: Document, password: [:0]const u8) bool {
        return raw.CGPDFDocumentUnlockWithPassword(self.handle, password.ptr);
    }

    pub fn allowsPrinting(self: Document) bool {
        return raw.CGPDFDocumentAllowsPrinting(self.handle);
    }

    pub fn allowsCopying(self: Document) bool {
        return raw.CGPDFDocumentAllowsCopying(self.handle);
    }

    /// The document's `/Info` dictionary -- title, author, producer and so
    /// on -- borrowed from the document. Read it with
    /// `cg.raw.CGPDFDictionaryGetString`; this binding does not wrap the
    /// PDF object model.
    pub fn info(self: Document) raw.CGPDFDictionaryRef {
        return raw.CGPDFDocumentGetInfo(self.handle);
    }
};

/// One page of a document. Borrowed from its document, so there is no
/// `deinit` -- keep the `Document` alive for as long as the page is used.
pub const Page = struct {
    handle: *raw.struct_CGPDFPage,

    pub fn fromRaw(value: raw.CGPDFPageRef) ?Page {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Page) raw.CGPDFPageRef {
        return self.handle;
    }

    /// This page's 1-based number within its document.
    pub fn number(self: Page) usize {
        return raw.CGPDFPageGetPageNumber(self.handle);
    }

    /// One of the page's rectangles, in PDF points -- 72 to the inch.
    pub fn box(self: Page, which: Box) Rect {
        return .fromRaw(raw.CGPDFPageGetBoxRect(self.handle, @backingInt(which)));
    }

    /// The rotation the page asks for, in degrees: 0, 90, 180 or 270.
    /// `drawingTransform` applies it, so this is only needed to work out
    /// how big the result will be.
    pub fn rotationAngle(self: Page) i32 {
        return raw.CGPDFPageGetRotationAngle(self.handle);
    }

    /// The transform that maps `box` onto `into`, applying the page's own
    /// rotation. Concatenate this before `Context.drawPdfPage` to fit a
    /// page to a rectangle.
    pub fn drawingTransform(
        self: Page,
        which: Box,
        into: Rect,
        extra_rotation: i32,
        preserve_aspect_ratio: bool,
    ) AffineTransform {
        return .fromRaw(raw.CGPDFPageGetDrawingTransform(
            self.handle,
            @backingInt(which),
            into.toRaw(),
            extra_rotation,
            preserve_aspect_ratio,
        ));
    }
};
