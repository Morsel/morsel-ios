//
//  ProfileViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLProfileViewController.h"

#import "MRSLArrayDataSource.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLUserActivityViewController.h"
#import "MRSLProfileImageView.h"
#import "MRSLProfileEditViewController.h"
#import "MRSLUserMorselsFeedViewController.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLProfileViewController ()
<NSFetchedResultsControllerDelegate,
UICollectionViewDelegate>

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet UICollectionView *profileCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userBioLabel;
@property (weak, nonatomic) IBOutlet UILabel *userHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIView *nullStateView;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) NSMutableArray *morselIDs;
@property (strong, nonatomic) NSFetchedResultsController *userMorselsFetchedResultsController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) MRSLArrayDataSource *arrayDataSource;

@end

@implementation MRSLProfileViewController

#pragma mark - Instance Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    if (userInfo[@"user_id"]) {
        self.user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                            withValue:userInfo[@"user_id"]];
        if (!_user) {
            self.user = [MRSLUser MR_createEntity];
            self.user.userID = @([userInfo[@"user_id"] intValue]);
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!_user) self.user = [MRSLUser currentUser];

    self.morselIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_morselIDs", _user.username]] ?: [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.profileCollectionView addSubview:_refreshControl];
    self.profileCollectionView.alwaysBounceVertical = YES;

    self.arrayDataSource = [[MRSLArrayDataSource alloc] initWithObjects:nil
                                                       cellIdentifier:@"ruid_MorselPreviewCell"
                                                   configureCellBlock:^(id cell, id morsel, NSIndexPath *indexPath, NSUInteger count) {
                                                       [cell setMorsel:morsel];
                                                   }];
    [self.profileCollectionView setDataSource:_arrayDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillAppear:animated];

    if ([_user isCurrentUser]) {
        self.title = @"My Profile";
        self.followButton.hidden = YES;
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-settings"]
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(displayEditProfile)];
        [self.navigationItem setRightBarButtonItem:editButton];
    }

    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    if (!self.userMorselsFetchedResultsController) {
        [self setupFetchRequest];
        [self populateContent];
        [self refreshContent];
    }

    [self populateUserContent];
}

#pragma mark - Action Methods

- (IBAction)displayMorselAdd {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayMorselAddNotification
                                                        object:@(YES)];
}

- (IBAction)displayLikes {
    [self performSegueWithIdentifier:@"seg_ProfileActivity"
                              sender:nil];
}

- (IBAction)displayFollowers {
    // Empty on purpose
}

- (IBAction)displayFollowing {
    // Empty on purpose
}

- (void)displayEditProfile {
    [self performSegueWithIdentifier:@"seg_ProfileEdit"
                              sender:nil];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_ProfileEdit"]) {
        MRSLProfileEditViewController *profileEditVC = [segue destinationViewController];
        profileEditVC.user = _user;
    } else if ([segue.identifier isEqualToString:@"seg_ProfileActivity"]) {
        MRSLUserActivityViewController *profileActivityVC = [segue destinationViewController];
        profileActivityVC.user = _user;
    }
}

#pragma mark - Private Methods

- (void)populateUserContent {
    self.profileImageView.user = _user;
    self.userNameLabel.text = _user.fullName;
    self.userTitleLabel.text = _user.title;
    self.userBioLabel.text = _user.bio;
    self.userHandleLabel.text = [NSString stringWithFormat:@"%@", _user.username];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%i", _user.like_countValue];
    self.itemCountLabel.text = [NSString stringWithFormat:@"%i", _user.item_countValue];
}

- (void)setupFetchRequest {
    self.userMorselsFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                                     ascending:NO
                                                                 withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@ AND (draft == NO)", _morselIDs]
                                                                       groupBy:nil
                                                                      delegate:self
                                                                     inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_userMorselsFetchedResultsController performFetch:&fetchError];
    [_arrayDataSource updateObjects:[_userMorselsFetchedResultsController fetchedObjects]];
    [_profileCollectionView reloadData];
    if ([self.user isCurrentUser]) self.nullStateView.hidden = ([_arrayDataSource count] > 0);
}

- (void)refreshContent {
    self.loadedAll = NO;
    self.refreshing = YES;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getUserProfile:_user
                                        success:^(id responseObject) {
                                            if (weakSelf) [weakSelf populateUserContent];
                                        } failure:nil];
    [_appDelegate.apiService getUserMorsels:_user
                                      withMaxID:nil
                                      orSinceID:nil
                                       andCount:@(12)
                                  includeDrafts:NO
                                        success:^(NSArray *responseArray) {
                                            [weakSelf.refreshControl endRefreshing];
                                            weakSelf.morselIDs = [responseArray mutableCopy];
                                            [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                      forKey:[NSString stringWithFormat:@"%@_morselIDs", _user.username]];
                                            [weakSelf setupFetchRequest];
                                            [weakSelf populateContent];
                                            weakSelf.refreshing = NO;
                                        } failure:^(NSError *error) {
                                            [weakSelf.refreshControl endRefreshing];
                                            weakSelf.refreshing = NO;
                                        }];
}

- (void)loadMore {
    if (_loadingMore || !_user || _loadedAll || _refreshing) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more user morsels");
    MRSLMorsel *lastMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:[_morselIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getUserMorsels:_user
                                  withMaxID:@([lastMorsel morselIDValue] - 1)
                                  orSinceID:nil
                                   andCount:@(12)
                              includeDrafts:NO
                                    success:^(NSArray *responseArray) {
                                        if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                        DDLogDebug(@"%lu user morsels added", (unsigned long)[responseArray count]);
                                        if (weakSelf) {
                                            if ([responseArray count] > 0) {
                                                [weakSelf.morselIDs addObjectsFromArray:responseArray];
                                                [[NSUserDefaults standardUserDefaults] setObject:weakSelf.morselIDs
                                                                                          forKey:[NSString stringWithFormat:@"%@_morselIDs", _user.username]];
                                                [weakSelf setupFetchRequest];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [weakSelf populateContent];
                                                });
                                            }
                                            weakSelf.loadingMore = NO;
                                        }
                                    } failure:^(NSError *error) {
                                        if (weakSelf) weakSelf.loadingMore = NO;
                                    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_arrayDataSource objectAtIndexPath:indexPath];
    MRSLUserMorselsFeedViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLUserMorselsFeedViewController"];
    userMorselsFeedVC.morsel = morsel;
    userMorselsFeedVC.user = _user;
    [self.navigationController pushViewController:userMorselsFeedVC
                                         animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 10.f) {
        [self loadMore];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
