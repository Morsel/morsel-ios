//
//  UINavigationController+Additions.m
//  Morsel
//
//  Created by Javier Otero on 7/15/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UINavigationController+Additions.h"

#import "MRSLMorselEditViewController.h"
#import "MRSLMorselListViewController.h"

@implementation UINavigationController (Additions)

- (BOOL)isDisplayingMorselAdd {
    __block BOOL isOnMorselAddFlow = YES;

    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:[MRSLMorselListViewController class]]) {
            isOnMorselAddFlow = NO;
            break;
        }
    }
    if (isOnMorselAddFlow) {
        isOnMorselAddFlow = [[self.viewControllers lastObject] isKindOfClass:[MRSLMorselEditViewController class]];
    }
    return isOnMorselAddFlow;
}

@end
