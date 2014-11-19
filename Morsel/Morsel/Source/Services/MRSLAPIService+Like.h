//
//  MRSLAPIService+Like.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Like)

#pragma mark - Like Services

- (void)getLikedMorselsForUser:(MRSLUser *)user
                         maxID:(NSNumber *)maxOrNil
                     orSinceID:(NSNumber *)sinceOrNil
                      andCount:(NSNumber *)countOrNil
                       success:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLFailureBlock)failureOrNil;

- (void)getMorselLikers:(MRSLMorsel *)morsel
                  maxID:(NSNumber *)maxOrNil
              orSinceID:(NSNumber *)sinceOrNil
               andCount:(NSNumber *)countOrNil
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil;

- (void)likeMorsel:(MRSLMorsel *)morsel
        shouldLike:(BOOL)shouldLike
           didLike:(MRSLAPILikeBlock)likeBlockOrNil
           failure:(MRSLFailureBlock)failureOrNil;

@end
