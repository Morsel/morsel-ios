#import "MRSLMorsel.h"

#import "MRSLItem.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLMorsel ()

@end


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
    if (self.draft) objectInfoJSON[@"draft"] = (self.draftValue) ? @"true" : @"false";
    if (self.place) objectInfoJSON[@"place_id"] = NSNullIfNil(self.place.placeID);

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
