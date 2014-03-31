#import "MRSLActivity.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLActivity ()
@end

@implementation MRSLActivity

- (NSString *)message {
    //  Creator action subject
    return [NSString stringWithFormat:@"%@ %@ %@", [self creatorDisplayName], [self actionDisplayName], [self subjectDisplayName] ?: @""];
}

- (void)didImport:(id)data {
    if ([data[@"subject_type"] isEqualToString:@"Morsel"]) [self importMorsel:data[@"subject"]];
}


#pragma mark - Private Methods

- (NSString *)actionDisplayName {
    if ([self.actionType isEqualToString:@"Like"]) {
        return @"liked";
    } else if ([self.actionType isEqualToString:@"Comment"]) {
        return @"commented on";
    } else {
        return nil;
    }
}

- (NSString *)creatorDisplayName {
    if ([self.creator isCurrentUser]) {
        return @"You";
    } else {
        return [self.creator displayName];
    }
}

- (void)importMorsel:(NSDictionary *)morselDictionary {
    if (![morselDictionary isEqual:[NSNull null]]) {
        MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:morselDictionary[@"id"]
                                                       inContext:self.managedObjectContext];
        if (!morsel) morsel = [MRSLMorsel MR_createInContext:self.managedObjectContext];
        [morsel MR_importValuesForKeysWithObject:morselDictionary];
        [morsel addActivitiesObject:self];
    }
}

- (NSString *)subjectDisplayName {
    if ([self.subjectType isEqualToString:@"Morsel"]) {
        return [self.morsel displayName];
    } else {
        return nil;
    }
}

@end
