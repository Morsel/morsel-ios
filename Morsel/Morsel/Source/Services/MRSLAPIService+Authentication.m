//
//  MRSLAPIService+Authentication.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Authentication.h"

#import "MRSLAPIClient.h"

#import "MRSLSocialAuthentication.h"

#import "MRSLSocialServiceFacebook.h"
#import "MRSLSocialServiceInstagram.h"
#import "MRSLSocialServiceTwitter.h"

#import "MRSLUser.h"

@implementation MRSLAPIService (Authentication)

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
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)createUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)userSuccessOrNil
                         failure:(MRSLFailureBlock)failureOrNil {
    NSString *uid = [NSString stringWithFormat:@"'%@'", authentication.uid];
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"authentication": @{@"provider": NSNullIfNil(authentication.provider),
                                                                                            @"uid": NSNullIfNil(uid),
                                                                                            @"token": NSNullIfNil(authentication.token),
                                                                                            @"secret": NSNullIfNil(authentication.secret),
                                                                                            @"short_lived": authentication.isTokenShortLived ? @"true" : @"false"}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] POST:@"authentications"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  authentication.authenticationID = responseObject[@"data"][@"id"];
                                  if (userSuccessOrNil) userSuccessOrNil(responseObject);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserAuthenticationsWithSuccess:(MRSLAPISuccessBlock)successOrNil
                                  failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] GET:@"authentications"
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
                                      if ([[socialAuth.provider lowercaseString] isEqualToString:@"facebook"]) {
                                          [[MRSLSocialServiceFacebook sharedService] restoreFacebookSessionWithAuthentication:socialAuth];
                                      } else if ([[socialAuth.provider lowercaseString] isEqualToString:@"twitter"]) {
                                          [[MRSLSocialServiceTwitter sharedService] restoreTwitterWithAuthentication:socialAuth
                                                                                                        shouldCreate:NO];
                                      } else if ([[socialAuth.provider lowercaseString] isEqualToString:@"instagram"]) {
                                          [[MRSLSocialServiceInstagram sharedService] restoreInstagramWithAuthentication:socialAuth
                                                                                                            shouldCreate:NO];
                                      } else {
                                          DDLogError(@"Cannot restore unsupported user authentication for provider (%@).", socialAuth.provider);
                                      }
                                  }];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getSocialProviderConnections:(NSString *)provider
                           usingUIDs:(NSString *)uids
                               maxID:(NSNumber *)maxOrNil
                           orSinceID:(NSNumber *)sinceOrNil
                            andCount:(NSNumber *)countOrNil
                             success:(MRSLAPIArrayBlock)successOrNil
                             failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"provider" : NSNullIfNil(provider)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    NSData *uidData = [uids dataUsingEncoding:NSUTF8StringEncoding];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString *urlString = [[NSURL URLWithString:@"authentications/connections"
                                  relativeToURL:[[MRSLAPIClient sharedClient] baseURL]] absoluteString];
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                           URLString:urlString
                                                                          parameters:parameters
                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                               [formData appendPartWithFormData:uidData name:@"uids"];
                                                           }];
    AFHTTPRequestOperation *operation = [[MRSLAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self importManagedObjectClass:[MRSLUser class]
                        withDictionary:responseObject
                               success:successOrNil
                               failure:failureOrNil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self reportFailure:failureOrNil
               forOperation:operation
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
    [[MRSLAPIClient sharedClient].operationQueue addOperation:operation];
}

- (void)updateUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)successOrNil
                         failure:(MRSLFailureBlock)failureOrNil {
    if (!authentication.authenticationID) {
        DDLogError(@"Authentication for provider (%@) does not have an id. Cannot update.", authentication.provider);
        return;
    }
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"authentication": @{@"provider": NSNullIfNil(authentication.provider),
                                                                                            @"uid": NSNullIfNil(authentication.uid),
                                                                                            @"token": NSNullIfNil(authentication.token),
                                                                                            @"secret": NSNullIfNil(authentication.secret),
                                                                                            @"short_lived": authentication.isTokenShortLived ? @"true" : @"false"}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"authentications/%i", [authentication.authenticationID intValue]]
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     if (successOrNil) successOrNil(responseObject);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [self reportFailure:failureOrNil
                                            forOperation:operation
                                               withError:error
                                                inMethod:NSStringFromSelector(_cmd)];
                                 }];
}

- (void)deleteUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)successOrNil
                         failure:(MRSLFailureBlock)failureOrNil {
    if (![authentication isValid]) {
        DDLogError(@"Authentication for provider (%@) is not valid. Cannot delete.", authentication.provider);
        return;
    }
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"authentications/%i", [authentication.authenticationID intValue]]
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     if (successOrNil) successOrNil(responseObject);
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     [self reportFailure:failureOrNil
                                            forOperation:operation
                                               withError:error
                                                inMethod:NSStringFromSelector(_cmd)];
                                 }];
}

@end
