//
//  MorselAPIService.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselAPIService.h"

#import "MorselAPIClient.h"
#import "JSONResponseSerializerWithData.h"

#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

/*

 Current Response Schema - 01.29.2014
 {
 "data": {} or [],
 "meta": {
 "total_results": 1245
 },
 "errors": {
 "username": [
 "is too long",
 "cannot contain special characters"
 ],
 "email": [
 "is invalid"
 ]
 }
 }
 */

@interface MorselAPIService ()

@end

@implementation MorselAPIService

#pragma mark - User Sign Up and Sign In Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
           success:(MorselAPISuccessBlock)userSuccessOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
                                 @"user" : @{
                                         @"username" : user.username,
                                         @"email" : user.email,
                                         @"password" : password,
                                         @"first_name" : user.first_name,
                                         @"last_name" : user.last_name,
                                         @"title" : user.title
                                         }
                                 };

    [[MorselAPIClient sharedClient] POST:@"users"
                              parameters:parameters
               constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         if (user.profilePhoto) {
             DDLogDebug(@"Profile Image included for User!");
             [formData appendPartWithFileData:user.profilePhoto
                                         name:@"user[photo]"
                                     fileName:@"photo.jpg"
                                     mimeType:@"image/jpeg"];
         }
     } success: ^(AFHTTPRequestOperation * operation, id responseObject) {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         [MRSLUser createOrUpdateUserFromResponseObject:responseObject[@"data"]
                                 shouldPostNotification:YES];

         if (userSuccessOrNil) userSuccessOrNil(responseObject[@"data"]);
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)signInUserWithEmail:(NSString *)emailAddress
                andPassword:(NSString *)password
                    success:(MorselAPISuccessBlock)successOrNil
                    failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
                                 @"user" : @{
                                         @"email" : emailAddress,
                                         @"password" : password
                                         }
                                 };

    [[MorselAPIClient sharedClient] POST:@"users/sign_in"
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         [MRSLUser createOrUpdateUserFromResponseObject:responseObject[@"data"]
                                 shouldPostNotification:YES];

         if (successOrNil) successOrNil(responseObject[@"data"]);
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

#pragma mark - User Services

- (void)updateUser:(MRSLUser *)user
           success:(MorselAPISuccessBlock)userSuccessOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
                                 @"user" : @{
                                         @"username" : user.username,
                                         @"email" : user.email,
                                         @"first_name" : user.first_name,
                                         @"last_name" : user.last_name,
                                         @"title" : user.title
                                         },
                                 @"api_key" : [MRSLUser apiTokenForCurrentUser]
                                 };

    [[MorselAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", user.userIDValue]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject[@"data"]);

         [MRSLUser createOrUpdateUserFromResponseObject:responseObject[@"data"]
                                 shouldPostNotification:NO];

         if (userSuccessOrNil) userSuccessOrNil(responseObject[@"data"]);
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)getUserProfile:(MRSLUser *)user
               success:(MorselAPISuccessBlock)userSuccessOrNil
               failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
                                 @"api_key" : [MRSLUser apiTokenForCurrentUser]
                                 };

    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i", user.userIDValue]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         [user MR_importValuesForKeysWithObject:responseObject[@"data"]];

         if (userSuccessOrNil) userSuccessOrNil(responseObject);
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)createFacebookAuthorizationWithToken:(NSString *)token
                                     forUser:(MRSLUser *)user
                                     success:(MorselAPISuccessBlock)userSuccessOrNil
                                     failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
                                 @"provider" : @"facebook",
                                 @"token" : token,
                                 @"api_key" : [MRSLUser apiTokenForCurrentUser]
                                 };

    [[MorselAPIClient sharedClient] POST:[NSString stringWithFormat:@"users/%i/authorizations", user.userIDValue]
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         if (userSuccessOrNil) userSuccessOrNil(responseObject);
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)createTwitterAuthorizationWithToken:(NSString *)token
                                     secret:(NSString *)secret
                                    forUser:(MRSLUser *)user
                                    success:(MorselAPISuccessBlock)userSuccessOrNil
                                    failure:(MorselAPIFailureBlock)failureOrNil {
    if (token && secret) {
        NSDictionary *parameters = @{
                                     @"provider" : @"twitter",
                                     @"token" : token,
                                     @"secret" : secret,
                                     @"api_key" : [MRSLUser apiTokenForCurrentUser]
                                     };

        [[MorselAPIClient sharedClient] POST:[NSString stringWithFormat:@"users/%i/authorizations", user.userIDValue]
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

             if (userSuccessOrNil) userSuccessOrNil(responseObject);
         } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
             [self reportFailure:failureOrNil
                       withError:error
                        inMethod:NSStringFromSelector(_cmd)];
         }];
    } else {
        [self reportFailure:failureOrNil
                  withError:[NSError errorWithDomain:@"com.eatmorsel.missingparameters"
                                                code:0
                                            userInfo:@{ NSLocalizedFailureReasonErrorKey : @"Unable to Authenticate with Twitter" }]
                   inMethod:NSStringFromSelector(_cmd)];
    }
}

