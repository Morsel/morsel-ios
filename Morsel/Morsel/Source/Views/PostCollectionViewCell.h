//
//  PostCollectionViewCell.h
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLPost;

@interface PostCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) MRSLPost *post;

@property (nonatomic, weak) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *postPipeView;

@end
