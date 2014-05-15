//
//  MRSLAPIService+Follow.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Follow)

#pragma mark - Follow Services

- (void)followUser:(MRSLUser *)user
      shouldFollow:(BOOL)shouldFollow
         didFollow:(MRSLAPIFollowBlock)followBlockOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getUserFollowers:(MRSLUser *)user
               withMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getUserFollowables:(MRSLUser *)user
                 withMaxID:(NSNumber *)maxOrNil
                 orSinceID:(NSNumber *)sinceOrNil
                  andCount:(NSNumber *)countOrNil
                   success:(MRSLAPIArrayBlock)successOrNil
                   failure:(MRSLAPIFailureBlock)failureOrNil;

@end
