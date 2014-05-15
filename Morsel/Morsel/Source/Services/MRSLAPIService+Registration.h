//
//  MRSLAPIService+Registration.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@class MRSLSocialAuthentication;

@interface MRSLAPIService (Registration)

#pragma mark - Registration Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
 andAuthentication:(MRSLSocialAuthentication *)authentication
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)signInUserWithEmailOrUsername:(NSString *)emailOrUsername
                          andPassword:(NSString *)password
                     orAuthentication:(MRSLSocialAuthentication *)authenticationOrNil
                              success:(MRSLAPISuccessBlock)successOrNil
                              failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)updateUserBio:(MRSLUser *)user
              success:(MRSLAPISuccessBlock)successOrNil
              failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)updateUserIndustry:(MRSLUser *)user
                   success:(MRSLAPISuccessBlock)successOrNil
                   failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)forgotPasswordWithEmail:(NSString *)emailAddress
                        success:(MRSLAPISuccessBlock)successOrNil
                        failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)checkUsernameAvailability:(NSString *)username
                        validated:(MRSLAPIValidationBlock)validateOrNil;

- (void)checkEmail:(NSString *)email
            exists:(MRSLAPIExistsBlock)existsOrNil;

@end
