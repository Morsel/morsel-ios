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
            parameters:(NSDictionary *)additionalParametersOrNil
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil;

- (void)getUserProfile:(MRSLUser *)user
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil;

- (void)updateUser:(MRSLUser *)user
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLFailureBlock)failureOrNil;

- (void)updateEmail:(NSString *)email
           password:(NSString *)password
    currentPassword:(NSString *)currentPassword
            success:(MRSLAPISuccessBlock)successOrNil
            failure:(MRSLFailureBlock)failureOrNil;

- (void)updateAutoFollow:(BOOL)shouldAutoFollow
                 success:(MRSLAPISuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

- (void)updateCurrentUserToProfessional:(BOOL)professional
                                success:(MRSLAPISuccessBlock)successOrNil
                                failure:(MRSLFailureBlock)failureOrNil;

- (void)updateUserImage:(MRSLUser *)user
                success:(MRSLAPISuccessBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil;

- (void)updatePhotoKey:(NSString *)photoKey
               forUser:(MRSLUser *)user
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil;

@end
