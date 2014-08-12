//
//  MRSLAPIService+Notifications.h
//  Morsel
//
//  Created by Javier Otero on 8/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@class MRSLNotification;

@interface MRSLAPIService (Notifications)

- (void)getNotificationsForUser:(MRSLUser *)user
                          maxID:(NSNumber *)maxOrNil
                      orSinceID:(NSNumber *)sinceOrNil
                       andCount:(NSNumber *)countOrNil
                        success:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil;

- (void)getUnreadCountWithSuccess:(MRSLAPICountBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil;

- (void)markAllNotificationsReadSinceNotification:(MRSLNotification *)notification
                                          success:(MRSLSuccessBlock)successOrNil
                                          failure:(MRSLFailureBlock)failureOrNil;

- (void)markNotificationRead:(MRSLNotification *)notification
                     success:(MRSLSuccessBlock)successOrNil
                     failure:(MRSLFailureBlock)failureOrNil;

@end
