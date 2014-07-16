//
//  NSMutableArray+Additions.m
//  Morsel
//
//  Created by Javier Otero on 3/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "NSMutableArray+Additions.h"

#import "MRSLMorsel.h"

@implementation NSMutableArray (Additions)

#pragma mark - Feed

+ (NSMutableArray *)feedIDArray {
    NSMutableArray *array = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"main_feedIDs"]] ?: [NSMutableArray array];
    return array;
}

+ (void)resetFeedIDArray {
    [[NSUserDefaults standardUserDefaults] setObject:[NSMutableArray array]
                                              forKey:[NSString stringWithFormat:@"main_feedIDs"]];
}

- (NSNumber *)firstObjectWithValidFeedItemID {
    NSNumber *foundID = nil;
    for (NSNumber *morselID in self) {
        MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:morselID];
        if (morsel.feedItemID || morsel.feedItemIDValue != 0) {
            foundID = morselID;
            break;
        }
    }
    return foundID;
}

- (void)saveFeedIDArray {
    NSArray *arrayToSave = [(NSMutableArray *)self subarrayWithRange:NSMakeRange(0, fmin(3, [(NSMutableArray *)self count]))];
    [[NSUserDefaults standardUserDefaults] setObject:arrayToSave
                                              forKey:[NSString stringWithFormat:@"main_feedIDs"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
