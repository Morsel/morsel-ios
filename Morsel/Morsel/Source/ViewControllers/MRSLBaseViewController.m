//
//  MRSLBaseViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

@implementation MRSLBaseViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationItems];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
