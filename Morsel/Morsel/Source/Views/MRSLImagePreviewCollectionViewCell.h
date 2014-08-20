//
//  MRSLImagePreviewCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLImagePreviewCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id mediaPreviewItem;

@property (weak, nonatomic) IBOutlet UILabel *itemPositionLabel;

@end
