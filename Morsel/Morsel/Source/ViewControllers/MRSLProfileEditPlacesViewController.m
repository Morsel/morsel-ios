//
//  MRSLProfileEditPlacesViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileEditPlacesViewController.h"

#import "MRSLAPIService+Place.h"

#import "MRSLCollectionViewFetchResultsDataSource.h"
#import "MRSLPlaceCollectionViewCell.h"

#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLProfileEditPlacesViewController ()
<MRSLCollectionViewDataSourceDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *placeIDs;
@property (strong, nonatomic) MRSLCollectionViewFetchResultsDataSource *dataSource;

@end

@implementation MRSLProfileEditPlacesViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.placeIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_placeIDs", [MRSLUser currentUser].username]] ?: [NSMutableArray array];
    self.dataSource = [[MRSLCollectionViewFetchResultsDataSource alloc] initWithManagedObjectClass:[MRSLPlace class]
                                                                                         predicate:[NSPredicate predicateWithFormat:@"placeID IN %@", _placeIDs]
                                                                                configureCellBlock:^UICollectionViewCell *(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                    if (!item) {
                                                                                        UICollectionViewCell *addCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_PlaceAddCell"
                                                                                                                                                                  forIndexPath:indexPath];
                                                                                        return addCell;
                                                                                    } else {
                                                                                        MRSLPlaceCollectionViewCell *placeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_PlaceCell"
                                                                                                                                                                           forIndexPath:indexPath];
                                                                                        placeCell.place = item;
                                                                                        return placeCell;
                                                                                    }
                                                                                    return nil;
                                                                                } collectionView:_collectionView];
    self.dataSource.delegate = self;
    [self.collectionView setDataSource:_dataSource];
    [self.collectionView setDelegate:_dataSource];
    [self refreshContent];
}

- (void)refreshContent {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getPlacesForUser:[MRSLUser currentUser]
                                    withMaxID:nil
                                    orSinceID:nil
                                     andCount:nil
                                      success:^(NSArray *responseArray) {
                                          weakSelf.placeIDs = [responseArray mutableCopy];
                                          [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                    forKey:[NSString stringWithFormat:@"%@_placeIDs", [MRSLUser currentUser].username]];
                                          [weakSelf updateDataSourcePredicate];
    } failure:^(NSError *error) {

    }];
}

#pragma mark - Private Methods

- (void)updateDataSourcePredicate {
    [self.dataSource updateFetchRequestWithManagedObjectClass:[MRSLPlace class]
                                                withPredicate:[NSPredicate predicateWithFormat:@"placeID IN %@", _placeIDs]];
}

#pragma mark - MRSLCollectionViewDataSourceDelegate

- (NSInteger)collectionViewDataSourceNumberOfItemsInSection:(NSInteger)section {
    return [_dataSource count] + 1;
}

- (void)collectionViewDataSource:(UICollectionView *)collectionView didSelectItem:(id)item {
    if (!item) {
        if ([self.delegate respondsToSelector:@selector(profileEditPlacesDidSelectAddNew)]) {
            [self.delegate profileEditPlacesDidSelectAddNew];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(profileEditPlacesDidSelectPlace:)]) {
            [self.delegate profileEditPlacesDidSelectPlace:item];
        }
    }
}

@end
