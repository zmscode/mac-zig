/* Umbrella header for translate-c. The single place the CoreGraphics API is
   pulled in, so the translation and the linked framework cannot disagree
   about what the API looks like.

   A few of Apple's spellings do not survive Zig 0.17's C translator, and each
   is handled here rather than in build.zig, so that the workaround sits
   next to the thing it works around.

   1. Nullability on bounded array parameters -- `const CGFloat wp[_Nonnull 3]`
	  in CGColorSpace.h and CGPattern.h. The translator answers yes to
	  __has_feature(nullability_on_arrays) and then rejects the syntax. The
	  annotations carry no ABI and translate-c erases them anyway, so the
	  spellings are blanked below.

   3. Struct-size assertions on bitfield structs -- see below.

   2. Blocks -- `typedef void (^CGPathApplyBlock)(...)`. The translator has no
	  blocks support, and Zig has no way to call a block regardless, so the
	  handful of headers carrying block declarations claim their own include
	  guards here and re-declare everything except the block APIs. Each
	  omitted call is listed with the non-block equivalent to use instead. */

/* 3. Struct-size assertions on bitfield structs. CoreFoundation reaches
	  mach/message.h, which asserts the layout of the Mach message
	  descriptors. Those carry bitfields, so translate-c can only render
	  them as `opaque`, and it then emits a top-level `comptime` block
	  asking for @sizeOf of an opaque type. Because that block is top
	  level, it fires the moment anything imports the raw module.

	  mach/port.h defines the assertion macros and already has a no-op
	  branch for them, so it is pulled in first and the three macros are
	  blanked. The assertions are tautologies for the compiler that just
	  parsed those headers; nothing is being checked away. */

/* 4. Objective-C's BOOL. objc.h makes it `bool` or `signed char` on the
	  strength of __OBJC_BOOL_IS_BOOL, which clang predefines for arm64
	  Darwin and the translator does not. Left undefined, the header falls
	  back to `signed char` on every Mac, which is right for x86_64 and
	  wrong for Apple silicon -- and the difference is visible, because
	  method type encodings spell the two 'c' and 'B'. Defined here the way
	  clang would, and before anything can reach objc.h. */

#if defined(__aarch64__) && !defined(__OBJC_BOOL_IS_BOOL)
#define __OBJC_BOOL_IS_BOOL 1
#endif

#include <mach/port.h>

#undef xnu_static_assert_struct_size
#undef xnu_static_assert_struct_size_kernel_user
#undef xnu_static_assert_struct_size_kernel_user64_user32
#define xnu_static_assert_struct_size(name, expected_size)
#define xnu_static_assert_struct_size_kernel_user(name, kernel_size, user_size)
#define xnu_static_assert_struct_size_kernel_user64_user32(name, k, u64, u32)

#include <CoreFoundation/CoreFoundation.h>

#include <CoreGraphics/CGBase.h>

#undef CG_NONNULL_ARRAY
#undef CG_NULLABLE_ARRAY
#define CG_NONNULL_ARRAY
#define CG_NULLABLE_ARRAY

#undef __nonnull
#undef __nullable
#undef __null_unspecified
#define __nonnull
#define __nullable
#define __null_unspecified

/* ------------------------------------------------------------------ */
/* CGPath.h                                                            */
/* Omitted: CGPathApplyWithBlock. Use CGPathApply, which takes a plain  */
/* function pointer and an info pointer -- cg's Path.apply wraps it.    */
/* ------------------------------------------------------------------ */

#define CGPATH_H_

#include <CoreFoundation/CFArray.h>
#include <CoreGraphics/CGAffineTransform.h>

typedef struct CGPath *CGMutablePathRef;
typedef const struct CGPath *CGPathRef;

typedef CF_ENUM(int32_t, CGLineJoin) {
	kCGLineJoinMiter,
	kCGLineJoinRound,
	kCGLineJoinBevel
};

typedef CF_ENUM(int32_t, CGLineCap) {
	kCGLineCapButt,
	kCGLineCapRound,
	kCGLineCapSquare
};

