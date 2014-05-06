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

#import "MRSLActivity.h"
#import "MRSLComment.h"
#import "MRSLItem.h"
#import "MRSLNotification.h"
#import "MRSLMorsel.h"
#import "MRSLKeyword.h"
#import "MRSLTag.h"
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

    NSString *releaseAppendedIdentifier = @"";

#if defined(MORSEL_BETA)
    releaseAppendedIdentifier = @"b";
#endif

    [parametersDictionary setObject:[NSString stringWithFormat:@"%@%@", [MRSLUtil appMajorMinorPatchString], releaseAppendedIdentifier]
                             forKey:@"client[version]"];



    return parametersDictionary;
}

#pragma mark - User Sign Up and Sign In Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
           success:(MRSLAPISuccessBlock)userSuccessOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user[password]": NSNullIfNil(password),
                                                                       @"user[industry]": @"chef"}
                                                includingMRSLObjects:@[user]
                                              requiresAuthentication:NO];

    [[MRSLAPIClient sharedClient] POST:@"users"
                            parameters:parameters
             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
                                       shouldMorselNotification:YES];

                 if (userSuccessOrNil) userSuccessOrNil(responseObject[@"data"]);
             } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                 [self reportFailure:failureOrNil
                           withError:error
                            inMethod:NSStringFromSelector(_cmd)];
             }];
}

- (void)signInUserWithEmail:(NSString *)emailAddress
                andPassword:(NSString *)password
                    success:(MRSLAPISuccessBlock)successOrNil
                    failure:(MRSLAPIFailureBlock)failureOrNil {
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
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                   [MRSLUser createOrUpdateUserFromResponseObject:responseObject[@"data"]
                                                         shouldMorselNotification:YES];
                                   if (successOrNil) successOrNil(responseObject[@"data"]);
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                   [self reportFailure:failureOrNil
                                             withError:error
                                              inMethod:NSStringFromSelector(_cmd)];
                               }];
}

#pragma mark - User Services