#pragma mark - Post Services

- (void)updatePost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
                                 @"post" : @{
                                         @"title" : post.title
                                         },
                                 @"api_key" : [MRSLUser apiTokenForCurrentUser]
                                 };

    [[MorselAPIClient sharedClient] PUT:[NSString stringWithFormat:@"posts/%i", [post.postID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         [post MR_importValuesForKeysWithObject:responseObject[@"data"]];

         if (successOrNil) successOrNil(responseObject);
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)getPost:(MRSLPost *)post
        success:(MorselAPISuccessBlock)successOrNil
        failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
                                 @"api_key" : [MRSLUser apiTokenForCurrentUser]
                                 };

    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"posts/%i", [post.postID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                    [post MR_importValuesForKeysWithObject:responseObject[@"data"]];

                                    if (successOrNil) successOrNil(responseObject);
                                } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                    [self reportFailure:failureOrNil
                                              withError:error
                                               inMethod:NSStringFromSelector(_cmd)];
                                }];
}

#pragma mark - Morsel Services

- (void)createMorsel:(MRSLMorsel *)morsel
      postToFacebook:(BOOL)postToFacebook
       postToTwitter:(BOOL)postToTwitter
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:[MRSLUser apiTokenForCurrentUser], @"api_key", nil];

    NSMutableDictionary *morselDictionary = [NSMutableDictionary dictionary];

    if (morsel.morselDescription) {
        [morselDictionary setObject:morsel.morselDescription
                             forKey:@"description"];
    }

    [morselDictionary setObject:(morsel.draftValue) ? @"true" : @"false"
                         forKey:@"draft"];

    if ([morselDictionary count] > 0) {
        [parameters setObject:morselDictionary
                       forKey:@"morsel"];
    }

    if (morsel.post && morsel.post.postID) {
        [parameters setObject:morsel.post.postID
                       forKey:@"post_id"];
        if (morsel.post.title) {
            [parameters setObject:morsel.post.title
                           forKey:@"post_title"];
        }
    }

    if (postToFacebook)
        [parameters setObject:@"true" forKey:@"post_to_facebook"];

    if (postToTwitter)
        [parameters setObject:@"true" forKey:@"post_to_twitter"];

    [[MorselAPIClient sharedClient] POST:@"morsels"
                              parameters:parameters
               constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         if (morsel.morselPhoto) {
             [formData appendPartWithFileData:morsel.morselPhoto
                                         name:@"morsel[photo]"
                                     fileName:@"photo.jpg"
                                     mimeType:@"image/jpeg"];
         }
     } success: ^(AFHTTPRequestOperation * operation, id responseObject) {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];

         [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidCreateMorselNotification
                                                             object:nil];

         if (successOrNil) successOrNil(responseObject);
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)createMorsel:(MRSLMorsel *)morsel
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    [self createMorsel:morsel
        postToFacebook:NO
         postToTwitter:NO
               success:successOrNil
               failure:failureOrNil];
}

