//
//  MRSLAPIService+Morsel.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Morsel)

#pragma mark - Morsel Services

- (void)createMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil;

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil;

- (void)updateMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil;

- (void)publishMorsel:(MRSLMorsel *)morsel
              success:(MRSLAPISuccessBlock)successOrNil
              failure:(MRSLFailureBlock)failureOrNil
       sendToFacebook:(BOOL)sendToFacebook
        sendToTwitter:(BOOL)sendToTwitter;

- (void)getMorsel:(MRSLMorsel *)morsel
          success:(MRSLAPISuccessBlock)successOrNil
          failure:(MRSLFailureBlock)failureOrNil;

- (void)getUserMorsels:(MRSLUser *)user
             withMaxID:(NSNumber *)maxOrNil
             orSinceID:(NSNumber *)sinceOrNil
              andCount:(NSNumber *)countOrNil
         includeDrafts:(BOOL)includeDrafts
               success:(MRSLAPIArrayBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil __deprecated;

- (void)getUserDraftsWithMaxID:(NSNumber *)maxOrNil
                     orSinceID:(NSNumber *)sinceOrNil
                      andCount:(NSNumber *)countOrNil
                       success:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLFailureBlock)failureOrNil;

@end
