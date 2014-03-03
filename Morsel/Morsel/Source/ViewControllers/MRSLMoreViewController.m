//
//  MRSLMoreViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMoreViewController.h"

#import "MRSLProfileImageView.h"
#import "MRSLMoreItem.h"
#import "MRSLMoreItemCell.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMoreViewController ()
    <UITableViewDataSource,
     UITableViewDelegate>

@property (nonatomic) NSUInteger draftCount;

@property (weak, nonatomic) IBOutlet UITableView *sideBarTableView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (nonatomic, strong) MRSLMoreItem *draftItem;

@property (nonatomic, strong) NSMutableArray *sideBarItems;

@end

@implementation MRSLMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.versionLabel.text = [MRSLUtil appVersionBuildString];
    
    [self.profileImageView addCornersWithRadius:20.f];
    [self.profileImageView setBorderWithColor:[UIColor whiteColor]
                                     andWidth:1.f];
    
    MRSLMoreItem *homeItem = [MRSLMoreItem sideBarItemWithTitle:@"Feed"
                                                iconImageName:@"icon-sidebar-home"
                                               cellIdentifier:@"ruid_SideBarItemCell"
                                                         type:SideBarMenuItemTypeHome];
    
    MRSLMoreItem *draftItem = [MRSLMoreItem sideBarItemWithTitle:@"Drafts"
                                                 iconImageName:@"icon-sidebar-edit"
                                                cellIdentifier:@"ruid_SideBarDraftCell"
                                                          type:SideBarMenuItemTypeDrafts];

    self.draftItem = draftItem;
    
    self.sideBarItems = [NSMutableArray arrayWithObjects:draftItem, homeItem, nil];

    self.userNameLabel.text = [MRSLUser currentUser].fullName;
    self.profileImageView.user = [MRSLUser currentUser];
    self.draftItem.badgeCount = [MRSLUser currentUser].draft_countValue;

    [self.sideBarTableView reloadData];
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
    //SideBarItem *sideBarItem = [_sideBarItems objectAtIndex:indexPath.row];

    // Display content based on type: sideBarItem.menuType
}

#pragma mark - Destruction

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
