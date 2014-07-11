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

#import "MRSLAPIService+Activity.h"

#import "MRSLUser.h"

@interface MRSLBaseTableViewController ()
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSString *objectIDsKey;
@property (strong, nonatomic) NSArray *objectIDs;

- (NSFetchedResultsController *)defaultFetchedResultsController;

@end

@interface MRSLBaseActivitiesTableViewController ()

@property (nonatomic, strong) NSString *tappedItemEventName;
@property (nonatomic, strong) NSString *tappedItemEventView;
@property (copy, nonatomic) MRSLRemoteRequestBlock remoteRequestBlock;

@end

@implementation MRSLNotificationsTableViewController

- (void)viewDidLoad {
    self.objectIDsKey = [NSString stringWithFormat:@"%@_notificationActivityIDs", [MRSLUser currentUser].username];
    self.tappedItemEventName = @"Tapped Notification";
    self.tappedItemEventView = @"Notifications";

    self.remoteRequestBlock = ^(NSNumber *maxID, NSNumber *sinceID, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService getUserNotificationsForUser:[MRSLUser currentUser]
                                                       maxID:maxID
                                                   orSinceID:sinceID
                                                    andCount:count
                                                     success:^(NSArray *responseArray) {
                                                         remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                     } failure:^(NSError *error) {
                                                         remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                     }];
    };

    [super viewDidLoad];
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

@end
