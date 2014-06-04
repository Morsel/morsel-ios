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
    if ([[data[@"subject_type"] lowercaseString] isEqualToString:@"item"]) [self importItem:data[@"subject"]];

    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
}


#pragma mark - Private Methods

- (NSString *)actionDisplayName {
    if ([[self.actionType lowercaseString] isEqualToString:@"like"]) {
        return @"liked";
    } else if ([[self.actionType lowercaseString] isEqualToString:@"comment"]) {
        return @"commented on";
    } else if ([[self.actionType lowercaseString] isEqualToString:@"follow"]) {
        return @"followed";
    } else {
        return [NSString stringWithFormat:@"%@ed", self.actionType];
    }
}

- (NSString *)creatorDisplayName {
    if ([self.creator isCurrentUser]) {
        return @"You";
    } else {
        return [self.creator username];
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
    if ([[self.subjectType lowercaseString] isEqualToString:@"item"]) {
        return [self.item displayName];
    } else if ([[self.subjectType lowercaseString] isEqualToString:@"user"]) {
        if (self.subjectIDValue == [MRSLUser currentUser].userIDValue) {
            return @"you";
        } else {
            MRSLUser *subjectUser = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                            withValue:self.subjectID
                                                            inContext:self.managedObjectContext];
            return [subjectUser username] ?: @"someone";
        }
    } else {
        return nil;
    }
}

@end
