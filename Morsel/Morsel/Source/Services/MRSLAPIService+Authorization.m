//
//  MRSLAPIService+Authorization.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Authorization.h"

#import "MRSLSocialAuthentication.h"

@implementation MRSLAPIService (Authorization)

#pragma mark - Authorization Services

- (void)checkAuthentication:(MRSLSocialAuthentication *)authentication
                     exists:(MRSLAPIExistsBlock)existsOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"authentication[provider]" : NSNullIfNil(authentication.provider),
                                                                       @"authentication[uid]" : NSNullIfNil(authentication.uid)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] GET:@"authentications/check"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (existsOrNil) existsOrNil([responseObject[@"data"] boolValue], nil);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  if (existsOrNil) existsOrNil(NO, error);
                                  [self reportFailure:nil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)createUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)userSuccessOrNil
                         failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"authentication": @{@"provider": NSNullIfNil(authentication.provider),
                                                                                            @"uid": NSNullIfNil(authentication.uid),
                                                                                            @"token": NSNullIfNil(authentication.token),
                                                                                            @"secret": NSNullIfNil(authentication.secret),
                                                                                            @"short_lived": authentication.isTokenShortLived ? @"true" : @"false"}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] PUT:@"users/authentications"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  if (userSuccessOrNil) userSuccessOrNil(responseObject);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

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

@end
