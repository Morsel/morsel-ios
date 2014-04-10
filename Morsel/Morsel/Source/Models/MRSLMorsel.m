#import "MRSLMorsel.h"


#import "MRSLComment.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLMorsel ()

@end

@implementation MRSLMorsel

#pragma mark - Class Methods

+ (MRSLMorsel *)localUniqueMorsel {
    MRSLMorsel *morsel = [MRSLMorsel MR_createEntity];

    NSString *uniqueUUID = [[NSUUID UUID] UUIDString];

    while ([MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.localUUID withValue:uniqueUUID]) {
        uniqueUUID = [[NSUUID UUID] UUIDString];
    }

    morsel.localUUID = uniqueUUID;
    morsel.creationDate = [NSDate date];
    morsel.morselID = nil;

    return morsel;
}

#pragma mark - Instance Methods

- (NSURLRequest *)morselPictureURLRequestForImageSizeType:(MorselImageSizeType)type {
    if (!self.morselPhotoURL) return nil;

    BOOL isRetina = ([UIScreen mainScreen].scale == 2.f);

    NSString *typeSizeString = nil;

    switch (type) {
        case MorselImageSizeTypeLarge:
            typeSizeString = (isRetina) ? @"_640x640" : @"_320x320";
            break;
        case MorselImageSizeTypeThumbnail:
            typeSizeString = (isRetina) ? @"_100x100" : @"_50x50";
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

- (NSString *)displayName {
    NSString *message = nil;

    if ([self.morselDescription length] > 0) {
        if (self.post && self.post.title && self.morselDescription) {
            message = [NSString stringWithFormat:@"\"%@: %@\"", self.post.title, self.morselDescription];
        } else if (self.morselDescription) {
            message = [NSString stringWithFormat:@"\"%@\"", self.morselDescription];
        }
    } else if([MRSLUser currentUserOwnsMorselWithCreatorID:self.creator_idValue]) {
        message = @"your item";
    } else {
        message = @"an item";
    }

    return message;
}

- (void)willImport:(id)data {
    if (![data[@"nonce"] isEqual:[NSNull null]]) {
        MRSLMorsel *potentialLocalOrphanedMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.localUUID
                                                                             withValue:data[@"nonce"]];
        if (potentialLocalOrphanedMorsel && potentialLocalOrphanedMorsel.morselPhotoCropped && !potentialLocalOrphanedMorsel.morselID) {
            DDLogDebug(@"Local orphaned Morsel found that matches server copy and it contains binary image data. Poaching then deleting!");
            self.morselPhotoCropped = [potentialLocalOrphanedMorsel.morselPhotoCropped copy] ?: nil;
            self.morselPhotoThumb = [potentialLocalOrphanedMorsel.morselPhotoThumb copy] ?: nil;
            [potentialLocalOrphanedMorsel MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
        }
    }
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
        self.morselPhotoURL = [photoDictionary[@"_100x100"] stringByReplacingOccurrencesOfString:@"_100x100"
                                                                                      withString:@"IMAGE_SIZE"];
    }
    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
    if (![data[@"updated_at"] isEqual:[NSNull null]]) {
        NSString *updateString = data[@"updated_at"];
        self.lastUpdatedDate = [_appDelegate.defaultDateFormatter dateFromString:updateString];
    }
    if (![data[@"nonce"] isEqual:[NSNull null]]) {
        self.localUUID = data[@"nonce"];
    } else {
        self.localUUID = nil;
    }

    if (self.photo_processingValue || self.morselPhotoURL) self.isUploading = @NO;

    if (!self.isUploadingValue && !self.morselPhotoURL && !self.photo_processingValue && self.creator_idValue == [MRSLUser currentUser].userIDValue && self.morselPhotoCropped) {
        self.didFailUpload = @YES;
    } else {
        self.didFailUpload = @NO;
    }
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];

    [objectInfoJSON setObject:(self.morselDescription) ? self.morselDescription : [NSNull null]
                       forKey:@"description"];

    if (self.localUUID) [objectInfoJSON setObject:self.localUUID
                                           forKey:@"nonce"];

    NSMutableDictionary *morselJSON = [NSMutableDictionary dictionaryWithObject:objectInfoJSON
                                                                         forKey:@"morsel"];

    if (self.post) {
        if (self.post.postID) [morselJSON setObject:self.post.postID
                                             forKey:@"post_id"];
        if (self.post.title) [morselJSON setObject:self.post.title
                                            forKey:@"post_title"];
        if (self.sort_order) [morselJSON setObject:self.sort_order
                                            forKey:@"sort_order"];
    }
    
    return morselJSON;
}

@end
