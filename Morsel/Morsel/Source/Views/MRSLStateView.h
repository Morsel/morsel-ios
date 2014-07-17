//
//  MRSLStateView.h
//  Morsel
//
//  Created by Marty Trzpit on 7/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLStateView;

@protocol MRSLStateViewDelegate <NSObject>

@optional
- (void)stateView:(MRSLStateView *)stateView didSelectButton:(UIButton *)button;

@end

@interface MRSLStateView : UIView

+ (instancetype)stateView;
+ (instancetype)stateViewWithWidth:(CGFloat)width;

@property (nonatomic, weak) id <MRSLStateViewDelegate> delegate;

- (void)setTitle:(NSString *)title;
- (void)setButtonTitle:(NSString *)title;
- (void)setAccessorySubview:(UIView *)accessorySubview;
- (CGPoint)defaultOffset;

@end
