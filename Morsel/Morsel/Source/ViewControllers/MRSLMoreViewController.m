//
//  MRSLMoreViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMoreViewController.h"

#import "MRSLProfileImageView.h"
#import "MRSLProfileViewController.h"
#import "MRSLMoreItem.h"
#import "MRSLMoreItemCell.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMoreViewController ()
<UITableViewDataSource,
UITableViewDelegate,
ProfileImageViewDelegate>

@property (nonatomic) NSUInteger draftCount;

@property (weak, nonatomic) IBOutlet UITableView *sideBarTableView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) MRSLMoreItem *draftItem;

@property (strong, nonatomic) NSMutableArray *sideBarItems;

@end

@implementation MRSLMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.versionLabel.text = [MRSLUtil appVersionBuildString];

    [_profileImageView addCornersWithRadius:20.f];
    [_profileImageView setBorderWithColor:[UIColor whiteColor]
                                     andWidth:1.f];
    _profileImageView.delegate = self;

    MRSLMoreItem *logoutItem = [MRSLMoreItem sideBarItemWithTitle:@"Logout"
                                                   iconImageName:@"icon-sidebar-logout"
                                                  cellIdentifier:@"ruid_SideBarItemCell"
                                                            type:SideBarMenuItemTypeLogout];

    self.sideBarItems = [NSMutableArray arrayWithObjects:logoutItem, nil];

    [self.sideBarTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.profileImageView.user = [MRSLUser currentUser];
    self.userNameLabel.text = [MRSLUser currentUser].fullName;
}

#pragma mark - Action

- (IBAction)logout {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceShouldLogOutUserNotification
                                                        object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sideBarItems count];
}

- (MRSLMoreItemCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMoreItem *sideBarItem = [_sideBarItems objectAtIndex:indexPath.row];
    MRSLMoreItemCell *sideBarCell = [tableView dequeueReusableCellWithIdentifier:sideBarItem.cellIdentifier];
    sideBarCell.sideBarItem = sideBarItem;

    return sideBarCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMoreItem *moreItem = [_sideBarItems objectAtIndex:indexPath.row];

    switch (moreItem.menuType) {
        case SideBarMenuItemTypeLogout:
            [[MRSLEventManager sharedManager] track:@"Tapped Logout Icon"
                                         properties:@{@"view": @"More"}];
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceShouldLogOutUserNotification
                                                                object:nil];
            break;
        default:
            break;
    }
}


#pragma mark - ProfileImageViewDelegate

- (void)profileImageViewDidSelectUser:(MRSLUser *)user {
    [[MRSLEventManager sharedManager] track:@"Tapped Profile Icon"
                                 properties:@{@"view": @"More"}];
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_ProfileViewController"];
    profileVC.user = user;

    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

#pragma mark - Destruction

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
