#import "_MRSLMorsel.h"

typedef NS_ENUM(NSUInteger, MorselImageSizeType) {
    MorselImageSizeTypeCropped,
    MorselImageSizeTypeThumbnail,
    MorselImageSizeTypeFull
};

@interface MRSLMorsel : _MRSLMorsel {
}

- (NSURLRequest *)morselPictureURLRequestForImageSizeType:(MorselImageSizeType)type;

@end
