//
//  UIViewController+Additions.h
//  Morsel
//
//  Created by Javier Otero on 7/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Additions)

#pragma mark - Utility

- (UIViewController *)topPresentingViewController;

#pragma mark - Cleanup

- (void)removeSubviews;
- (void)resetChildViewControllers;
- (void)resetChildNavigationControllers;

@end
