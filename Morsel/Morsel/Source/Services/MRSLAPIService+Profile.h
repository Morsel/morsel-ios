//
//  MRSLAPIService+Profile.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Profile)

#pragma mark - User Services

- (void)getUserProfile:(MRSLUser *)user
               success:(MRSLAPISuccessBlock)userSuccessOrNil
               failure:(MRSLFailureBlock)failureOrNil;

- (void)updateUser:(MRSLUser *)user
           success:(MRSLAPISuccessBlock)userSuccessOrNil
           failure:(MRSLFailureBlock)failureOrNil;

- (void)updateEmail:(NSString *)email
           password:(NSString *)password
    currentPassword:(NSString *)currentPassword
            success:(MRSLAPISuccessBlock)successOrNil
            failure:(MRSLFailureBlock)failureOrNil;

- (void)updateAutoFollow:(BOOL)shouldAutoFollow
                 success:(MRSLAPISuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

@end
