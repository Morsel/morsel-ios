#import "MRSLMorsel.h"

#import "MRSLItem.h"
#import "MRSLUser.h"

@interface MRSLMorsel ()

@end


@implementation MRSLMorsel

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

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];
    [objectInfoJSON setObject:(self.title) ? self.title : [NSNull null]
                       forKey:@"title"];
    if (self.draft) [objectInfoJSON setObject:(self.draftValue) ? @"true" : @"false"
                                       forKey:@"draft"];
    MRSLItem *coverItem = [self coverItem];
    if (coverItem)[objectInfoJSON setObject:NSNullIfNil(coverItem.itemID)
                       forKey:@"primary_item_id"];

    NSMutableDictionary *morselJSON = [NSMutableDictionary dictionaryWithObject:objectInfoJSON
                                                                       forKey:@"morsel"];

    return morselJSON;
}

- (MRSLItem *)coverItem {
    MRSLItem *item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                             withValue:self.primary_item_id] ?: [self.itemsArray lastObject];
    return item;
}

#pragma mark - MagicalRecord

- (void)didImport:(id)data {
    if (![data[@"creator_id"] isEqual:[NSNull null]] &&
        !self.creator) {
        NSNumber *creatorID = data[@"creator_id"];
        self.creator = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                               withValue:creatorID
                                               inContext:self.managedObjectContext];
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
        self.morselPhotoURL = photoDictionary[@"_400x300"];
    }
}

@end
