//
//  MRSLAPIService+Registration.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Registration.h"

#import "MRSLAPIService+Authentication.h"

#import "MRSLAPIClient.h"

#import "MRSLSocialAuthentication.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Registration)

#pragma mark - User Sign Up and Sign In Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
 andAuthentication:(MRSLSocialAuthentication *)authentication
           success:(MRSLAPISuccessBlock)userSuccessOrNil
           failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user[username]": NSNullIfNil(user.username),
                                                                       @"user[email]": NSNullIfNil(user.email)}
                                                includingMRSLObjects:@[user]
                                              requiresAuthentication:NO];
    if (password) [parameters setObject:NSNullIfNil(password)
                                 forKey:@"user[password]"];

    if (authentication) {
        NSDictionary *authenticationParameters = @{@"authentication": @{@"provider": NSNullIfNil(authentication.provider),
                                                                        @"uid": NSNullIfNil(authentication.uid),
                                                                        @"token": NSNullIfNil(authentication.token),
                                                                        @"secret": NSNullIfNil(authentication.secret),
                                                                        @"short_lived": authentication.isTokenShortLived ? @"true" : @"false"}};
        [parameters addEntriesFromDictionary:authenticationParameters];
    }

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
                                       shouldMorselNotification:NO];

                 if (userSuccessOrNil) userSuccessOrNil(responseObject[@"data"]);
             } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                 [self reportFailure:failureOrNil
                        forOperation:operation
                           withError:error
                            inMethod:NSStringFromSelector(_cmd)];
             }];
}

- (void)signInUserWithEmailOrUsername:(NSString *)emailOrUsername
                          andPassword:(NSString *)password
                     orAuthentication:(MRSLSocialAuthentication *)authenticationOrNil
                              success:(MRSLAPISuccessBlock)successOrNil
                              failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = nil;
    if (authenticationOrNil) {
        parameters = [self parametersWithDictionary:@{@"authentication": @{@"provider": NSNullIfNil(authenticationOrNil.provider),
                                                                           @"token": NSNullIfNil(authenticationOrNil.token),
                                                                           @"secret": NSNullIfNil(authenticationOrNil.secret),
                                                                           @"uid": NSNullIfNil(authenticationOrNil.uid)}}
                               includingMRSLObjects:nil
                             requiresAuthentication:NO];
    } else {
        NSString *emailOrUsernameKey = ([emailOrUsername rangeOfString:@"@"].location != NSNotFound) ? @"email" : @"username";
        parameters = [self parametersWithDictionary:@{@"user" : @{emailOrUsernameKey : NSNullIfNil(emailOrUsername),
                                                                  @"password" : NSNullIfNil(password)}}
                               includingMRSLObjects:nil
                             requiresAuthentication:NO];
    }

    [[MRSLAPIClient sharedClient] POST:@"users/sign_in"
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                   [MRSLUser createOrUpdateUserFromResponseObject:responseObject[@"data"]
                                                         shouldMorselNotification:YES];
                                   if (successOrNil) successOrNil(responseObject[@"data"]);
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                   [self reportFailure:failureOrNil
                                          forOperation:operation
                                             withError:error
                                              inMethod:NSStringFromSelector(_cmd)];
                               }];
}

- (void)updateUserBio:(MRSLUser *)user
              success:(MRSLAPISuccessBlock)successOrNil
              failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user": @{@"bio": NSNullIfNil(user.bio)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (successOrNil) successOrNil(responseObject);
                           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                               if ([operation.response statusCode] == 200) {
                                   if (successOrNil) successOrNil(nil);
                               } else {
                                   [self reportFailure:failureOrNil
                                          forOperation:operation
                                             withError:error
                                              inMethod:NSStringFromSelector(_cmd)];
                               }
                           }];
}

- (void)updateUserIndustry:(MRSLUser *)user
                   success:(MRSLAPISuccessBlock)successOrNil
                   failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user": @{@"industry": NSNullIfNil(user.industryTypeName)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i/updateindustry", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (successOrNil) successOrNil(responseObject);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  if ([operation.response statusCode] == 200) {
                                      if (successOrNil) successOrNil(nil);
                                  } else {
                                      [self reportFailure:failureOrNil
                                             forOperation:operation
                                                withError:error
                                                 inMethod:NSStringFromSelector(_cmd)];
                                  }
                              }];
}

- (void)forgotPasswordWithEmail:(NSString *)emailAddress
                        success:(MRSLAPISuccessBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"email" : NSNullIfNil(emailAddress)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    [[MRSLAPIClient sharedClient] POST:@"users/forgot_password"
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   if (successOrNil) successOrNil(responseObject);
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   if ([operation.response statusCode] == 200) {
                                       if (successOrNil) successOrNil(nil);
                                   } else {
                                       [self reportFailure:failureOrNil
                                              forOperation:operation
                                                 withError:error
                                                  inMethod:NSStringFromSelector(_cmd)];
                                   }
                               }];
}

- (void)checkUsernameAvailability:(NSString *)username
                        validated:(MRSLAPIValidationBlock)validateOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"username" : NSNullIfNil(username)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] GET:@"users/validateusername"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (validateOrNil) validateOrNil(YES, nil);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                  if ([serviceErrorInfo.errorInfo rangeOfString:@"has already been taken"].location != NSNotFound) {
                                      if (validateOrNil) validateOrNil(NO, error);
                                  } else {
                                      if (validateOrNil) validateOrNil(YES, error);
                                  }
                              }];
}

- (void)checkEmail:(NSString *)email
         exists:(MRSLAPIExistsBlock)existsOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"email" : NSNullIfNil(email)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] GET:@"users/validate_email"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (existsOrNil) existsOrNil(NO, nil);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                  if ([serviceErrorInfo.errorInfo rangeOfString:@"has already been taken"].location != NSNotFound) {
                                      if (existsOrNil) existsOrNil(YES, error);
                                  } else {
                                      if (existsOrNil) existsOrNil(NO, error);
                                  }
                              }];
}

@end
