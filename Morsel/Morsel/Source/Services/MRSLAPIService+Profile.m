//
//  MRSLAPIService+Profile.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Profile.h"

#import "MRSLUser.h"

@implementation MRSLAPIService (Profile)

#pragma mark - User Services

- (void)getUserProfile:(MRSLUser *)user
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil {
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
           failure:(MRSLFailureBlock)failureOrNil {
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

- (void)updateEmail:(NSString *)email
           password:(NSString *)password
       currentPassword:(NSString *)currentPassword
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user": @{@"current_password": currentPassword}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    if (email) [parameters setObject:email forKey:@"user[email]"];
    if (password) [parameters setObject:password forKey:@"user[password]"];

    MRSLUser *currentUser = [MRSLUser currentUser];
    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", currentUser.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (currentUser.managedObjectContext) {
                                      [currentUser MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                      [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                  }
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

@end
