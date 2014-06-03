//
//  MRSLDataSource.h
//  Morsel
//
//  Created by Marty Trzpit on 4/2/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

// Based off of: http://www.objc.io/issue-1/lighter-view-controllers.html
typedef UICollectionViewCell *(^MRSLCellConfigureBlock)(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count);
typedef UICollectionReusableView *(^MRSLSupplementaryCellConfigureBlock)(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath);
typedef CGSize (^MRSLLayoutHeaderSizeConfigureBlock)(UICollectionView *collectionView, NSInteger section);
typedef CGSize (^MRSLLayoutCellSizeConfigureBlock)(UICollectionView *collectionView, NSIndexPath *indexPath);
typedef UIEdgeInsets (^MRSLLayoutSectionInsetConfigureBlock)(UICollectionView *collectionView, NSInteger section);

@protocol MRSLCollectionViewDataSourceDelegate <NSObject>

@optional
- (void)collectionViewDataSource:(UICollectionView *)collectionView
                   didSelectItem:(id)item;
- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView
                               withOffset:(CGFloat)offset;
- (NSInteger)collectionViewDataSourceNumberOfItemsInSection:(NSInteger)section;

@end

@interface MRSLCollectionViewDataSource : NSObject
<UICollectionViewDataSource,
UICollectionViewDelegate>

@property (weak, nonatomic) id <MRSLCollectionViewDataSourceDelegate> delegate;

- (id)initWithCollectionView:(UICollectionView *)collectionView;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)count;

@end