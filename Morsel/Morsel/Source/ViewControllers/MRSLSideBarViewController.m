//
//  MRSLSideBarViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSideBarViewController.h"

#import "ProfileImageView.h"
#import "SideBarItemCell.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLSideBarViewController ()
    <UITableViewDataSource,
     UITableViewDelegate>

@property (nonatomic) NSUInteger draftCount;

@property (weak, nonatomic) IBOutlet UITableView *sideBarTableView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@property (nonatomic, strong) SideBarItem *draftItem;

@property (nonatomic, strong) NSMutableArray *sideBarItems;

@end

@implementation MRSLSideBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.profileImageView addCornersWithRadius:20.f];
    [self.profileImageView setBorderWithColor:[UIColor whiteColor]
                                     andWidth:2.f];
    
    SideBarItem *homeItem = [SideBarItem sideBarItemWithTitle:@"Feed"
                                                iconImageName:@"icon-sidebar-home"
                                               cellIdentifier:@"SideBarItemCell"
                                                         type:SideBarMenuItemTypeHome];
    
    SideBarItem *draftItem = [SideBarItem sideBarItemWithTitle:@"Drafts"
                                                 iconImageName:@"icon-sidebar-draft"
                                                cellIdentifier:@"SideBarDraftCell"
                                                          type:SideBarMenuItemTypeDrafts];

    self.draftItem = draftItem;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:)
                                                 name:MRSLServiceDidLogInUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:)
                                                 name:MRSLServiceDidLogOutUserNotification
                                               object:nil];
    
    self.sideBarItems = [NSMutableArray arrayWithObjects:draftItem, homeItem, nil];
}

#pragma mark - NSNotification

- (void)userLoggedIn:(NSNotification *)notification {
    self.userNameLabel.text = [MRSLUser currentUser].fullName;
    self.profileImageView.user = [MRSLUser currentUser];
    self.draftItem.badgeCount = [MRSLUser currentUser].draft_countValue;

    [self.sideBarTableView reloadData];
}

- (void)userLoggedOut:(NSNotification *)notification {
    self.userNameLabel.text = nil;
    self.profileImageView.user = nil;
}

#pragma mark - Action

- (IBAction)hideSideBar {
    if ([self.delegate respondsToSelector:@selector(sideBarDidSelectMenuItemOfType:)]) {
        [self.delegate sideBarDidSelectMenuItemOfType:SideBarMenuItemTypeHide];
    }
}

- (IBAction)displayUserProfile {
    if ([self.delegate respondsToSelector:@selector(sideBarDidSelectMenuItemOfType:)]) {
        [self.delegate sideBarDidSelectMenuItemOfType:SideBarMenuItemTypeProfile];
    }
}

- (IBAction)logout {
    if ([self.delegate respondsToSelector:@selector(sideBarDidSelectMenuItemOfType:)]) {
        [self.delegate sideBarDidSelectMenuItemOfType:SideBarMenuItemTypeLogout];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sideBarItems count];
}

- (SideBarItemCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideBarItem *sideBarItem = [_sideBarItems objectAtIndex:indexPath.row];
    SideBarItemCell *sideBarCell = [tableView dequeueReusableCellWithIdentifier:sideBarItem.cellIdentifier];
    sideBarCell.sideBarItem = sideBarItem;
    
    return sideBarCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SideBarItem *sideBarItem = [_sideBarItems objectAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(sideBarDidSelectMenuItemOfType:)]) {
        [self.delegate sideBarDidSelectMenuItemOfType:sideBarItem.menuType];
    }
}

#pragma mark - Destruction

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
