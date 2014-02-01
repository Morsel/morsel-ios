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

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLSideBarViewController ()
    <NSFetchedResultsControllerDelegate,
     UITableViewDataSource,
     UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *sideBarTableView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@property (nonatomic, strong) SideBarItem *draftSideBarItem;

@property (nonatomic, strong) NSMutableArray *sideBarItems;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

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
    
    NSPredicate *draftMorselPredicate = [NSPredicate predicateWithFormat:@"draft == YES"];
    
    self.fetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                          ascending:NO
                                                      withPredicate:draftMorselPredicate
                                                            groupBy:nil
                                                           delegate:self
                                                          inContext:[ModelController sharedController].defaultContext];
    
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
    //sideBarCell.pipeView.hidden = (indexPath.row == [_sideBarItems count] - 1);
    
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
    if ([sideBarItem.title isEqualToString:@"Drafts"]) {
        if ([self.delegate respondsToSelector:@selector(sideBarDidSelectDisplayDrafts)]) {
            [self.delegate sideBarDidSelectDisplayDrafts];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSUInteger fetchedObjectsCount = [[controller fetchedObjects] count];
    
    DDLogDebug(@"Fetch controller detected change in content. Reloading with %lu drafts.", (unsigned long)fetchedObjectsCount);
    
    if (fetchedObjectsCount > 0) {
        self.draftSideBarItem.draftCount = fetchedObjectsCount;
        if (![_sideBarItems containsObject:_draftSideBarItem]) {
            [self.sideBarItems insertObject:_draftSideBarItem atIndex:0];
        }
    } else {
        [self.sideBarItems removeObject:_draftSideBarItem];
    }
    
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    
    if (fetchError) {
        DDLogDebug(@"Refresh Fetch Failed! %@", fetchError.userInfo);
    }
    
    [self.sideBarTableView reloadData];
}

@end
