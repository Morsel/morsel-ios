#import "_MRSLItem.h"

#import "MRSLImageRequestable.h"

@interface MRSLItem : _MRSLItem <MRSLImageRequestable>

+ (MRSLItem *)localUniqueItemInContext:(NSManagedObjectContext *)context;

- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type;

- (NSString *)socialMessage;

- (NSString *)displayName;

- (void)API_updateImage;

@end