- (void)getMorsel:(MRSLMorsel *)morsel success:(MorselAPISuccessBlock)successOrNil failure:(MorselAPIFailureBlock)failureOrNil {
    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                             parameters:@{@"api_key": [MRSLUser apiTokenForCurrentUser]}
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];

         if (successOrNil) successOrNil(responseObject);
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)updateMorsel:(MRSLMorsel *)morsel
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
                                 @"morsel" : @{
                                         @"description" : morsel.morselDescription,
                                         @"post_id" : morsel.post.postID,
                                         @"draft" : (morsel.draftValue) ? @"true" : @"false"
                                         },
                                 @"api_key" : [MRSLUser apiTokenForCurrentUser]
                                 };

    [[MorselAPIClient sharedClient] PUT:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];

         [self updatePost:morsel.post
                  success:nil
                  failure:nil];

         [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdateMorselNotification
                                                             object:nil];

         if (successOrNil) successOrNil(responseObject);
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MorselDataSuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    [[MorselAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                                parameters:@{@"api_key": [MRSLUser apiTokenForCurrentUser]}
                                   success:nil
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([operation.response statusCode] == 200) {
                                           int morselID = [morsel.morselID intValue];

                                           DDLogDebug(@"Morsel %i deleted from server. Attempting local.", morselID);

                                           MRSLPost *morselPost = morsel.post;

                                           [morsel MR_deleteEntity];

                                           // Last Morsel, delete the entity
                                           if ([morselPost.morsels count] == 0) [morselPost MR_deleteEntity];

                                           [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidDeleteMorselNotification
                                                                                               object:[NSNumber numberWithInt:morselID]];

                                           if (successOrNil) successOrNil(YES);
                                       } else {
                                           [self reportFailure:failureOrNil
                                                     withError:error
                                                      inMethod:NSStringFromSelector(_cmd)];
                                       }
                                   }];
}

- (void)likeMorsel:(MRSLMorsel *)morsel
        shouldLike:(BOOL)shouldLike
           didLike:(MorselAPILikeBlock)didLike
           failure:(MorselAPIFailureBlock)failureOrNil {
    if (shouldLike) {
        [[MorselAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/like", [morsel.morselID intValue]]
                                  parameters:@{@"api_key": [MRSLUser apiTokenForCurrentUser]}
                                     success:nil
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if ([operation.response statusCode] == 200) {
                                             didLike(YES);
                                         } else {
                                             [self reportFailure:failureOrNil
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }
                                     }];
    } else {
        [[MorselAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i/like", [morsel.morselID intValue]]
                                    parameters:@{@"api_key": [MRSLUser apiTokenForCurrentUser]}
                                       success:nil
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if ([operation.response statusCode] == 200) {
                 didLike(NO);
             } else {
                 [self reportFailure:failureOrNil
                           withError:error
                            inMethod:NSStringFromSelector(_cmd)];
             }
         }];
    }
}

#pragma mark - Feed Services

- (void)getFeedWithSuccess:(MorselAPIArrayBlock)success
                   failure:(MorselAPIFailureBlock)failureOrNil {

    [[MorselAPIClient sharedClient] GET:@"posts"
                             parameters:@{@"include_drafts": @"true",
                                          @"api_key": [MRSLUser apiTokenForCurrentUser]}
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                    if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {

                                        NSArray *feedArray = responseObject[@"data"];

                                        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                            [feedArray enumerateObjectsUsingBlock:^(NSDictionary *postDictionary, NSUInteger idx, BOOL *stop) {

                                                MRSLPost *post = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                                                         withValue:postDictionary[@"id"]
                                                                                         inContext:localContext];
                                                if (!post) post = [MRSLPost MR_createInContext:localContext];
                                                [post MR_importValuesForKeysWithObject:postDictionary];

                                            }];
                                        }];

                                        success(feedArray);
                                    }
                                } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                    [self reportFailure:failureOrNil
                                              withError:error
                                               inMethod:NSStringFromSelector(_cmd)];
                                }];
}

