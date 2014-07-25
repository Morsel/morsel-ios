//
//  MRSLBaseModalViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseModalViewController.h"

@interface MRSLBaseModalViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation MRSLBaseModalViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_disableFade) [self.view setAlpha:.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) {
        [self.view setY:[self.view getY] - 22.f];
        [self.view setHeight:[self.view getHeight] + 22.f];
    }
    if (!_tapRecognizer) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(dismiss:)];
        [self.view addGestureRecognizer:_tapRecognizer];
    }
    if (!_disableFade) {
        [UIView animateWithDuration:animated ? 0.f : .4f
                         animations:^{
                             [self.view setAlpha:1.f];
                         }];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLModalWillDisplayNotification
                                                        object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.tapRecognizer) {
        [self.view removeGestureRecognizer:_tapRecognizer];
        self.tapRecognizer = nil;
    }
}

#pragma mark - Action Methods

- (IBAction)dismiss:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLModalWillDismissNotification
                                                        object:nil];
    [self viewWillDisappear:YES];
    if (!_disableFade) {
        [UIView animateWithDuration:.4f
                         animations:^{
                             [self.view setAlpha:.0f];
                         } completion:^(BOOL finished) {
                             [self.view removeFromSuperview];
                             [self removeFromParentViewController];
                         }];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        });
    }
}

@end
