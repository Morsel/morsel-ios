//
//  MRSLProfileEditPlacesViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileEditPlacesViewController.h"
#import "MRSLPlacesAddViewController.h"

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
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLProfileEditPlacesViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.placeIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_placeIDs", [MRSLUser currentUser].username]] ?: [NSMutableArray array];
    self.dataSource = [[MRSLCollectionViewFetchResultsDataSource alloc] initWithManagedObjectClass:[MRSLPlace class]
                                                                                         predicate:[NSPredicate predicateWithFormat:@"placeID IN %@", _placeIDs]
                                                                                configureCellBlock:^UICollectionViewCell *(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                    MRSLPlaceCollectionViewCell *placeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_PlaceCell"
                                                                                                                                                                           forIndexPath:indexPath];
                                                                                        placeCell.place = item;
                                                                                        return placeCell;
                                                                                    return nil;
                                                                                } collectionView:_collectionView];
    self.dataSource.delegate = self;
    [self.collectionView setDataSource:_dataSource];
    [self.collectionView setDelegate:_dataSource];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.collectionView addSubview:_refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
                                          [weakSelf.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [weakSelf.refreshControl endRefreshing];
    }];
}

- (IBAction)addPlace:(id)sender {
    [self.navigationController pushViewController:[[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLPlacesAddViewController"]
                                         animated:YES];
}

#pragma mark - Private Methods

- (void)updateDataSourcePredicate {
    [self.dataSource updateFetchRequestWithManagedObjectClass:[MRSLPlace class]
                                                withPredicate:[NSPredicate predicateWithFormat:@"placeID IN %@", _placeIDs]];
}

#pragma mark - MRSLCollectionViewDataSourceDelegate

- (NSInteger)collectionViewDataSourceNumberOfItemsInSection:(NSInteger)section {
    return [_dataSource count];
}

- (void)collectionViewDataSource:(UICollectionView *)collectionView didSelectItem:(id)item {
    if ([self.delegate respondsToSelector:@selector(profileEditPlacesDidSelectPlace:)]) {
        [self.delegate profileEditPlacesDidSelectPlace:item];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
}

@end
