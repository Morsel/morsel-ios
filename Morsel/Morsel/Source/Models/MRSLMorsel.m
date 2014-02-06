#import "MRSLMorsel.h"


#import "MRSLComment.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLMorsel ()

@end

@implementation MRSLMorsel

- (NSURLRequest *)morselPictureURLRequestForImageSizeType:(MorselImageSizeType)type {
    if (!self.morselPhotoURL) return nil;

    BOOL isRetina = ([UIScreen mainScreen].scale == 2.f);

    NSString *typeSizeString = nil;

    switch (type) {
    case MorselImageSizeTypeCropped:
        typeSizeString = (isRetina) ? @"_640x428" : @"_320x214";
        break;
    case MorselImageSizeTypeThumbnail:
        typeSizeString = (isRetina) ? @"_208x208" : @"_104x104";
        break;
    case MorselImageSizeTypeFull:
        typeSizeString = @"_640x640";
        break;
    default:
        DDLogError(@"Unsupported Morsel Image Size Type Requested!");
        return nil;
        break;
    }

    NSString *adjustedURLForType = [self.morselPhotoURL stringByReplacingOccurrencesOfString:@"IMAGE_SIZE"
                                                                                    withString:typeSizeString];

    return [NSURLRequest requestWithURL:[NSURL URLWithString:adjustedURLForType]];
}

- (void)didImport:(id)data {
    if (![data[@"photos"] isEqual:[NSNull null]]) {
        NSDictionary *photoDictionary = data[@"photos"];

        self.morselPhotoURL = [photoDictionary[@"_104x104"] stringByReplacingOccurrencesOfString:@"_104x104"
                                                                                        withString:@"IMAGE_SIZE"];
    }

    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [Appdelegate.defaultDateFormatter dateFromString:dateString];
    }
}

@end
