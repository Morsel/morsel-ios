//
//  MRSLPlaceViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceViewController.h"

#import "MRSLAPIService+Place.h"
#import "MRSLAPIService+Router.h"

#import "MRSLAPIClient.h"
#import "MRSLFollowButton.h"
#import "MRSLPanelSegmentedCollectionViewDataSource.h"
#import "MRSLPlaceDetailViewController.h"
#import "MRSLProfileViewController.h"
#import "MRSLSegmentedHeaderReusableView.h"
#import "MRSLSocialService.h"
#import "MRSLMorselDetailViewController.h"

#import "MRSLCollectionView.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLPlaceUserCollectionViewCell.h"
#import "MRSLPlacePanelCollectionViewCell.h"

#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLPlaceViewController ()
<UIActionSheetDelegate,
MRSLCollectionViewDataSourceDelegate,
MRSLPlacePanelCollectionViewCellDelegate,
MRSLSegmentedHeaderReusableViewDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (nonatomic) MRSLDataSourceType dataSourceTabType;

@property (weak, nonatomic) IBOutlet MRSLCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet MRSLFollowButton *followButton;

@property (strong, nonatomic) NSMutableArray *objectIDs;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) MRSLPanelSegmentedCollectionViewDataSource *segmentedPanelCollectionViewDataSource;

@end

@implementation MRSLPlaceViewController

#pragma mark - Instance Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    self.userInfo = userInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.userInfo[@"place_id"]) {
        self.place = [MRSLPlace MR_findFirstByAttribute:MRSLPlaceAttributes.placeID
                                              withValue:self.userInfo[@"place_id"]];
        if (!_place) {
            self.place = [MRSLPlace MR_createEntity];
            self.place.placeID = @([self.userInfo[@"place_id"] intValue]);
        }
        __weak __typeof(self)weakSelf = self;
        [_appDelegate.apiService getPlace:_place
                                  success:^(id responseObject) {
                                      if (weakSelf) {
                                          [weakSelf loadObjectIDs];
                                          [weakSelf setupCollectionViewDataSource];
                                          [weakSelf refreshContent];
                                      }
                                  }
                                  failure:^(NSError *error) {
                                      [UIAlertView showAlertViewForErrorString:@"Unable to load place."
                                                                      delegate:nil];
                                  }];
    }

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.collectionView addSubview:_refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.segmentedPanelCollectionViewDataSource) {
        [self loadObjectIDs];
        [self setupCollectionViewDataSource];
        [self refreshContent];
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

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    [self.collectionView toggleLoading:loading];
}

- (void)setupCollectionViewDataSource {
    __weak __typeof(self) weakSelf = self;
    NSString *predicateString = [NSString stringWithFormat:@"%@ID", [MRSLUtil stringForDataSourceType:_dataSourceTabType]];
    self.segmentedPanelCollectionViewDataSource = [[MRSLPanelSegmentedCollectionViewDataSource alloc] initWithManagedObjectClass:[MRSLUtil classForDataSourceType:_dataSourceTabType]
                                                                                                                       predicate:[NSPredicate predicateWithFormat:@"%K IN %@", predicateString, _objectIDs]
                                                                                                                  collectionView:_collectionView
                                                                                                                      cellConfig:^(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                                                          return [weakSelf configureCellForItem:item
                                                                                                                                               inCollectionView:collectionView
                                                                                                                                                    atIndexPath:indexPath
                                                                                                                                                       andCount:count];
                                                                                                                      } supplementaryConfig:^(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath) {
                                                                                                                          UICollectionReusableView *reusableView = nil;
                                                                                                                          if (indexPath.section == 1) {
                                                                                                                              reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                                                                withReuseIdentifier:MRSLStoryboardRUIDHeaderCellKey
                                                                                                                                                                                       forIndexPath:indexPath];
                                                                                                                              [(MRSLSegmentedHeaderReusableView *)reusableView setDelegate:weakSelf];
                                                                                                                          } else {
                                                                                                                              reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                                                                withReuseIdentifier:MRSLStoryboardRUIDHeaderCellKey
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
    [self.collectionView setDataSource:_segmentedPanelCollectionViewDataSource];
    [self.collectionView setDelegate:_segmentedPanelCollectionViewDataSource];
    [self.collectionView setEmptyStateTitle:@"No morsels added"];

    [self.segmentedPanelCollectionViewDataSource setDelegate:self];
}

- (void)refreshPlace {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getPlace:_place
                              success:^(id responseObject) {
                                  if (weakSelf) [weakSelf populatePlaceInformation];
                              }
                              failure:nil];
}

- (void)populatePlaceInformation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.followButton.place = _place;
        [_collectionView reloadData];
    });
}

