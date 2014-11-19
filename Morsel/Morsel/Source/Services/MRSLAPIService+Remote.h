//
//  MRSLAPIService+Remote.h
//  Morsel
//
//  Created by Javier Otero on 11/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Remote)

- (void)getUserDevicesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil;

- (void)createUserDeviceWithToken:(NSString *)deviceToken
                          success:(MRSLAPISuccessBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil;

- (void)updateUserDevice:(MRSLRemoteDevice *)remoteDevice
                 success:(MRSLAPISuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

- (void)deleteUserDeviceWithID:(NSNumber *)remoteDeviceID
                       success:(MRSLAPISuccessBlock)successOrNil
                       failure:(MRSLFailureBlock)failureOrNil;

@end
