#import "_MRSLItem.h"

typedef NS_ENUM(NSUInteger, ItemImageSizeType) {
    ItemImageSizeTypeLarge,
    ItemImageSizeTypeThumbnail,
    ItemImageSizeTypeFull
};

@interface MRSLItem : _MRSLItem

+ (MRSLItem *)localUniqueItemInContext:(NSManagedObjectContext *)context;

- (NSURLRequest *)itemPictureURLRequestForImageSizeType:(ItemImageSizeType)type;

- (NSString *)socialMessage;

- (NSString *)displayName;

@end