- (void)loadObjectIDs {
    NSString *objectIDsKey = [NSString stringWithFormat:@"place_%@_%@IDs", _place.placeID, [MRSLUtil stringForDataSourceType:_dataSourceTabType]];
    self.objectIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:objectIDsKey] ?: [NSMutableArray array];
}

- (void)updateDataSourcePredicate {
    NSString *predicateString = [NSString stringWithFormat:@"%@ID", [MRSLUtil stringForDataSourceType:_dataSourceTabType]];
    [self.segmentedPanelCollectionViewDataSource updateFetchRequestWithManagedObjectClass:[MRSLUtil classForDataSourceType:_dataSourceTabType]
                                                                            withPredicate:[NSPredicate predicateWithFormat:@"%K IN %@", predicateString, _objectIDs]];
}

- (void)refreshContent {
    if ([self isLoading]) return;
    [self refreshPlace];
    self.loadedAll = NO;
    self.loading = YES;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getPlaceData:_place
                        forDataSourceType:_dataSourceTabType
                                withMaxID:nil
                                orSinceID:nil
                                 andCount:@(12)
                                  success:^(NSArray *responseArray) {
                                      [weakSelf.refreshControl endRefreshing];
                                      weakSelf.objectIDs = [responseArray mutableCopy];
                                      [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                forKey:[NSString stringWithFormat:@"place_%@_%@IDs", weakSelf.place.placeID, [MRSLUtil stringForDataSourceType:weakSelf.dataSourceTabType]]];
                                      [weakSelf updateDataSourcePredicate];
                                      weakSelf.loading = NO;
                                  } failure:^(NSError *error) {
                                      [weakSelf.refreshControl endRefreshing];
                                      weakSelf.loading = NO;
                                  }];
}

- (void)loadMore {
    if (_loadingMore || !_place || _loadedAll || [self isLoading]) return;
    self.loadingMore = YES;
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getPlaceData:_place
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
                                                                                        forKey:[NSString stringWithFormat:@"place_%@_%@IDs", weakSelf.place.placeID, [MRSLUtil stringForDataSourceType:weakSelf.dataSourceTabType]]];
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

#pragma mark - MRSLPanelSegmentedCollectionViewDataSource

- (UICollectionViewCell *)configureCellForItem:(id)item
                              inCollectionView:(UICollectionView *)collectionView
                                   atIndexPath:(NSIndexPath *)indexPath
                                      andCount:(NSUInteger)count {
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDPanelCellKey
                                                         forIndexPath:indexPath];
        [(MRSLPlacePanelCollectionViewCell *)cell setPlace:self.place];
        [(MRSLPlacePanelCollectionViewCell *)cell setDelegate:self];
    } else {
        if (count > 0) {
            [cell addBorderWithDirections:MRSLBorderSouth
                              borderColor:[UIColor morselDefaultBorderColor]];
            if ([item isKindOfClass:[MRSLMorsel class]]) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDMorselPreviewCellKey
                                                                 forIndexPath:indexPath];
                [(MRSLMorselPreviewCollectionViewCell *)cell setMorsel:item];
            } else if ([item isKindOfClass:[MRSLUser class]]) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDUserCellKey
                                                                 forIndexPath:indexPath];
                [(MRSLPlaceUserCollectionViewCell *)cell setUser:item];
                if (indexPath.row != count) {
                    [cell addBorderWithDirections:MRSLBorderSouth
                                      borderColor:[UIColor morselDefaultBorderColor]];
                }
            }
        }
    }

    if (!cell) {
        // Create an empty state cell.
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDEmptyCellKey
                                                         forIndexPath:indexPath];
        // If the place doesn't have twitter, set the label inside the cell to black to not look tappable (default)
        if (!_place.twitter_username) {
            [[[cell contentView] subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
                if ([subview isKindOfClass:[UILabel class]]) {
                    [(UILabel *)subview setTextColor:[UIColor blackColor]];
                }
            }];
        }
    }
    return cell;
}

