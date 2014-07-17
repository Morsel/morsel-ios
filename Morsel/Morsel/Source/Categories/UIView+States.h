//
//  UIView+States.h
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLStateViewDelegate;

@interface UIView (States)

- (void)setEmptyStateTitle:(NSString *)emptyStateTitle;
- (void)setEmptyStateButtonTitle:(NSString *)title;
- (void)setEmptyStateDelegate:(id<MRSLStateViewDelegate>)delegate;
- (void)toggleLoading:(BOOL)shouldEnable;

@end
