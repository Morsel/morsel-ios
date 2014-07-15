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
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        if ([viewController isKindOfClass:[MRSLMorselListViewController class]]) {
            isOnMorselAddFlow = NO;
            *stop = YES;
        }
    }];
    if (isOnMorselAddFlow) {
        isOnMorselAddFlow = [[self.viewControllers lastObject] isKindOfClass:[MRSLMorselEditViewController class]] && [self.viewControllers count] == 2;
    }
    return isOnMorselAddFlow;
}

@end
