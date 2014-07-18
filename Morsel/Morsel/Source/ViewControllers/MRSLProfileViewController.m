//
//  ProfileViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLProfileViewController.h"

#import "MRSLAPIClient.h"

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Profile.h"
#import "MRSLAPIService+Router.h"

#import "MRSLKeywordUsersViewController.h"
#import "MRSLFollowButton.h"
#import "MRSLPanelSegmentedCollectionViewDataSource.h"
#import "MRSLPlaceViewController.h"
#import "MRSLProfileEditFieldsViewController.h"
#import "MRSLProfileImageView.h"
#import "MRSLProfileUserTagsListViewController.h"
#import "MRSLUserMorselsFeedViewController.h"
#import "MRSLUserFollowListViewController.h"
#import "MRSLUserTagListViewController.h"

#import "MRSLStateView.h"
#import "MRSLCollectionView.h"
#import "MRSLContainerCollectionViewCell.h"
#import "MRSLUserLikedItemCollectionViewCell.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLPlaceCollectionViewCell.h"
#import "MRSLProfilePanelCollectionViewCell.h"
#import "MRSLSegmentedHeaderReusableView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLTag.h"
#import "MRSLUser.h"

@interface MRSLProfileViewController ()
<UIScrollViewDelegate,
MRSLCollectionViewDataSourceDelegate,
MRSLProfilePanelCollectionViewCellDelegate,
MRSLProfileUserTagsListViewControllerDelegate,
MRSLSegmentedHeaderReusableViewDelegate,
MRSLStateViewDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;
@property (nonatomic) BOOL shouldShowFollowers;

@property (nonatomic) MRSLDataSourceType dataSourceTabType;

@property (weak, nonatomic) IBOutlet MRSLFollowButton *followButton;
@property (weak, nonatomic) IBOutlet MRSLCollectionView *profileCollectionView;

@property (strong, nonatomic) NSMutableArray *objectIDs;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *keywordType;