CG_EXTERN CFTypeID CGPathGetTypeID(void);
CG_EXTERN CGMutablePathRef CGPathCreateMutable(void);
CG_EXTERN CGPathRef CGPathCreateCopy(CGPathRef path);
CG_EXTERN CGPathRef CGPathCreateCopyByTransformingPath(
	CGPathRef path, const CGAffineTransform *transform);
CG_EXTERN CGMutablePathRef CGPathCreateMutableCopy(CGPathRef path);
CG_EXTERN CGMutablePathRef CGPathCreateMutableCopyByTransformingPath(
	CGPathRef path, const CGAffineTransform *transform);
CG_EXTERN CGPathRef CGPathCreateWithRect(CGRect rect,
										 const CGAffineTransform *transform);
CG_EXTERN CGPathRef
CGPathCreateWithEllipseInRect(CGRect rect, const CGAffineTransform *transform);
CG_EXTERN CGPathRef CGPathCreateWithRoundedRect(
	CGRect rect, CGFloat cornerWidth, CGFloat cornerHeight,
	const CGAffineTransform *transform);
CG_EXTERN void CGPathAddRoundedRect(CGMutablePathRef path,
									const CGAffineTransform *transform,
									CGRect rect, CGFloat cornerWidth,
									CGFloat cornerHeight);
CG_EXTERN CGPathRef CGPathCreateCopyByDashingPath(
	CGPathRef path, const CGAffineTransform *transform, CGFloat phase,
	const CGFloat *lengths, size_t count);
CG_EXTERN CGPathRef CGPathCreateCopyByStrokingPath(
	CGPathRef path, const CGAffineTransform *transform, CGFloat lineWidth,
	CGLineCap lineCap, CGLineJoin lineJoin, CGFloat miterLimit);
CG_EXTERN CGPathRef CGPathRetain(CGPathRef path);
CG_EXTERN void CGPathRelease(CGPathRef path);
CG_EXTERN bool CGPathEqualToPath(CGPathRef path1, CGPathRef path2);
CG_EXTERN void CGPathMoveToPoint(CGMutablePathRef path,
								 const CGAffineTransform *m, CGFloat x,
								 CGFloat y);
CG_EXTERN void CGPathAddLineToPoint(CGMutablePathRef path,
									const CGAffineTransform *m, CGFloat x,
									CGFloat y);
CG_EXTERN void CGPathAddQuadCurveToPoint(CGMutablePathRef path,
										 const CGAffineTransform *m,
										 CGFloat cpx, CGFloat cpy, CGFloat x,
										 CGFloat y);
CG_EXTERN void CGPathAddCurveToPoint(CGMutablePathRef path,
									 const CGAffineTransform *m, CGFloat cp1x,
									 CGFloat cp1y, CGFloat cp2x, CGFloat cp2y,
									 CGFloat x, CGFloat y);
CG_EXTERN void CGPathCloseSubpath(CGMutablePathRef path);
CG_EXTERN void CGPathAddRect(CGMutablePathRef path, const CGAffineTransform *m,
							 CGRect rect);
CG_EXTERN void CGPathAddRects(CGMutablePathRef path, const CGAffineTransform *m,
							  const CGRect *rects, size_t count);
CG_EXTERN void CGPathAddLines(CGMutablePathRef path, const CGAffineTransform *m,
							  const CGPoint *points, size_t count);
CG_EXTERN void CGPathAddEllipseInRect(CGMutablePathRef path,
									  const CGAffineTransform *m, CGRect rect);
CG_EXTERN void CGPathAddRelativeArc(CGMutablePathRef path,
									const CGAffineTransform *matrix, CGFloat x,
									CGFloat y, CGFloat radius,
									CGFloat startAngle, CGFloat delta);
CG_EXTERN void CGPathAddArc(CGMutablePathRef path, const CGAffineTransform *m,
							CGFloat x, CGFloat y, CGFloat radius,
							CGFloat startAngle, CGFloat endAngle,
							bool clockwise);
CG_EXTERN void CGPathAddArcToPoint(CGMutablePathRef path,
								   const CGAffineTransform *m, CGFloat x1,
								   CGFloat y1, CGFloat x2, CGFloat y2,
								   CGFloat radius);
CG_EXTERN void CGPathAddPath(CGMutablePathRef path1, const CGAffineTransform *m,
							 CGPathRef path2);
