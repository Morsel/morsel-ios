//
//  MRSLNavigationController.m
//  Morsel
//
//  Created by Marty Trzpit on 7/16/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLNavigationController.h"

@interface MRSLNavigationController ()

@end

@implementation MRSLNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    UINavigationBar *navigationBar = self.navigationBar;

    [navigationBar addShadowWithOpacity:0.4f
                              andRadius:1.f
                              withColor:[UIColor blackColor]];

    [navigationBar setTranslucent:NO];
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
