//
//  UIView+States.h
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (States)

- (void)setEmptyStateTitle:(NSString *)emptyStateTitle;
- (void)toggleLoading:(BOOL)shouldEnable;

@end
