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
               failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)updateUser:(MRSLUser *)user
           success:(MRSLAPISuccessBlock)userSuccessOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

@end
