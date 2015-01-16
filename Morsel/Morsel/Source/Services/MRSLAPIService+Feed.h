//
//  MRSLAPIService+Feed.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Feed)

#pragma mark - Feed Services

- (void)getFeedWithMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                   count:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

@end
