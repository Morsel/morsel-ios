#import "MRSLComment.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLComment ()

@end

@implementation MRSLComment

- (BOOL)shouldImport:(id)data {
    if (![data[@"creator_id"] isEqual:[NSNull null]]) {
        NSNumber *creatorID = data[@"creator_id"];
        self.creator = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                               withValue:creatorID
                                               inContext:self.managedObjectContext];

        if (!self.creator) {
            return NO;
        }
    }

    if (![data[@"morsel_id"] isEqual:[NSNull null]]) {
        NSNumber *morselID = data[@"morsel_id"];
        self.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                               withValue:morselID
                                                inContext:self.managedObjectContext];

        if (!self.morsel) {
            return NO;
        }
    }
    return YES;
}

- (void)didImport:(id)data {
    if (![data[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = data[@"created_at"];
        self.creationDate = [Appdelegate.defaultDateFormatter dateFromString:dateString];
    }
}

@end
