//
//  MorselCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMorsel;

@interface MRSLMorselCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) MRSLMorsel *morsel;

@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *morselPipeView;

@end