@property (strong, nonatomic) MRSLPanelSegmentedCollectionViewDataSource *segmentedPanelCollectionViewDataSource;

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

    [self loadObjectIDs];

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.profileCollectionView addSubview:_refreshControl];
    self.profileCollectionView.alwaysBounceVertical = YES;

    __weak __typeof(self) weakSelf = self;
    NSString *predicateString = [NSString stringWithFormat:@"%@ID", [MRSLUtil stringForDataSourceType:_dataSourceTabType]];
    self.segmentedPanelCollectionViewDataSource = [[MRSLPanelSegmentedCollectionViewDataSource alloc] initWithManagedObjectClass:[MRSLUtil classForDataSourceType:_dataSourceTabType]
                                                                                                                       predicate:[NSPredicate predicateWithFormat:@"%K IN %@", predicateString, _objectIDs]
                                                                                                                  collectionView:_profileCollectionView
                                                                                                                      cellConfig:^(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                                                          return [weakSelf configureCellForItem:item
                                                                                                                                               inCollectionView:collectionView
                                                                                                                                                    atIndexPath:indexPath
                                                                                                                                                       andCount:count];
                                                                                                                      } supplementaryConfig:^(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath) {
                                                                                                                          UICollectionReusableView *reusableView = nil;
                                                                                                                          if (indexPath.section == 1) {
                                                                                                                              reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                                                                withReuseIdentifier:@"ruid_HeaderCell"
                                                                                                                                                                                       forIndexPath:indexPath];

                                                                                                                              [(MRSLSegmentedHeaderReusableView *)reusableView setDelegate:weakSelf];
                                                                                                                              [(MRSLSegmentedHeaderReusableView *)reusableView setShouldDisplayProfessionalTabs:[weakSelf.user isProfessional]];
                                                                                                                          } else {
                                                                                                                              reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                                                                withReuseIdentifier:@"ruid_HeaderCell"
                                                                                                                                                                                       forIndexPath:indexPath];
                                                                                                                              [reusableView setHidden:YES];
                                                                                                                          }
                                                                                                                          return reusableView;
                                                                                                                      } headerConfig:^(UICollectionView *collectionView, NSInteger section) {
                                                                                                                          if (section != 0) {
                                                                                                                              return CGSizeMake(collectionView.bounds.size.width, 50.f);
                                                                                                                          } else {
                                                                                                                              return CGSizeZero;
                                                                                                                          }
                                                                                                                      } cellSizeConfig:^(UICollectionView *collectionView, NSIndexPath *indexPath) {
                                                                                                                          return [weakSelf configureSizeForCollectionView:collectionView
                                                                                                                                                              atIndexPath:indexPath];
                                                                                                                      } sectionInsetConfig:^(UICollectionView *collectionView, NSInteger section) {
                                                                                                                          if (section != 0) {
                                                                                                                              return UIEdgeInsetsMake(0.f, 0.f, 10.f, 0.f);
                                                                                                                          } else {
                                                                                                                              return UIEdgeInsetsZero;
                                                                                                                          }
                                                                                                                      }];

    [self.profileCollectionView setDataSource:_segmentedPanelCollectionViewDataSource];
    [self.profileCollectionView setDelegate:_segmentedPanelCollectionViewDataSource];
    [self.profileCollectionView setEmptyStateTitle:@"No morsels added"];
    [self.profileCollectionView setEmptyStateDelegate:self];

    [self.segmentedPanelCollectionViewDataSource setDelegate:self];

    if ([self.user isCurrentUser]) {
        //  Hide the follow button and show a 'Edit' button instead
        [self.followButton setHidden:YES];

        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                    style:UIBarButtonItemStyleBordered
                                                                                   target:self
                                                                                   action:@selector(displayEditProfile)]];
        [self.profileCollectionView setEmptyStateButtonTitle:@"Add a morsel"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillAppear:animated];

    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    [self populateUserInformation];
    [self refreshContent];
}

#pragma mark - Private Methods

- (BOOL)isCurrentUserProfile {
    return [self.user isCurrentUser];
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    [self.profileCollectionView toggleLoading:loading];
}

- (void)displayEditProfile {
    MRSLProfileEditFieldsViewController *profileEditFieldsViewController = [[UIStoryboard settingsStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileEditFieldsViewController"];
    profileEditFieldsViewController.user = self.user;
    [self.navigationController pushViewController:profileEditFieldsViewController
                                         animated:YES];
}

- (void)refreshProfile {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getUserProfile:_user
                                    success:^(id responseObject) {
                                        if (weakSelf) [weakSelf populateUserInformation];
                                    } failure:nil];
}

- (void)populateUserInformation {
    self.title = _user.username;
    self.followButton.user = _user;
    [_profileCollectionView reloadData];
}

- (void)loadObjectIDs {
    self.objectIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[self objectIDsKey]] ?: [NSMutableArray array];
}

- (void)updateDataSourcePredicate {
    NSString *predicateString = [NSString stringWithFormat:@"%@ID", [MRSLUtil stringForDataSourceType:_dataSourceTabType]];
    [self.segmentedPanelCollectionViewDataSource updateFetchRequestWithManagedObjectClass:[MRSLUtil classForDataSourceType:_dataSourceTabType]
                                                                            withPredicate:[NSPredicate predicateWithFormat:@"%K IN %@", predicateString, _objectIDs]];
}

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%@_%@IDs", _user.username, [MRSLUtil stringForDataSourceType:_dataSourceTabType]];
}

