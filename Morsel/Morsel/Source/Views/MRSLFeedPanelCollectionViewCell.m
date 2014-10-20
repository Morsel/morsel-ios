//
//  MRSLFeedPanelCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedPanelCollectionViewCell.h"

#import "MRSLFeedPanelViewController.h"

@interface MRSLFeedPanelCollectionViewCell ()
<MRSLFeedPanelViewControllerDelegate>

@property (weak, nonatomic) UIViewController *owningViewController;

@end

@implementation MRSLFeedPanelCollectionViewCell

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setOwningViewController:(UIViewController *)owningViewController
                       withMorsel:(MRSLMorsel *)morsel {
    _owningViewController = owningViewController;
    if (!_feedPanelViewController) {
        MRSLFeedPanelViewController *feedPanelVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardFeedPanelViewControllerKey];
        [feedPanelVC.view setFrame:CGRectMake(0.f, 0.f, [self getWidth], [self getHeight])];
        feedPanelVC.delegate = self;
        [self.owningViewController addChildViewController:feedPanelVC];
        [self addSubview:feedPanelVC.view];
        [feedPanelVC didMoveToParentViewController:owningViewController];

        self.owningViewController = owningViewController;
        self.feedPanelViewController = feedPanelVC;
    }
    _feedPanelViewController.morsel = morsel;
}

#pragma mark - MRSLFeedPanelViewControllerDelegate

- (void)feedPanelViewControllerDidSelectNextMorsel {
    if ([self.delegate respondsToSelector:@selector(feedPanelCollectionViewCellDidSelectNextMorsel)]) {
        [self.delegate feedPanelCollectionViewCellDidSelectNextMorsel];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    if (self.feedPanelViewController) {
        [self.feedPanelViewController willMoveToParentViewController:nil];
        [self.feedPanelViewController.view removeFromSuperview];
        [self.feedPanelViewController removeFromParentViewController];
        self.feedPanelViewController.delegate = nil;
        self.feedPanelViewController = nil;
    }
    self.owningViewController = nil;
}

@end
