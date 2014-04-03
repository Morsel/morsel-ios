#import "_MRSLMorsel.h"

typedef NS_ENUM(NSUInteger, MorselImageSizeType) {
    MorselImageSizeTypeCropped,
    MorselImageSizeTypeThumbnail,
    MorselImageSizeTypeFull
};

@interface MRSLMorsel : _MRSLMorsel

+ (MRSLMorsel *)localUniqueMorsel;

- (NSURLRequest *)morselPictureURLRequestForImageSizeType:(MorselImageSizeType)type;

- (NSString *)socialMessage;

- (NSString *)displayName;

@end
