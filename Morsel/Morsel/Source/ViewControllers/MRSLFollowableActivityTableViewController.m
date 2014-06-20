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
@property (copy, nonatomic) MRSLRemoteRequestBlock remoteRequestBlock;

@end

@implementation MRSLFollowableActivityTableViewController

- (void)viewDidLoad {
    self.objectIDsKey = [NSString stringWithFormat:@"%@_followableActivityIDs", [MRSLUser currentUser].username];
    self.tappedItemEventName = @"Tapped Followable Activity";
    self.tappedItemEventView = @"Followable Activity";

    self.remoteRequestBlock = ^(NSNumber *maxID, NSNumber *sinceID, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService getFollowablesActivitiesForUser:[MRSLUser currentUser]
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

@end
