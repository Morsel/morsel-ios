//
//  MorselAPIService.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselAPIService.h"

#import "NSManagedObject+JSON.h"

#import "MorselAPIClient.h"
#import "JSONResponseSerializerWithData.h"

#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MorselAPIService ()

@end

@implementation MorselAPIService

#pragma mark - Parameters

- (NSMutableDictionary *)parametersWithDictionary:(NSDictionary *)dictionaryOrNil
                             includingMRSLObjects:(NSArray *)objects
                           requiresAuthentication:(BOOL)requiresAuthentication {
    __block NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionary];

    // append initial dictionary
    if (dictionaryOrNil) [parametersDictionary addEntriesFromDictionary:dictionaryOrNil];

    // loop through objects and convert into JSON
    for (NSManagedObject *managedObject in objects) {
        if ([managedObject respondsToSelector:@selector(objectToJSON)]) {
            NSDictionary *objectDictionary = [managedObject objectToJSON];
            [parametersDictionary addEntriesFromDictionary:objectDictionary];
        }
    }

    // apply authentication
    if (requiresAuthentication) [parametersDictionary setObject:[MRSLUser apiTokenForCurrentUser]
                                                         forKey:@"api_key"];

    // apply device information
    [parametersDictionary setObject:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"ipad" : @"iphone"
                             forKey:@"device"];

    return parametersDictionary;
}

#pragma mark - User Sign Up and Sign In Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
           success:(MorselAPISuccessBlock)userSuccessOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user[password]": password}
                                                includingMRSLObjects:@[user]
                                              requiresAuthentication:NO];

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
    NSDictionary *userParameters = @{
                                 @"user" : @{
                                         @"email" : emailAddress,
                                         @"password" : password
                                         }
                                 };

    NSMutableDictionary *parameters = [self parametersWithDictionary:userParameters
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

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
    NSDictionary *facebookParameters = @{
                                         @"provider" : @"facebook",
                                         @"token" : token
                                         };

    NSMutableDictionary *parameters = [self parametersWithDictionary:facebookParameters
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

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
        NSDictionary *twitterParameters = @{
                                            @"provider" : @"twitter",
                                            @"token" : token,
                                            @"secret" : secret
                                            };
        NSMutableDictionary *parameters = [self parametersWithDictionary:twitterParameters
                                                    includingMRSLObjects:nil
                                                  requiresAuthentication:YES];

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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[post]
                                              requiresAuthentication:YES];
    
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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    if (postToFacebook)
        [parameters setObject:@"true" forKey:@"post_to_facebook"];

    if (postToTwitter)
        [parameters setObject:@"true" forKey:@"post_to_twitter"];

    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidCreateMorselNotification
                                                        object:nil];

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

- (void)getMorsel:(MRSLMorsel *)morsel
          success:(MorselAPISuccessBlock)successOrNil
          failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                             parameters:parameters
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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdateMorselNotification
                                                        object:morsel];

    [[MorselAPIClient sharedClient] PUT:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                             parameters:parameters
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

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MorselDataSuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MorselAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                                parameters:parameters
                                   success:nil
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([operation.response statusCode] == 200) {
                                           int morselID = [morsel.morselID intValue];

                                           DDLogDebug(@"Morsel %i deleted from server. Attempting local.", morselID);

                                           if (morsel.draftValue) {
                                               [[MRSLUser currentUser] decrementDraftCountAndSave];
                                           }

                                           MRSLPost *morselPost = morsel.post;

                                           [morsel MR_deleteEntity];

                                           // Last Morsel, delete the entity
                                           if ([morselPost.morsels count] == 0) [morselPost MR_deleteEntity];

                                           [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidDeleteMorselNotification
                                                                                               object:@(morselID)];

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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (shouldLike) {
        [[MorselAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/like", [morsel.morselID intValue]]
                                  parameters:parameters
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
                                    parameters:parameters
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
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"include_drafts": @"true"}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MorselAPIClient sharedClient] GET:@"posts"
                             parameters:parameters
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

    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[user]
                                              requiresAuthentication:YES];

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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"morsels/%i/comments", morsel.morselIDValue]
                             parameters:parameters
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
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"comment": @{@"description": description}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MorselAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/comments", morsel.morselIDValue]
                              parameters:parameters
                                 success: ^(AFHTTPRequestOperation * operation, id responseObject) {
                                     DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                     [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                         MRSLComment *comment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                                                           withValue:responseObject[@"data"][@"id"]
                                                                                           inContext:localContext];
                                         if (!comment) comment = [MRSLComment MR_createInContext:localContext];
                                         [comment MR_importValuesForKeysWithObject:responseObject[@"data"]];

                                         [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidCreateCommentNotification
                                                                                             object:morsel];
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
    MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
    
    if (!serviceErrorInfo) {
        DDLogError(@"Request error in method (%@) with userInfo: %@", methodName, error.userInfo);
    } else {
        DDLogError(@"Request error in method (%@) with serviceInfo: %@", methodName, [serviceErrorInfo errorInfo]);
    }
    
    if (failureOrNil)
        failureOrNil(error);
}

@end
