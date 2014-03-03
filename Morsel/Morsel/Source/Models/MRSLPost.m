#import "MRSLPost.h"


#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLPost ()

@end

@implementation MRSLPost

#pragma mark - Instance Methods

- (NSDate *)latestUpdatedDate {
    __block NSDate *latestUpdated = self.lastUpdatedDate;

    [self.morsels enumerateObjectsUsingBlock:^(MRSLMorsel *morsel, BOOL *stop) {
        NSDate *morselUpdatedDate = [latestUpdated laterDate:morsel.lastUpdatedDate];

        if (![morselUpdatedDate isEqualToDate:latestUpdated]) {
            latestUpdated = morsel.lastUpdatedDate;
        }
    }];
    return latestUpdated;
}

- (NSArray *)morselsArray {
    NSSortDescriptor *idSort = [NSSortDescriptor sortDescriptorWithKey:@"sort_order"
                                                                       ascending:YES];
    return [[self.morsels allObjects] sortedArrayUsingDescriptors:@[idSort]];
}

- (NSDictionary *)objectToJSON {
    NSMutableDictionary *objectInfoJSON = [NSMutableDictionary dictionary];
    [objectInfoJSON setObject:(self.title) ? self.title : [NSNull null]
                       forKey:@"title"];
    if (self.draft) [objectInfoJSON setObject:(self.draftValue) ? @"true" : @"false"
                                       forKey:@"draft"];

    NSMutableDictionary *postJSON = [NSMutableDictionary dictionaryWithObject:objectInfoJSON
                                                                         forKey:@"post"];

    return postJSON;
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
        NSString *updateString = data[@"published_at"];
        self.lastUpdatedDate = [_appDelegate.defaultDateFormatter dateFromString:updateString];
    }

    if (![data[@"updated_at"] isEqual:[NSNull null]]) {
        NSString *updateString = data[@"updated_at"];
        self.lastUpdatedDate = [_appDelegate.defaultDateFormatter dateFromString:updateString];
    }
    
    if (!self.draft) {
        self.draft = @NO;
    }
}

@end