- (void)getUserProfile:(MRSLUser *)user
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:([user isCurrentUser])];

    NSString *userEndpoint = ([user isCurrentUser]) ? @"users/me" : [NSString stringWithFormat:@"users/%i", user.userIDValue];

    NSString *authToken = [user.auth_token copy];
    [[MRSLAPIClient sharedClient] GET:userEndpoint
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  [user MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                  if ([user isCurrentUser] && authToken && !user.auth_token) user.auth_token = authToken;
                                  if (successOrNil) successOrNil(responseObject);
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)updateUser:(MRSLUser *)user
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[user]
                                              requiresAuthentication:YES];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString *urlString = [[NSURL URLWithString:[NSString stringWithFormat:@"users/%i", user.userIDValue] relativeToURL:[[MRSLAPIClient sharedClient] baseURL]] absoluteString];
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"PUT"
                                                                           URLString:urlString
                                                                          parameters:parameters
                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                               if (user.profilePhotoFull) {
                                                                   [formData appendPartWithFileData:user.profilePhotoFull
                                                                                               name:@"user[photo]"
                                                                                           fileName:@"photo.jpg"
                                                                                           mimeType:@"image/jpeg"];
                                                               }
                                                           }];

    NSString *authToken = [user.auth_token copy];
    AFHTTPRequestOperation *operation = [[MRSLAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                                                                  if (user.managedObjectContext) {
                                                                                                      [user MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                                                                      if ([user isCurrentUser] && authToken && !user.auth_token) user.auth_token = authToken;
                                                                                                      [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                                                                                  }
                                                                                                  if (successOrNil) successOrNil(responseObject);
                                                                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                  [self reportFailure:failureOrNil
                                                                                                            withError:error
                                                                                                             inMethod:NSStringFromSelector(_cmd)];
                                                                                              }];
    [[MRSLAPIClient sharedClient].operationQueue addOperation:operation];
}

#pragma mark - Authorization Services

- (void)createFacebookAuthorizationWithToken:(NSString *)token
                                     forUser:(MRSLUser *)user
                                     success:(MRSLAPISuccessBlock)userSuccessOrNil
                                     failure:(MRSLAPIFailureBlock)failureOrNil {
    NSDictionary *facebookParameters = @{
                                         @"provider" : @"facebook",
                                         @"token" : NSNullIfNil(token)
                                         };

    NSMutableDictionary *parameters = [self parametersWithDictionary:facebookParameters
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] POST:@"users/authorizations"
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                                    success:(MRSLAPISuccessBlock)userSuccessOrNil
                                    failure:(MRSLAPIFailureBlock)failureOrNil {
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
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

#pragma mark - Activity Services

- (void)getLikedItemsForUser:(MRSLUser *)user
                       maxID:(NSNumber *)maxOrNil
                   orSinceID:(NSNumber *)sinceOrNil
                    andCount:(NSNumber *)countOrNil
                     success:(MRSLAPIArrayBlock)successOrNil
                     failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"type": @"Item"}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call user likes with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/likeables", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *itemIDs = [NSMutableArray array];
                                      NSArray *likeablesArray = responseObject[@"data"];
                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [likeablesArray enumerateObjectsUsingBlock:^(NSDictionary *itemDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                                               withValue:itemDictionary[@"morsel"][@"id"]
                                                                                                               inContext:localContext];
                                              if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                                              [morsel MR_importValuesForKeysWithObject:itemDictionary[@"morsel"]];
                                              MRSLItem *item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                                       withValue:itemDictionary[@"id"]
                                                                                       inContext:localContext];
                                              if (!item) item = [MRSLItem MR_createInContext:localContext];
                                              [item MR_importValuesForKeysWithObject:itemDictionary];
                                              [itemIDs addObject:itemDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(itemIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserActivitiesForUser:(MRSLUser *)user
                           maxID:(NSNumber *)maxOrNil
                       orSinceID:(NSNumber *)sinceOrNil
                        andCount:(NSNumber *)countOrNil
                         success:(MRSLAPIArrayBlock)successOrNil
                         failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call activities with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] GET:@"users/activities"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *activityIDs = [NSMutableArray array];
                                      NSArray *activityArray = responseObject[@"data"];
                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [activityArray enumerateObjectsUsingBlock:^(NSDictionary *activityDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLActivity *activity = [MRSLActivity MR_findFirstByAttribute:MRSLActivityAttributes.activityID
                                                                                                   withValue:activityDictionary[@"id"]
                                                                                                   inContext:localContext];
                                              if (!activity) activity = [MRSLActivity MR_createInContext:localContext];
                                              [activity MR_importValuesForKeysWithObject:activityDictionary];
                                              [localContext MR_saveOnlySelfAndWait];
                                              [activityIDs addObject:activityDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(activityIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserNotificationsForUser:(MRSLUser *)user
                              maxID:(NSNumber *)maxOrNil
                          orSinceID:(NSNumber *)sinceOrNil
                           andCount:(NSNumber *)countOrNil
                            success:(MRSLAPIArrayBlock)successOrNil
                            failure:(MRSLAPIFailureBlock)failureOrNil {

    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call notifications with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] GET:@"users/notifications"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *notificationIDs = [NSMutableArray array];
                                      NSArray *notificationArray = responseObject[@"data"];
                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [notificationArray enumerateObjectsUsingBlock:^(NSDictionary *notificationDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLNotification *notification = [MRSLNotification MR_findFirstByAttribute:MRSLNotificationAttributes.notificationID
                                                                                                               withValue:notificationDictionary[@"id"]
                                                                                                               inContext:localContext];
                                              if (!notification) notification = [MRSLNotification MR_createInContext:localContext];
                                              [notification MR_importValuesForKeysWithObject:notificationDictionary];
                                              [localContext MR_saveOnlySelfAndWait];
                                              [notificationIDs addObject:notificationDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(notificationIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}


#pragma mark - Morsel Services

- (void)createMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] POST:@"morsels"
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];
    int morselID = morsel.morselIDValue;
    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i", morselID]
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                     if (morsel) {
                                         [morsel MR_deleteEntity];
                                         [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                     }
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidDeleteMorselNotification
                                                                                             object:@(morselID)];
                                     });

                                     if (successOrNil) successOrNil(responseObject);
                                 } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                     [self reportFailure:failureOrNil
                                               withError:error
                                                inMethod:NSStringFromSelector(_cmd)];
                                 }];
}

- (void)updateMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"morsels/%i", morsel.morselIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                  [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdateMorselNotification
                                                                                          object:morsel];
                                  });

                                  if (successOrNil) successOrNil(responseObject);
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)publishMorsel:(MRSLMorsel *)morsel
              success:(MRSLAPISuccessBlock)successOrNil
              failure:(MRSLAPIFailureBlock)failureOrNil
       sendToFacebook:(BOOL)sendToFacebook
        sendToTwitter:(BOOL)sendToTwitter {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    if (sendToFacebook) [parameters setObject:@"true"
                                       forKey:@"post_to_facebook"];
    if (sendToTwitter) [parameters setObject:@"true"
                                      forKey:@"post_to_twitter"];

    [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/publish", morsel.morselIDValue]
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                   [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidPublishMorselNotification
                                                                                           object:morsel];
                                   });
                                   if (successOrNil) successOrNil(responseObject);
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                   if (morsel) morsel.draft = @(!morsel.draftValue);
                                   [self reportFailure:failureOrNil
                                             withError:error
                                              inMethod:NSStringFromSelector(_cmd)];
                               }];
}

