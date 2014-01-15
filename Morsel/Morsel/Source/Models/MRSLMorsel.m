#import "MRSLMorsel.h"

#import "ModelController.h"

@interface MRSLMorsel ()

@end


@implementation MRSLMorsel

- (void)setWithDictionary:(NSDictionary *)dictionary
                inContext:(NSManagedObjectContext *)context
{
#warning Following properties have not yet been implemented for generation
    // morselThumb
    // morselThumbURL
    // sortOrder
    
    self.liked = ([dictionary[@"liked"] isEqual:[NSNull null]]) ? self.liked : [NSNumber numberWithBool:[dictionary[@"liked"] boolValue]];
    self.morselID = ([dictionary[@"id"] isEqual:[NSNull null]]) ? self.morselID : [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
    
    if (![dictionary[@"created_at"] isEqual:[NSNull null]])
    {
        NSString *dateString = dictionary[@"created_at"];
        self.creationDate = [[ModelController sharedController].defaultDateFormatter dateFromString:dateString];
    }
    
    self.morselDescription = ([dictionary[@"description"] isEqual:[NSNull null]]) ? self.morselDescription : dictionary[@"description"];
    self.morselPictureURL = ([dictionary[@"photo_url"] isEqual:[NSNull null]]) ? self.morselPictureURL : dictionary[@"photo_url"];
}

- (NSURLRequest *)morselPictureURLRequest
{
    return (self.morselPictureURL) ? [NSURLRequest requestWithURL:[NSURL URLWithString:self.morselPictureURL]] : nil;
}

@end
