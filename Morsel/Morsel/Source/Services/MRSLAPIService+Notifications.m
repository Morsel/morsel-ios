//
//  MRSLAPIService+Notifications.m
//  Morsel
//
//  Created by Javier Otero on 8/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Notifications.h"

#import "MRSLAPIClient.h"

#import "MRSLNotification.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Notifications)

- (void)getNotificationsForUser:(MRSLUser *)user
                          maxID:(NSNumber *)maxOrNil
                      orSinceID:(NSNumber *)sinceOrNil
                       andCount:(NSNumber *)countOrNil
                        success:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] performRequest:@"notifications"
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             [self importManagedObjectClass:[MRSLNotification class]
                                                             withDictionary:responseObject
                                                                    success:successOrNil
                                                                    failure:failureOrNil];
                                         } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

- (void)getUnreadCountWithSuccess:(MRSLAPICountBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] performRequest:@"notifications/unread_count"
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             int unreadCount = [responseObject[@"data"][@"unread_count"] intValue];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [[NSUserDefaults standardUserDefaults] setObject:@(unreadCount)
                                                                                           forKey:@"MRSLUserUnreadCount"];
                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidUpdateUnreadAmountNotification
                                                                                                     object:@(unreadCount)];
                                                 [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
                                             });
                                             if (successOrNil) return successOrNil(unreadCount);
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

- (void)markAllNotificationsReadSinceNotification:(MRSLNotification *)notification
                                          success:(MRSLSuccessBlock)successOrNil
                                          failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"max_id": NSNullIfNil(notification.notificationID)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    __block NSManagedObjectContext *workContext = nil;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        workContext = localContext;
        NSPredicate *unreadPredicate = [NSPredicate predicateWithFormat:@"read == NO"];
        NSArray *unreadNotifications = [MRSLNotification MR_findAllWithPredicate:unreadPredicate
                                                                       inContext:localContext];
        [unreadNotifications enumerateObjectsUsingBlock:^(MRSLNotification *unreadNotification, NSUInteger idx, BOOL *stop) {
            unreadNotification.read = @YES;
            unreadNotification.markedReadAt = [NSDate date];
        }];
    } completion:^(BOOL success, NSError *error) {
        [workContext reset];
    }];
    [[MRSLAPIClient sharedClient] multipartFormRequestString:@"notifications/mark_read"
                                                  withMethod:MRSLAPIMethodTypePUT
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         [MRSLUser API_updateNotificationsAmount:nil
                                                                                         failure:nil];
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)markNotificationRead:(MRSLNotification *)notification
                     success:(MRSLSuccessBlock)successOrNil
                     failure:(MRSLFailureBlock)failureOrNil {
    if (notification.readValue) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    notification.read = @YES;
    notification.markedReadAt = [NSDate date];
    [notification.managedObjectContext MR_saveOnlySelfAndWait];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"notifications/%i/mark_read", notification.notificationIDValue]
                                                  withMethod:MRSLAPIMethodTypePUT
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         [MRSLUser API_updateNotificationsAmount:nil
                                                                                         failure:nil];
                                                         if (successOrNil) successOrNil(YES);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

@end
