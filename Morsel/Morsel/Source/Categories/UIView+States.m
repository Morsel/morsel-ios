//
//  UIView+States.m
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIView+States.h"
#import "MRSLIconStateView.h"
#import "MRSLLoadingStateView.h"

#import <objc/runtime.h>

static char const *const EmptyStateViewKey = "EmptyStateViewKey";
static char const *const LoadingStateViewKey = "LoadingStateViewKey";
static char const *const CurrentStateViewKey = "CurrentStateViewKey";

@interface UIView (States_Private)

@property (strong, nonatomic) MRSLIconStateView *emptyStateView;
@property (strong, nonatomic) MRSLLoadingStateView *loadingStateView;

@property (strong, nonatomic) MRSLStateView *currentStateView;

@end

@implementation UIView (States)

#pragma mark - Instance Methods

- (MRSLStateView *)currentStateView {
    return objc_getAssociatedObject(self, CurrentStateViewKey);
}

- (void)setCurrentStateView:(MRSLStateView *)currentStateView {
    [self.currentStateView removeFromSuperview];
    [self addCenteredSubview:currentStateView
                  withOffset:[currentStateView defaultOffset]];
    objc_setAssociatedObject(self, CurrentStateViewKey, currentStateView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Empty State View

- (void)setEmptyStateTitle:(NSString *)emptyStateTitle {
    [self.emptyStateView setTitle:emptyStateTitle];
}

- (MRSLIconStateView *)emptyStateView {
    if (!objc_getAssociatedObject(self, EmptyStateViewKey)) [self setEmptyStateView:[MRSLIconStateView iconStateViewWithTitle:@"No results."
                                                                                                                   imageNamed:nil]];
    return objc_getAssociatedObject(self, EmptyStateViewKey);
}

- (void)setEmptyStateView:(MRSLIconStateView *)emptyStateView {
    objc_setAssociatedObject(self, EmptyStateViewKey, emptyStateView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)toggleEmpty:(BOOL)shouldEnable {
    if (shouldEnable) [self setCurrentStateView:self.emptyStateView];
}

#pragma mark - Loading State View

- (MRSLLoadingStateView *)loadingStateView {
    if (!objc_getAssociatedObject(self, LoadingStateViewKey)) [self setLoadingStateView:[MRSLLoadingStateView loadingStateView]];
    return objc_getAssociatedObject(self, LoadingStateViewKey);
}

- (void)setLoadingStateView:(MRSLLoadingStateView *)loadingStateView {
    objc_setAssociatedObject(self, LoadingStateViewKey, loadingStateView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)toggleLoading:(BOOL)shouldEnable {
    BOOL shouldShowEmptyState = [self shouldShowEmptyState];
    if (shouldEnable && shouldShowEmptyState) {
        [self setCurrentStateView:self.loadingStateView];
    } else {
        [self setCurrentStateView:nil];
        [self toggleEmpty:shouldShowEmptyState];
    }
}

#pragma mark - Private Methods

- (BOOL)shouldShowEmptyState {
    return NO;
}

@end