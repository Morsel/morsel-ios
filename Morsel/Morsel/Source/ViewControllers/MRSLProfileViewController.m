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
#import "MRSLMorselDetailViewController.h"
#import "MRSLUserFollowListViewController.h"
#import "MRSLCollectionDetailViewController.h"
#import "MRSLCollectionCreateViewController.h"

#import "MRSLStateView.h"
#import "MRSLCollectionView.h"
#import "MRSLContainerCollectionViewCell.h"
#import "MRSLUserLikedMorselCollectionViewCell.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLPlaceCollectionViewCell.h"
#import "MRSLProfilePanelCollectionViewCell.h"
#import "MRSLSegmentedHeaderReusableView.h"
#import "MRSLTagStatsNameCell.h"
#import "MRSLCollectionPreviewCell.h"

#import "MRSLItem.h"
#import "MRSLCollection.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLKeyword.h"
#import "MRSLUser.h"

@interface MRSLProfileViewController ()
<UIActionSheetDelegate,
MRSLCollectionViewDataSourceDelegate,
MRSLProfilePanelCollectionViewCellDelegate,
MRSLSegmentedHeaderReusableViewDelegate,
MRSLStateViewDelegate>

@property (nonatomic) BOOL shouldShowFollowers;
@property (nonatomic) BOOL queuedToDisplayFollowers;
@property (nonatomic) BOOL dataAscending;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (nonatomic) MRSLDataSourceType dataSourceTabType;
@property (nonatomic) MRSLDataSortType dataSortType;

@property (weak, nonatomic) IBOutlet MRSLFollowButton *followButton;

@property (strong, nonatomic) NSString *keywordType;

@end

@implementation MRSLProfileViewController

#pragma mark - Instance Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    self.userInfo = userInfo;
}

- (void)viewDidLoad {
    if (self.userInfo[@"user_id"]) {
        self.user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                            withValue:@([self.userInfo[@"user_id"] intValue])];
        if (!_user) {
            self.user = [MRSLUser MR_createEntity];
            self.user.userID = @([self.userInfo[@"user_id"] intValue]);
            [self.user.managedObjectContext MR_saveOnlySelfAndWait];
        }
        __weak __typeof(self)weakSelf = self;
        [_appDelegate.apiService getUserProfile:_user
                                        success:^(id responseObject) {
                                            if (weakSelf) {
                                                [weakSelf setupRemoteRequestBlock];
                                            }
                                        } failure:^(NSError *error) {
                                            [UIAlertView showAlertViewForErrorString:@"Unable to load user profile."
                                                                            delegate:nil];
                                        }];
        if ([self.userInfo[@"action"] isEqualToString:@"followers"]) {
            self.queuedToDisplayFollowers = YES;
        }
    } else {
        if (!_user) self.user = [MRSLUser currentUser];
        [self setupRemoteRequestBlock];
        [self populateUserInformation];
    }

    self.emptyStateString = @"No morsels added";
    self.dataSourceTabType = MRSLDataSourceTypeMorsel;
    self.dataSortType = MRSLDataSortTypePublishedDate;
    self.followButton.hidden = YES;
    self.allowObserversToRemain = YES;

    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCollections:)
                                                 name:MRSLUserDidCreateCollectionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCollections:)
                                                 name:MRSLUserDidUpdateCollectionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCollections:)
                                                 name:MRSLUserDidDeleteCollectionNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.queuedToDisplayFollowers && self.userInfo) {
        self.queuedToDisplayFollowers = NO;
        self.shouldShowFollowers = YES;
        [self performSegueWithIdentifier:MRSLStoryboardSegueFollowListKey
                                  sender:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.selectedIndexPath) {
        [self.collectionView deselectItemAtIndexPath:self.selectedIndexPath
                                            animated:YES];
        self.selectedIndexPath = nil;
    }
}

#pragma mark - Action Methods

- (IBAction)report {
    if ([MRSLUser isCurrentUserGuest]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayLandingNotification
                                                            object:nil];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"Report inappropriate"
                                                    otherButtonTitles:nil];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark - Private Methods

- (void)refreshCollections:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[MRSLCollection class]]) {
        MRSLCollection *newCollection = notification.object;
        if (newCollection.creator.userIDValue == self.user.userIDValue) {
            if (self.dataSourceTabType == MRSLDataSourceTypeCollection) {
                [self refreshRemoteContent];
            }
        }
    } else if ([notification.object isKindOfClass:[NSNumber class]]) {
        NSNumber *userID = notification.object;
        if ([userID intValue] == self.user.userIDValue) {
            if (self.dataSourceTabType == MRSLDataSourceTypeCollection) {
                [self refreshRemoteContent];
            }
        }
    }
}

