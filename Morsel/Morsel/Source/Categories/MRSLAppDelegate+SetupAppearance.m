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

        NSShadow *shadow = [NSShadow new];
        [shadow setShadowColor: [UIColor colorWithWhite:0.f
                                                  alpha:0.f]];
        [shadow setShadowOffset: CGSizeMake(0.f, 0.f)];

        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                               NSFontAttributeName : [UIFont primaryBoldFontOfSize:17.f],
                                                               NSForegroundColorAttributeName : [UIColor morselDefaultTextColor],
                                                               NSShadowAttributeName : shadow
                                                               }];

        [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                               NSFontAttributeName : [UIFont primaryLightFontOfSize:17.f],
                                                               NSForegroundColorAttributeName : [UIColor morselPrimary],
                                                               NSShadowAttributeName : shadow
                                                               }
                                                    forState:UIControlStateNormal];

        [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                               NSFontAttributeName : [UIFont primaryLightFontOfSize:17.f],
                                                               NSForegroundColorAttributeName : [UIColor morselDefaultPlaceholderTextColor],
                                                               NSShadowAttributeName : shadow
                                                               }
                                                    forState:UIControlStateDisabled];
    }

    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor morselDefaultBackgroundColor]];
}

@end
