#import "_MRSLMorsel.h"

typedef NS_ENUM(NSUInteger, MorselImageSizeType)
{
    MorselImageSizeTypeCropped,
    MorselImageSizeTypeThumbnail,
    MorselImageSizeTypeFull
};

@interface MRSLMorsel : _MRSLMorsel {}

- (void)setWithDictionary:(NSDictionary *)dictionary;

- (BOOL)belongsToCurrentUser;
- (BOOL)isDraft;
- (NSURLRequest *)morselPictureURLRequestForImageSizeType:(MorselImageSizeType)type;

@end
