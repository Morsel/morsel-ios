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

- (NSString *)socialMessage {
    NSString *message = nil;

    if (self.post && self.post.title && self.morselDescription && self.url) {
        message = [NSString stringWithFormat:@"%@: %@ %@", self.post.title, self.morselDescription, self.url];
    } else if (self.morselDescription) {
        message = [NSString stringWithFormat:@"%@ %@", self.morselDescription, self.url];
    } else if (self.url) {
        message = self.url;
    }

    return message;
}

- (void)didImport:(id)data {
    if (![data[@"post_id"] isEqual:[NSNull null]]) {
        NSNumber *postID = data[@"post_id"];
        MRSLPost *potentialPost = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                            withValue:postID
                                            inContext:self.managedObjectContext];
        if (potentialPost) {
            self.post = potentialPost;
            [self.post addMorselsObject:self];
        }
    }
    if (![data[@"photos"] isEqual:[NSNull null]]) {
        NSDictionary *photoDictionary = data[@"photos"];

        self.morselPhotoURL = [photoDictionary[@"_104x104"] stringByReplacingOccurrencesOfString:@"_104x104"
                                                                                      withString:@"IMAGE_SIZE"];
    }
    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }

    self.didFailUpload = @NO;
    self.isUploading = @NO;

    if (!self.draft) {
        self.draft = @NO;
    }
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];

    if (self.morselDescription) [objectInfoJSON setObject:self.morselDescription
                                                   forKey:@"description"];

    if (self.draft) [objectInfoJSON setObject:(self.draftValue) ? @"true" : @"false"
                                       forKey:@"draft"];

    NSMutableDictionary *morselJSON = [NSMutableDictionary dictionaryWithObject:objectInfoJSON
                                                                         forKey:@"morsel"];

    if (self.post) {
        if (self.post.postID) {
            [morselJSON setObject:self.post.postID
                           forKey:@"post_id"];
        }
        if (self.post.title) {
            [morselJSON setObject:self.post.title
                           forKey:@"post_title"];
        }
    }

    return morselJSON;
}

@end
