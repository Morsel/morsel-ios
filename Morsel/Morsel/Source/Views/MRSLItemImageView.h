//
//  MRSLItemImageView.h
//  Morsel
//
//  Created by Javier Otero on 3/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLItemImageViewDelegate <NSObject>

@optional
- (void)itemImageViewDidSelectMorsel:(MRSLItem *)item;

@end

@interface MRSLItemImageView : UIImageView

@property (weak, nonatomic) id <MRSLItemImageViewDelegate> delegate;

@property (weak, nonatomic) MRSLItem *item;

- (void)displayEmptyMorselState;

@end