- (void)getMorsel:(MRSLMorsel *)morsel
          success:(MRSLAPISuccessBlock)successOrNil
          failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    int morselID = morsel.morselIDValue;
    __block MRSLMorsel *morselToGet = morsel;

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"morsels/%i", morselID]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if (!morselToGet || !morselToGet.managedObjectContext) {
                                      morselToGet = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                              withValue:@(morselID)];
                                  }
                                  if (morselToGet.managedObjectContext) {
                                      @try {
                                          [morselToGet MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                      } @catch (NSException *exception) {
                                          DDLogError(@"Unable to import morsel data due to exception: %@", exception.debugDescription);
                                      }

                                      if (successOrNil) successOrNil(morselToGet);
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserMorsels:(MRSLUser *)user
             withMaxID:(NSNumber *)maxOrNil
             orSinceID:(NSNumber *)sinceOrNil
              andCount:(NSNumber *)countOrNil
         includeDrafts:(BOOL)includeDrafts
               success:(MRSLAPIArrayBlock)successOrNil
               failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    if (includeDrafts) parameters[@"include_drafts"] = @"true";

    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call user morsels with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/morsels", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *morselIDs = [NSMutableArray array];
                                      NSArray *userMorselsArray = responseObject[@"data"];

                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [userMorselsArray enumerateObjectsUsingBlock:^(NSDictionary *morselDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                             withValue:morselDictionary[@"id"]
                                                                                             inContext:localContext];
                                              if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                                              [morsel MR_importValuesForKeysWithObject:morselDictionary];
                                              [morselIDs addObject:morselDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(morselIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserDraftsWithMaxID:(NSNumber *)maxOrNil
                     orSinceID:(NSNumber *)sinceOrNil
                      andCount:(NSNumber *)countOrNil
                       success:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call user morsels with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] GET:@"morsels/drafts"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *morselIDs = [NSMutableArray array];
                                      NSArray *userMorselsArray = responseObject[@"data"];

                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [userMorselsArray enumerateObjectsUsingBlock:^(NSDictionary *morselDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                             withValue:morselDictionary[@"id"]
                                                                                             inContext:localContext];
                                              if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                                              [morsel MR_importValuesForKeysWithObject:morselDictionary];
                                              [morselIDs addObject:morselDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(morselIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

#pragma mark - Item Services

- (void)createItem:(MRSLItem *)item
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[item]
                                              requiresAuthentication:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidBeginCreateMorselNotification
                                                            object:nil];
    });

    NSString *itemLocalUUID = [item.localUUID copy];

    __block MRSLItem *localItem = item;

    [[MRSLAPIClient sharedClient] POST:@"items"
                            parameters:parameters
                               success: ^(AFHTTPRequestOperation * operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                   if (!localItem || !localItem.managedObjectContext) {
                                       localItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.localUUID
                                                                           withValue:itemLocalUUID];
                                   }
                                   if (localItem && localItem.managedObjectContext) {
                                       [localItem MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[NSNotificationCenter defaultCenter] postNotificationName:MRSLItemUploadDidCompleteNotification
                                                                                               object:localItem];
                                       });
                                       [localItem.managedObjectContext MR_saveOnlySelfAndWait];
                                       if (successOrNil) successOrNil(localItem);
                                   }
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                   if (!item || !item.managedObjectContext) {
                                       localItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.localUUID
                                                                           withValue:itemLocalUUID];
                                   }
                                   if (localItem) {
                                       MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                       if (serviceErrorInfo) {
                                           if ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"already exists"].location != NSNotFound) {
                                               [localItem MR_deleteEntity];
                                               [localItem.managedObjectContext MR_saveToPersistentStoreAndWait];
                                               return;
                                           }
                                       }
                                       localItem.didFailUpload = @YES;
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[NSNotificationCenter defaultCenter] postNotificationName:MRSLItemUploadDidFailNotification
                                                                                               object:localItem];
                                       });
                                       [self reportFailure:failureOrNil
                                                 withError:error
                                                  inMethod:NSStringFromSelector(_cmd)];
                                   }
                               }];
}

