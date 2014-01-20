//
//  MorselAPIService.h
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSLMorsel, MRSLPost, MRSLUser;

@interface MorselAPIService : NSObject

#pragma mark - User Sign Up and Sign In Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil;

- (void)signInUserWithEmail:(NSString *)emailAddress
                andPassword:(NSString *)password
                    success:(MorselAPISuccessBlock)successOrNil
                    failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Morsel Services

- (void)createPost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil;

- (void)likeMorsel:(MRSLMorsel *)morsel
        shouldLike:(BOOL)shouldLike
           didLike:(MorselAPILikeBlock)didLike
           failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Feed Services

- (void)retrieveFeedWithSuccess:(MorselAPIArrayBlock)success
                        failure:(MorselAPIFailureBlock)failureOrNil;

@end
