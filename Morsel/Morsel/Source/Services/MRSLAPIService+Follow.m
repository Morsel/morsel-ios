//
//  MRSLAPIService+Follow.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Follow.h"

#import "MRSLUser.h"

@implementation MRSLAPIService (Follow)

#pragma mark - Follow Services

- (void)followUser:(MRSLUser *)user
      shouldFollow:(BOOL)shouldFollow
         didFollow:(MRSLAPIFollowBlock)followBlockOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (shouldFollow) {
        user.follower_count = @(user.follower_countValue + 1);
        [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"users/%i/follow", user.userIDValue]
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       if (followBlockOrNil) followBlockOrNil(YES);
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                       if ([operation.response statusCode] == 200 || [serviceErrorInfo.errorInfo isEqualToString:@"User: already followed"]) {
                                           if (followBlockOrNil) followBlockOrNil(YES);
                                       } else {
                                           [self reportFailure:failureOrNil
                                                     withError:error
                                                      inMethod:NSStringFromSelector(_cmd)];
                                       }
                                   }];
    } else {
        user.follower_count = @(user.follower_countValue - 1);
        [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"users/%i/follow", user.userIDValue]
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if (followBlockOrNil) followBlockOrNil(NO);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                         if ([operation.response statusCode] == 200  || [serviceErrorInfo.errorInfo isEqualToString:@"User: not followed"]) {
                                             if (followBlockOrNil) followBlockOrNil(NO);
                                         } else {
                                             [self reportFailure:failureOrNil
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }
                                     }];
    }
}

- (void)getUserFollowers:(MRSLUser *)user
               withMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;
    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/followers", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importUsersWithDictionary:responseObject
                                                          success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserFollowables:(MRSLUser *)user
                 withMaxID:(NSNumber *)maxOrNil
                 orSinceID:(NSNumber *)sinceOrNil
                  andCount:(NSNumber *)countOrNil
                   success:(MRSLAPIArrayBlock)successOrNil
                   failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"type": @"User"}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;
    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/followables", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importUsersWithDictionary:responseObject
                                                          success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

@end