- (void)getItem:(MRSLItem *)item
        success:(MRSLAPISuccessBlock)successOrNil
        failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    int itemID = item.itemIDValue;
    __block MRSLItem *itemToGet = item;

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"items/%i", itemID]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                  if (!itemToGet || !itemToGet.managedObjectContext) {
                                      itemToGet = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                          withValue:@(itemID)];
                                  }
                                  if (itemToGet) {
                                      [itemToGet MR_importValuesForKeysWithObject:responseObject[@"data"]];

                                      if (successOrNil) successOrNil(itemToGet);
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getItemLikes:(MRSLItem *)item
             success:(MRSLAPIArrayBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"items/%i/likers", item.itemIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  __block NSMutableArray *itemLikers = [NSMutableArray array];
                                  NSArray *likerUsersArray = responseObject[@"data"];
                                  [likerUsersArray enumerateObjectsUsingBlock:^(NSDictionary *userDictionary, NSUInteger idx, BOOL *stop) {

                                      MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                               withValue:userDictionary[@"id"]];
                                      NSString *authToken = nil;
                                      if (!user) {
                                          user = [MRSLUser MR_createEntity];
                                      } else {
                                          authToken = [user.auth_token copy];
                                      }
                                      [user MR_importValuesForKeysWithObject:userDictionary];
                                      if (!user.auth_token && authToken) user.auth_token = authToken;
                                      [itemLikers addObject:user];
                                  }];
                                  if (successOrNil) successOrNil(itemLikers);
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)updateItem:(MRSLItem *)item
         andMorsel:(MRSLMorsel *)morselOrNil
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[item]
                                              requiresAuthentication:YES];

    if (morselOrNil) {
        [parameters addEntriesFromDictionary:@{@"new_morsel_id": NSNullIfNil(morselOrNil.morselID),
                                               @"morsel_id": NSNullIfNil(item.morsel.morselID)}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdateItemNotification
                                                            object:item];
    });

    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"items/%i", item.itemIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                  if (morselOrNil) {
                                      [item.morsel removeItemsObject:item];
                                      [morselOrNil addItemsObject:item];
                                      item.morsel = morselOrNil;
                                  }

                                  [item MR_importValuesForKeysWithObject:responseObject[@"data"]];

                                  if (successOrNil) successOrNil(responseObject);
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)updateItemImage:(MRSLItem *)item
                success:(MRSLAPISuccessBlock)successOrNil
                failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[item]
                                              requiresAuthentication:YES];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString *urlString = [[NSURL URLWithString:[NSString stringWithFormat:@"items/%i", item.itemIDValue] relativeToURL:[[MRSLAPIClient sharedClient] baseURL]] absoluteString];
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"PUT"
                                                                           URLString:urlString
                                                                          parameters:parameters
                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                               if (item.itemPhotoFull) {
                                                                   [formData appendPartWithFileData:item.itemPhotoFull
                                                                                               name:@"item[photo]"
                                                                                           fileName:@"photo.jpg"
                                                                                           mimeType:@"image/jpeg"];
                                                               }
                                                           }];

    AFHTTPRequestOperation *operation = [[MRSLAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                                                                  if (item.managedObjectContext) {
                                                                                                      item.isUploading = @NO;
                                                                                                      item.itemID = responseObject[@"data"][@"id"];
                                                                                                      [item MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                                                                      [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                                                                                  }
                                                                                                  if (successOrNil) successOrNil(responseObject);
                                                                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                  if (item.managedObjectContext) {
                                                                                                      item.isUploading = @NO;
                                                                                                      item.didFailUpload = @YES;
                                                                                                  }
                                                                                                  [self reportFailure:failureOrNil
                                                                                                            withError:error
                                                                                                             inMethod:NSStringFromSelector(_cmd)];
                                                                                              }];
    [[MRSLAPIClient sharedClient].operationQueue addOperation:operation];
}

- (void)deleteItem:(MRSLItem *)item
           success:(MRSLDataSuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    int itemID = item.itemIDValue;

    [item MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"items/%i", itemID]
                              parameters:parameters
                                 success:nil
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if ([operation.response statusCode] == 200) {
                                         if (successOrNil) successOrNil(YES);
                                     } else {
                                         [self reportFailure:failureOrNil
                                                   withError:error
                                                    inMethod:NSStringFromSelector(_cmd)];
                                     }
                                 }];
}

