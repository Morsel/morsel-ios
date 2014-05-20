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

- (void)getUserAuthenticationsWithSuccess:(MRSLAPISuccessBlock)userSuccessOrNil
                                  failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)deleteUserAuthentication:(MRSLSocialAuthentication *)authentication
                         success:(MRSLAPISuccessBlock)successOrNil
                         failure:(MRSLAPIFailureBlock)failureOrNil;

@end
