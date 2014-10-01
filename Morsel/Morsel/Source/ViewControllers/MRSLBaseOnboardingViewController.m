//
//  MRSLBaseOnboardingViewController.m
//  Morsel
//
//  Created by Javier Otero on 10/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseOnboardingViewController.h"

@interface MRSLBaseOnboardingViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation MRSLBaseOnboardingViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(dismiss)];
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)dismiss {
    if (self.tapRecognizer) [self.view removeGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer = nil;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:.4f
                     animations:^{
                         [weakSelf.view setAlpha:0.f];
                     } completion:^(BOOL finished) {
                         if (weakSelf) {
                             [weakSelf willMoveToParentViewController:nil];
                             [weakSelf.view removeFromSuperview];
                             [weakSelf removeFromParentViewController];
                         }
                     }];
}

@end
