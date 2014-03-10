//
//  MorselAPIService.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

#import "NSManagedObject+JSON.h"

#import "MRSLAPIClient.h"
#import "JSONResponseSerializerWithData.h"

#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLAPIService ()

@end

@implementation MRSLAPIService

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
                             forKey:@"client[device]"];

    [parametersDictionary setObject:[MRSLUtil appMajorMinorPatchString]
                             forKey:@"client[version]"];

    return parametersDictionary;
}

#pragma mark - User Sign Up and Sign In Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
           success:(MorselAPISuccessBlock)userSuccessOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user[password]": NSNullIfNil(password),
                                                                       @"user[industry]": @"chef"}
                                                includingMRSLObjects:@[user]
                                              requiresAuthentication:NO];

    [[MRSLAPIClient sharedClient] POST:@"users"
                              parameters:parameters
               constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         if (user.profilePhotoFull) {
             DDLogDebug(@"Profile image included for user");
             [formData appendPartWithFileData:user.profilePhotoFull
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
                                             @"email" : NSNullIfNil(emailAddress),
                                             @"password" : NSNullIfNil(password)
                                             }
                                     };

    NSMutableDictionary *parameters = [self parametersWithDictionary:userParameters
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    [[MRSLAPIClient sharedClient] POST:@"users/sign_in"
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

    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", user.userIDValue]
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

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i", user.userIDValue]
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
                                         @"token" : NSNullIfNil(token)
                                         };

    NSMutableDictionary *parameters = [self parametersWithDictionary:facebookParameters
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] POST:@"users/authorizations"
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
                                            @"token" : NSNullIfNil(token),
                                            @"secret" : NSNullIfNil(secret)
                                            };
        NSMutableDictionary *parameters = [self parametersWithDictionary:twitterParameters
                                                    includingMRSLObjects:nil
                                                  requiresAuthentication:YES];

        [[MRSLAPIClient sharedClient] POST:@"users/authorizations"
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

- (void)createPost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[post]
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] POST:@"posts"
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

- (void)deletePost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[post]
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"posts/%i", [post.postID intValue]]
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                   if (post) {
                                       [post MR_deleteEntity];
                                       [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                   }
                                   if (successOrNil) successOrNil(responseObject);
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                   [self reportFailure:failureOrNil
                                             withError:error
                                              inMethod:NSStringFromSelector(_cmd)];
                               }];
}

- (void)updatePost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[post]
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"posts/%i", [post.postID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         [post MR_importValuesForKeysWithObject:responseObject[@"data"]];

         [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdatePostNotification
                                                             object:post];

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

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"posts/%i", post.postIDValue]
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

- (void)appendMorsel:(MRSLMorsel *)morsel
              toPost:(MRSLPost *)post
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"morsel_id": NSNullIfNil(morsel.morselID)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"posts/%i/append", post.postIDValue]
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     [post addMorselsObject:morsel];
                                     morsel.post = post;
                                     if (successOrNil) successOrNil(responseObject);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [self reportFailure:failureOrNil
                                               withError:error
                                                inMethod:NSStringFromSelector(_cmd)];
                                 }];
}