- (BOOL)isCurrentUserProfile {
    return [self.user isCurrentUser];
}

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"profile_user_%@_%@IDs", _user.userID, [MRSLUtil stringForDataSourceType:_dataSourceTabType]];
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    NSString *predicateString = [NSString stringWithFormat:@"%@ID", [MRSLUtil stringForDataSourceType:self.dataSourceTabType]];
    NSString *sortString = [MRSLUtil stringForDataSortType:self.dataSortType];
    return [[MRSLUtil classForDataSourceType:self.dataSourceTabType] MR_fetchAllSortedBy:sortString
                                                                               ascending:self.dataAscending
                                                                           withPredicate:[NSPredicate predicateWithFormat:@"%K IN %@", predicateString, self.objectIDs]
                                                                                 groupBy:nil
                                                                                delegate:self
                                                                               inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    __weak __typeof(self) weakSelf = self;
    MRSLDataSource *newDataSource = [[MRSLPanelSegmentedCollectionViewDataSource alloc] initWithObjects:nil
                                                                                               sections:nil
                                                                                     configureCellBlock:^UICollectionViewCell *(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                         return [weakSelf configureCellForItem:item
                                                                                                              inCollectionView:collectionView
                                                                                                                   atIndexPath:indexPath
                                                                                                                         count:count];
                                                                                     }
                                                                                     supplementaryBlock:^UICollectionReusableView *(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath) {
                                                                                         UICollectionReusableView *reusableView = nil;
                                                                                         if (indexPath.section == 1) {
                                                                                             if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
                                                                                                 reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                                   withReuseIdentifier:MRSLStoryboardRUIDLoadingCellKey
                                                                                                                                                          forIndexPath:indexPath];
                                                                                             } else {
                                                                                                 reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                                   withReuseIdentifier:MRSLStoryboardRUIDHeaderCellKey
                                                                                                                                                          forIndexPath:indexPath];

                                                                                                 [(MRSLSegmentedHeaderReusableView *)reusableView setDelegate:weakSelf];
                                                                                             }
                                                                                         } else {
                                                                                             reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                               withReuseIdentifier:MRSLStoryboardRUIDHeaderCellKey
                                                                                                                                                      forIndexPath:indexPath];
                                                                                             [reusableView setHidden:YES];
                                                                                         }
                                                                                         return reusableView;
                                                                                     }
                                                                                 sectionHeaderSizeBlock:^(UICollectionView *collectionView, NSInteger section) {
                                                                                     if (section != 0) {
                                                                                         return CGSizeMake(collectionView.bounds.size.width, 50.f);
                                                                                     } else {
                                                                                         return CGSizeZero;
                                                                                     }
                                                                                 }
                                                                                 sectionFooterSizeBlock:^CGSize(UICollectionView *collectionView, NSInteger section) {
                                                                                     return (weakSelf.loadingMore && section == 1) ? CGSizeMake([collectionView getWidth], 50.f) : CGSizeZero;
                                                                                 }
                                                                                          cellSizeBlock:^CGSize(UICollectionView *collectionView, NSIndexPath *indexPath) {
                                                                                              return [weakSelf configureSizeForCollectionView:collectionView
                                                                                                                                  atIndexPath:indexPath];
                                                                                          }
                                                                                     sectionInsetConfig:^UIEdgeInsets(UICollectionView *collectionView, NSInteger section) {
                                                                                         if (section != 0) {
                                                                                             return UIEdgeInsetsMake(0.f, 0.f, 10.f, 0.f);
                                                                                         } else {
                                                                                             return UIEdgeInsetsZero;
                                                                                         }
                                                                                     }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

- (void)setupRemoteRequestBlock {
    [self refreshProfile];
    __weak __typeof(self)weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [_appDelegate.apiService getUserData:strongSelf.user
                           forDataSourceType:strongSelf.dataSourceTabType
                                        page:page
                                       count:nil
                                     success:^(NSArray *responseArray) {
                                         remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                     } failure:^(NSError *error) {
                                         remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                     }];
    };
}

- (void)displayEditProfile {
    MRSLProfileEditFieldsViewController *profileEditFieldsViewController = [[UIStoryboard settingsStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileEditFieldsViewControllerKey];
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
    if ([self.user isCurrentUser]) {
        //  Hide the follow button and show a 'Edit' button instead
        [self.followButton setHidden:YES];

        if (![self.navigationItem.rightBarButtonItem.title isEqualToString:@"Edit"]) {
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                                        style:UIBarButtonItemStyleBordered
                                                                                       target:self
                                                                                       action:@selector(displayEditProfile)]];

        }
    } else {
        self.followButton.user = _user;
        self.followButton.hidden = NO;
    }
}