- (void)likeItem:(MRSLItem *)item
      shouldLike:(BOOL)shouldLike
         didLike:(MRSLAPILikeBlock)likeBlockOrNil
         failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (shouldLike) {
        item.like_count = @(item.like_countValue + 1);
        [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"items/%i/like", item.itemIDValue]
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       if (likeBlockOrNil) likeBlockOrNil(YES);
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                       if ([operation.response statusCode] == 200 || [serviceErrorInfo.errorInfo isEqualToString:@"Item: already liked"]) {
                                           if (likeBlockOrNil) likeBlockOrNil(YES);
                                       } else {
                                           [self reportFailure:failureOrNil
                                                     withError:error
                                                      inMethod:NSStringFromSelector(_cmd)];
                                       }
                                   }];
    } else {
        item.like_count = @(item.like_countValue - 1);
        [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"items/%i/like", item.itemIDValue]
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if (likeBlockOrNil) likeBlockOrNil(NO);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                         if ([operation.response statusCode] == 200  || [serviceErrorInfo.errorInfo isEqualToString:@"Item: not liked"]) {
                                             if (likeBlockOrNil) likeBlockOrNil(NO);
                                         } else {
                                             [self reportFailure:failureOrNil
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }
                                     }];
    }
}

#pragma mark - Feed Services

- (void)getFeedWithMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call feed with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] GET:@"feed"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *feedItemIDs = [NSMutableArray array];
                                      NSArray *feedItemsArray = responseObject[@"data"];
                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [feedItemsArray enumerateObjectsUsingBlock:^(NSDictionary *feedItemDictionary, NSUInteger idx, BOOL *stop) {
                                              if ([feedItemDictionary[@"subject_type"] isEqualToString:@"Morsel"]) {
                                                  if (![feedItemDictionary[@"subject"] isEqual:[NSNull null]]) {
                                                      NSDictionary *morselDictionary = feedItemDictionary[@"subject"];
                                                      MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                                     withValue:morselDictionary[@"id"]
                                                                                                     inContext:localContext];
                                                      if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                                                      [morsel MR_importValuesForKeysWithObject:morselDictionary];
                                                      morsel.feedItemID = feedItemDictionary[@"id"];
                                                      [feedItemIDs addObject:morselDictionary[@"id"]];
                                                  }
                                              }
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(feedItemIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

#pragma mark - Comment Services

- (void)getComments:(MRSLItem *)item
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"items/%i/comments", item.itemIDValue]
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

- (void)addCommentWithDescription:(NSString *)description
                         toMorsel:(MRSLItem *)item
                          success:(MRSLAPISuccessBlock)successOrNil
                          failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"comment": @{@"description": NSNullIfNil(description)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"items/%i/comments", item.itemIDValue]
                            parameters:parameters
                               success: ^(AFHTTPRequestOperation * operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                   MRSLComment *comment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                                                     withValue:responseObject[@"data"][@"id"]];
                                   if (!comment) comment = [MRSLComment MR_createEntity];
                                   [comment MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                   item.comment_count = @(item.comment_countValue + 1);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidCreateCommentNotification
                                                                                           object:item];
                                   });
                                   if (successOrNil) successOrNil(responseObject);
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                   [self reportFailure:failureOrNil
                                             withError:error
                                              inMethod:NSStringFromSelector(_cmd)];
                               }];
}

#pragma mark - Tag Services

- (void)getCuisinesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLAPIFailureBlock)failureOrNil {
    [self getKeywordsOfType:MRSLKeywordCuisinesType
                    success:successOrNil
                    failure:failureOrNil];
}

- (void)getSpecialtiesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                          failure:(MRSLAPIFailureBlock)failureOrNil {
    [self getKeywordsOfType:MRSLKeywordSpecialtiesType
                    success:successOrNil
                    failure:failureOrNil];
}

