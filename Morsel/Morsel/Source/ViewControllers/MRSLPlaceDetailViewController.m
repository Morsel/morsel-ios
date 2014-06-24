//
//  MRSLPlaceDetailViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceDetailViewController.h"

#import "MRSLCollectionViewArraySectionsDataSource.h"
#import "MRSLSectionHeaderReusableView.h"
#import "MRSLPlaceDetailBaseCollectionViewCell.h"
#import "MRSLPlaceDetailPanelCollectionViewCell.h"

#import "MRSLPlace.h"
#import "MRSLPlaceInfo.h"

@interface MRSLPlaceDetailViewController ()
<MRSLCollectionViewDataSourceDelegate,
MRSLPlaceDetailPanelCollectionViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *detailSections;

@property (strong, nonatomic) MRSLCollectionViewArraySectionsDataSource *collectionViewDataSource;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *contactInfo;
@property (strong, nonatomic) NSArray *hoursInfo;
@property (strong, nonatomic) NSArray *diningInfo;
@property (strong, nonatomic) NSArray *directionsInfo;

@end

@implementation MRSLPlaceDetailViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.contactInfo = _place.contactInfo;
    self.hoursInfo = _place.hourInfo;
    self.diningInfo = _place.diningInfo;
    self.directionsInfo = _place.directionsInfo;

    self.detailSections = [NSMutableArray arrayWithObject:@"Details"];

    if ([_contactInfo count] > 0) [_detailSections addObject:@"Contact"];
    if ([_hoursInfo count] > 0) [_detailSections addObject:@"Hours"];
    if ([_diningInfo count] > 0) [_detailSections addObject:@"Dining"];
    if ([_directionsInfo count] > 0) [_detailSections addObject:@"Directions"];

    __weak __typeof(self) weakSelf = self;
    self.collectionViewDataSource = [[MRSLCollectionViewArraySectionsDataSource alloc] initWithObjects:@[[NSNull null]]
                                                                                              sections:_detailSections
                                                                                    configureCellBlock:^UICollectionViewCell *(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                        return [weakSelf configureCellForCollectionView:collectionView
                                                                                                                              indexPath:indexPath];
                                                                                    } supplementaryBlock:^UICollectionReusableView *(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath) {
                                                                                        MRSLSectionHeaderReusableView *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                                                          withReuseIdentifier:@"ruid_SectionHeader"
                                                                                                                                                                                 forIndexPath:indexPath];
                                                                                        sectionHeader.titleLabel.text = [weakSelf.detailSections objectAtIndex:[indexPath section]];
                                                                                        return sectionHeader;
                                                                                    } sectionSizeBlock:^CGSize(UICollectionView *collectionView, NSInteger section) {
                                                                                        return [weakSelf configureSectionSizeForCollectionView:collectionView
                                                                                                                                     section:section];
                                                                                    } cellSizeBlock:^CGSize(UICollectionView *collectionView, NSIndexPath *indexPath) {
                                                                                        return [weakSelf configureCellSizeForCollectionView:collectionView
                                                                                                                                  indexPath:indexPath];
                                                                                    }];
    [self.collectionView setDataSource:_collectionViewDataSource];
    [self.collectionView setDelegate:_collectionViewDataSource];
    [self.collectionViewDataSource setDelegate:self];
}

#pragma mark - Private Methods