- (void)detachMorsel:(MRSLMorsel *)morsel
            fromPost:(MRSLPost *)post
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"morsel_id": NSNullIfNil(morsel.morselID)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"posts/%i/append", post.postIDValue]
                                parameters:parameters
                                   success:nil
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([operation.response statusCode] == 200) {
                                           [post removeMorselsObject:morsel];
                                       } else {
                                           [self reportFailure:failureOrNil
                                                     withError:error
                                                      inMethod:NSStringFromSelector(_cmd)];
                                       }
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

    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidBeginCreateMorselNotification
                                                        object:nil];

    [[MRSLAPIClient sharedClient] POST:@"morsels"
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
         if (morsel && morsel.managedObjectContext) {
             morsel.isUploading = @NO;
             morsel.didFailUpload = @NO;

             [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];

             [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

             [[NSNotificationCenter defaultCenter] postNotificationName:MRSLMorselUploadDidCompleteNotification
                                                                 object:morsel];

             [[MRSLEventManager sharedManager] track:@"Published Morsel"
                                          properties:@{@"view": @"MRSLAPIService",
                                                       @"morsel_id": NSNullIfNil(morsel.morselID),
                                                       @"morsel_draft": (morsel.post.draftValue) ? @"true" : @"false"}];
             
             if (successOrNil) successOrNil(responseObject);
         }
     } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
         if (morsel && morsel.managedObjectContext) {
             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
             if (serviceErrorInfo) {
                 if ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"already exists"].location != NSNotFound) {
                     [morsel MR_deleteEntity];
                     [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                     return;
                 }
             }
             if (morsel.managedObjectContext) {
                 [[MRSLEventManager sharedManager] track:@"Failed to Publish Morsel"
                                              properties:@{@"view": @"MRSLAPIService",
                                                           @"morsel_draft": (morsel.post.draftValue) ? @"true" : @"false"}];

                 morsel.isUploading = @NO;
                 morsel.didFailUpload = @YES;

                 [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

                 [[NSNotificationCenter defaultCenter] postNotificationName:MRSLMorselUploadDidFailNotification
                                                                     object:morsel];
                 [self reportFailure:failureOrNil
                           withError:error
                            inMethod:NSStringFromSelector(_cmd)];
             }
         }
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

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
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
             andPost:(MRSLPost *)postOrNil
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    if (postOrNil) {
        [parameters addEntriesFromDictionary:@{@"new_post_id": NSNullIfNil(postOrNil.postID),
                                               @"post_id": NSNullIfNil(morsel.post.postID)}];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdateMorselNotification
                                                        object:morsel];

    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         if (postOrNil) {
             [morsel.post removeMorselsObject:morsel];
             [postOrNil addMorselsObject:morsel];
             morsel.post = postOrNil;
         }
         [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];

         [[MRSLEventManager sharedManager] track:@"Updated Morsel"
                               properties:@{@"view": @"MRSLAPIService",
                                            @"morsel_id": NSNullIfNil(morsel.morselID),
                                            @"morsel_draft": (morsel.post.draftValue) ? @"true" : @"false"}];

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

    int morselID = morsel.morselIDValue;

    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                                parameters:parameters
                                   success:nil
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([operation.response statusCode] == 200) {
                                           if (morsel) {
                                               MRSLPost *post = morsel.post;
                                               DDLogDebug(@"Morsel %i deleted from server. Attempting local.", morselID);

                                               if (post.draftValue) {
                                                   [[MRSLUser currentUser] decrementDraftCountAndSave];
                                               }

                                               [morsel MR_deleteEntity];
                                               [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

                                               if ([post.morsels count] == 0) {
                                                   [post MR_deleteEntity];
                                                   [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                               }
                                           }
                                           
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
        [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/like", [morsel.morselID intValue]]
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         didLike(YES);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                         if ([operation.response statusCode] == 200 || [serviceErrorInfo.errorInfo isEqualToString:@"Morsel: already liked"]) {
                                             didLike(YES);
                                         } else {
                                             [self reportFailure:failureOrNil
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }
                                     }];
    } else {
        [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i/like", [morsel.morselID intValue]]
                                    parameters:parameters
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           didLike(NO);
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
             if ([operation.response statusCode] == 200  || [serviceErrorInfo.errorInfo isEqualToString:@"Morsel: not liked"]) {
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

- (void)getFeedWithSuccess:(MorselAPIArrayBlock)successOrNil
                   failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceWillPurgeDataNotification
                                                        object:nil];

    [[MRSLAPIClient sharedClient] GET:@"posts"
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                    if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                        NSPredicate *feedMorselsPredicate = [NSPredicate predicateWithFormat:@"(post.draft == NO) AND (isUploading == NO) AND (didFailUpload == NO)"];
                                        [MRSLMorsel MR_deleteAllMatchingPredicate:feedMorselsPredicate];
                                        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

                                        NSArray *feedArray = responseObject[@"data"];

                                        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                            [feedArray enumerateObjectsUsingBlock:^(NSDictionary *postDictionary, NSUInteger idx, BOOL *stop) {

                                                MRSLPost *post = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                                                         withValue:postDictionary[@"id"]
                                                                                         inContext:localContext];
                                                if (!post) post = [MRSLPost MR_createInContext:localContext];
                                                [post MR_importValuesForKeysWithObject:postDictionary];
                                            }];
                                        } completion:^(BOOL success, NSError *error) {
                                            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceWillRestoreDataNotification
                                                                                                object:nil];
                                        }];

                                        if (successOrNil) successOrNil(feedArray);
                                    }
                                } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                    [self reportFailure:failureOrNil
                                              withError:error
                                               inMethod:NSStringFromSelector(_cmd)];
                                }];
}

