//
//  MRSLToolbarView.h
//  Morsel
//
//  Created by Javier Otero on 7/11/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLToolbarViewDelegate <NSObject>

@optional
- (void)toolbarDidSelectLeftButton:(UIButton *)leftButton;
- (void)toolbarDidSelectRightButton:(UIButton *)rightButton;

@end

@interface MRSLToolbar : UIView

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet id <MRSLToolbarViewDelegate> delegate;

@end