- (void)refreshContent {
    [self refreshProfile];
    self.loadedAll = NO;
    self.loading = YES;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getUserData:_user
                       forDataSourceType:_dataSourceTabType
                               withMaxID:nil
                               orSinceID:nil
                                andCount:@(12)
                                 success:^(NSArray *responseArray) {
                                     if (weakSelf) {
                                         [weakSelf.refreshControl endRefreshing];
                                         weakSelf.objectIDs = [responseArray mutableCopy];
                                         [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                   forKey:[weakSelf objectIDsKey]];
                                         [weakSelf updateDataSourcePredicate];
                                         weakSelf.loading = NO;
                                     }
                                 } failure:^(NSError *error) {
                                     if (weakSelf) {
                                         [weakSelf.refreshControl endRefreshing];
                                         weakSelf.loading = NO;
                                     }
                                 }];
}

- (void)loadMore {
    if (_loadingMore || !_user || _loadedAll || [self isLoading]) return;
    self.loadingMore = YES;
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getUserData:_user
                       forDataSourceType:_dataSourceTabType
                               withMaxID:@([self lastObjectID])
                               orSinceID:nil
                                andCount:@(12)
                                 success:^(NSArray *responseArray) {
                                     if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                     DDLogDebug(@"%lu user data objects added", (unsigned long)[responseArray count]);
                                     if (weakSelf) {
                                         if ([responseArray count] > 0) {
                                             [weakSelf.objectIDs addObjectsFromArray:responseArray];
                                             [[NSUserDefaults standardUserDefaults] setObject:weakSelf.objectIDs
                                                                                       forKey:[self objectIDsKey]];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakSelf updateDataSourcePredicate];
                                             });
                                         }
                                         weakSelf.loadingMore = NO;
                                     }
                                 } failure:^(NSError *error) {
                                     if (weakSelf) weakSelf.loadingMore = NO;
                                 }];
}

- (int)lastObjectID {
    int lastID = [[_objectIDs lastObject] intValue];
    return (lastID == 0) ? 0 : lastID - 1;
}

- (void)displayUserFeedWithMorsel:(MRSLMorsel *)morsel {
    MRSLUserMorselsFeedViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLUserMorselsFeedViewController"];
    userMorselsFeedVC.morsel = morsel;
    userMorselsFeedVC.user = morsel.creator;
    [self.navigationController pushViewController:userMorselsFeedVC
                                         animated:YES];
}

#pragma mark - MRSLPanelSegmentedCollectionViewDataSource

- (UICollectionViewCell *)configureCellForItem:(id)item
                              inCollectionView:(UICollectionView *)collectionView
                                   atIndexPath:(NSIndexPath *)indexPath
                                      andCount:(NSUInteger)count {
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_PanelCell"
                                                         forIndexPath:indexPath];
        [(MRSLProfilePanelCollectionViewCell *)cell setUser:self.user];
        [(MRSLProfilePanelCollectionViewCell *)cell setDelegate:self];
    } else {
        if (count > 0) {
            [cell addBorderWithDirections:MRSLBorderSouth
                              borderColor:[UIColor whiteColor]];
            if ([item isKindOfClass:[MRSLMorsel class]]) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MorselPreviewCell"
                                                                 forIndexPath:indexPath];
                [(MRSLMorselPreviewCollectionViewCell *)cell setMorsel:item];
            } else if ([item isKindOfClass:[MRSLItem class]]) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_UserLikedItemCell"
                                                                 forIndexPath:indexPath];
                [(MRSLUserLikedItemCollectionViewCell *)cell setItem:item
                                                             andUser:_user];
                if (indexPath.row != count) {
                    [cell addBorderWithDirections:MRSLBorderSouth
                                      borderColor:[UIColor morselLightOffColor]];
                }
            } else if ([item isKindOfClass:[MRSLPlace class]]) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_PlaceCell"
                                                                 forIndexPath:indexPath];
                [(MRSLPlaceCollectionViewCell *)cell setPlace:item];
                if (indexPath.row != count) {
                    [cell addBorderWithDirections:MRSLBorderSouth
                                      borderColor:[UIColor morselLightOffColor]];
                }
            }
        } else {
            if (_dataSourceTabType == MRSLDataSourceTypeTag) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_ContainerCell"
                                                                 forIndexPath:indexPath];
                if ([[cell.contentView.subviews firstObject] tag] != MRSLStatsTagViewTag) {
                    MRSLProfileUserTagsListViewController *statsTagVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileUserTagsListViewController"];
                    statsTagVC.delegate = self;
                    statsTagVC.user = _user;
                    statsTagVC.view.tag = MRSLStatsTagViewTag;
                    [statsTagVC.view setHeight:500.f];
                    [self addChildViewController:statsTagVC];
                    [cell.contentView addSubview:statsTagVC.view];
                }
            }
        }
    }
    return cell ?: [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_EmptyCell"
                                                             forIndexPath:indexPath];
}

