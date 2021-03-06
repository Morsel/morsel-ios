//
//  MRSLCollectionViewDataSource.h
//  Morsel
//
//  Created by Marty Trzpit on 4/2/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MRSLDataSource.h"

typedef UICollectionViewCell *(^MRSLCVCellConfigureBlock)(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count);
typedef UICollectionReusableView *(^MRSLSupplementaryCellConfigureBlock)(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath);
typedef CGSize (^MRSLLayoutHeaderSizeConfigureBlock)(UICollectionView *collectionView, NSInteger section);
typedef CGSize (^MRSLLayoutCellSizeConfigureBlock)(UICollectionView *collectionView, NSIndexPath *indexPath);
typedef UIEdgeInsets (^MRSLLayoutSectionInsetConfigureBlock)(UICollectionView *collectionView, NSInteger section);
typedef CGSize (^MRSLLayoutSectionSizeConfigureBlock)(UICollectionView *collectionView, NSInteger section);

@protocol MRSLCollectionViewDataSourceDelegate <NSObject>

@optional
- (void)collectionViewDataSource:(UICollectionView *)collectionView
                   didSelectItem:(id)item;
- (void)collectionViewDataSource:(UICollectionView *)collectionView
        didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView
                               withOffset:(CGFloat)offset;
- (NSInteger)collectionViewDataSourceNumberOfItemsInSection:(NSInteger)section;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

@end

@interface MRSLCollectionViewDataSource : MRSLDataSource
<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (weak, nonatomic) id <MRSLCollectionViewDataSourceDelegate> delegate;

- (id)initWithCollectionView:(UICollectionView *)collectionView;
- (id)initWithObjects:(id)objects
   configureCellBlock:(MRSLCVCellConfigureBlock)configureCellBlock;
- (id)initWithObjects:(NSArray *)objects
             sections:(NSArray *)sectionsOrNil
   configureCellBlock:(MRSLCVCellConfigureBlock)configureCellBlock
   supplementaryBlock:(MRSLSupplementaryCellConfigureBlock)supplementaryBlock
sectionHeaderSizeBlock:(MRSLLayoutSectionSizeConfigureBlock)sectionHeaderSizeBlock
sectionFooterSizeBlock:(MRSLLayoutSectionSizeConfigureBlock)sectionFooterSizeBlock
        cellSizeBlock:(MRSLLayoutCellSizeConfigureBlock)cellSizeBlock
   sectionInsetConfig:(MRSLLayoutSectionInsetConfigureBlock)insetConfig;

@end