- (void)getUserPosts:(MRSLUser *)user
             success:(MorselAPIArrayBlock)success
             failure:(MorselAPIFailureBlock)failureOrNil {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:[MRSLUser apiTokenForCurrentUser], @"api_key", user.userID, @"user_id", nil];

    if (user.isCurrentUser) {
        [parameters setObject:@"true"
                       forKey:@"include_drafts"];
    }

    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/posts", user.userIDValue]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                    if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {

                                        NSArray *userPostsArray = responseObject[@"data"];

                                        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                            [userPostsArray enumerateObjectsUsingBlock:^(NSDictionary *postDictionary, NSUInteger idx, BOOL *stop) {
                                                MRSLPost *post = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                                                         withValue:postDictionary[@"id"]
                                                                                         inContext:localContext];
                                                if (!post) post = [MRSLPost MR_createInContext:localContext];
                                                [post MR_importValuesForKeysWithObject:postDictionary];
                                            }];
                                        }];

                                        success(userPostsArray);
                                    }
                                } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                    [self reportFailure:failureOrNil
                                              withError:error
                                               inMethod:NSStringFromSelector(_cmd)];
                                }];
}

#pragma mark - Comment Services

- (void)getComments:(MRSLMorsel *)morsel
            success:(MorselAPIArrayBlock)successOrNil
            failure:(MorselAPIFailureBlock)failureOrNil {
    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"morsels/%i/comments", morsel.morselIDValue]
                             parameters:@{@"api_key": [MRSLUser apiTokenForCurrentUser]}
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                    if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                        NSArray *commentsArray = responseObject[@"data"];
                                        DDLogDebug(@"%lu comments available for Morsel!", (unsigned long)[commentsArray count]);

                                        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                            [commentsArray enumerateObjectsUsingBlock:^(NSDictionary *commentDictionary, NSUInteger idx, BOOL *stop) {
                                                MRSLComment *comment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                                                                  withValue:commentDictionary[@"id"]
                                                                                                  inContext:localContext];
                                                if (!comment) comment = [MRSLComment MR_createInContext:localContext];
                                                [comment MR_importValuesForKeysWithObject:commentDictionary];
                                            }];
                                        }];
                                        successOrNil(commentsArray);
                                    }
                                } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                    [self reportFailure:failureOrNil
                                              withError:error
                                               inMethod:NSStringFromSelector(_cmd)];
                                }];
}

- (void)postCommentWithDescription:(NSString *)description
                          toMorsel:(MRSLMorsel *)morsel
              success:(MorselAPISuccessBlock)successOrNil
              failure:(MorselAPIFailureBlock)failureOrNil {
    [[MorselAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/comments", morsel.morselIDValue]
                              parameters:@{@"comment": @{@"description": description},
                                           @"api_key": [MRSLUser apiTokenForCurrentUser]}
                                 success: ^(AFHTTPRequestOperation * operation, id responseObject) {
                                     DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                     [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                         MRSLComment *comment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                                                           withValue:responseObject[@"data"][@"id"]
                                                                                           inContext:localContext];
                                         if (!comment) comment = [MRSLComment MR_createInContext:localContext];
                                         [comment MR_importValuesForKeysWithObject:responseObject[@"data"]];

                                         [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidCreateCommentNotification
                                                                                             object:nil];
                                     }];
                                     
                                     if (successOrNil) successOrNil(responseObject);
                                 } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                     [self reportFailure:failureOrNil
                                               withError:error
                                                inMethod:NSStringFromSelector(_cmd)];
                                 }];
}

#pragma mark - General Methods

- (void)reportFailure:(MorselAPIFailureBlock)failureOrNil
            withError:(NSError *)error
             inMethod:(NSString *)methodName {
    NSDictionary *userInfoDictionary = error.userInfo[JSONResponseSerializerWithDataKey];
    
    if (!userInfoDictionary) {
        DDLogError(@"%@ Request Error: %@", methodName, error.userInfo);
    } else {
        DDLogError(@"%@ Request Error: %@", methodName, userInfoDictionary[@"errors"]);
    }
    
    if (failureOrNil)
        failureOrNil(error);
}

@end
