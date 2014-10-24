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

- (void)getLikedItemsForUser:(MRSLUser *)user
                       maxID:(NSNumber *)maxOrNil
                   orSinceID:(NSNumber *)sinceOrNil
                    andCount:(NSNumber *)countOrNil
                     success:(MRSLAPIArrayBlock)successOrNil
                     failure:(MRSLFailureBlock)failureOrNil;

- (void)getItemLikes:(MRSLItem *)item
       orMorselLikes:(MRSLMorsel *)morsel
             success:(MRSLAPIArrayBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil;

- (void)likeItem:(MRSLItem *)item
    orLikeMorsel:(MRSLMorsel *)morsel
      shouldLike:(BOOL)shouldLike
         didLike:(MRSLAPILikeBlock)likeBlockOrNil
         failure:(MRSLFailureBlock)failureOrNil;

@end
