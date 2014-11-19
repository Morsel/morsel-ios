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
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user": @{@"username": NSNullIfNil(user.username),
                                                                                  @"email": NSNullIfNil(user.email)}}
                                                includingMRSLObjects:@[NSNullIfNil(user)]
                                              requiresAuthentication:NO];
    if (authentication) {
        NSDictionary *authenticationParameters = @{@"authentication": @{@"provider": NSNullIfNil(authentication.provider),
                                                                        @"uid": NSNullIfNil(authentication.uid),
                                                                        @"token": NSNullIfNil(authentication.token),
                                                                        @"secret": NSNullIfNil(authentication.secret),
                                                                        @"short_lived": authentication.isTokenShortLived ? @"true" : @"false"}};
        [parameters addEntriesFromDictionary:authenticationParameters];
    } else {
        parameters[@"user"][@"password"] = NSNullIfNil(password);
    }

    if (user.profilePhotoFull) {
        parameters[@"prepare_presigned_upload"] = @"true";
    }

    [[MRSLAPIClient sharedClient] multipartFormRequestString:@"users"
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                                         [MRSLUser createOrUpdateUserFromResponseObject:responseObject[@"data"]
                                                                                           existingUser:NO];

                                                         if (userSuccessOrNil) userSuccessOrNil(responseObject[@"data"]);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

    [[MRSLAPIClient sharedClient] multipartFormRequestString:@"users/sign_in"
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         [MRSLUser createOrUpdateUserFromResponseObject:responseObject[@"data"]
                                                                                           existingUser:YES];
                                                         if (successOrNil) successOrNil(responseObject[@"data"]);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)forgotPasswordWithEmail:(NSString *)emailAddress
                        success:(MRSLAPISuccessBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"email" : NSNullIfNil(emailAddress)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:@"users/forgot_password"
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
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
    [[MRSLAPIClient sharedClient] performRequest:@"users/validate_username"
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
    [[MRSLAPIClient sharedClient] performRequest:@"users/validate_email"
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