- (void)getUserPosts:(MRSLUser *)user
       includeDrafts:(BOOL)includeDrafts
             success:(MorselAPIArrayBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceWillPurgeDataNotification
                                                        object:nil];

    if (includeDrafts) parameters[@"include_drafts"] = @"true";

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/posts", user.userIDValue]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                    if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                        NSPredicate *currentUserMorselsPredicate = [NSPredicate predicateWithFormat:@"(post.creator.userID == %i) AND (post.draft == NO) AND (isUploading == NO) AND (didFailUpload == NO)", [[MRSLUser currentUser].userID intValue]];
                                        [MRSLMorsel MR_deleteAllMatchingPredicate:currentUserMorselsPredicate];
                                        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

                                        NSArray *userPostsArray = responseObject[@"data"];

                                        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                            [userPostsArray enumerateObjectsUsingBlock:^(NSDictionary *postDictionary, NSUInteger idx, BOOL *stop) {
                                                MRSLPost *post = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                                                         withValue:postDictionary[@"id"]
                                                                                         inContext:localContext];
                                                if (!post) post = [MRSLPost MR_createInContext:localContext];
                                                [post MR_importValuesForKeysWithObject:postDictionary];
                                            }];
                                        } completion:^(BOOL success, NSError *error) {
                                            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceWillRestoreDataNotification
                                                                                                object:nil];
                                        }];

                                        if (successOrNil) successOrNil(userPostsArray);
                                    }
                                } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                    [self reportFailure:failureOrNil
                                              withError:error
                                               inMethod:NSStringFromSelector(_cmd)];
                                }];
}

- (void)getUserDraftsWithSuccess:(MorselAPIArrayBlock)successOrNil
                         failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceWillPurgeDataNotification
                                                        object:nil];
    
    [[MRSLAPIClient sharedClient] GET:@"posts/drafts"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      NSPredicate *currentUserMorselsPredicate = [NSPredicate predicateWithFormat:@"(post.creator.userID == %i) AND (post.draft == YES) AND (isUploading == NO) AND (didFailUpload == NO)", [[MRSLUser currentUser].userID intValue]];
                                      [MRSLMorsel MR_deleteAllMatchingPredicate:currentUserMorselsPredicate];
                                      [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

                                      NSArray *userPostsArray = responseObject[@"data"];

                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [userPostsArray enumerateObjectsUsingBlock:^(NSDictionary *postDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLPost *post = [MRSLPost MR_findFirstByAttribute:MRSLPostAttributes.postID
                                                                                       withValue:postDictionary[@"id"]
                                                                                       inContext:localContext];
                                              if (!post) post = [MRSLPost MR_createInContext:localContext];
                                              [post MR_importValuesForKeysWithObject:postDictionary];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceWillRestoreDataNotification
                                                                                              object:nil];
                                      }];

                                      if (successOrNil) successOrNil(userPostsArray);
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

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"morsels/%i/comments", morsel.morselIDValue]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                    if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                        NSArray *commentsArray = responseObject[@"data"];
                                        DDLogDebug(@"%lu comments available for Morsel!", (unsigned long)[commentsArray count]);

                                            [commentsArray enumerateObjectsUsingBlock:^(NSDictionary *commentDictionary, NSUInteger idx, BOOL *stop) {
                                                MRSLComment *comment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                                                                  withValue:commentDictionary[@"id"]];
                                                if (!comment) comment = [MRSLComment MR_createEntity];
                                                [comment MR_importValuesForKeysWithObject:commentDictionary];
                                            }];
                                        if (successOrNil) successOrNil(commentsArray);
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
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"comment": @{@"description": NSNullIfNil(description)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/comments", morsel.morselIDValue]
                              parameters:parameters
                                 success: ^(AFHTTPRequestOperation * operation, id responseObject) {
                                     DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                     [[MRSLEventManager sharedManager] track:@"Added Comment"
                                                           properties:@{@"view": @"AddCommentViewController",
                                                                        @"morsel_id": NSNullIfNil(morsel.morselID),
                                                                        @"comment_id": NSNullIfNil(responseObject[@"data"][@"id"])}];

                                         MRSLComment *comment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                                                           withValue:responseObject[@"data"][@"id"]];
                                         if (!comment) comment = [MRSLComment MR_createEntity];
                                         [comment MR_importValuesForKeysWithObject:responseObject[@"data"]];

                                         [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidCreateCommentNotification
                                                                                             object:morsel];

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
        [[MRSLEventManager sharedManager] track:@"Service Request Error"
                              properties:@{@"view": @"MRSLAPIService",
                                           @"error_message": NSNullIfNil([serviceErrorInfo errorInfo])}];
        DDLogError(@"Request error in method (%@) with serviceInfo: %@", methodName, [serviceErrorInfo errorInfo]);
    }
    
    if (failureOrNil)
        failureOrNil(error);
}

@end