CG_EXTERN bool CGPathIsEmpty(CGPathRef path);
CG_EXTERN bool CGPathIsRect(CGPathRef path, CGRect *rect);
CG_EXTERN CGPoint CGPathGetCurrentPoint(CGPathRef path);
CG_EXTERN CGRect CGPathGetBoundingBox(CGPathRef path);
CG_EXTERN CGRect CGPathGetPathBoundingBox(CGPathRef path);
CG_EXTERN bool CGPathContainsPoint(CGPathRef path, const CGAffineTransform *m,
								   CGPoint point, bool eoFill);

typedef CF_ENUM(int32_t, CGPathElementType) {
	kCGPathElementMoveToPoint,
	kCGPathElementAddLineToPoint,
	kCGPathElementAddQuadCurveToPoint,
	kCGPathElementAddCurveToPoint,
	kCGPathElementCloseSubpath
};

struct CGPathElement {
	CGPathElementType type;
	CGPoint *points;
};
typedef struct CGPathElement CGPathElement;

typedef void (*CGPathApplierFunction)(void *info, const CGPathElement *element);

CG_EXTERN void CGPathApply(CGPathRef path, void *info,
						   CGPathApplierFunction function);

CG_EXTERN CGPathRef CGPathCreateCopyByNormalizing(CGPathRef path,
												  bool evenOddFillRule);
CG_EXTERN CGPathRef CGPathCreateCopyByUnioningPath(CGPathRef path,
												   CGPathRef maskPath,
												   bool evenOddFillRule);
CG_EXTERN CGPathRef CGPathCreateCopyByIntersectingPath(CGPathRef path,
													   CGPathRef maskPath,
													   bool evenOddFillRule);
CG_EXTERN CGPathRef CGPathCreateCopyBySubtractingPath(CGPathRef path,
													  CGPathRef maskPath,
													  bool evenOddFillRule);
CG_EXTERN CGPathRef CGPathCreateCopyBySymmetricDifferenceOfPath(
	CGPathRef path, CGPathRef maskPath, bool evenOddFillRule);
CG_EXTERN CGPathRef CGPathCreateCopyOfLineBySubtractingPath(
	CGPathRef path, CGPathRef maskPath, bool evenOddFillRule);
CG_EXTERN CGPathRef CGPathCreateCopyOfLineByIntersectingPath(
	CGPathRef path, CGPathRef maskPath, bool evenOddFillRule);
CG_EXTERN CFArrayRef CGPathCreateSeparateComponents(CGPathRef path,
													bool evenOddFillRule);
CG_EXTERN CGPathRef CGPathCreateCopyByFlattening(CGPathRef path,
												 CGFloat flatteningThreshold);
CG_EXTERN bool CGPathIntersectsPath(CGPathRef path1, CGPathRef path2,
									bool evenOddFillRule);

/* ------------------------------------------------------------------ */
/* CGRenderingBufferProvider.h (macOS 26)                              */
/* Omitted: CGRenderingBufferProviderCreate, whose three callbacks are  */
/* blocks. CGRenderingBufferProviderCreateWithCFData covers the case    */
/* reachable from Zig.                                                  */
/* ------------------------------------------------------------------ */

#define CGRENDERINGBUFFERPROVIDER_H_

typedef struct CGRenderingBufferProvider *CGRenderingBufferProviderRef;

CG_EXTERN CGRenderingBufferProviderRef
CGRenderingBufferProviderCreateWithCFData(CFMutableDataRef data);
CG_EXTERN size_t
CGRenderingBufferProviderGetSize(CGRenderingBufferProviderRef provider);
CG_EXTERN void *
CGRenderingBufferLockBytePtr(CGRenderingBufferProviderRef provider);
CG_EXTERN void
CGRenderingBufferUnlockBytePtr(CGRenderingBufferProviderRef provider);
CG_EXTERN CFTypeID CGRenderingBufferProviderGetTypeID(void);

/* ------------------------------------------------------------------ */
/* CGPDFArray.h and CGPDFDictionary.h                                  */
/* Omitted: CGPDFArrayApplyBlock and CGPDFDictionaryApplyBlock. Walk an */
/* array by index with CGPDFArrayGetCount/GetObject; walk a dictionary  */
/* with CGPDFDictionaryApplyFunction, which takes a function pointer.   */
/* ------------------------------------------------------------------ */

