#import "MRSLActivity.h"
#import "MRSLItem.h"
#import "MRSLUser.h"

@interface MRSLActivity ()
@end

@implementation MRSLActivity

- (NSString *)message {
    //  Creator action subject
    return [NSString stringWithFormat:@"%@ %@ %@", [self creatorDisplayName], [self actionDisplayName], [self subjectDisplayName] ?: @""];
}

- (void)didImport:(id)data {
    if ([data[@"subject_type"] isEqualToString:@"Item"]) [self importItem:data[@"subject"]];

    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
}


#pragma mark - Private Methods

- (NSString *)actionDisplayName {
    if ([self.actionType isEqualToString:@"Like"]) {
        return @"liked";
    } else if ([self.actionType isEqualToString:@"Comment"]) {
        return @"commented on";
    } else if ([self.actionType isEqualToString:@"Follow"]) {
        return @"followed";
    } else {
        return [NSString stringWithFormat:@"%@ed", self.actionType];
    }
}

- (NSString *)creatorDisplayName {
    if ([self.creator isCurrentUser]) {
        return @"You";
    } else {
        return [self.creator displayName];
    }
}

- (void)importItem:(NSDictionary *)itemDictionary {
    if (![itemDictionary isEqual:[NSNull null]]) {
        MRSLItem *item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                       withValue:itemDictionary[@"id"]
                                                       inContext:self.managedObjectContext];
        if (!item) item = [MRSLItem MR_createInContext:self.managedObjectContext];
        [item MR_importValuesForKeysWithObject:itemDictionary];
        [self setItem:item];
        [item addActivitiesObject:self];
    }
}

- (NSString *)subjectDisplayName {
    if ([self.subjectType isEqualToString:@"Item"]) {
        return [self.item displayName];
    } else {
        return nil;
    }
}

@end