- (void)loadObjectIDs {
    self.objectIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[self objectIDsKey]] ?: [NSMutableArray array];
}

- (void)displayUserFeedWithMorsel:(MRSLMorsel *)morsel {
    MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
    userMorselsFeedVC.morsel = morsel;
    userMorselsFeedVC.user = morsel.creator;
    userMorselsFeedVC.isExplore = YES;
    [self.navigationController pushViewController:userMorselsFeedVC
                                         animated:YES];
}

- (BOOL)isCollectionTabAndSection:(NSInteger)section {
    return (section == 1 && self.dataSourceTabType == MRSLDataSourceTypeCollection);
}

- (void)createCollection {
    MRSLCollectionCreateViewController *collectionCreateVC = [[UIStoryboard collectionsStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCollectionCreateViewControllerKey];
    [self.navigationController pushViewController:collectionCreateVC
                                         animated:YES];
}

#pragma mark - MRSLPanelSegmentedCollectionViewDataSource

- (NSInteger)collectionViewDataSourceNumberOfItemsInSection:(NSInteger)section {
    NSInteger count = (section == 0) ? 1 : ([self.dataSource count] ?: 0);
    if ([self.user isCurrentUser]) count += ([self isCollectionTabAndSection:section]) ? 1 : 0;
    return count;
}

- (UICollectionViewCell *)configureCellForItem:(id)item
                              inCollectionView:(UICollectionView *)collectionView
                                   atIndexPath:(NSIndexPath *)indexPath
                                         count:(NSUInteger)count {
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDPanelCellKey
                                                         forIndexPath:indexPath];
        [(MRSLProfilePanelCollectionViewCell *)cell setUser:self.user];
        [(MRSLProfilePanelCollectionViewCell *)cell setDelegate:self];
    } else {
        [cell removeBorder];
        if (count > 0) {
            [cell addBorderWithDirections:MRSLBorderSouth
                              borderColor:[UIColor whiteColor]];
            if ([item isKindOfClass:[MRSLMorsel class]]) {
                if (self.dataSourceTabType == MRSLDataSourceTypeLikedMorsel) {
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDUserLikedMorselCellKey
                                                                     forIndexPath:indexPath];
                    [(MRSLUserLikedMorselCollectionViewCell *)cell setMorsel:item
                                                                     andUser:_user];
                    if (indexPath.row != count) {
                        [cell addDefaultBorderForDirections:MRSLBorderSouth];
                    }
                } else {
                    cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDMorselPreviewCellKey
                                                                     forIndexPath:indexPath];
                    [(MRSLMorselPreviewCollectionViewCell *)cell setMorsel:item];
                }
            } else if ([item isKindOfClass:[MRSLPlace class]]) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDPlaceCellKey
                                                                 forIndexPath:indexPath];
                [(MRSLPlaceCollectionViewCell *)cell setPlace:item];
                if (indexPath.row != count) {
                    [cell addDefaultBorderForDirections:MRSLBorderSouth];
                }
            } else if ([item isKindOfClass:[MRSLCollection class]]) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDCollectionCellKey
                                                                 forIndexPath:indexPath];
                [(MRSLCollectionPreviewCell *)cell setCollection:item];
            } else {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDCollectionAddCellKey
                                                                 forIndexPath:indexPath];
                [cell setBackgroundColor:[UIColor whiteColor]];
            }
        }
    }
    return cell ?: [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDEmptyCellKey
                                                             forIndexPath:indexPath];
}

- (CGSize)configureSizeForCollectionView:(UICollectionView *)collectionView
                             atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(collectionView.frame.size.width, 124.f);
    } else {
        if ([self.dataSource count] == 0) {
            return CGSizeMake(collectionView.frame.size.width, (_dataSourceTabType == MRSLDataSourceTypeTag) ? 500.f : 80.f);
        } else {
            id object = [self.dataSource objectAtIndexPath:indexPath];
            if ([object isKindOfClass:[MRSLMorsel class]] ||
                [object isKindOfClass:[MRSLCollection class]]) {
                if (self.dataSourceTabType == MRSLDataSourceTypeLikedMorsel) {
                    return CGSizeMake(collectionView.frame.size.width, 80.f);
                } else {
                    return [MRSLMorselPreviewCollectionViewCell defaultCellSizeForCollectionView:collectionView
                                                                                     atIndexPath:indexPath];
                }
            } else {
                if ([self isCollectionTabAndSection:indexPath.section]) {
                    return [MRSLMorselPreviewCollectionViewCell defaultCellSizeForCollectionView:collectionView
                                                                                     atIndexPath:indexPath];
                } else {
                    return CGSizeMake(collectionView.frame.size.width, 80.f);
                }
            }
        }
    }
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:MRSLStoryboardSegueFollowListKey]) {
        MRSLUserFollowListViewController *userFollowListVC = [segue destinationViewController];
        userFollowListVC.user = _user;
        userFollowListVC.shouldDisplayFollowers = _shouldShowFollowers;
    }
}

