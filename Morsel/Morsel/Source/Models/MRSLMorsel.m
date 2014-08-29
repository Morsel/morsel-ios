#import "MRSLMorsel.h"

#import "MRSLAPIService+Report.h"
#import "MRSLAPIService+Templates.h"

#import "MRSLItem.h"
#import "MRSLPlace.h"
#import "MRSLTemplate.h"
#import "MRSLTemplateItem.h"
#import "MRSLUser.h"

@implementation MRSLMorsel

#pragma mark - Class Methods

+ (NSString *)API_identifier {
    return MRSLMorselAttributes.morselID;
}

#pragma mark - Instance Methods

- (NSDate *)latestUpdatedDate {
    __block NSDate *latestUpdated = self.lastUpdatedDate;

    [self.items enumerateObjectsUsingBlock:^(MRSLItem *item, BOOL *stop) {
        NSDate *itemUpdatedDate = [latestUpdated laterDate:item.lastUpdatedDate];

        if (![itemUpdatedDate isEqualToDate:latestUpdated]) {
            latestUpdated = item.lastUpdatedDate;
        }
    }];
    return latestUpdated;
}

- (NSArray *)itemsArray {
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"sort_order"
                                                             ascending:YES];
    return [[self.items allObjects] sortedArrayUsingDescriptors:@[idSort]];
}

- (NSString *)jsonKeyName {
    return @"morsel";
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];
    objectInfoJSON[@"title"] = NSNullIfNil(self.title);
    objectInfoJSON[@"place_id"] = NSNullIfNil(self.place.placeID);
    if (self.template_id) objectInfoJSON[@"template_id"] = NSNullIfNil(self.template_id);
    MRSLItem *coverItem = [self coverItem];
    if (coverItem) objectInfoJSON[@"primary_item_id"] = NSNullIfNil(coverItem.itemID);

    return objectInfoJSON;
}

- (MRSLItem *)coverItem {
    MRSLItem *item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                             withValue:self.primary_item_id] ?: [self.itemsArray lastObject];
    return item;
}

- (BOOL)hasCreatorInfo {
    //  Can tell if a User object has been fetched if a username exists.
    return self.creator && self.creator.username;
}

- (BOOL)hasPlaceholderTitle {
    MRSLTemplate *morselTemplate = [MRSLTemplate MR_findFirstByAttribute:MRSLTemplateAttributes.templateID
                                                               withValue:self.template_id];
    return ([[self.title lowercaseString] isEqualToString:[[NSString stringWithFormat:@"%@ morsel", morselTemplate.title] lowercaseString]]) || [[self.title lowercaseString] isEqualToString:@"new morsel"];
}

- (NSString *)reportableUrlString {
    return [NSString stringWithFormat:@"morsels/%i/report", self.morselIDValue];
}

- (void)API_reportWithSuccess:(MRSLSuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    [_appDelegate.apiService sendReportable:self
                                    success:successOrNil
                                    failure:failureOrNil];
}

- (NSData *)downloadCoverPhotoIfNilWithCompletion:(MRSLSuccessOrFailureBlock)completionOrNil {
    // Specifically to ensure the cover photo full NSData is available for Instagram distribution
    MRSLItem *coverItem = [self coverItem];
    if (coverItem.itemPhotoFull) return coverItem.itemPhotoFull;

    if (!coverItem.itemPhotoFull && coverItem.itemPhotoURL && !coverItem.photo_processingValue) {
        __block NSManagedObjectContext *workContext = nil;
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            workContext = localContext;
            MRSLItem *localContextCoverItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                      withValue:coverItem.itemID
                                                                      inContext:localContext];
            localContextCoverItem.itemPhotoFull = [NSData dataWithContentsOfURL:[coverItem imageURLRequestForImageSizeType:MRSLImageSizeTypeFull].URL];
        } completion:^(BOOL success, NSError *error) {
            [workContext reset];
            if (completionOrNil) completionOrNil(success, error);
        }];
    } else if(completionOrNil) {
        completionOrNil(NO, nil);
    }

    return nil;
}

- (void)reloadTemplateDataIfNecessaryWithSuccess:(MRSLSuccessBlock)successOrNil
                                         failure:(MRSLFailureBlock)failureOrNil {
    MRSLTemplate *morselTemplate = [MRSLTemplate MR_findFirstByAttribute:MRSLTemplateAttributes.templateID
                                                               withValue:self.template_id ?: @(1)];
    if (!morselTemplate) {
        __weak __typeof(self)weakSelf = self;
        [_appDelegate.apiService getTemplatesWithSuccess:^(NSArray *responseArray) {
            [weakSelf reloadPlaceholderItemsWithSuccess:successOrNil
                                                failure:failureOrNil];
        } failure:failureOrNil];
    } else {
        [self reloadPlaceholderItemsWithSuccess:successOrNil
                                        failure:failureOrNil];
    }
}

- (void)reloadPlaceholderItemsWithSuccess:(MRSLSuccessBlock)successOrNil
                                  failure:(MRSLFailureBlock)failureOrNil {
    __weak __typeof(self)weakSelf = self;
    __block NSManagedObjectContext *workContext = nil;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        if (weakSelf) {
            workContext = localContext;
            MRSLMorsel *localContextMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                       withValue:weakSelf.morselID
                                                                       inContext:localContext];
            for (MRSLItem *item in localContextMorsel.items) {
                if (item.template_order && !item.placeholder_description) {
                    MRSLTemplateItem *templateItem = [MRSLTemplateItem MR_findFirstByAttribute:MRSLTemplateItemAttributes.template_order
                                                                                     withValue:item.template_order
                                                                                     inContext:localContext];
                    item.placeholder_description = templateItem.placeholder_description;
                    item.placeholder_photo_large = templateItem.placeholder_photo_large;
                    item.placeholder_photo_small = templateItem.placeholder_photo_small;
                }
            }
        }
    } completion:^(BOOL success, NSError *error) {
        [workContext reset];
        if (successOrNil) successOrNil(YES);
    }];
}

#pragma mark - MagicalRecord

- (void)didImport:(id)data {
    if (![data[@"creator_id"] isEqual:[NSNull null]] &&
        !self.creator) {
        NSNumber *creatorID = data[@"creator_id"];
        MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                 withValue:creatorID
                                                 inContext:self.managedObjectContext];
        if (!user) {
            user = [MRSLUser MR_createInContext:self.managedObjectContext];
            user.userID = data[@"creator_id"];
        }
        self.creator = user;
    }

    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }

    if (![data[@"published_at"] isEqual:[NSNull null]]) {
        NSString *publishString = data[@"published_at"];
        self.publishedDate = [_appDelegate.defaultDateFormatter dateFromString:publishString];
    }

    if (![data[@"updated_at"] isEqual:[NSNull null]]) {
        NSString *updateString = data[@"updated_at"];
        self.lastUpdatedDate = [_appDelegate.defaultDateFormatter dateFromString:updateString];
    }
    if (![data[@"photos"] isEqual:[NSNull null]]) {
        NSDictionary *photoDictionary = data[@"photos"];
        self.morselPhotoURL = photoDictionary[@"_800x600"];
    }
}

@end
