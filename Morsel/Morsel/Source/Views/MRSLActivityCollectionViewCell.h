//
//  MRSLActivityCollectionViewCell.h
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLActivityCollectionViewCell, MRSLActivity;

@protocol MorselActivityCollectionViewCellDelegate <NSObject>

@optional
- (void)itemActivityCollectionViewCellDidDisplayProgression:(MRSLActivityCollectionViewCell *)cell;
- (void)itemActivityCollectionViewCellDidSelectActivity:(MRSLActivity *)activity;

@end

@interface MRSLActivityCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<MorselActivityCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) MRSLActivity *activity;

@end
