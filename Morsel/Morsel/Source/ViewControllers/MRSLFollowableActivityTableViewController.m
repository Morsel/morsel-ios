//
//  MRSLFollowableActivityTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//
//

#import "MRSLFollowableActivityTableViewController.h"

#import "MRSLAPIService+Activity.h"

#import "MRSLUser.h"

@interface MRSLBaseTableViewController ()

@property (strong, nonatomic) NSString *objectIDsKey;
@property (strong, nonatomic) NSArray *objectIDs;
@property (copy, nonatomic) MRSLRemotePagedRequestBlock pagedRemoteRequestBlock;

@end

@interface MRSLBaseActivitiesTableViewController ()

@property (strong, nonatomic) NSString *tappedItemEventName;
@property (strong, nonatomic) NSString *tappedItemEventView;

@end

@implementation MRSLFollowableActivityTableViewController

- (void)viewDidLoad {
    self.objectIDsKey = [NSString stringWithFormat:@"%@_followableActivityIDs", [MRSLUser currentUser].username];
    self.tappedItemEventName = @"Tapped Followable Activity";
    self.tappedItemEventView = @"Followable Activity";

    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService getFollowablesActivitiesForUser:[MRSLUser currentUser]
                                                            page:page
                                                           count:count
                                                         success:^(NSArray *responseArray) {
                                                             remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                         } failure:^(NSError *error) {
                                                             remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                         }];
    };

    [super viewDidLoad];
}

@end
