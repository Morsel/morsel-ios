//
//  MorselAPIService.h
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSLComment, MRSLItem, MRSLMorsel, MRSLUser;

@interface MRSLAPIService : NSObject

#pragma mark - User Sign Up and Sign In Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)signInUserWithEmail:(NSString *)emailAddress
                andPassword:(NSString *)password
                    success:(MRSLAPISuccessBlock)successOrNil
                    failure:(MRSLAPIFailureBlock)failureOrNil;

#pragma mark - User Services

- (void)getUserProfile:(MRSLUser *)user
               success:(MRSLAPISuccessBlock)userSuccessOrNil
               failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)createFacebookAuthorizationWithToken:(NSString *)token
                                     forUser:(MRSLUser *)user
                                     success:(MRSLAPISuccessBlock)userSuccessOrNil
                                     failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)createTwitterAuthorizationWithToken:(NSString *)token
                                     secret:(NSString *)secret
                                    forUser:(MRSLUser *)user
                                    success:(MRSLAPISuccessBlock)userSuccessOrNil
                                    failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getUserActivitiesForUser:(MRSLUser *)user
                           maxID:(NSNumber *)maxOrNil
                       orSinceID:(NSNumber *)sinceOrNil
                        andCount:(NSNumber *)countOrNil
                         success:(MRSLAPIArrayBlock)successOrNil
                         failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getUserNotificationsForUser:(MRSLUser *)user
                              maxID:(NSNumber *)maxOrNil
                          orSinceID:(NSNumber *)sinceOrNil
                           andCount:(NSNumber *)countOrNil
                            success:(MRSLAPIArrayBlock)successOrNil
                            failure:(MRSLAPIFailureBlock)failureOrNil;


#pragma mark - Morsel Services

- (void)createMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)updateMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)publishMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil
      sendToFacebook:(BOOL)sendToFacebook
        sendToTwitter:(BOOL)sendToTwitter;

- (void)getMorsel:(MRSLMorsel *)morsel
          success:(MRSLAPISuccessBlock)successOrNil
          failure:(MRSLAPIFailureBlock)failureOrNil;

#pragma mark - Morsel Services

- (void)createItem:(MRSLItem *)item
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getItem:(MRSLItem *)item
        success:(MRSLAPISuccessBlock)successOrNil
        failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getItemLikes:(MRSLItem *)item
             success:(MRSLAPIArrayBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)updateItem:(MRSLItem *)item
         andMorsel:(MRSLMorsel *)morselOrNil
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)updateItemImage:(MRSLItem *)item
                success:(MRSLAPISuccessBlock)successOrNil
                failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)deleteItem:(MRSLItem *)item
           success:(MRSLDataSuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)likeItem:(MRSLItem *)item
      shouldLike:(BOOL)shouldLike
         didLike:(MRSLAPILikeBlock)didLikeOrNil
         failure:(MRSLAPIFailureBlock)failureOrNil;

#pragma mark - Feed Services

- (void)getFeedWithMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getUserMorsels:(MRSLUser *)user
         includeDrafts:(BOOL)includeDrafts
               success:(MRSLAPIArrayBlock)successOrNil
               failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getUserDraftsWithSuccess:(MRSLAPIArrayBlock)success
                         failure:(MRSLAPIFailureBlock)failureOrNil;

#pragma mark - Comment Services

- (void)getComments:(MRSLItem *)item
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)addCommentWithDescription:(NSString *)description
                         toMorsel:(MRSLItem *)item
                          success:(MRSLAPISuccessBlock)successOrNil
                          failure:(MRSLAPIFailureBlock)failureOrNil;

@end
