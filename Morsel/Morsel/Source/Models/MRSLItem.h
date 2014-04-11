#import "_MRSLItem.h"

typedef NS_ENUM(NSUInteger, ItemImageSizeType) {
    ItemImageSizeTypeLarge,
    ItemImageSizeTypeThumbnail,
    ItemImageSizeTypeFull
};

@interface MRSLItem : _MRSLItem

+ (MRSLItem *)localUniqueItem;

- (NSURLRequest *)itemPictureURLRequestForImageSizeType:(ItemImageSizeType)type;

- (NSString *)socialMessage;

- (NSString *)displayName;

@end
