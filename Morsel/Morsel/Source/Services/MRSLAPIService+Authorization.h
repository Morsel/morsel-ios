//
//  MRSLAPIService+Authorization.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@class MRSLSocialAuthentication;

@interface MRSLAPIService (Authorization)

#pragma mark - Authorization Services

- (void)checkAuthentication:(MRSLSocialAuthentication *)authentication
                               exists:(MRSLAPIExistsBlock)existsOrNil;

- (void)createUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)userSuccessOrNil
                         failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)createFacebookAuthorizationWithToken:(NSString *)token
                                     forUser:(MRSLUser *)user
                                     success:(MRSLAPISuccessBlock)userSuccessOrNil
                                     failure:(MRSLAPIFailureBlock)failureOrNil __deprecated;

- (void)createTwitterAuthorizationWithToken:(NSString *)token
                                     secret:(NSString *)secret
                                    forUser:(MRSLUser *)user
                                    success:(MRSLAPISuccessBlock)userSuccessOrNil
                                    failure:(MRSLAPIFailureBlock)failureOrNil __deprecated;

@end
