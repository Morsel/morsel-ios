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

@end

@interface MRSLBaseActivitiesTableViewController ()

@property (nonatomic, strong) NSString *tappedItemEventName;
@property (nonatomic, strong) NSString *tappedItemEventView;

- (void)refreshContent;
- (void)setupFetchRequest;
- (void)populateContent;

@end

@implementation MRSLFollowableActivityTableViewController

- (void)viewDidLoad {
    self.objectIDsKey = [NSString stringWithFormat:@"%@_followableActivityIDs", [MRSLUser currentUser].username];
    self.tappedItemEventName = @"Tapped Followable Activity";
    self.tappedItemEventView = @"Followable Activity";

    [super viewDidLoad];
}

- (void)refreshContent {
    __weak typeof(self) weakSelf = self;
    [_appDelegate.apiService getFollowablesActivitiesForUser:[MRSLUser currentUser]
                                                       maxID:nil
                                                   orSinceID:nil
                                                    andCount:nil
                                                     success:^(NSArray *responseArray) {
                                                         weakSelf.objectIDs = [responseArray copy];
                                                         [weakSelf setupFetchRequest];
                                                         [weakSelf populateContent];
                                                     } failure:nil];
}

@end
