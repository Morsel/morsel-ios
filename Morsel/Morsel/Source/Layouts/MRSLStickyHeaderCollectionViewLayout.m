//
//  MRSLStickyHeaderCollectionViewLayout.m
//  Morsel
//
//  Created by Javier Otero on 5/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStickyHeaderCollectionViewLayout.h"

@implementation MRSLStickyHeaderCollectionViewLayout

- (id)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
	return self;
}

- (void)setUp {
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    UICollectionView *const cv = self.collectionView;
    CGPoint const contentOffset = cv.contentOffset;

    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];

    for (UICollectionViewLayoutAttributes *layoutAttributes in attributes) {
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:layoutAttributes.indexPath.section];
        }
    }

    for (UICollectionViewLayoutAttributes *layoutAttributes in attributes) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [missingSections removeIndex:layoutAttributes.indexPath.section];
        }
    }

    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];

        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                  atIndexPath:indexPath];

        if (layoutAttributes) [attributes addObject:layoutAttributes];
    }];

	for (UICollectionViewLayoutAttributes *layoutAttributes in attributes) {

        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];

            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];

            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            UICollectionViewLayoutAttributes *lastCellAttrs = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];

			if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
				CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
				CGPoint origin = layoutAttributes.frame.origin;
				origin.y = MIN(MAX(contentOffset.y, (CGRectGetMinY(firstCellAttrs.frame) - headerHeight)),
							   (CGRectGetMaxY(lastCellAttrs.frame) - headerHeight));

				layoutAttributes.zIndex = 1024;
				layoutAttributes.frame = (CGRect){.origin = origin, .size = layoutAttributes.frame.size};
			} else {
				CGFloat headerWidth = CGRectGetWidth(layoutAttributes.frame);
				CGPoint origin = layoutAttributes.frame.origin;
				origin.x = MIN(MAX(contentOffset.x, (CGRectGetMinX(firstCellAttrs.frame) - headerWidth)),
							   (CGRectGetMaxX(lastCellAttrs.frame) - headerWidth));

				layoutAttributes.zIndex = 1024;
				layoutAttributes.frame = (CGRect){.origin = origin, .size = layoutAttributes.frame.size};
			}
        }
    }

    return attributes;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}

@end
