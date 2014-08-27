//
//  MRSLMenuViewController.m
//  Morsel
//
//  Created by Javier Otero on 6/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMenuViewController.h"

#import "MRSLBadgeLabelView.h"
#import "MRSLMenuItem.h"
#import "MRSLMenuOptionTableViewCell.h"
#import "MRSLProfileImageView.h"
#import "MRSLSectionView.h"

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
                                             selector:@selector(clearUserInformation)
                                                 name:MRSLServiceDidLogOutUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenuBadge:)
                                                 name:MRSLServiceDidUpdateUnreadAmountNotification
                                               object:nil];

    [self setupMenuOptions];
    [self.menuTableView setScrollsToTop:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.menuTableView reloadData];
    });
}

#pragma mark - Private Methods

- (void)setupMenuOptions {
    MRSLMenuItem *itemNewMorsel = [[MRSLMenuItem alloc] initWithName:@"New morsel"
                                                                 key:MRSLMenuAddKey
                                                                icon:@"icon-menu-morseladd"];
    MRSLMenuItem *itemDrafts = [[MRSLMenuItem alloc] initWithName:@"Drafts"
                                                              key:MRSLMenuDraftsKey
                                                             icon:@"icon-menu-morseldrafts"];

    MRSLMenuItem *itemFeed = [[MRSLMenuItem alloc] initWithName:@"Feed"
                                                            key:MRSLMenuFeedKey
                                                           icon:@"icon-menu-feed"];
    MRSLMenuItem *itemNotifications = [[MRSLMenuItem alloc] initWithName:@"Notifications"
                                                                     key:MRSLMenuNotificationsKey
                                                                    icon:@"icon-menu-notifications"];
    MRSLMenuItem *itemActivity = [[MRSLMenuItem alloc] initWithName:@"Activity"
                                                                key:MRSLMenuActivityKey
                                                               icon:@"icon-menu-activity"];
    MRSLMenuItem *itemFindFriends = [[MRSLMenuItem alloc] initWithName:@"Find people"
                                                                   key:MRSLMenuFindKey
                                                                  icon:@"icon-menu-find"];
    MRSLMenuItem *itemSettings = [[MRSLMenuItem alloc] initWithName:@"Settings"
                                                                key:MRSLMenuSettingsKey
                                                               icon:@"icon-menu-settings"];

    self.menuOptions = @[
                         @{
                             @"name": @"",
                             @"options": @[
                                     itemNewMorsel,
                                     itemDrafts
                                     ]
                             }, @{
                             @"name": @"",
                             @"options": @[
                                     itemFeed,
                                     itemNotifications,
                                     itemActivity,
                                     itemFindFriends,
                                     itemSettings
                                     ]
                             }
                         ];
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

- (void)updateContent:(NSNotification *)notification {
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSSet *updatedObjects = [userInfoDictionary objectForKey:NSUpdatedObjectsKey];
    __weak __typeof(self) weakSelf = self;
    [updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject *managedObject, BOOL *stop) {
        if ([managedObject isKindOfClass:[MRSLUser class]]) {
            MRSLUser *user = (MRSLUser *)managedObject;
            if ([user isCurrentUser]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf displayUserInformation];
                });
            }
        }
    }];
}

- (void)updateMenuBadge:(NSNotification *)notification {
    NSIndexPath *notificationsIndexPath = [self indexPathForKey:MRSLMenuNotificationsKey];
    MRSLMenuItem *notificationItem = [self menuItemAtIndexPath:notificationsIndexPath];
    notificationItem.badgeCount = [notification.object intValue];
    [self.menuTableView reloadRowsAtIndexPaths:@[notificationsIndexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    [self.menuTableView selectRowAtIndexPath:_selectedIndexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
}

- (void)displayUserInformation {
    MRSLUser *currentUser = [MRSLUser currentUser];
    self.profileImageView.user = currentUser;
    self.userNameLabel.text = [currentUser fullName];
    NSIndexPath *draftIndexPath = [self indexPathForKey:MRSLMenuDraftsKey];
    MRSLMenuItem *draftItem = [self menuItemAtIndexPath:draftIndexPath];
    draftItem.badgeCount = currentUser.draft_countValue;
    [self.menuTableView reloadRowsAtIndexPaths:@[draftIndexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    [self.menuTableView selectRowAtIndexPath:_selectedIndexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
}

- (void)clearUserInformation {
    self.profileImageView.user = nil;
    self.userNameLabel.text = @"";
}

- (void)presentFeed:(NSNotification *)notification {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf selectRowWithKey:MRSLMenuFeedKey];
    });
}

#pragma mark - Utility Methods

- (NSArray *)arrayForSection:(NSInteger)section {
    return [self.menuOptions objectAtIndex:section][@"options"];
}

- (MRSLMenuItem *)menuItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForKey:(NSString *)searchKey {
    NSIndexPath *keyIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    for (NSDictionary *menuOptionDictionary in self.menuOptions) {
        for (MRSLMenuItem *menuItem in menuOptionDictionary[@"options"]) {
            if ([searchKey isEqualToString:menuItem.key]) {
                keyIndexPath = [NSIndexPath indexPathForRow:[menuOptionDictionary[@"options"] indexOfObject:menuItem] inSection:[self.menuOptions indexOfObject:menuOptionDictionary]];
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
    return section == 0 ? 0.0f : 34.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [MRSLSectionView sectionViewWithTitle:[[self.menuOptions objectAtIndex:section][@"name"] uppercaseString]];
}

- (MRSLMenuOptionTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMenuItem *menuItem = [self menuItemAtIndexPath:indexPath];
    MRSLMenuOptionTableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDMenuOptionCellKey];
    tableViewCell.optionNameLabel.text = menuItem.name;
    tableViewCell.iconImageView.image = [UIImage imageNamed:menuItem.iconImageName];
    tableViewCell.badgeCount = menuItem.badgeCount;
    return tableViewCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    NSString *menuOptionKey = [self menuItemAtIndexPath:indexPath].key;
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
