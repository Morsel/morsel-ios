//
//  MRSLLoadingStateView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLLoadingStateView.h"
#import "MRSLActivityIndicatorView.h"

static CGFloat kLoadingContainerWidth = 140.0f;

@implementation MRSLLoadingStateView

#pragma mark - Class Methods

+ (instancetype)loadingStateView {
    MRSLLoadingStateView *loadingStateView = [self stateViewWithWidth:kLoadingContainerWidth];

    [loadingStateView setTitle:@"Loading..."];
    MRSLActivityIndicatorView *activityIndicatorView = [MRSLActivityIndicatorView defaultActivityIndicatorView];
    [activityIndicatorView startAnimating];
    [loadingStateView setAccessorySubview:activityIndicatorView];

    return loadingStateView;
}

@end
