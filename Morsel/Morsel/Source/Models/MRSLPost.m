#import "MRSLPost.h"

#import "ModelController.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLPost ()

@end

@implementation MRSLPost

#pragma mark - Instance Methods

- (void)setWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary[@"created_at"] isEqual:[NSNull null]]) {
        NSString *dateString = dictionary[@"created_at"];
        self.creationDate = [[ModelController sharedController].defaultDateFormatter dateFromString:dateString];
    }

    self.postID = ([dictionary[@"id"] isEqual:[NSNull null]]) ? self.postID : [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
    self.title = ([dictionary[@"title"] isEqual:[NSNull null]]) ? self.title : dictionary[@"title"];

    if (![dictionary[@"creator"] isEqual:[NSNull null]]) {
        if (![dictionary[@"creator"][@"id"] isEqual:[NSNull null]]) {
            NSNumber *userID = dictionary[@"creator"][@"id"];

            MRSLUser *author = [[ModelController sharedController] userWithID:userID];

            if (!author) {
                author = [MRSLUser MR_createInContext:[ModelController sharedController].defaultContext];
                author.userID = userID;
            }

            if (!dictionary[@"creator"]) {
                [[ModelController sharedController].morselApiService getUserProfile:author
                                                                            success:nil
                                                                            failure:nil];
            } else {
                [author setWithDictionary:dictionary[@"creator"]];
            }

            self.author = author;
        }
    }

    if (![dictionary[@"morsels"] isEqual:[NSNull null]]) {
        NSArray *morsels = dictionary[@"morsels"];

        if ([morsels count] > 0) {
            __block NSMutableArray *mrsls = [NSMutableArray array];

            [morsels enumerateObjectsUsingBlock:^(NSDictionary *morselDictionary, NSUInteger idx, BOOL *stop)
            {
                NSNumber *morselID = [NSNumber numberWithInt:[morselDictionary[@"id"] intValue]];

                MRSLMorsel *morsel = [[ModelController sharedController] morselWithID:morselID];

                if (!morsel) {
                    // Morsel not found. Creating.
                    morsel = [MRSLMorsel MR_createInContext:[ModelController sharedController].defaultContext];
                }

                [morsel setWithDictionary:morselDictionary];

                [mrsls addObject:morsel];
            }];

            /*
            NSArray *sortedMrsls = [mrsls sortedArrayUsingComparator:^NSComparisonResult(MRSLMorsel *morselA, MRSLMorsel *morselB)
            {
                return [morselA.sortOrder compare:morselB.sortOrder];
            }];
            */
            self.morsels = [NSOrderedSet orderedSetWithArray:mrsls];
        }
    }
}

- (void)addMorsel:(MRSLMorsel *)morsel {
    [self.morselsSet addObject:morsel];
}

- (void)removeMorsel:(MRSLMorsel *)morsel {
    [self.morselsSet removeObject:morsel];
}

- (BOOL)isDraft {
    return [self.draft boolValue];
}

@end
