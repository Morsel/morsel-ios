//
//  MRSLMorselPreviewCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 4/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLMorselPreviewCollectionViewCell : UICollectionViewCell

+ (CGSize)defaultCellSizeForCollectionView:(UICollectionView *)collectionView
                               atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, getter=isEditing) BOOL editing;
@property (nonatomic, getter=isChecked) BOOL checked;

@property (weak, nonatomic) MRSLMorsel *morsel;

@end