- (void)getKeywordsOfType:(NSString *)tagType
                  success:(MRSLAPIArrayBlock)successOrNil
                  failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] GET:tagType
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importKeywordsWithDictionary:responseObject
                                                             success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getCuisineUsers:(MRSLKeyword *)cuisine
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLAPIFailureBlock)failureOrNil {
    [self getTagUsersForKeyword:cuisine
                         ofType:MRSLKeywordCuisinesType
                        success:successOrNil
                        failure:failureOrNil];
}

- (void)getSpecialtyUsers:(MRSLKeyword *)specialty
                  success:(MRSLAPIArrayBlock)successOrNil
                  failure:(MRSLAPIFailureBlock)failureOrNil {
    [self getTagUsersForKeyword:specialty
                         ofType:MRSLKeywordSpecialtiesType
                        success:successOrNil
                        failure:failureOrNil];
}

- (void)getTagUsersForKeyword:(MRSLKeyword *)keyword
                       ofType:(NSString *)keywordType
                      success:(MRSLAPIArrayBlock)successOrNil
                      failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"%@/%i/users", keywordType, keyword.keywordIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importUsersWithDictionary:responseObject
                                                          success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserCuisines:(MRSLUser *)user
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLAPIFailureBlock)failureOrNil {
    [self getUserTags:user
        ofKeywordType:MRSLKeywordCuisinesType
              success:successOrNil
              failure:failureOrNil];
}

- (void)getUserSpecialties:(MRSLUser *)user
                   success:(MRSLAPIArrayBlock)successOrNil
                   failure:(MRSLAPIFailureBlock)failureOrNil {
    [self getUserTags:user
        ofKeywordType:MRSLKeywordSpecialtiesType
              success:successOrNil
              failure:failureOrNil];
}

- (void)getUserTags:(MRSLUser *)user
      ofKeywordType:(NSString *)keywordType
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/%@", user.userIDValue, keywordType]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importTagsWithDictionary:responseObject
                                                         success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)createTagForKeyword:(MRSLKeyword *)keyword
                    success:(MRSLAPISuccessBlock)successOrNil
                    failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"tag": @{@"keyword_id": keyword.keywordID}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"users/%i/tags", [MRSLUser currentUser].userIDValue]
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                   MRSLTag *tag = [MRSLTag MR_findFirstByAttribute:MRSLTagAttributes.tagID
                                                                                     withValue:responseObject[@"data"][@"id"]];
                                   if (!tag) tag = [MRSLTag MR_createEntity];
                                   [tag MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                   [tag.managedObjectContext MR_saveOnlySelfAndWait];
                                   if (successOrNil) successOrNil(responseObject);
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   [self reportFailure:failureOrNil
                                             withError:error
                                              inMethod:NSStringFromSelector(_cmd)];
                               }];
}

- (void)deleteTag:(MRSLTag *)tag
          success:(MRSLDataSuccessBlock)successOrNil
          failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    int tagID = tag.tagIDValue;
    [tag MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"users/%i/tags/%i", [MRSLUser currentUser].userIDValue, tagID]
                              parameters:parameters
                                 success:nil
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if ([operation.response statusCode] == 200) {
                                         if (successOrNil) successOrNil(YES);
                                     } else {
                                         [self reportFailure:failureOrNil
                                                   withError:error
                                                    inMethod:NSStringFromSelector(_cmd)];
                                     }
                                 }];
}

#pragma mark - Following Services

- (void)followUser:(MRSLUser *)user
      shouldFollow:(BOOL)shouldFollow
         didFollow:(MRSLAPIFollowBlock)followBlockOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (shouldFollow) {
        user.follower_count = @(user.follower_countValue + 1);
        [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"users/%i/follow", user.userIDValue]
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       if (followBlockOrNil) followBlockOrNil(YES);
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                       if ([operation.response statusCode] == 200 || [serviceErrorInfo.errorInfo isEqualToString:@"User: already followed"]) {
                                           if (followBlockOrNil) followBlockOrNil(YES);
                                       } else {
                                           [self reportFailure:failureOrNil
                                                     withError:error
                                                      inMethod:NSStringFromSelector(_cmd)];
                                       }
                                   }];
    } else {
        user.follower_count = @(user.follower_countValue - 1);
        [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"users/%i/follow", user.userIDValue]
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if (followBlockOrNil) followBlockOrNil(NO);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                         if ([operation.response statusCode] == 200  || [serviceErrorInfo.errorInfo isEqualToString:@"User: not followed"]) {
                                             if (followBlockOrNil) followBlockOrNil(NO);
                                         } else {
                                             [self reportFailure:failureOrNil
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }
                                     }];
    }
}

