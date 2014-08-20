#import "_MRSLItem.h"

#import "MRSLImageRequestable.h"
#import "MRSLReportable.h"

@interface MRSLItem : _MRSLItem <MRSLImageRequestable, MRSLReportable>

+ (MRSLItem *)localUniqueItemInContext:(NSManagedObjectContext *)context;

- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type;

- (NSString *)socialMessage;

- (NSString *)displayName;

- (BOOL)isCoverItem;

- (void)API_updateImage;

@end
