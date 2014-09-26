//
//  MRSLExploreViewController.m
//  Morsel
//
//  Created by Javier Otero on 9/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLExploreViewController.h"

#import "MRSLCollectionView.h"
#import "MRSLMorselPreviewCollectionViewCell.h"

@interface MRSLExploreViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet MRSLCollectionView *collectionView;

@end

@implementation MRSLExploreViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_eventView = @"Explore";
    // Load Explore
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Setup layout
    // Setup predicate
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorselPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDMorselPreviewCellKey
                                                                                          forIndexPath:indexPath];
    // cell.morsel = foo;
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - UICollectionViewFlowLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(106.f, 106.f);
}

@end
