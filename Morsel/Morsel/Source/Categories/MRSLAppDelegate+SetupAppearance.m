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
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
            [[UINavigationBar appearance] setBarTintColor:[UIColor morselDefaultNavigationBarBackgroundColor]];
            [[UINavigationBar appearance] setTintColor:[UIColor morselPrimary]];
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"graphic-navigation-bar-background"]
                                               forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearance] setBackgroundColor:[UIColor morselDefaultNavigationBarBackgroundColor]];

        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                               UITextAttributeFont : [UIFont robotoSlabBoldFontOfSize:17.f],
                                                               UITextAttributeTextColor : [UIColor morselDefaultTextColor],
                                                               UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.f, 0.f)]
                                                               }];

        [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                               UITextAttributeFont : [UIFont robotoLightFontOfSize:17.f],
                                                               UITextAttributeTextColor : [UIColor morselPrimary],
                                                               UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.f, 0.f)]
                                                               }
                                                    forState:UIControlStateNormal];

        [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                               UITextAttributeFont : [UIFont robotoLightFontOfSize:17.f],
                                                               UITextAttributeTextColor : [UIColor morselDefaultPlaceholderTextColor],
                                                               UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.f, 0.f)]
                                                               }
                                                    forState:UIControlStateDisabled];
    }

    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor morselDefaultBackgroundColor]];
}

@end
