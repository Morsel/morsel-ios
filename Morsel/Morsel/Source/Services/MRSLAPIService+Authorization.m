//
//  MRSLAPIService+Authorization.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Authorization.h"

#import "MRSLSocialAuthentication.h"

#import "MRSLSocialServiceFacebook.h"
#import "MRSLSocialServiceTwitter.h"

@implementation MRSLAPIService (Authorization)

#pragma mark - Authorization Services

- (void)checkAuthentication:(MRSLSocialAuthentication *)authentication
                     exists:(MRSLAPIExistsBlock)existsOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"authentication": @{@"provider" : NSNullIfNil(authentication.provider),
                                                                                            @"uid" : NSNullIfNil(authentication.uid)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] GET:@"authentications/check"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
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
    [[MRSLAPIClient sharedClient] POST:@"users/authentications"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if (userSuccessOrNil) userSuccessOrNil(responseObject);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserAuthenticationsWithSuccess:(MRSLAPISuccessBlock)successOrNil
                                  failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] GET:@"users/authentications"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  NSArray *authentications = responseObject[@"data"];
                                  [authentications enumerateObjectsUsingBlock:^(NSDictionary *authDictionary, NSUInteger idx, BOOL *stop) {
                                      MRSLSocialAuthentication *socialAuth = [[MRSLSocialAuthentication alloc] init];
                                      socialAuth.authenticationID = authDictionary[@"id"];
                                      socialAuth.token = authDictionary[@"token"];
                                      socialAuth.provider = authDictionary[@"provider"];
                                      socialAuth.secret = authDictionary[@"secret"];
                                      socialAuth.uid = authDictionary[@"uid"];
                                      socialAuth.username = authDictionary[@"name"];
                                      if ([socialAuth.provider isEqualToString:@"facebook"]) {
                                          [[MRSLSocialServiceFacebook sharedService] restoreFacebookSessionWithAuthentication:socialAuth];
                                      } else if ([socialAuth.provider isEqualToString:@"twitter"]) {
                                          [[MRSLSocialServiceTwitter sharedService] restoreTwitterWithAuthentication:socialAuth
                                                                                                        shouldCreate:NO];
                                      } else {
                                          DDLogError(@"Cannot restore unsupported user authentication for provider (%@).", socialAuth.provider);
                                      }
                                  }];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)deleteUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)successOrNil
                         failure:(MRSLAPIFailureBlock)failureOrNil {
    if (!authentication.authenticationID) {
        DDLogError(@"Authentication for provider (%@) does not have an id. Cannot delete.", authentication.provider);
        return;
    }
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"users/authentications/%i", [authentication.authenticationID intValue]]
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     if (successOrNil) successOrNil(responseObject);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [self reportFailure:failureOrNil
                                               withError:error
                                                inMethod:NSStringFromSelector(_cmd)];
                                 }];
}

@end
