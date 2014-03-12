//
//  MRSLAppDelegate+SetupAppearance.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAppDelegate+SetupAppearance.h"

@implementation MRSLAppDelegate (SetupAppearance)

+ (void)setupTheme {
    //  Setup NavBar
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) {
            [[UINavigationBar appearance] setBarTintColor:[UIColor morselUserInterface]];
            [[UINavigationBar appearance] setTintColor:[UIColor morselRed]];
            [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:2.f forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"graphic-navigation-bar-background"]
                                               forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearance] setBackgroundColor:[UIColor morselUserInterface]];
        } else {
            [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                               forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearance] setBackgroundColor:[UIColor morselUserInterface]];
            [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage alloc] init]
                                                              forState:UIControlStateNormal
                                                            barMetrics:UIBarMetricsDefault];
            [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage alloc] init]
                                                    forState:UIControlStateNormal
                                                  barMetrics:UIBarMetricsDefault];
        }

        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                               UITextAttributeFont : [UIFont helveticaNeueLTStandardThinCondensedFontOfSize:24.f],
                                                               UITextAttributeTextColor : [UIColor morselDarkContent],
                                                               UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.f, 0.f)]
                                                               }];

        [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                               UITextAttributeFont : [UIFont helveticaLightFontOfSize:17.f],
                                                               UITextAttributeTextColor : [UIColor morselRed],
                                                               UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.f, 0.f)]
                                                               }
                                                    forState:UIControlStateNormal];

        [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                               UITextAttributeFont : [UIFont helveticaLightFontOfSize:17.f],
                                                               UITextAttributeTextColor : [UIColor morselLightContent],
                                                               UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.f, 0.f)]
                                                               }
                                                    forState:UIControlStateDisabled];
    }

    //  Setup TabBar
    if ([[UITabBarItem class] respondsToSelector:@selector(appearance)]) {
        // Todo once tab bar returns.
    }
}

@end