- (CGSize)configureSizeForCollectionView:(UICollectionView *)collectionView
                             atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(collectionView.frame.size.width, 120.f);
    } else {
        if ([self.segmentedPanelCollectionViewDataSource count] == 0) {
            return CGSizeMake(collectionView.frame.size.width, 80.f);
        } else {
            id object = [_segmentedPanelCollectionViewDataSource objectAtIndexPath:indexPath];
            if ([object isKindOfClass:[MRSLMorsel class]]) {
                return CGSizeMake(MAX(106.f, (collectionView.frame.size.width / 3) - 1.f), MAX(106.f, (collectionView.frame.size.width / 3) - 1.f));
            } else {
                return CGSizeMake(collectionView.frame.size.width, 80.f);
            }
        }
    }
}

#pragma mark - MRSLCollectionViewDataSourceDelegate

- (void)collectionViewDataSource:(UICollectionView *)collectionView didSelectItem:(id)item {
    if ([item isKindOfClass:[MRSLMorsel class]]) {
        MRSLMorsel *morsel = item;
        MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
        userMorselsFeedVC.morsel = morsel;
        userMorselsFeedVC.user = morsel.creator;
        [self.navigationController pushViewController:userMorselsFeedVC
                                             animated:YES];
    } else if ([item isKindOfClass:[MRSLUser class]]) {
        MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
        profileVC.user = item;
        [self.navigationController pushViewController:profileVC
                                             animated:YES];
    }
}

- (void)collectionViewDataSource:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:MRSLStoryboardRUIDEmptyCellKey] && _place.twitter_username) {
        [[MRSLSocialService sharedService] shareTextToTwitter:[NSString stringWithFormat:@"Hey @%@ I’d love to see your food and drinks on @eatmorsel!", _place.twitter_username]
                                             inViewController:self
                                                      success:nil
                                                       cancel:nil];
    }
}

- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView withOffset:(CGFloat)offset {
    if (offset <= 10.f) {
        [self loadMore];
    }
}

#pragma mark - MRSLSegmentedHeaderReusableViewDelegate

- (void)segmentedHeaderDidSelectIndex:(NSInteger)index {
    if (_dataSourceTabType != index) {
        self.dataSourceTabType = index;

        switch (index) {
            case MRSLDataSourceTypeMorsel:
                [self.collectionView setEmptyStateTitle:@"No morsels added"];
                [self.segmentedPanelCollectionViewDataSource setDataSortType:MRSLDataSortTypeCreationDate
                                                                   ascending:NO];
                break;
            case MRSLDataSourceTypePlace:
                [self.collectionView setEmptyStateTitle:@"No places added"];
                [self.segmentedPanelCollectionViewDataSource setDataSortType:MRSLDataSortTypeName
                                                                   ascending:YES];
                break;
            default:
                [self.collectionView setEmptyStateTitle:@"No results"];
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

#pragma mark - MRSLPlacePanelCollectionViewCellDelegate

- (void)placePanelDidSelectDetails {
    MRSLPlaceDetailViewController *placeDetailVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlaceDetailViewControllerKey];
    placeDetailVC.place = _place;
    [self.navigationController pushViewController:placeDetailVC
                                         animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Report inappropriate"]) {
        [self.place API_reportWithSuccess:^(BOOL success) {
            [UIAlertView showOKAlertViewWithTitle:@"Report Successful"
                                          message:@"Thank you for the feedback!"];
        } failure:^(NSError *error) {
            [UIAlertView showOKAlertViewWithTitle:@"Report Failed"
                                          message:@"Please try again"];
        }];
    }
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
}

@end
