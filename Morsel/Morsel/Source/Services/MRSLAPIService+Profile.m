//
//  MRSLAPIService+Profile.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Profile.h"

#import "MRSLAPIClient.h"

#import "MRSLUser.h"

@implementation MRSLAPIService (Profile)

#pragma mark - User Services

- (void)getUserProfile:(MRSLUser *)user
            parameters:(NSDictionary *)additionalParametersOrNil
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil {
    if (!user) return;
    BOOL isCurrentUser = [user isCurrentUser];
    NSMutableDictionary *parameters = [self parametersWithDictionary:isCurrentUser ? additionalParametersOrNil : nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:isCurrentUser];

    NSString *userEndpoint = isCurrentUser ? @"users/me" : [NSString stringWithFormat:@"users/%i", user.userIDValue];

    [[MRSLAPIClient sharedClient] GET:userEndpoint
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  [user MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                  if (successOrNil) successOrNil(responseObject);
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserProfile:(MRSLUser *)user
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil {
    [self getUserProfile:user
              parameters:nil
                 success:successOrNil
                 failure:failureOrNil];
}

- (void)updateUser:(MRSLUser *)user
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[NSNullIfNil(user)]
                                              requiresAuthentication:YES];
    if (user.profilePhotoFull) {
        parameters[@"prepare_presigned_upload"] = @"true";
    }

    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if (user.managedObjectContext) {
                                      [user MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                      [user.managedObjectContext MR_saveToPersistentStoreAndWait];
                                  }
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdateUserNotification
                                                                                          object:nil];
                                  });
                                  if (successOrNil) successOrNil(responseObject);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)updateEmail:(NSString *)email
           password:(NSString *)password
       currentPassword:(NSString *)currentPassword
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *userParameters = [NSMutableDictionary dictionaryWithDictionary:@{ @"current_password": currentPassword }];
    if (email) [userParameters setObject:email forKey:@"email"];
    if (password) [userParameters setObject:password forKey:@"password"];

    NSMutableDictionary *parameters = [self parametersWithDictionary:@{ @"user": userParameters }
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    MRSLUser *currentUser = [MRSLUser currentUser];
    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", currentUser.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (currentUser.managedObjectContext) {
                                      [currentUser MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                      [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                  }
                                  if (successOrNil) successOrNil(responseObject);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)updateAutoFollow:(BOOL)shouldAutoFollow
                 success:(MRSLAPISuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user": @{@"settings": @{@"auto_follow": @(shouldAutoFollow)}}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    MRSLUser *currentUser = [MRSLUser currentUser];
    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", currentUser.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (currentUser.managedObjectContext) {
                                      [currentUser MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                      [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                  }
                                  if (successOrNil) successOrNil(responseObject);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)updateCurrentUserToProfessional:(BOOL)professional
                                success:(MRSLAPISuccessBlock)successOrNil
                                failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user": @{@"professional": @(professional)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    MRSLUser *currentUser = [MRSLUser currentUser];
    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", currentUser.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (currentUser.managedObjectContext) {
                                      [currentUser MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                      [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                  }
                                  if (successOrNil) successOrNil(responseObject);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)updateUserImage:(MRSLUser *)user
                success:(MRSLAPISuccessBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    int userID = user.userIDValue;
    __block MRSLUser *userToUpdate = user;

    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString *urlString = [[NSURL URLWithString:[NSString stringWithFormat:@"users/%i", userID] relativeToURL:[[MRSLAPIClient sharedClient] baseURL]] absoluteString];
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

    AFHTTPRequestOperation *operation = [[MRSLAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                                                                  if (!userToUpdate || !userToUpdate.managedObjectContext) {
                                                                                                      userToUpdate = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                                                                                             withValue:@(userID)];
                                                                                                  }
                                                                                                  if (userToUpdate) {
                                                                                                      userToUpdate.isUploading = @NO;
                                                                                                      userToUpdate.userID = responseObject[@"data"][@"id"];
                                                                                                      [userToUpdate MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                                                                      [userToUpdate.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                                                                      if (successOrNil) successOrNil(responseObject);
                                                                                                  } else {
                                                                                                      if (failureOrNil) failureOrNil(nil);
                                                                                                  }
                                                                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                  if (!userToUpdate || !userToUpdate.managedObjectContext) {
                                                                                                      userToUpdate = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                                                                                             withValue:@(userID)];
                                                                                                  }
                                                                                                  if ([userToUpdate managedObjectContext]) {
                                                                                                      userToUpdate.isUploading = @NO;
                                                                                                  }
                                                                                                  [self reportFailure:failureOrNil
                                                                                                         forOperation:operation
                                                                                                            withError:error
                                                                                                             inMethod:NSStringFromSelector(_cmd)];
                                                                                              }];
    [[MRSLAPIClient sharedClient].operationQueue addOperation:operation];}

- (void)updatePhotoKey:(NSString *)photoKey
               forUser:(MRSLUser *)user
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    parameters[@"user"] = @{ @"photo_key": photoKey };

    int userID = user.userIDValue;
    __block MRSLUser *userToUpdate = user;

    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", userID]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if (!userToUpdate || !userToUpdate.managedObjectContext) {
                                      userToUpdate = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                             withValue:@(userID)];
                                  }
                                  [userToUpdate MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                  if (userToUpdate) {
                                      [userToUpdate.managedObjectContext MR_saveToPersistentStoreAndWait];
                                      if (successOrNil) successOrNil(responseObject);
                                  } else {
                                      if (failureOrNil) failureOrNil(nil);
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

@end
