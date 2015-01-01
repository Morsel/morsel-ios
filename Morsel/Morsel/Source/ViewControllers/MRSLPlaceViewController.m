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

@property (nonatomic) BOOL dataAscending;

@property (nonatomic) MRSLDataSourceType dataSourceTabType;
@property (nonatomic) MRSLDataSortType dataSortType;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (weak, nonatomic) IBOutlet MRSLFollowButton *followButton;

@end

@implementation MRSLPlaceViewController

#pragma mark - Instance Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    self.userInfo = userInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.emptyStateString = @"No morsels added";
    self.dataSourceTabType = MRSLDataSourceTypeMorsel;
    self.dataSortType = MRSLDataSortTypePublishedDate;

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
                                          [weakSelf setupRemoteRequestBlock];
                                      }
                                  }
                                  failure:^(NSError *error) {
                                      [UIAlertView showAlertViewForErrorString:@"Unable to load place."
                                                                      delegate:nil];
                                  }];
    } else {
        [self setupRemoteRequestBlock];
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

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"place_%@_%@IDs", _place.placeID, [MRSLUtil stringForDataSourceType:_dataSourceTabType]];
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

- (MRSLCollectionViewDataSource *)dataSource {
    MRSLCollectionViewDataSource *superDataSource = (MRSLCollectionViewDataSource *)[super dataSource];
    if (superDataSource) return superDataSource;

    __weak __typeof(self) weakSelf = self;
    MRSLCollectionViewDataSource *newDataSource = [[MRSLPanelSegmentedCollectionViewDataSource alloc] initWithObjects:nil
                                                                                                             sections:nil
                                                                                                   configureCellBlock:^(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                                       return [weakSelf configureCellForItem:item
                                                                                                                            inCollectionView:collectionView
                                                                                                                                 atIndexPath:indexPath
                                                                                                                                       count:count];
                                                                                                   } supplementaryBlock:^(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath) {
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
                                                                                                   } sectionHeaderSizeBlock:^(UICollectionView *collectionView, NSInteger section) {
                                                                                                       if (section != 0) {
                                                                                                           return CGSizeMake(collectionView.bounds.size.width, 50.f);
                                                                                                       } else {
                                                                                                           return CGSizeZero;
                                                                                                       }
                                                                                                   } sectionFooterSizeBlock:nil
                                                                                                        cellSizeBlock:^(UICollectionView *collectionView, NSIndexPath *indexPath) {
                                                                                                            return [weakSelf configureSizeForCollectionView:collectionView
                                                                                                                                                atIndexPath:indexPath];
                                                                                                        } sectionInsetConfig:^(UICollectionView *collectionView, NSInteger section) {
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
    [self refreshPlace];
    __weak __typeof(self)weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [_appDelegate.apiService getPlaceData:strongSelf.place
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
        [self.collectionView reloadData];
    });
}

#pragma mark - MRSLPanelSegmentedCollectionViewDataSource

- (UICollectionViewCell *)configureCellForItem:(id)item
                              inCollectionView:(UICollectionView *)collectionView
                                   atIndexPath:(NSIndexPath *)indexPath
                                         count:(NSUInteger)count {
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
        if ([self.dataSource count] == 0) {
            return CGSizeMake(collectionView.frame.size.width, 80.f);
        } else {
            id object = [self.dataSource objectAtIndexPath:indexPath];
            if ([object isKindOfClass:[MRSLMorsel class]]) {
                return [MRSLMorselPreviewCollectionViewCell defaultCellSizeForCollectionView:collectionView
                                                                                 atIndexPath:indexPath];
            } else {
                return CGSizeMake(collectionView.frame.size.width, 80.f);
            }
        }
    }
}

#pragma mark - MRSLCollectionViewDataSourceDelegate

- (void)collectionViewDataSource:(UICollectionView *)collectionView
                   didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    id item = [self.dataSource objectAtIndexPath:indexPath];
    if ([item isKindOfClass:[MRSLMorsel class]]) {
        MRSLMorsel *morsel = item;
        MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
        userMorselsFeedVC.morsel = morsel;
        userMorselsFeedVC.user = morsel.creator;
        userMorselsFeedVC.isExplore = YES;
        [self.navigationController pushViewController:userMorselsFeedVC
                                             animated:YES];
    } else if ([item isKindOfClass:[MRSLUser class]]) {
        MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardProfileViewControllerKey];
        profileVC.user = item;
        [self.navigationController pushViewController:profileVC
                                             animated:YES];
    } else {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if ([cell.reuseIdentifier isEqualToString:MRSLStoryboardRUIDEmptyCellKey] && _place.twitter_username) {
            [[MRSLSocialService sharedService] shareTextToTwitter:[NSString stringWithFormat:@"Hey @%@ I’d love to see your food and drinks on @eatmorsel!", _place.twitter_username]
                                                 inViewController:self
                                                          success:nil
                                                           cancel:nil];
        }
    }
}

#pragma mark - MRSLSegmentedHeaderReusableViewDelegate

- (void)segmentedHeaderDidSelectIndex:(NSInteger)index {
    if (_dataSourceTabType != index) {
        self.dataSourceTabType = index;

        switch (index) {
            case MRSLDataSourceTypeMorsel:
                self.emptyStateString = @"No morsels added";
                self.dataSortType = MRSLDataSortTypePublishedDate;
                self.dataAscending = NO;
                break;
            case MRSLDataSourceTypePlace:
                self.emptyStateString = @"No places added";
                self.dataSortType = MRSLDataSortTypeName;
                self.dataAscending = YES;
                break;
            default:
                self.emptyStateString = @"No results";
                self.dataSortType = MRSLDataSortTypeNone;
                self.dataAscending = NO;
                break;
        }

        [self setupRemoteRequestBlock];
        [super refreshRemoteContent];
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

@end
