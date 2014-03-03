//
//  MRSLStatusHeaderCollectionReusableView.h
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLStatusHeaderCollectionReusableViewDelegate <NSObject>

@optional
- (void)statusHeaderDidSelectViewAllForType:(MRSLStoryStatusType)statusType;

@end

@interface MRSLStatusHeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) id <MRSLStatusHeaderCollectionReusableViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewAllButton;

@end
