//
//  UIViewController+Additions.m
//  Morsel
//
//  Created by Javier Otero on 7/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

#pragma mark - Utility

- (UIViewController *)topPresentingViewController {
    UIViewController *topMostVC = (self.navigationController) ? self.navigationController : self;
    UIViewController *potentialTopMostVC = topMostVC;
    while (potentialTopMostVC != nil) {
        topMostVC = potentialTopMostVC;
        if (potentialTopMostVC.navigationController) potentialTopMostVC = potentialTopMostVC.navigationController;
        potentialTopMostVC = potentialTopMostVC.presentedViewController;
    }
    return topMostVC;
}

#pragma mark - Cleanup

- (void)removeSubviews {
    [[self.view subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
}

- (void)resetChildViewControllers {
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        viewController = nil;
    }];
}

- (void)resetChildNavigationControllers {
    [self.childViewControllers enumerateObjectsUsingBlock:^(UINavigationController *navController, NSUInteger idx, BOOL *stop) {
        if ([navController isKindOfClass:[UINavigationController class]]) {
            [navController willMoveToParentViewController:nil];
            [navController.view removeFromSuperview];
            [navController removeFromParentViewController];
            for (UIViewController *viewController in [navController viewControllers]) {
                [viewController beginAppearanceTransition:NO
                                                 animated:NO];
                [viewController.view removeFromSuperview];
                [viewController endAppearanceTransition];
            }
            [navController setViewControllers:nil];
            navController = nil;
        }
    }];
}

@end