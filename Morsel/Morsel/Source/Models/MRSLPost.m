#import "MRSLPost.h"


#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLPost ()

@end

@implementation MRSLPost

#pragma mark - Instance Methods

- (BOOL)isPublished {
    __block BOOL isPublished = NO;

    [self.morsels enumerateObjectsUsingBlock:^(MRSLMorsel *morsel, NSUInteger idx, BOOL *stop) {
        if (!morsel.draftValue) {
            isPublished = YES;
            *stop = YES;
        }
    }];
    return isPublished;
}

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
        self.creationDate = [Appdelegate.defaultDateFormatter dateFromString:dateString];
    }
}

@end
