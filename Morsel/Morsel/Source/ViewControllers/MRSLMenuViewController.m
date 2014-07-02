//
//  MRSLMenuViewController.m
//  Morsel
//
//  Created by Javier Otero on 6/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMenuViewController.h"

#import "MRSLBadgeLabelView.h"
#import "MRSLMenuOptionTableViewCell.h"
#import "MRSLProfileImageView.h"
#import "MRSLRobotoBoldLabel.h"

#import "MRSLUser.h"

@interface MRSLMenuViewController ()
<UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@property (strong, nonatomic) NSArray *menuOptions;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation MRSLMenuViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentFeed:)
                                                 name:MRSLUserDidPublishMorselNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentFeed:)
                                                 name:MRSLServiceDidLogInUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayUserInformation)
                                                 name:MRSLServiceDidLogInUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayUserInformation)
                                                 name:MRSLUserDidUpdateUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearUserInformation)
                                                 name:MRSLServiceDidLogOutUserNotification
                                               object:nil];
    [self setupMenuOptions];
    [self.menuTableView setScrollsToTop:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.menuTableView reloadData];
    });
}

#pragma mark - Private Methods

- (void)setupMenuOptions {
    self.menuOptions = @[@{@"name": @"Create",
                           @"options": @[
                                   @{@"name": @"Create New Morsel!",
                                     @"key": MRSLMenuAddKey,
                                     @"icon": @"icon-menu-morseladd",
                                     @"showsBadge": @NO},
                                   @{@"name": @"Drafts",
                                     @"key": MRSLMenuDraftsKey,
                                     @"icon": @"icon-menu-morseldrafts",
                                     @"showsBadge": @YES}]},
                         @{@"name": @"Feeds / Activity",
                           @"options": @[
                                   @{@"name": @"Morsel Feed",
                                     @"key": MRSLMenuFeedKey,
                                     @"icon": @"icon-menu-feed",
                                     @"showsBadge": @NO},
                                   @{@"name": @"Notifications",
                                     @"key": MRSLMenuNotificationsKey,
                                     @"icon": @"icon-menu-notifications",
                                     @"showsBadge": @YES}]},
                         @{@"name": @"Following",
                           @"options": @[
//                                   @{@"name": @"Restaurants",
//                                     @"key": MRSLMenuPlacesKey,
//                                     @"icon": @"icon-menu-places",
//                                     @"showsBadge": @NO},
                                   @{@"name": @"People",
                                     @"key": MRSLMenuPeopleKey,
                                     @"icon": @"icon-menu-people",
                                     @"showsBadge": @NO},
                                   @{@"name": @"Find Friends",
                                     @"key": MRSLMenuFindKey,
                                     @"icon": @"icon-menu-find",
                                     @"showsBadge": @NO}]},
                         @{@"name": @"Other",
                           @"options": @[
                                   @{@"name": @"Settings",
                                     @"key": MRSLMenuSettingsKey,
                                     @"icon": @"icon-menu-settings",
                                     @"showsBadge": @NO}]}];
}

#pragma mark - Action Methods

- (IBAction)displayProfile {
    if ([self.delegate respondsToSelector:@selector(menuViewControllerDidSelectMenuOption:)]) {
        [self.delegate menuViewControllerDidSelectMenuOption:MRSLMenuProfileKey];
        if (self.selectedIndexPath) {
            [self.menuTableView deselectRowAtIndexPath:_selectedIndexPath
                                              animated:NO];
            self.selectedIndexPath = nil;
        }
    }
}

- (IBAction)collapseMenu {
    if ([self.delegate respondsToSelector:@selector(menuViewControllerDidSelectMenuOption:)]) {
        [self.delegate menuViewControllerDidSelectMenuOption:nil];
    }
}

#pragma mark - Notification Methods

- (void)displayUserInformation {
    MRSLUser *currentUser = [MRSLUser currentUser];
    self.profileImageView.user = currentUser;
    self.userNameLabel.text = [currentUser fullName];
}

- (void)clearUserInformation {
    self.profileImageView.user = nil;
    self.userNameLabel.text = @"";
}

- (void)presentFeed:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self selectRowWithKey:MRSLMenuFeedKey];
    });
}

#pragma mark - Utility Methods

- (NSArray *)arrayForSection:(NSInteger)section {
    return [self.menuOptions objectAtIndex:section][@"options"];
}

- (NSDictionary *)menuOptionAtIndexPath:(NSIndexPath *)indexPath {
    return [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForKey:(NSString *)searchKey {
    NSIndexPath *keyIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    for (NSDictionary *menuOptionDictionary in self.menuOptions) {
        for (NSDictionary *menuOption in menuOptionDictionary[@"options"]) {
            if ([searchKey isEqualToString:menuOption[@"key"]]) {
                keyIndexPath = [NSIndexPath indexPathForRow:[menuOptionDictionary[@"options"] indexOfObject:menuOption] inSection:[self.menuOptions indexOfObject:menuOptionDictionary]];
                break;
            }
        }
    }
    return keyIndexPath;
}

- (void)selectRowWithKey:(NSString *)key {
    NSIndexPath *indexPath = [self indexPathForKey:key];
    [self.menuTableView selectRowAtIndexPath:indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.menuTableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.menuOptions count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self arrayForSection:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MRSLRobotoBoldLabel *boldLabel = [[MRSLRobotoBoldLabel alloc] initWithFrame:CGRectMake(16.f, 5.f, 240.f, 14.f)
                                                                    andFontSize:12.f];
    boldLabel.text = [[self.menuOptions objectAtIndex:section][@"name"] uppercaseString];
    boldLabel.textColor = [UIColor morselRed];
    boldLabel.backgroundColor = [UIColor clearColor];

    UIView *menuOptionHeader = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 24.f)];
    [menuOptionHeader setBackgroundColor:[UIColor colorWithWhite:1.f
                                                           alpha:.4f]];
    [menuOptionHeader addSubview:boldLabel];
    return menuOptionHeader;
}

- (MRSLMenuOptionTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *menuOption = [self menuOptionAtIndexPath:indexPath];
    MRSLMenuOptionTableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"ruid_MenuOptionCell"];
    [tableViewCell reset];
    tableViewCell.optionNameLabel.text = menuOption[@"name"];
    tableViewCell.iconImageView.image = [UIImage imageNamed:menuOption[@"icon"]];
    tableViewCell.badgeLabelView.hidden = YES;
    tableViewCell.pipeView.hidden = ([[self arrayForSection:indexPath.section] count] - 1 == indexPath.row);
    return tableViewCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    NSString *menuOptionKey = [self menuOptionAtIndexPath:indexPath][@"key"];
    if ([self.delegate respondsToSelector:@selector(menuViewControllerDidSelectMenuOption:)]) {
        [self.delegate menuViewControllerDidSelectMenuOption:menuOptionKey];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    self.menuTableView.dataSource = nil;
    self.menuTableView.delegate = nil;
    [self.menuTableView removeFromSuperview];
    self.menuTableView = nil;
}

@end
