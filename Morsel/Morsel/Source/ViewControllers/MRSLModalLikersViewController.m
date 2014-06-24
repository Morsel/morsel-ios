//
//  MRSLModalLikesViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLModalLikersViewController.h"

#import "MRSLAPIService+Like.h"

#import "MRSLUserFollowTableViewCell.h"
#import "MRSLProfileViewController.h"

@interface MRSLModalLikersViewController ()
<UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *likersTableView;

@property (strong, nonatomic) NSMutableArray *likers;

@end

@implementation MRSLModalLikersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.likers = [NSMutableArray array];

    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService getItemLikes:_item
                                      success:^(NSArray *responseArray) {
                                          if (weakSelf) {
                                              [weakSelf.likers addObjectsFromArray:responseArray];
                                              [weakSelf.likersTableView reloadData];
                                          }
                                      } failure:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_likers count];
}

- (MRSLUserFollowTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLUser *user = [_likers objectAtIndex:indexPath.row];

    MRSLUserFollowTableViewCell *likerCell = [tableView dequeueReusableCellWithIdentifier:@"ruid_UserFollowCell"];
    likerCell.user = user;
    likerCell.pipeView.hidden = (indexPath.row == [_likers count] - 1);

    return likerCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLUser *user = [_likers objectAtIndex:indexPath.row];
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileViewController"];
    profileVC.user = user;
    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

#pragma mark - Dealloc

- (void)dealloc {
    self.likersTableView.dataSource = nil;
    self.likersTableView.delegate = nil;
    [self.likersTableView removeFromSuperview];
    self.likersTableView = nil;
}

@end
