#import "MRSLMorsel.h"

#import "ModelController.h"

#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLMorsel ()

@end

@implementation MRSLMorsel

- (void)setWithDictionary:(NSDictionary *)dictionary {
    self.liked = ([dictionary[@"liked"] isEqual:[NSNull null]]) ? self.liked : [NSNumber numberWithBool:[dictionary[@"liked"] boolValue]];
    self.morselID = ([dictionary[@"id"] isEqual:[NSNull null]]) ? self.morselID : [NSNumber numberWithInt:[dictionary[@"id"] intValue]];

    if (![dictionary[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = dictionary[@"created_at"];
        self.creationDate = [[ModelController sharedController].defaultDateFormatter dateFromString:dateString];
    }

    self.morselDescription = ([dictionary[@"description"] isEqual:[NSNull null]]) ? self.morselDescription : dictionary[@"description"];

    if (![dictionary[@"photos"] isEqual:[NSNull null]]) {
        NSDictionary *photoDictionary = dictionary[@"photos"];

        self.morselPictureURL = [photoDictionary[@"_104x104"] stringByReplacingOccurrencesOfString:@"_104x104"
                                                                                        withString:@"IMAGE_SIZE"];
    }

    if (!self.post) {
        if (![dictionary[@"post_id"] isEqual:[NSNull null]]) {
            NSNumber *postID = [NSNumber numberWithInt:[dictionary[@"post_id"] intValue]];

            self.post = [[ModelController sharedController] postWithID:postID];

            if (!self.post) {
                self.post = [MRSLPost MR_createInContext:[ModelController sharedController].defaultContext];
                self.post.postID = postID;

                [[ModelController sharedController].morselApiService getPost:self.post
                                                                     success:nil
                                                                     failure:nil];
            }
        }
    } else {
        if (self.post.isDraft) {
            // Created as a draft, should now be updated with real ID and converted to normal post. If post exists elsewhere, replace it.

            if (![dictionary[@"post_id"] isEqual:[NSNull null]]) {
                NSNumber *postID = [NSNumber numberWithInt:[dictionary[@"post_id"] intValue]];

                MRSLPost *existingPost = [[ModelController sharedController] postWithID:postID];

                if (!existingPost) {
                    self.post.postID = postID;
                    self.post.draft = [NSNumber numberWithBool:NO];
                } else {
                    [[ModelController sharedController].defaultContext deleteObject:self.post];

                    self.post = existingPost;
                }
            }
        }
    }

    if (self.isDraft) {
        // If Morsel is converted from draft, trash all the stored image data

        self.morselThumb = nil;
        self.morselPicture = nil;
        self.morselPictureCropped = nil;
    }

    self.draft = [NSNumber numberWithBool:NO];
}

- (BOOL)belongsToCurrentUser {
    return ([self.post.author.userID intValue] == [[ModelController sharedController].currentUser.userID intValue]);
}

- (BOOL)isDraft {
    return [self.draft boolValue];
}

- (NSURLRequest *)morselPictureURLRequestForImageSizeType:(MorselImageSizeType)type {
    if (!self.morselPictureURL) return nil;

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

    NSString *adjustedURLForType = [self.morselPictureURL stringByReplacingOccurrencesOfString:@"IMAGE_SIZE"
                                                                                    withString:typeSizeString];

    return [NSURLRequest requestWithURL:[NSURL URLWithString:adjustedURLForType]];
}

@end
