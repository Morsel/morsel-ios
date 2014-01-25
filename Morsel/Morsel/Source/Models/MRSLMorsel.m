#import "MRSLMorsel.h"

#import "ModelController.h"

@interface MRSLMorsel ()

@end

@implementation MRSLMorsel

- (void)setWithDictionary:(NSDictionary *)dictionary
                inContext:(NSManagedObjectContext *)context
{
    self.liked = ([dictionary[@"liked"] isEqual:[NSNull null]]) ? self.liked : [NSNumber numberWithBool:[dictionary[@"liked"] boolValue]];
    self.morselID = ([dictionary[@"id"] isEqual:[NSNull null]]) ? self.morselID : [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
    
    if (![dictionary[@"created_at"] isEqual:[NSNull null]])
    {
        NSString *dateString = dictionary[@"created_at"];
        self.creationDate = [[ModelController sharedController].defaultDateFormatter dateFromString:dateString];
    }
    
    self.morselDescription = ([dictionary[@"description"] isEqual:[NSNull null]]) ? self.morselDescription : dictionary[@"description"];
    
    if (![dictionary[@"photos"] isEqual:[NSNull null]])
    {
        NSDictionary *photoDictionary = dictionary[@"photos"];
        
        self.morselPictureURL = [photoDictionary[@"_104x104"] stringByReplacingOccurrencesOfString:@"_104x104"
                                                                                     withString:@"IMAGE_SIZE"];
    }
}

- (NSURLRequest *)morselPictureURLRequestForImageSizeType:(MorselImageSizeType)type
{
    if (!self.morselPictureURL) return nil;
    
    BOOL isRetina = ([UIScreen mainScreen].scale == 2.f);

    NSString *typeSizeString = nil;
    
    switch (type)
    {
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
    
    NSString *adjustedURLForType = [self.morselPictureURL stringByReplacingOccurrencesOfString:@"IMAGE_SIZE"
                                                                                    withString:typeSizeString];
    
    return [NSURLRequest requestWithURL:[NSURL URLWithString:adjustedURLForType]];
}

@end
