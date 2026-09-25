//! What `zig build generate` generates for Foundation. The result is
//! `src/foundation/generated.zig`, reached as `foundation.all`.
//!
//! The everyday classes are wrapped by hand in `src/foundation/` --
//! `String`, `Array(T)`, `Data` and the rest -- and generated methods keep
//! taking and returning those. What is generated here is everything else:
//! the full method lists of those same classes (`foundation.all.String`,
//! reached from a `foundation.String` with `.all()`), the long tail of
//! classes nobody wraps by hand, and Foundation's constants and C
//! functions.

pub const framework = "Foundation";
pub const imports = [_][]const u8{"Foundation/Foundation.h"};
pub const prefixes = [_][]const u8{"NS"};
/// The frameworks whose `extern` constants and C functions are generated.
pub const frameworks = [_][]const u8{"Foundation"};

pub const classes = [_][]const u8{
    // The hand-wrapped classes, every method.
    "NSString",
    "NSMutableString",
    "NSNumber",
    "NSValue",
    "NSData",
    "NSMutableData",
    "NSURL",
    "NSError",
    "NSArray",
    "NSMutableArray",
    "NSDictionary",
    "NSMutableDictionary",
    // The long tail.
    "NSSet",
    "NSMutableSet",
    "NSIndexSet",
    "NSCharacterSet",
    "NSDate",
    "NSTimeZone",
    "NSLocale",
    "NSUUID",
    "NSFileManager",
    "NSDirectoryEnumerator",
    "NSFileHandle",
    "NSPipe",
    "NSTask",
    "NSBundle",
    "NSProcessInfo",
    "NSUserDefaults",
    "NSNotification",
    "NSNotificationCenter",
    "NSTimer",
    "NSRunLoop",
    "NSThread",
    "NSOperation",
    "NSBlockOperation",
    "NSOperationQueue",
    "NSJSONSerialization",
    "NSURLComponents",
    "NSURLQueryItem",
    "NSURLRequest",
    "NSMutableURLRequest",
    "NSURLResponse",
    "NSHTTPURLResponse",
    "NSURLSession",
    "NSURLSessionConfiguration",
    "NSURLSessionTask",
    "NSURLSessionDataTask",
    "NSURLSessionDownloadTask",
    "NSURLSessionUploadTask",
};

pub const protocols = [_][]const u8{
    "NSFileManagerDelegate",
    "NSURLSessionDelegate",
    "NSURLSessionTaskDelegate",
    "NSURLSessionDataDelegate",
};

pub const enums = [_][]const u8{
    "NSComparisonResult",
    "NSSearchPathDirectory",
    "NSSearchPathDomainMask",
    "NSQualityOfService",
    "NSStringCompareOptions",
    "NSStringEnumerationOptions",
    "NSStringEncodingConversionOptions",
    "NSDataReadingOptions",
    "NSDataWritingOptions",
    "NSDataSearchOptions",
    "NSDataBase64EncodingOptions",
    "NSDataBase64DecodingOptions",
    "NSDataCompressionAlgorithm",
    "NSBinarySearchingOptions",
    "NSEnumerationOptions",
    "NSSortOptions",
    "NSJSONReadingOptions",
    "NSJSONWritingOptions",
    "NSURLBookmarkCreationOptions",
    "NSURLBookmarkResolutionOptions",
    "NSDirectoryEnumerationOptions",
    "NSFileManagerItemReplacementOptions",
    "NSFileManagerUnmountOptions",
    "NSVolumeEnumerationOptions",
    "NSURLRelationship",
    "NSTaskTerminationReason",
    "NSProcessInfoThermalState",
    "NSActivityOptions",
    "NSOperationQueuePriority",
    "NSNotificationSuspensionBehavior",
    "NSTimeZoneNameStyle",
    "NSLocaleLanguageDirection",
    "NSURLRequestCachePolicy",
    "NSURLRequestNetworkServiceType",
    "NSURLRequestAttribution",
    "NSURLSessionTaskState",
    "NSURLSessionDelayedRequestDisposition",
    "NSURLSessionAuthChallengeDisposition",
    "NSURLSessionResponseDisposition",
    "NSURLSessionMultipathServiceType",
    "NSURLSessionWebSocketMessageType",
    "NSURLSessionWebSocketCloseCode",
    "NSHTTPCookieAcceptPolicy",
    "NSURLCacheStoragePolicy",
    "NSKeyValueObservingOptions",
    "NSKeyValueChange",
    "NSKeyValueSetMutationKind",
    "NSOrderedCollectionDifferenceCalculationOptions",
    "NSLinguisticTaggerOptions",
    "NSFileManagerUploadLocalVersionConflictPolicy",
    "NSFileManagerResumeSyncBehavior",
};

pub const structs = [_][]const u8{
    "NSOperatingSystemVersion",
    "NSEdgeInsets",
};