#define CGPDFARRAY_H_
#define CGPDFDICTIONARY_H_

typedef struct CGPDFArray *CGPDFArrayRef;
typedef struct CGPDFDictionary *CGPDFDictionaryRef;

#include <CoreGraphics/CGPDFObject.h>
#include <CoreGraphics/CGPDFStream.h>
#include <CoreGraphics/CGPDFString.h>

CG_EXTERN size_t CGPDFArrayGetCount(CGPDFArrayRef array);
CG_EXTERN bool CGPDFArrayGetObject(CGPDFArrayRef array, size_t index,
								   CGPDFObjectRef *value);
CG_EXTERN bool CGPDFArrayGetNull(CGPDFArrayRef array, size_t index);
CG_EXTERN bool CGPDFArrayGetBoolean(CGPDFArrayRef array, size_t index,
									CGPDFBoolean *value);
CG_EXTERN bool CGPDFArrayGetInteger(CGPDFArrayRef array, size_t index,
									CGPDFInteger *value);
CG_EXTERN bool CGPDFArrayGetNumber(CGPDFArrayRef array, size_t index,
								   CGPDFReal *value);
CG_EXTERN bool CGPDFArrayGetName(CGPDFArrayRef array, size_t index,
								 const char **value);
CG_EXTERN bool CGPDFArrayGetString(CGPDFArrayRef array, size_t index,
								   CGPDFStringRef *value);
CG_EXTERN bool CGPDFArrayGetArray(CGPDFArrayRef array, size_t index,
								  CGPDFArrayRef *value);
CG_EXTERN bool CGPDFArrayGetDictionary(CGPDFArrayRef array, size_t index,
									   CGPDFDictionaryRef *value);
CG_EXTERN bool CGPDFArrayGetStream(CGPDFArrayRef array, size_t index,
								   CGPDFStreamRef *value);

CG_EXTERN size_t CGPDFDictionaryGetCount(CGPDFDictionaryRef dict);
CG_EXTERN bool CGPDFDictionaryGetObject(CGPDFDictionaryRef dict,
										const char *key, CGPDFObjectRef *value);
CG_EXTERN bool CGPDFDictionaryGetBoolean(CGPDFDictionaryRef dict,
										 const char *key, CGPDFBoolean *value);
CG_EXTERN bool CGPDFDictionaryGetInteger(CGPDFDictionaryRef dict,
										 const char *key, CGPDFInteger *value);
CG_EXTERN bool CGPDFDictionaryGetNumber(CGPDFDictionaryRef dict,
										const char *key, CGPDFReal *value);
CG_EXTERN bool CGPDFDictionaryGetName(CGPDFDictionaryRef dict, const char *key,
									  const char **value);
CG_EXTERN bool CGPDFDictionaryGetString(CGPDFDictionaryRef dict,
										const char *key, CGPDFStringRef *value);
CG_EXTERN bool CGPDFDictionaryGetArray(CGPDFDictionaryRef dict, const char *key,
									   CGPDFArrayRef *value);
CG_EXTERN bool CGPDFDictionaryGetDictionary(CGPDFDictionaryRef dict,
											const char *key,
											CGPDFDictionaryRef *value);
CG_EXTERN bool CGPDFDictionaryGetStream(CGPDFDictionaryRef dict,
										const char *key, CGPDFStreamRef *value);

typedef void (*CGPDFDictionaryApplierFunction)(const char *key,
											   CGPDFObjectRef value,
											   void *info);
CG_EXTERN void
CGPDFDictionaryApplyFunction(CGPDFDictionaryRef dict,
							 CGPDFDictionaryApplierFunction function,
							 void *info);

/* ------------------------------------------------------------------ */
/* CGBitmapContext.h                                                   */
/* Omitted: CGBitmapContextCreateAdaptive (macOS 26), whose four        */
/* callbacks are blocks, and the CGContentInfo / CGBitmapParameters /   */
/* CGBitmapLayout / CGComponent / CGColorModel types that only it uses. */
/* CGBitmapContextCreate and CGBitmapContextCreateWithData cover every  */
/* bitmap this binding creates.                                         */
/* ------------------------------------------------------------------ */

