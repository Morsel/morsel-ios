#import "_MRSLItem.h"

@interface MRSLItem : _MRSLItem

+ (MRSLItem *)localUniqueItemInContext:(NSManagedObjectContext *)context;

- (NSURLRequest *)itemPictureURLRequestForImageSizeType:(MRSLItemImageSizeType)type;

- (NSString *)socialMessage;

- (NSString *)displayName;

@end
