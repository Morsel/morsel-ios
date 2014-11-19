//
//  MRSLAPIService+Remote.m
//  Morsel
//
//  Created by Javier Otero on 11/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Remote.h"

#import "MRSLAPIClient.h"

#import "MRSLRemoteDevice.h"

@implementation MRSLAPIService (Remote)

- (void)getUserDevicesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] performRequest:@"users/devices"
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             [self importManagedObjectClass:[MRSLRemoteDevice class]
                                                             withDictionary:responseObject
                                                                    success:successOrNil
                                                                    failure:failureOrNil];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

- (void)createUserDeviceWithToken:(NSString *)deviceToken
                          success:(MRSLAPISuccessBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"device" : @{@"name" : NSNullIfNil([[UIDevice currentDevice] name]),
                                                                                     @"model" : NSNullIfNil([[UIDevice currentDevice] model]),
                                                                                     @"token" : NSNullIfNil(deviceToken)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:@"users/devices"
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         MRSLRemoteDevice *remoteDevice = [MRSLRemoteDevice MR_findFirstByAttribute:MRSLRemoteDeviceAttributes.deviceID
                                                                                                                          withValue:responseObject[@"data"][@"id"]];
                                                         if (!remoteDevice) remoteDevice = [MRSLRemoteDevice MR_createEntity];
                                                         [remoteDevice MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         [[NSUserDefaults standardUserDefaults] setObject:remoteDevice.deviceID
                                                                                                   forKey:@"deviceID"];
                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                         if (successOrNil) successOrNil(remoteDevice);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)updateUserDevice:(MRSLRemoteDevice *)remoteDevice
                 success:(MRSLAPISuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[remoteDevice]
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"users/devices/%i", remoteDevice.deviceIDValue]
                                                  withMethod:MRSLAPIMethodTypePUT
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         MRSLRemoteDevice *remoteDevice = [MRSLRemoteDevice MR_findFirstByAttribute:MRSLRemoteDeviceAttributes.deviceID
                                                                                                                          withValue:responseObject[@"data"][@"id"]];
                                                         if (!remoteDevice) remoteDevice = [MRSLRemoteDevice MR_createEntity];
                                                         [remoteDevice MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         [[NSUserDefaults standardUserDefaults] setObject:remoteDevice.deviceID
                                                                                                   forKey:@"deviceID"];
                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                         if (successOrNil) successOrNil(remoteDevice);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)deleteUserDeviceWithID:(NSNumber *)remoteDeviceID
                       success:(MRSLAPISuccessBlock)successOrNil
                       failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    NSPredicate *remotePredicate = [NSPredicate predicateWithFormat:@"deviceID == %@", remoteDeviceID];
    [MRSLRemoteDevice MR_deleteAllMatchingPredicate:remotePredicate
                                          inContext:[NSManagedObjectContext MR_defaultContext]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    [[NSUserDefaults standardUserDefaults] setObject:@(-1)
                                              forKey:@"deviceID"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"users/devices/%@", remoteDeviceID]
                                                  withMethod:MRSLAPIMethodTypeDELETE
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
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