#define CGBITMAPCONTEXT_H_

#include <CoreGraphics/CGContext.h>

typedef void (*CGBitmapContextReleaseDataCallback)(void *releaseInfo,
												   void *data);

CG_EXTERN CGContextRef CGBitmapContextCreateWithData(
	void *data, size_t width, size_t height, size_t bitsPerComponent,
	size_t bytesPerRow, CGColorSpaceRef space, CGBitmapInfo bitmapInfo,
	CGBitmapContextReleaseDataCallback releaseCallback, void *releaseInfo);
CG_EXTERN CGContextRef CGBitmapContextCreate(
	void *data, size_t width, size_t height, size_t bitsPerComponent,
	size_t bytesPerRow, CGColorSpaceRef space, CGBitmapInfo bitmapInfo);
CG_EXTERN void *CGBitmapContextGetData(CGContextRef context);
CG_EXTERN size_t CGBitmapContextGetWidth(CGContextRef context);
CG_EXTERN size_t CGBitmapContextGetHeight(CGContextRef context);
CG_EXTERN size_t CGBitmapContextGetBitsPerComponent(CGContextRef context);
CG_EXTERN size_t CGBitmapContextGetBitsPerPixel(CGContextRef context);
CG_EXTERN size_t CGBitmapContextGetBytesPerRow(CGContextRef context);
CG_EXTERN CGColorSpaceRef CGBitmapContextGetColorSpace(CGContextRef context);
CG_EXTERN CGImageAlphaInfo CGBitmapContextGetAlphaInfo(CGContextRef context);
CG_EXTERN CGBitmapInfo CGBitmapContextGetBitmapInfo(CGContextRef context);
CG_EXTERN CGImageRef CGBitmapContextCreateImage(CGContextRef context);

/* ------------------------------------------------------------------ */

#include <CoreGraphics/CoreGraphics.h>

/* ------------------------------------------------------------------ */
/* ImageIO, under -Dimageio. CoreGraphics draws; it does not encode, so */
/* PNG and JPEG output comes from here.                                 */
/*                                                                      */
/* Omitted: CGImageAnimation.h entirely (animated-image playback, all of */
/* it block-based) and the CGImageMetadata API (XMP tag enumeration,     */
/* likewise). The two metadata handle types are declared because         */
/* CGImageSource and CGImageDestination mention them in signatures.      */
/* ------------------------------------------------------------------ */

#ifdef MAC_ZIG_IMAGEIO

#define CGIMAGEANIMATION_H_
#define CGIMAGEMETADATA_H_

typedef struct CGImageMetadata *CGImageMetadataRef;
typedef struct CGImageMetadataTag *CGImageMetadataTagRef;

#include <ImageIO/ImageIO.h>

#endif

/* ------------------------------------------------------------------ */
/* IOKit, under -Diokit. Power sources: battery charge, whether the     */
/* machine is on mains, and how long it has left.                       */
/*                                                                      */
/* Only the power-source headers are pulled in. IOKit as a whole is far */
/* larger, and the rest of it is not wrapped.                           */
/* ------------------------------------------------------------------ */

#ifdef MAC_ZIG_IOKIT
#include <IOKit/ps/IOPSKeys.h>
#include <IOKit/ps/IOPowerSources.h>
#endif

/* ------------------------------------------------------------------ */
/* The Objective-C runtime, under -Dobjc. Plain C: classes, selectors, */
/* the message-send trampolines and the block runtime's copy/release.   */
/*                                                                      */
/* objc_msgSend is declared `void objc_msgSend(void)` here, which is     */
/* deliberate -- it is never called through that type. mac.objc casts   */
/* it to the exact function type of each send, which is the only way it  */
/* is correct to call. The one block-taking call, objc_enumerateClasses, */
/* sits behind __BLOCKS__, which the translator does not define.         */
/* ------------------------------------------------------------------ */

#ifdef MAC_ZIG_OBJC
#include <Block.h>
#include <objc/message.h>
#include <objc/runtime.h>
#endif