- (UICollectionViewCell *)configureCellForCollectionView:(UICollectionView *)collectionView
                                               indexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    MRSLPlaceInfo *placeInfo = nil;
    NSString *sectionName = [_detailSections objectAtIndex:[indexPath section]];
    if ([sectionName isEqualToString:@"Details"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_BasicInfoCell"
                                                         forIndexPath:indexPath];
        [(MRSLPlaceDetailPanelCollectionViewCell *)cell setPlace:_place];
        [(MRSLPlaceDetailPanelCollectionViewCell *)cell setDelegate:self];
    } else if ([sectionName isEqualToString:@"Contact"]) {
        placeInfo = [_contactInfo objectAtIndex:indexPath.row];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_ContactCell"
                                                         forIndexPath:indexPath];
        [(MRSLPlaceDetailBaseCollectionViewCell *)cell setPlaceInfo:placeInfo];
    } else if ([sectionName isEqualToString:@"Hours"]) {
        placeInfo = [_hoursInfo objectAtIndex:indexPath.row];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_HoursCell"
                                                         forIndexPath:indexPath];
        [(MRSLPlaceDetailBaseCollectionViewCell *)cell setPlaceInfo:placeInfo];
    } else if ([sectionName isEqualToString:@"Dining"]) {
        placeInfo = [_diningInfo objectAtIndex:indexPath.row];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_InfoCell"
                                                         forIndexPath:indexPath];
        [(MRSLPlaceDetailBaseCollectionViewCell *)cell setPlaceInfo:placeInfo];
    } else if ([sectionName isEqualToString:@"Directions"]) {
        placeInfo = [_directionsInfo objectAtIndex:indexPath.row];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_InfoCell"
                                                         forIndexPath:indexPath];
        [(MRSLPlaceDetailBaseCollectionViewCell *)cell setPlaceInfo:placeInfo];
    }

    return cell;
}

- (CGSize)configureSectionSizeForCollectionView:(UICollectionView *)collectionView
                                        section:(NSInteger)section {
    NSString *sectionName = [_detailSections objectAtIndex:section];
    CGSize cellSize = CGSizeMake(320.f, 44.f);
    if ([sectionName isEqualToString:@"Details"]) {
        cellSize.height = 0.f;
    }
    return cellSize;
}

- (CGSize)configureCellSizeForCollectionView:(UICollectionView *)collectionView
                                   indexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = [_detailSections objectAtIndex:[indexPath section]];
    CGSize cellSize = CGSizeMake(320.f, 44.f);
    if ([sectionName isEqualToString:@"Details"]) {
        cellSize.height = 180.f;
    }
    return cellSize;
}

#pragma mark - MRSLCollectionViewDataSourceDelegate

- (NSInteger)collectionViewDataSourceNumberOfItemsInSection:(NSInteger)section {
    NSString *sectionName = [_detailSections objectAtIndex:section];
    NSInteger numberOfItems = 0;
    if ([sectionName isEqualToString:@"Details"]) {
        numberOfItems = 1;
    } else if ([sectionName isEqualToString:@"Contact"]) {
        numberOfItems = [_contactInfo count];
    } else if ([sectionName isEqualToString:@"Hours"]) {
        numberOfItems = [_hoursInfo count];
    } else if ([sectionName isEqualToString:@"Dining"]) {
        numberOfItems = [_diningInfo count];
    } else if ([sectionName isEqualToString:@"Directions"]) {
        numberOfItems = [_directionsInfo count];
    }
    return numberOfItems;
}

- (void)collectionViewDataSource:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = [_detailSections objectAtIndex:indexPath.section];
    if ([sectionName isEqualToString:@"Contact"]) {
        [self handleContactSelectionForPlaceInfo:_contactInfo[indexPath.row]];
    }
}

- (void)handleContactSelectionForPlaceInfo:(MRSLPlaceInfo *)placeInfo {
    if (!placeInfo.secondaryInfo) return;

    if ([placeInfo.primaryInfo isEqualToString:@"twitter"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification
                                                            object:@{@"title": self.place.name,
                                                                     @"url": [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", TWITTER_BASE_URL, placeInfo.secondaryInfo]]}];
    } else if ([placeInfo.primaryInfo isEqualToString:@"phone"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldCallPhoneNumberNotification
                                                            object:@{@"phone": placeInfo.secondaryInfo}];
    } else if ([placeInfo.primaryInfo isEqualToString:@"website"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification
                                                            object:@{@"title": self.place.name,
                                                                     @"url": [NSURL URLWithString:placeInfo.secondaryInfo]}];
    }
}

#pragma mark - MRSLPlaceDetailPanelCollectionViewCellDelegate

- (void)placeDetailPanelDidSelectMenu {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": _place.name ?: @"Menu",
                                                                                                                   @"url": [NSURL URLWithString:_place.menu_mobile_url ?: _place.menu_url]}];
}

- (void)placeDetailPanelDidSelectReservation {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": _place.name ?: @"Reservation",
                                                                                                                   @"url": [NSURL URLWithString:_place.reservations_url]}];
}

#pragma mark - Dealloc

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
}

@end
