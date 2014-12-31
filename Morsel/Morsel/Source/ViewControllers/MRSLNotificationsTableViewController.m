//
//  MRSLNotificationsTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 7/10/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLNotificationsTableViewController.h"

#import "MRSLTableViewDataSource.h"
#import "MRSLActivity.h"

#import "MRSLAPIService+Notifications.h"

#import "MRSLUser.h"

@interface MRSLBaseTableViewController ()
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSString *objectIDsKey;
@property (strong, nonatomic) NSArray *objectIDs;
@property (copy, nonatomic) MRSLRemotePagedRequestBlock pagedRemoteRequestBlock;

@end

@interface MRSLBaseActivitiesTableViewController ()

@property (strong, nonatomic) MRSLTableViewDataSource *dataSource;
@property (strong, nonatomic) NSString *tappedItemEventName;
@property (strong, nonatomic) NSString *tappedItemEventView;

- (void)refreshContent;

@end

@implementation MRSLNotificationsTableViewController

- (void)viewDidLoad {
    self.objectIDsKey = [NSString stringWithFormat:@"%@_notificationActivityIDs", [MRSLUser currentUser].username];
    self.tappedItemEventName = @"Tapped Notification";
    self.tappedItemEventView = @"Notifications";

    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService getNotificationsForUser:[MRSLUser currentUser]
                                                    page:page
                                                   count:count
                                                 success:^(NSArray *responseArray) {
                                                     remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                 } failure:^(NSError *error) {
                                                     remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                 }];
    };

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshNotifications)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [MRSLUser API_updateNotificationsAmount:nil
                                    failure:nil];

    [super viewDidLoad];
}

#pragma mark - NSNotification Methods

- (void)refreshNotifications {
    [self refreshContent];
}

#pragma mark - MRSLBaseTableViewController Methods

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return [MRSLActivity MR_fetchAllSortedBy:@"notification.notificationID"
                                   ascending:NO
                               withPredicate:[NSPredicate predicateWithFormat:@"notification.notificationID IN %@", self.objectIDs]
                                     groupBy:nil
                                    delegate:self
                                   inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (NSString *)emptyStateTitle {
    return @"No notifications yet!";
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    int unreadCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MRSLUserUnreadCount"] intValue];
    if (unreadCount > 0) {
        MRSLActivity *latestActivity = [self.dataSource objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [_appDelegate.apiService markAllNotificationsReadSinceNotification:latestActivity.notification
                                                                   success:nil
                                                                   failure:nil];
    }
}

@end
