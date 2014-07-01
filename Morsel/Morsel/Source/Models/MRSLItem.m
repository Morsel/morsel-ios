#import "MRSLItem.h"


#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLItem ()

@end

@implementation MRSLItem

#pragma mark - Class Methods

+ (MRSLItem *)localUniqueItemInContext:(NSManagedObjectContext *)context {
    MRSLItem *item = [MRSLItem MR_createInContext:context];

    NSString *uniqueUUID = [[NSUUID UUID] UUIDString];

    while ([MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.localUUID withValue:uniqueUUID]) {
        uniqueUUID = [[NSUUID UUID] UUIDString];
    }

    item.localUUID = uniqueUUID;
    item.creationDate = [NSDate date];
    item.itemID = nil;

    return item;
}

#pragma mark - Instance Methods

- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type {
    if (!self.itemPhotoURL) return nil;

    BOOL isRetina = ([UIScreen mainScreen].scale == 2.f);

    NSString *typeSizeString = nil;

    switch (type) {
        case MRSLImageSizeTypeLarge:
            typeSizeString = (isRetina) ? @"_640x640" : @"_320x320";
            break;
        case MRSLImageSizeTypeSmall:
            typeSizeString = (isRetina) ? @"_100x100" : @"_50x50";
            break;
        case MRSLImageSizeTypeFull:
            typeSizeString = @"_640x640";
            break;
        default:
            DDLogError(@"Unsupported Morsel Image Size Type Requested!");
            return nil;
            break;
    }

    NSString *adjustedURLForType = [self.itemPhotoURL stringByReplacingOccurrencesOfString:@"IMAGE_SIZE"
                                                                                withString:typeSizeString];

    return [NSURLRequest requestWithURL:[NSURL URLWithString:adjustedURLForType]];
}

- (NSString *)socialMessage {
    NSString *message = nil;

    if (self.morsel && self.morsel.title && self.itemDescription && self.url) {
        message = [NSString stringWithFormat:@"%@: %@ %@", self.morsel.title, self.itemDescription, self.url];
    } else if (self.itemDescription) {
        message = [NSString stringWithFormat:@"%@ %@", self.itemDescription, self.url];
    } else if (self.url) {
        message = self.url;
    }

    return message;
}

- (NSString *)displayName {
    NSString *message = nil;

    if ([self.itemDescription length] > 0) {
        if (self.morsel && self.morsel.title && self.itemDescription) {
            message = [NSString stringWithFormat:@"\"%@: %@\"", self.morsel.title, self.itemDescription];
        } else if (self.itemDescription) {
            message = [NSString stringWithFormat:@"\"%@\"", self.itemDescription];
        }
    } else if([MRSLUser currentUserOwnsMorselWithCreatorID:self.creator_idValue]) {
        message = @"your item";
    } else {
        message = @"an item";
    }

    return message;
}

- (NSData *)localImageLarge {
    return self.itemPhotoCropped;
}

- (NSData *)localImageSmall {
    return self.itemPhotoThumb;
}

- (NSString *)imageURL {
    return self.itemPhotoURL;
}

- (void)willImport:(id)data {
    if (![data[@"nonce"] isEqual:[NSNull null]]) {
        MRSLItem *localItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.localUUID
                                                      withValue:data[@"nonce"]];
        if (localItem &&
            !localItem.itemID &&
            localItem.didFailUploadValue &&
            !localItem.itemPhotoURL &&
            ![localItem.objectID isEqual:self.objectID]) {
            DDLogDebug(@"Duplicate local failed item found without server id. Removing before import of updated item.");
            if (localItem.itemPhotoFull) {
                self.itemPhotoFull = [localItem.itemPhotoFull copy] ?: nil;
                self.itemPhotoCropped = [localItem.itemPhotoCropped copy] ?: nil;
                self.itemPhotoThumb = [localItem.itemPhotoThumb copy] ?: nil;
            }
            [localItem.morsel removeItemsObject:localItem];
            [localItem.morsel addItemsObject:self];
            [localItem MR_deleteEntity];
            [localItem.managedObjectContext MR_saveOnlySelfAndWait];
        }
    }
}

- (void)didImport:(id)data {
    if (![data[@"morsel_id"] isEqual:[NSNull null]]) {
        NSNumber *morselID = data[@"morsel_id"];
        MRSLMorsel *potentialMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                withValue:morselID
                                                                inContext:self.managedObjectContext];
        if (potentialMorsel) {
            self.morsel = potentialMorsel;
            [self.morsel addItemsObject:self];
        }
    }
    if (![data[@"photos"] isEqual:[NSNull null]]) {
        NSDictionary *photoDictionary = data[@"photos"];
        self.itemPhotoURL = [photoDictionary[@"_100x100"] stringByReplacingOccurrencesOfString:@"_100x100"
                                                                                    withString:@"IMAGE_SIZE"];
    }
    if (![data[@"liked_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"liked_at"];
        self.likedDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
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

    if (self.photo_processingValue || self.itemPhotoURL) self.isUploading = @NO;

    if (!self.isUploadingValue && !self.itemPhotoURL && !self.photo_processingValue && self.creator_idValue == [MRSLUser currentUser].userIDValue && self.itemPhotoFull) {
        self.didFailUpload = @YES;
    } else {
        self.didFailUpload = @NO;
    }
}

- (NSString *)jsonKeyName {
    return @"item";
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];

    [objectInfoJSON setObject:(self.itemDescription) ? self.itemDescription : [NSNull null]
                       forKey:@"description"];

    if (self.localUUID) [objectInfoJSON setObject:self.localUUID
                                           forKey:@"nonce"];

    if (self.morsel) {
        if (self.morsel.morselID) [objectInfoJSON setObject:self.morsel.morselID
                                                     forKey:@"morsel_id"];
        if (self.sort_order) [objectInfoJSON setObject:self.sort_order
                                                forKey:@"sort_order"];
    }

    return objectInfoJSON;
}

@end