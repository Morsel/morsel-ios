#import "MRSLPost.h"

#import "ModelController.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLPost ()

@end


@implementation MRSLPost

#pragma mark - Instance Methods

- (void)setWithDictionary:(NSDictionary *)dictionary
                inContext:(NSManagedObjectContext *)context
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
            
            if ([[ModelController sharedController].currentUser.userID intValue] == [userID intValue] &&
                [context isEqual:[ModelController sharedController].defaultContext])
            {
                author = [ModelController sharedController].currentUser;
            }
            else
            {
                author = [MRSLUser MR_createInContext:context];
                [author setWithDictionary:dictionary[@"creator"]
                                inContext:context];
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
                 MRSLMorsel *morsel = [MRSLMorsel MR_createInContext:context];
                 [morsel setWithDictionary:morselDictionary
                                 inContext:context];
                 
                 [mrsls addObject:morsel];
             }];
            
            NSArray *sortedMrsls = [mrsls sortedArrayUsingComparator:^NSComparisonResult(MRSLMorsel *morselA, MRSLMorsel *morselB)
            {
                return [morselA.sortOrder compare:morselB.sortOrder];
            }];
            
            self.morsels = [NSOrderedSet orderedSetWithArray:sortedMrsls];
        }
    }
}

- (void)addMorsel:(MRSLMorsel *)morsel
{
    [self.morselsSet addObject:morsel];
}

@end
