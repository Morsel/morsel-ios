//
//  MRSLIconStateView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/10/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLIconStateView.h"

@implementation MRSLIconStateView

#pragma mark - Class Methods

+ (instancetype)iconStateViewWithTitle:(NSString *)title imageNamed:(NSString *)imageName {
    MRSLIconStateView *iconStateView = [self stateView];

    [iconStateView setTitle:title];
    if (imageName) [iconStateView setAccessorySubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]]];

    return iconStateView;
}

@end
