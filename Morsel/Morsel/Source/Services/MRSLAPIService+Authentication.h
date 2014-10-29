//
//  MRSLAPIService+Authentication.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@class MRSLSocialAuthentication;

@interface MRSLAPIService (Authentication)

#pragma mark - Authorization Services

- (void)checkAuthentication:(MRSLSocialAuthentication *)authentication
                               exists:(MRSLAPIExistsBlock)existsOrNil;

- (void)createUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)userSuccessOrNil
                         failure:(MRSLFailureBlock)failureOrNil;

- (void)getUserAuthentication:(MRSLSocialAuthentication *)authentication
                      success:(MRSLAPISuccessBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil;

- (void)getUserAuthenticationsWithSuccess:(MRSLAPISuccessBlock)userSuccessOrNil
                                  failure:(MRSLFailureBlock)failureOrNil;

- (void)getSocialProviderConnections:(NSString *)provider
                           usingUIDs:(NSString *)uids
                               maxID:(NSNumber *)maxOrNil
                           orSinceID:(NSNumber *)sinceOrNil
                            andCount:(NSNumber *)countOrNil
                             success:(MRSLAPIArrayBlock)successOrNil
                             failure:(MRSLFailureBlock)failureOrNil;

- (void)updateUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)successOrNil
                         failure:(MRSLFailureBlock)failureOrNil;

- (void)deleteUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)successOrNil
                         failure:(MRSLFailureBlock)failureOrNil;

@end
