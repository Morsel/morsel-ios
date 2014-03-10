//
//  MorselAPIService.h
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSLComment, MRSLMorsel, MRSLPost, MRSLUser;

@interface MRSLAPIService : NSObject

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

- (void)createFacebookAuthorizationWithToken:(NSString *)token
                                     forUser:(MRSLUser *)user
                                     success:(MorselAPISuccessBlock)userSuccessOrNil
                                     failure:(MorselAPIFailureBlock)failureOrNil;

- (void)createTwitterAuthorizationWithToken:(NSString *)token
                                     secret:(NSString *)secret
                                    forUser:(MRSLUser *)user
                                    success:(MorselAPISuccessBlock)userSuccessOrNil
                                    failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Post Services

- (void)createPost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil;

- (void)deletePost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil;

- (void)updatePost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil;

- (void)getPost:(MRSLPost *)post
        success:(MorselAPISuccessBlock)successOrNil
        failure:(MorselAPIFailureBlock)failureOrNil;

- (void)appendMorsel:(MRSLMorsel *)morsel
              toPost:(MRSLPost *)post
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

- (void)detachMorsel:(MRSLMorsel *)morsel
            fromPost:(MRSLPost *)post
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Morsel Services

- (void)createMorsel:(MRSLMorsel *)morsel
      postToFacebook:(BOOL)postToFacebook
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
             andPost:(MRSLPost *)postOrNil
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil ;

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MorselDataSuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

- (void)likeMorsel:(MRSLMorsel *)morsel
        shouldLike:(BOOL)shouldLike
           didLike:(MorselAPILikeBlock)didLike
           failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Feed Services

- (void)getFeedWithSuccess:(MorselAPIArrayBlock)success
                   failure:(MorselAPIFailureBlock)failureOrNil;

- (void)getUserPosts:(MRSLUser *)user
       includeDrafts:(BOOL)includeDrafts
             success:(MorselAPIArrayBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

- (void)getUserDraftsWithSuccess:(MorselAPIArrayBlock)success
                         failure:(MorselAPIFailureBlock)failureOrNil;

#pragma mark - Comment Services

- (void)getComments:(MRSLMorsel *)morsel
            success:(MorselAPIArrayBlock)successOrNil
            failure:(MorselAPIFailureBlock)failureOrNil;

- (void)postCommentWithDescription:(NSString *)description
                          toMorsel:(MRSLMorsel *)morsel
                           success:(MorselAPISuccessBlock)successOrNil
                           failure:(MorselAPIFailureBlock)failureOrNil;

@end