#pragma mark - MRSLCollectionViewDataSourceDelegate

- (void)collectionViewDataSource:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self.dataSource objectAtIndexPath:indexPath];
    self.selectedIndexPath = indexPath;
    if ([item isKindOfClass:[MRSLMorsel class]]) {
        MRSLMorsel *morsel = item;
        MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
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
        MRSLPlaceViewController *placeVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlaceViewControllerKey];
        placeVC.place = item;
        [self.navigationController pushViewController:placeVC
                                             animated:YES];
    } else if ([item isKindOfClass:[MRSLCollection class]]) {
        MRSLCollectionDetailViewController *collectionDetailVC = [[UIStoryboard collectionsStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCollectionDetailViewControllerKey];
        collectionDetailVC.collection = item;
        [self.navigationController pushViewController:collectionDetailVC
                                             animated:YES];
    } else {
        if ([self isCollectionTabAndSection:indexPath.section]) {
            [self createCollection];
        }
    }
}

#pragma mark - MRSLProfilePanelCollectionViewCellDelegate

- (void)profilePanelDidSelectFollowers {
    self.shouldShowFollowers = YES;
    [self performSegueWithIdentifier:MRSLStoryboardSegueFollowListKey
                              sender:nil];
}

- (void)profilePanelDidSelectFollowing {
    self.shouldShowFollowers = NO;
    [self performSegueWithIdentifier:MRSLStoryboardSegueFollowListKey
                              sender:nil];
}

#pragma mark - MRSLSegmentedHeaderReusableViewDelegate

- (void)segmentedHeaderDidSelectIndex:(NSInteger)index {
    if (_dataSourceTabType != index) {
        self.dataSourceTabType = index;

        switch (index) {
            case MRSLDataSourceTypeLikedMorsel:
                self.emptyStateString = @"No activity yet";
                if ([self isCurrentUserProfile]) self.emptyStateButtonString = nil;
                self.dataSortType = MRSLDataSortTypeLikedDate;
                self.dataAscending = NO;
                break;
            case MRSLDataSourceTypeMorsel:
                self.emptyStateString = @"No morsels added";
                if ([self isCurrentUserProfile]) self.emptyStateButtonString = @"Add a morsel";
                self.dataSortType = MRSLDataSortTypePublishedDate;
                self.dataAscending = NO;
                break;
            case MRSLDataSourceTypePlace:
                self.emptyStateString = @"No places added";
                if ([self isCurrentUserProfile]) self.emptyStateButtonString = @"Add a place";
                self.dataSortType = MRSLDataSortTypeName;
                self.dataAscending = YES;
                break;
            case MRSLDataSourceTypeCollection:
                self.emptyStateString = @"No collections added";
                if ([self isCurrentUserProfile]) self.emptyStateButtonString = @"Add a collection";
                self.dataSortType = MRSLDataSortTypeCreationDate;
                self.dataAscending = NO;
                break;
            default:
                self.emptyStateString = @"No results";
                if ([self isCurrentUserProfile]) self.emptyStateButtonString = nil;
                self.dataSortType = MRSLDataSortTypeNone;
                self.dataAscending = NO;
                break;
        }

        [self setupRemoteRequestBlock];
        [self refreshRemoteContent];
    }
}

- (NSIndexSet *)segmentedButtonViewIndexSetToDisplay {
    if (![self.user ?: [MRSLUser currentUser] isProfessional]) {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        [indexSet addIndex:0];
        [indexSet addIndex:1];
        [indexSet addIndex:3];
        return indexSet;
    }
    return nil;
}

#pragma mark - MRSLStateViewDelegate

- (void)stateView:(MRSLStateView *)stateView
  didSelectButton:(UIButton *)button {
    if ([button.titleLabel.text isEqualToString:@"Add a morsel"]) {
        [self displayMorselAdd];
    } else if ([button.titleLabel.text isEqualToString:@"Add a collection"]) {
        [self createCollection];
    } else if ([button.titleLabel.text isEqualToString:@"Add a place"]) {
        [self displayAddPlace:button];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Report inappropriate"]) {
        [self.user API_reportWithSuccess:^(BOOL success) {
            [UIAlertView showOKAlertViewWithTitle:@"Report Successful"
                                          message:@"Thank you for the feedback!"];
        } failure:^(NSError *error) {
            [UIAlertView showOKAlertViewWithTitle:@"Report Failed"
                                          message:@"Please try again"];
        }];
    }
}

@end