- (CGSize)configureSizeForCollectionView:(UICollectionView *)collectionView
                             atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(320.f, 124.f);
    } else {
        if ([self.segmentedPanelCollectionViewDataSource count] == 0) {
            return CGSizeMake(320.f, (_dataSourceTabType == MRSLDataSourceTypeTag) ? 500.f : 80.f);
        } else {
            id object = [_segmentedPanelCollectionViewDataSource objectAtIndexPath:indexPath];
            if ([object isKindOfClass:[MRSLMorsel class]]) {
                return CGSizeMake(106.f, 106.f);
            } else {
                return CGSizeMake(320.f, 80.f);
            }
        }
    }
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_KeywordList"]) {
        MRSLUserTagListViewController *userKeywordListVC = [segue destinationViewController];
        userKeywordListVC.user = _user;
        userKeywordListVC.keywordType = _keywordType;
    } else if ([segue.identifier isEqualToString:@"seg_FollowList"]) {
        MRSLUserFollowListViewController *userFollowListVC = [segue destinationViewController];
        userFollowListVC.user = _user;
        userFollowListVC.shouldDisplayFollowers = _shouldShowFollowers;
    }
}

#pragma mark - MRSLCollectionViewDataSourceDelegate

- (void)collectionViewDataSource:(UICollectionView *)collectionView didSelectItem:(id)item {
    if ([item isKindOfClass:[MRSLMorsel class]]) {
        MRSLMorsel *morsel = item;
        MRSLUserMorselsFeedViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLUserMorselsFeedViewController"];
        userMorselsFeedVC.morsel = morsel;
        userMorselsFeedVC.user = _user;
        [self.navigationController pushViewController:userMorselsFeedVC
                                             animated:YES];
    } else if ([item isKindOfClass:[MRSLItem class]]) {
        MRSLItem *morselItem = item;
        if (morselItem.morsel && [morselItem.morsel hasCreatorInfo]) {
            [self displayUserFeedWithMorsel:morselItem.morsel];
        } else if (morselItem.morsel_id) {
            __weak __typeof(self) weakSelf = self;
            [_appDelegate.apiService getMorsel:nil
                                      orWithID:morselItem.morsel_id
                                       success:^(id responseObject) {
                                           if ([responseObject isKindOfClass:[MRSLMorsel class]]) {
                                               [weakSelf displayUserFeedWithMorsel:responseObject];
                                           }
                                       } failure:nil];
        }
    } else if ([item isKindOfClass:[MRSLPlace class]]) {
        MRSLPlaceViewController *placeVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLPlaceViewController"];
        placeVC.place = item;
        [self.navigationController pushViewController:placeVC
                                             animated:YES];
    }
}

- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView withOffset:(CGFloat)offset {
    if (offset <= 10.f) {
        [self loadMore];
    }
}

#pragma mark - MRSLProfilePanelCollectionViewCellDelegate

- (void)profilePanelDidSelectFollowers {
    self.shouldShowFollowers = YES;
    [self performSegueWithIdentifier:@"seg_FollowList"
                              sender:nil];
}

