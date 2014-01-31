//
//  MRSLSideBarViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSideBarViewController.h"

#import "ModelController.h"

#import "ProfileImageView.h"
#import "SideBarItem.h"
#import "SideBarItemCell.h"

#import "MRSLUser.h"

@interface MRSLSideBarViewController ()
    <UITableViewDataSource,
     UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *sideBarTableView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@property (nonatomic, strong) SideBarItem *draftSideBarItem;

@property (nonatomic, strong) NSMutableArray *sideBarItems;

@end

@implementation MRSLSideBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.profileImageView addCornersWithRadius:20.f];
    [self.profileImageView setBorderWithColor:[UIColor whiteColor]
                                     andWidth:2.f];
    
    SideBarItem *homeItem = [SideBarItem sideBarItemWithTitle:@"Home"
                                                iconImageName:@"icon-sidebar-home"
                                                     cellType:@"SideBarItemCell"];
    
    SideBarItem *draftItem = [SideBarItem sideBarItemWithTitle:@"Drafts"
                                                 iconImageName:@"icon-sidebar-draft"
                                                      cellType:@"SideBarDraftCell"];
    self.draftSideBarItem = draftItem;
    
    // Check for drafts with FetchRequest, if they exist, inject in sidebar item. If they don't, remove.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:)
                                                 name:MRSLServiceDidLogInUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:)
                                                 name:MRSLServiceDidLogOutUserNotification
                                               object:nil];
    
    self.sideBarItems = [NSMutableArray arrayWithObjects:homeItem, nil];
}

#pragma mark - NSNotification

- (void)userLoggedIn:(NSNotification *)notification {
    self.userNameLabel.text = [ModelController sharedController].currentUser.fullName;
    self.profileImageView.user = [ModelController sharedController].currentUser;
}

- (void)userLoggedOut:(NSNotification *)notification {
    self.userNameLabel.text = nil;
    self.profileImageView.user = nil;
}

#pragma mark - Action

- (IBAction)hideSideBar {
    if ([self.delegate respondsToSelector:@selector(sideBarDidSelectHideSideBar)]) {
        [self.delegate sideBarDidSelectHideSideBar];
    }
}

- (IBAction)displayUserProfile {
    if ([self.delegate respondsToSelector:@selector(sideBarDidSelectDisplayProfile)]) {
        [self.delegate sideBarDidSelectDisplayProfile];
    }
}

- (IBAction)logout {
    if ([self.delegate respondsToSelector:@selector(sideBarDidSelectLogout)]) {
        [self.delegate sideBarDidSelectLogout];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sideBarItems count];
}

- (SideBarItemCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideBarItem *sideBarItem = [_sideBarItems objectAtIndex:indexPath.row];
    SideBarItemCell *sideBarCell = [tableView dequeueReusableCellWithIdentifier:sideBarItem.preferredCellType];
    sideBarCell.sideBarItem = sideBarItem;
    return sideBarCell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SideBarItem *sideBarItem = [_sideBarItems objectAtIndex:indexPath.row];
    if ([sideBarItem.title isEqualToString:@"Home"]) {
        if ([self.delegate respondsToSelector:@selector(sideBarDidSelectDisplayHome)]) {
            [self.delegate sideBarDidSelectDisplayHome];
        }
    }
}

@end
