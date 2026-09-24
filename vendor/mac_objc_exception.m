/* The one Objective-C source file in the package: @try has no C spelling,
   so catching an Objective-C exception from Zig needs a frame that was
   compiled as Objective-C.

   `body` is a Zig function. An exception raised anywhere beneath it -- in
   objc_msgSend, in a framework, in a method implemented in Zig --
   unwinds through the Zig frames to the @catch here. Zig's `defer`s in
   those frames do not run on the way; mac.objc keeps the frames between
   the throw and this catch free of them.

   Built without ARC, so the retain below is spelled out. The caller owns
   the exception it gets back. */

#import <Foundation/Foundation.h>

void *mac_zig_objc_try(void (*body)(void *context), void *context) {
	@try {
		body(context);
		return NULL;
	} @catch (id exception) {
		return [exception retain];
	}
}