- (void)profilePanelDidSelectFollowing {
    self.shouldShowFollowers = NO;
    [self performSegueWithIdentifier:@"seg_FollowList"
                              sender:nil];
}

#pragma mark - MRSLSegmentedHeaderReusableViewDelegate

- (void)segmentedHeaderDidSelectIndex:(NSInteger)index {
    if (_dataSourceTabType != index) {
        self.dataSourceTabType = index;

        switch (index) {
            case MRSLDataSourceTypeActivityItem:
                [self.profileCollectionView setEmptyStateTitle:@"No activity yet"];
                if ([self isCurrentUserProfile]) [self.profileCollectionView setEmptyStateButtonTitle:nil];
                [self.segmentedPanelCollectionViewDataSource setDataSortType:MRSLDataSortTypeLikedDate
                                                                   ascending:NO];
                break;
            case MRSLDataSourceTypeMorsel:
                [self.profileCollectionView setEmptyStateTitle:@"No morsels added"];
                if ([self isCurrentUserProfile]) [self.profileCollectionView setEmptyStateButtonTitle:@"Add a morsel"];
                [self.segmentedPanelCollectionViewDataSource setDataSortType:MRSLDataSortTypeCreationDate
                                                                   ascending:NO];
                break;
            case MRSLDataSourceTypePlace:
                [self.profileCollectionView setEmptyStateTitle:@"No places added"];
                if ([self isCurrentUserProfile]) [self.profileCollectionView setEmptyStateButtonTitle:@"Add a place"];
                [self.segmentedPanelCollectionViewDataSource setDataSortType:MRSLDataSortTypeName
                                                                   ascending:YES];
                break;
            case MRSLDataSourceTypeTag:
                [self.profileCollectionView setEmptyStateTitle:@"No tags added"];
                if ([self isCurrentUserProfile]) [self.profileCollectionView setEmptyStateButtonTitle:@"Manage tags"];
                [self.segmentedPanelCollectionViewDataSource setDataSortType:MRSLDataSortTypeName
                                                                   ascending:YES];
                break;
            default:
                [self.profileCollectionView setEmptyStateTitle:@"No results"];
                if ([self isCurrentUserProfile]) [self.profileCollectionView setEmptyStateButtonTitle:nil];
                [self.segmentedPanelCollectionViewDataSource setDataSortType:MRSLDataSortTypeNone
                                                                   ascending:NO];
                break;
        }

        [[MRSLAPIClient sharedClient].operationQueue cancelAllOperations];
        [self loadObjectIDs];
        [self updateDataSourcePredicate];
        [self refreshContent];
    }
}

#pragma mark - MRSLProfileUserTagsListViewControllerDelegate

- (void)profileUserTagsListViewControllerDidSelectTag:(MRSLTag *)tag {
    MRSLKeywordUsersViewController *keywordUsersVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLKeywordUsersViewController"];
    keywordUsersVC.keyword = tag.keyword;
    [self.navigationController pushViewController:keywordUsersVC
                                         animated:YES];
}

- (void)profileUserTagsListViewControllerDidSelectType:(NSString *)type {
    self.keywordType = type;
    [self performSegueWithIdentifier:@"seg_KeywordList" sender:nil];
}


#pragma mark - MRSLStateViewDelegate

- (void)stateView:(MRSLStateView *)stateView didSelectButton:(UIButton *)button {
    if ([button.titleLabel.text isEqualToString:@"Add a morsel"]) {
        [self displayMorselAdd];
    } else if ([button.titleLabel.text isEqualToString:@"Add a place"]) {
        [self displayAddPlace:button];
    } else if ([button.titleLabel.text isEqualToString:@"Manage tags"]) {
        [self displayProfessionalSettings];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.profileCollectionView setEmptyStateDelegate:nil];
    self.profileCollectionView.delegate = nil;
    self.profileCollectionView.dataSource = nil;
    [self.profileCollectionView removeFromSuperview];
    self.profileCollectionView = nil;
}

@end
