#import "MRSLPost.h"

#import "ModelController.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLPost ()

@end

@implementation MRSLPost

#pragma mark - Instance Methods

- (void)setWithDictionary:(NSDictionary *)dictionary
{
    if (![dictionary[@"created_at"] isEqual:[NSNull null]])
    {
        NSString *dateString = dictionary[@"created_at"];
        self.creationDate = [[ModelController sharedController].defaultDateFormatter dateFromString:dateString];
    }
    
    self.postID = ([dictionary[@"id"] isEqual:[NSNull null]]) ? self.postID : [NSNumber numberWithInt:[dictionary[@"id"] intValue]];
    self.title = ([dictionary[@"title"] isEqual:[NSNull null]]) ? self.title : dictionary[@"title"];
    
    if (![dictionary[@"creator"] isEqual:[NSNull null]])
    {
        if (![dictionary[@"creator"][@"id"] isEqual:[NSNull null]])
        {
            NSNumber *userID = dictionary[@"creator"][@"id"];
            
            MRSLUser *author = nil;
            
            if ([[ModelController sharedController].currentUser.userID intValue] == [userID intValue])
            {
                author = [ModelController sharedController].currentUser;
            }
            else
            {
                author = [MRSLUser MR_createInContext:[ModelController sharedController].defaultContext];
                [author setWithDictionary:dictionary[@"creator"]];
            }
            
            self.author = author;
        }
    }
    
    if (![dictionary[@"morsels"] isEqual:[NSNull null]])
    {
        NSArray *morsels = dictionary[@"morsels"];
        
        if ([morsels count] > 0)
        {
            __block NSMutableArray *mrsls = [NSMutableArray array];
            
            [morsels enumerateObjectsUsingBlock:^(NSDictionary *morselDictionary, NSUInteger idx, BOOL *stop)
             {
                 MRSLMorsel *morsel = [MRSLMorsel MR_createInContext:[ModelController sharedController].defaultContext];
                 [morsel setWithDictionary:morselDictionary];
                 
                 [mrsls addObject:morsel];
             }];
            
#warning Compare Morsel order with new Sort Order object
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

- (void)addMorsel:(MRSLMorsel *)morsel
{
    [self.morselsSet addObject:morsel];
}

- (BOOL)isDraft
{
    return [self.draft boolValue];
}

@end
