//
//  ProfileViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLProfileViewController.h"

#import "MRSLAPIClient.h"
#import "MRSLFeedCollectionViewCell.h"
#import "MRSLProfileImageView.h"
#import "MRSLMorselEditViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLProfileViewController ()
<MorselFeedCollectionViewCellDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *profileCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *nullStateView;
@property (weak, nonatomic) IBOutlet UIImageView *itemIconView;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSFetchedResultsController *userMorselsFetchedResultsController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) MRSLItem *selectedMorsel;

@end

@implementation MRSLProfileViewController

#pragma mark - Instance Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    if (userInfo[@"user_id"]) {
        self.user = [MRSLUser MR_createEntity];
        self.user.userID = @([userInfo[@"user_id"] intValue]);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.items = [NSMutableArray array];

    if (!_user) self.user = [MRSLUser currentUser];

    if ([_user isCurrentUser]) self.title = @"My Profile";

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshUserMorselsAndProfile)
              forControlEvents:UIControlEventValueChanged];

    [self.profileCollectionView addSubview:_refreshControl];
    self.profileCollectionView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    if (!self.userMorselsFetchedResultsController) {
        [self setupUserMorselsFetchRequest];
        [self populateContent];
        [self refreshUserMorselsAndProfile];
    }

    self.profileImageView.user = _user;
    self.userNameLabel.text = _user.fullName;
    self.userTitleLabel.text = _user.title;
    self.likeCountLabel.text = [NSString stringWithFormat:@"%i", _user.like_countValue];
    self.itemCountLabel.text = [NSString stringWithFormat:@"%i", _user.item_countValue];
    [self layoutUserContent];
}

#pragma mark - Action Methods

- (IBAction)displayMorselAdd {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayMorselAddNotification
                                                        object:nil];
}

#pragma mark - Private Methods

- (void)setupUserMorselsFetchRequest {
    if (_userMorselsFetchedResultsController) return;

    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"(morsel.creator.userID == %i) AND (morsel.draft == NO)", [_user.userID intValue]];

    self.userMorselsFetchedResultsController = [MRSLItem MR_fetchAllSortedBy:@"creationDate"
                                                                   ascending:NO
                                                               withPredicate:currentUserPredicate
                                                                     groupBy:nil
                                                                    delegate:self
                                                                   inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_userMorselsFetchedResultsController performFetch:&fetchError];

    if (_userMorselsFetchedResultsController) {
        [self.items removeAllObjects];
        [self.items addObjectsFromArray:[_userMorselsFetchedResultsController fetchedObjects]];
    }

    [self.profileCollectionView reloadData];

    if ([self.user isCurrentUser]) {
        self.nullStateView.hidden = ([_items count] > 0);
    }
}

- (void)layoutUserContent {
    [_likeCountLabel sizeToFit];
    [_itemCountLabel sizeToFit];
    [_itemIconView setX:[_likeCountLabel getX] + [_likeCountLabel getWidth] + 8.f];
    [_itemCountLabel setX:[_itemIconView getX] + [_itemIconView getWidth] + 5.f];
}

- (void)refreshUserMorselsAndProfile {
    __weak __typeof(self)weakSelf = self;

    [_appDelegate.itemApiService getUserProfile:_user
                                          success:^(id responseObject) {
         if (weakSelf) {
             weakSelf.likeCountLabel.text = [NSString stringWithFormat:@"%i", _user.like_countValue];
             weakSelf.itemCountLabel.text = [NSString stringWithFormat:@"%i", _user.item_countValue];
             [weakSelf layoutUserContent];
         }
     } failure:nil];

    [_appDelegate.itemApiService getUserMorsels:_user
                                  includeDrafts:NO
                                        success:^(NSArray *responseArray) {
                                            [_refreshControl endRefreshing];
                                        } failure:^(NSError *error) {
                                            [_refreshControl endRefreshing];
                                        }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_items count];
}

- (MRSLFeedCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLItem *item = [_items objectAtIndex:indexPath.row];

    MRSLFeedCollectionViewCell *itemCell = [self.profileCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_ItemCell"
                                                                                                     forIndexPath:indexPath];
    itemCell.delegate = self;
    itemCell.item = item;

    return itemCell;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - Destruction

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
