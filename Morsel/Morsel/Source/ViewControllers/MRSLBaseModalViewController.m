//
//  MRSLBaseModalViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseModalViewController.h"

@interface MRSLBaseModalViewController ()

@end

@implementation MRSLBaseModalViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setAlpha:.0f];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismiss:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) {
        [self.view setY:[self.view getY] - 22.f];
        [self.view setHeight:[self.view getHeight] + 22.f];
    }
    [UIView animateWithDuration:animated ? 0.f : .4f
                     animations:^{
                         [self.view setAlpha:1.f];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLModalWillDisplayNotification
                                                        object:nil];
}

#pragma mark - Action Methods

- (IBAction)dismiss:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLModalWillDismissNotification
                                                        object:nil];
    [UIView animateWithDuration:.4f
                     animations:^{
        [self.view setAlpha:.0f];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

@end
