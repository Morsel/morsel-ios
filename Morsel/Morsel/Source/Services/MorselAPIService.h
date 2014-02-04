//
//  MorselAPIService.h
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSLComment, MRSLMorsel, MRSLPost, MRSLUser;

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

#pragma mark - User Services

- (void)updateUser:(MRSLUser *)user
           success:(MorselAPISuccessBlock)userSuccessOrNil
           failure:(MorselAPIFailureBlock)failureOrNil;

- (void)getUserProfile:(MRSLUser *)user
               success:(MorselAPISuccessBlock)userSuccessOrNil
               failure:(MorselAPIFailureBlock)failureOrNil;

- (void)createTwitterAuthorizationFromParamString:(NSString *)paramString
                                          forUser:(MRSLUser *)user
                                          success:(MorselAPISuccessBlock)userSuccessOrNil
                                          failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Post Services

- (void)updatePost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil;

- (void)getPost:(MRSLPost *)post
        success:(MorselAPISuccessBlock)successOrNil
        failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Morsel Services

- (void)createMorsel:(MRSLMorsel *)morsel
       postToTwitter:(BOOL)postToTwitter
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

- (void)createMorsel:(MRSLMorsel *)morsel
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

- (void)getMorsel:(MRSLMorsel *)morsel
          success:(MorselAPISuccessBlock)successOrNil
          failure:(MorselAPIFailureBlock)failureOrNil;

- (void)updateMorsel:(MRSLMorsel *)morsel
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MorselDataSuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

- (void)likeMorsel:(MRSLMorsel *)morsel
        shouldLike:(BOOL)shouldLike
           didLike:(MorselAPILikeBlock)didLike
           failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Feed Services

- (void)retrieveFeedWithSuccess:(MorselAPIArrayBlock)success
                        failure:(MorselAPIFailureBlock)failureOrNil;

- (void)retrieveUserPosts:(MRSLUser *)user
                  success:(MorselAPIArrayBlock)success
                  failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Comment Services

- (void)getComments:(MRSLMorsel *)morsel
            success:(MorselAPIArrayBlock)successOrNil
            failure:(MorselAPIFailureBlock)failureOrNil;

- (void)postComment:(MRSLComment *)comment
            success:(MorselAPIArrayBlock)successOrNil
            failure:(MorselAPIFailureBlock)failureOrNil;

@end