- (void)getUserFollowers:(MRSLUser *)user
               withMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call user followers with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;
    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/followers", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importUsersWithDictionary:responseObject
                                                          success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserFollowables:(MRSLUser *)user
                 withMaxID:(NSNumber *)maxOrNil
                 orSinceID:(NSNumber *)sinceOrNil
                  andCount:(NSNumber *)countOrNil
                   success:(MRSLAPIArrayBlock)successOrNil
                   failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"type": @"User"}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call user followables with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;
    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/followables", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importUsersWithDictionary:responseObject
                                                          success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

#pragma mark - Importing Helpers

- (void)importTagsWithDictionary:(NSDictionary *)responseDictionary
                             success:(MRSLAPIArrayBlock)successOrNil {
    __block NSMutableArray *tagIDs = [NSMutableArray array];
    NSArray *tagArray = responseDictionary[@"data"];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [tagArray enumerateObjectsUsingBlock:^(NSDictionary *tagDictionary, NSUInteger idx, BOOL *stop) {
            MRSLTag *tag = [MRSLTag MR_findFirstByAttribute:MRSLTagAttributes.tagID
                                                              withValue:tagDictionary[@"id"]
                                                              inContext:localContext];
            if (!tag) tag = [MRSLTag MR_createInContext:localContext];
            [tag MR_importValuesForKeysWithObject:tagDictionary];
            [tagIDs addObject:tagDictionary[@"id"]];
        }];
    } completion:^(BOOL success, NSError *error) {
        if (successOrNil) successOrNil(tagIDs);
    }];
}

- (void)importKeywordsWithDictionary:(NSDictionary *)responseDictionary
                             success:(MRSLAPIArrayBlock)successOrNil {
    __block NSMutableArray *keywordIDs = [NSMutableArray array];
    NSArray *keywordArray = responseDictionary[@"data"];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [keywordArray enumerateObjectsUsingBlock:^(NSDictionary *keywordDictionary, NSUInteger idx, BOOL *stop) {
            MRSLKeyword *keyword = [MRSLKeyword MR_findFirstByAttribute:MRSLKeywordAttributes.keywordID
                                                              withValue:keywordDictionary[@"id"]
                                                              inContext:localContext];
            if (!keyword) keyword = [MRSLKeyword MR_createInContext:localContext];
            [keyword MR_importValuesForKeysWithObject:keywordDictionary];
            [keywordIDs addObject:keywordDictionary[@"id"]];
        }];
    } completion:^(BOOL success, NSError *error) {
        if (successOrNil) successOrNil(keywordIDs);
    }];
}

- (void)importUsersWithDictionary:(NSDictionary *)responseDictionary
                          success:(MRSLAPIArrayBlock)successOrNil {
    if ([responseDictionary[@"data"] isKindOfClass:[NSArray class]]) {
        __block NSMutableArray *userIDs = [NSMutableArray array];
        NSArray *userArray = responseDictionary[@"data"];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [userArray enumerateObjectsUsingBlock:^(NSDictionary *userDictionary, NSUInteger idx, BOOL *stop) {
                MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                                 withValue:userDictionary[@"id"]
                                                                                 inContext:localContext];
                if (!user) user = [MRSLUser MR_createInContext:localContext];
                NSString *authToken = user.auth_token;
                [user MR_importValuesForKeysWithObject:userDictionary];
                if ([user isCurrentUser] && authToken && !user.auth_token) user.auth_token = authToken;
                [userIDs addObject:userDictionary[@"id"]];
            }];
        } completion:^(BOOL success, NSError *error) {
            if (successOrNil) successOrNil(userIDs);
        }];
    }
}

#pragma mark - General Methods

- (void)reportFailure:(MRSLAPIFailureBlock)failureOrNil
            withError:(NSError *)error
             inMethod:(NSString *)methodName {
    MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

    if (!serviceErrorInfo) {
        DDLogError(@"Request error in method (%@) with userInfo: %@", methodName, error.userInfo);
    } else {
        DDLogError(@"Request error in method (%@) with serviceInfo: %@", methodName, [serviceErrorInfo errorInfo]);
    }
    
    if (failureOrNil) failureOrNil(error);
}

@end
