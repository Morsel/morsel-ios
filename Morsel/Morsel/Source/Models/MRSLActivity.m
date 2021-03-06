#import "MRSLActivity.h"
#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLActivity ()
@end

@implementation MRSLActivity

#pragma mark - Class Methods

+ (NSString *)API_identifier {
    return MRSLActivityAttributes.activityID;
}

#pragma mark - Instance Methods

- (NSString *)message {
    //  Creator action subject
    return [NSString stringWithFormat:@"%@ %@ %@", [self creatorDisplayName], [self actionDisplayName], [self subjectDisplayName] ?: @""];
}

- (void)didImport:(id)data {
    if ([data[@"subject_type"] isEqualToString:@"Item"])
        [self importItemSubject:data[@"subject"]];
    else if ([data[@"subject_type"] isEqualToString:@"Place"])
        [self importPlaceSubject:data[@"subject"]];
    else if ([data[@"subject_type"] isEqualToString:@"User"])
        [self importUserSubject:data[@"subject"]];
    else if ([data[@"subject_type"] isEqualToString:@"Morsel"])
        [self importMorselSubject:data[@"subject"]];

    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [_appDelegate.defaultDateFormatter dateFromString:dateString];
    }
}

- (BOOL)hasItemSubject {
    return [self.subjectType isEqualToString:@"Item"];
}

- (BOOL)hasMorselSubject {
    return [self.subjectType isEqualToString:@"Morsel"];
}

- (BOOL)hasPlaceSubject {
    return [self.subjectType isEqualToString:@"Place"];
}

- (BOOL)hasUserSubject {
    return [self.subjectType isEqualToString:@"User"];
}

- (BOOL)isCommentAction {
    return [self.actionType isEqualToString:@"Comment"];
}

- (BOOL)isFollowAction {
    return [self.actionType isEqualToString:@"Follow"];
}

- (BOOL)isMorselUserTagAction {
    return [self.actionType isEqualToString:@"MorselUserTag"];
}

- (BOOL)isLikeAction {
    return [self.actionType isEqualToString:@"Like"];
}

#pragma mark - Private Methods

- (NSString *)actionDisplayName {
    if ([self isLikeAction]) {
        return @"liked";
    } else if ([self isCommentAction]) {
        return @"commented on";
    } else if ([self isFollowAction]) {
        return @"followed";
    } else if ([self isMorselUserTagAction]) {
        return @"tagged you in";
    } else {
        return [NSString stringWithFormat:@"%@ed", [self.actionType lowercaseString]];
    }
}

- (NSString *)creatorDisplayName {
    if ([self.creator isCurrentUser]) {
        return @"You";
    } else {
        return [self.creator username];
    }
}

- (void)importItemSubject:(NSDictionary *)subjectDictionary {
    if (![subjectDictionary isEqual:[NSNull null]]) {
        MRSLItem *item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                       withValue:subjectDictionary[@"id"]
                                                       inContext:self.managedObjectContext];
        if (!item) item = [MRSLItem MR_createInContext:self.managedObjectContext];
        [item MR_importValuesForKeysWithObject:subjectDictionary];
        [self setItemSubject:item];
        [item addActivitiesAsSubjectObject:self];
    }
}

- (void)importPlaceSubject:(NSDictionary *)subjectDictionary {
    if (![subjectDictionary isEqual:[NSNull null]]) {
        MRSLPlace *place = [MRSLPlace MR_findFirstByAttribute:MRSLPlaceAttributes.placeID
                                                 withValue:subjectDictionary[@"id"]
                                                 inContext:self.managedObjectContext];
        if (!place) place = [MRSLPlace MR_createInContext:self.managedObjectContext];
        [place MR_importValuesForKeysWithObject:subjectDictionary];
        [self setPlaceSubject:place];
        [place addActivitiesAsSubjectObject:self];
    }
}

- (void)importUserSubject:(NSDictionary *)subjectDictionary {
    if (![subjectDictionary isEqual:[NSNull null]]) {
        MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                 withValue:subjectDictionary[@"id"]
                                                 inContext:self.managedObjectContext];
        if (!user) user = [MRSLUser MR_createInContext:self.managedObjectContext];
        [user MR_importValuesForKeysWithObject:subjectDictionary];
        [self setUserSubject:user];
        [user addActivitiesAsSubjectObject:self];
    }
}

- (void)importMorselSubject:(NSDictionary *)subjectDictionary {
    if (![subjectDictionary isEqual:[NSNull null]]) {
        MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                 withValue:subjectDictionary[@"id"]
                                                 inContext:self.managedObjectContext];
        if (!morsel) morsel = [MRSLMorsel MR_createInContext:self.managedObjectContext];
        [morsel MR_importValuesForKeysWithObject:subjectDictionary];
        [self setMorselSubject:morsel];
        [morsel addActivitiesAsSubjectObject:self];
    }
}

- (NSString *)subjectDisplayName {
    if ([self hasItemSubject]) {
        return [self.itemSubject displayName];
    } else if ([self hasPlaceSubject]) {
        return self.placeSubject.name ?: @"some place";
    } else if ([self hasUserSubject]) {
        if (self.userSubject.userIDValue == [MRSLUser currentUser].userIDValue) {
            return @"you";
        } else {
            return [self.userSubject username] ?: @"someone";
        }
    } else if ([self hasMorselSubject]) {
        return self.morselSubject.title;
    } else {
        return nil;
    }
}

@end
