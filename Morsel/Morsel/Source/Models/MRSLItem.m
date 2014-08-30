#import "MRSLItem.h"

#import "MRSLS3Service.h"
#import "MRSLAPIService+Item.h"
#import "MRSLAPIService+Report.h"

#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLPresignedUpload.h"
#import "MRSLUser.h"

@interface MRSLItem ()

@end

@implementation MRSLItem

#pragma mark - Class Methods

+ (NSString *)API_identifier {
    return MRSLItemAttributes.itemID;
}

+ (MRSLItem *)localUniqueItemInContext:(NSManagedObjectContext *)context {
    MRSLItem *item = [MRSLItem MR_createInContext:context];
    int randomID = arc4random_uniform(1410065407);
    item.itemID = @(randomID);

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

- (void)API_updateImage {
    self.isUploading = @YES;
    self.didFailUpload = @NO;
    //  If presignedUpload returned, use it, otherwise fallback to old upload method
    if (self.presignedUpload) {
        [self S3_updateImage];
    } else {
        [self API_prepareAndUploadPresignedUpload];
    }
}

- (void)API_prepareAndUploadPresignedUpload {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getItem:self
                          parameters:@{ @"prepare_presigned_upload": @"true" }
                             success:^(id responseObject) {
                                 if (weakSelf) [weakSelf S3_updateImage];
                             } failure:^(NSError *error) {
                                 [_appDelegate.apiService updateItemImage:weakSelf
                                                                  success:^(id responseObject) {
                                                                      if (weakSelf) weakSelf.isUploading = @NO;
                                                                  } failure:nil];
                             }];
}

- (void)S3_updateImage {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.s3Service uploadImageData:self.itemPhotoFull
                         forPresignedUpload:self.presignedUpload
                                    success:^(NSDictionary *responseDictionary) {
                                        [_appDelegate.apiService updatePhotoKey:responseDictionary[@"Key"]
                                                                        forItem:weakSelf
                                                                        success:^(id responseObject) {
                                                                            if (weakSelf) {
                                                                                [weakSelf.presignedUpload MR_deleteEntity];
                                                                                [weakSelf.presignedUpload.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                                                weakSelf.isUploading = @NO;
                                                                            }
                                                                        } failure:nil];
                                    } failure:^(NSError *error) {
                                        //  S3 upload failed, fallback to API upload
                                        [_appDelegate.apiService updateItemImage:self
                                                                         success:^(id responseObject) {
                                                                             if (weakSelf) weakSelf.isUploading = @NO;
                                                                         } failure:nil];
                                    }];
}

- (BOOL)isCoverItem {
    return [[self.morsel coverItem] isEqual:self];
}

- (BOOL)isTemplatePlaceholderItem {
    return (self.template_order != nil && !self.itemPhotoURL && !self.itemPhotoFull);
}

- (NSURLRequest *)imageURLRequestForImageSizeType:(MRSLImageSizeType)type {
    if (!self.itemPhotoURL) return nil;

    BOOL isRetina = ([UIScreen mainScreen].scale == 2.f);

    NSString *typeSizeString = nil;

    switch (type) {
        case MRSLImageSizeTypeLarge:
            typeSizeString = (isRetina) ? MRSLItemImageLargeRetinaKey : MRSLItemImageLargeKey;
            break;
        case MRSLImageSizeTypeSmall:
            typeSizeString = (isRetina) ? MRSLItemImageSmallRetinaKey : MRSLItemImageSmallKey;
            break;
        case MRSLImageSizeTypeFull:
            typeSizeString = MRSLItemImageLargeRetinaKey;
            break;
        default:
            DDLogError(@"Unsupported Morsel Image Size Type Requested!");
            return nil;
            break;
    }

    NSString *adjustedURLForType = [self.itemPhotoURL stringByReplacingOccurrencesOfString:MRSLImageSizeKey
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
    return self.itemPhotoFull;
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
    if (![data[@"photos"] isEqual:[NSNull null]] && !self.photo_processingValue && !self.isUploadingValue) {
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

- (NSString *)reportableUrlString {
    return [NSString stringWithFormat:@"items/%i/report", self.itemIDValue];
}

- (void)API_reportWithSuccess:(MRSLSuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    [_appDelegate.apiService sendReportable:self
                                    success:successOrNil
                                    failure:failureOrNil];
}

- (NSString *)jsonKeyName {
    return @"item";
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];

    if (self.itemDescription) objectInfoJSON[@"description"] = self.itemDescription;

    if (self.localUUID) objectInfoJSON[@"nonce"] = self.localUUID;

    if (self.template_order) objectInfoJSON[@"template_order"] = self.template_order;

    if (self.morsel) {
        if (self.morsel.morselID) objectInfoJSON[@"morsel_id"] = self.morsel.morselID;
        if (self.sort_order) objectInfoJSON[@"sort_order"] = self.sort_order;
    }

    return objectInfoJSON;
}

@end