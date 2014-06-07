//
//  MRSLAPIService+Activity.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Activity.h"

#import "MRSLActivity.h"
#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLNotification.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Activity)

#pragma mark - Activity Services

- (void)getUserActivitiesForUser:(MRSLUser *)user
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

    [[MRSLAPIClient sharedClient] GET:@"users/activities"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *activityIDs = [NSMutableArray array];
                                      NSArray *activityArray = responseObject[@"data"];
                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [activityArray enumerateObjectsUsingBlock:^(NSDictionary *activityDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLActivity *activity = [MRSLActivity MR_findFirstByAttribute:MRSLActivityAttributes.activityID
                                                                                                   withValue:activityDictionary[@"id"]
                                                                                                   inContext:localContext];
                                              if (!activity) activity = [MRSLActivity MR_createInContext:localContext];
                                              [activity MR_importValuesForKeysWithObject:activityDictionary];
                                              [localContext MR_saveOnlySelfAndWait];
                                              [activityIDs addObject:activityDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(activityIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUserNotificationsForUser:(MRSLUser *)user
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

    [[MRSLAPIClient sharedClient] GET:@"users/notifications"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *notificationIDs = [NSMutableArray array];
                                      NSArray *notificationArray = responseObject[@"data"];
                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [notificationArray enumerateObjectsUsingBlock:^(NSDictionary *notificationDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLNotification *notification = [MRSLNotification MR_findFirstByAttribute:MRSLNotificationAttributes.notificationID
                                                                                                               withValue:notificationDictionary[@"id"]
                                                                                                               inContext:localContext];
                                              if (!notification) notification = [MRSLNotification MR_createInContext:localContext];
                                              [notification MR_importValuesForKeysWithObject:notificationDictionary];
                                              [localContext MR_saveOnlySelfAndWait];
                                              [notificationIDs addObject:notificationDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(notificationIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

@end
