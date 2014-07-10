//
//  MRSLStateView.h
//  Morsel
//
//  Created by Marty Trzpit on 7/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLStateView : UIView

+ (instancetype)stateView;
+ (instancetype)stateViewWithWidth:(CGFloat)width;

- (void)setTitle:(NSString *)title;
- (void)setAccessorySubview:(UIView *)accessorySubview;
- (CGPoint)defaultOffset;

@end
