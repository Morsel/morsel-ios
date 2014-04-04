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

@property (strong, nonatomic) MRSLFeedPanelViewController *feedPanelViewController;

@end

@implementation MRSLFeedPanelCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.feedPanelViewController = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLFeedPanelViewController"];
    _feedPanelViewController.delegate = self;
}

- (void)setOwningViewController:(UIViewController *)owningViewController
                       withPost:(MRSLPost *)post {
    _owningViewController = owningViewController;
    if (!_feedPanelViewController.parentViewController) {
        [self.owningViewController addChildViewController:_feedPanelViewController];
        [self addSubview:_feedPanelViewController.view];
    }
    _feedPanelViewController.post = post;
}

#pragma mark - MRSLFeedPanelViewControllerDelegate

- (void)feedPanelViewControllerDidSelectPreviousStory {
    if ([self.delegate respondsToSelector:@selector(feedPanelCollectionViewCellDidSelectPreviousStory)]) {
        [self.delegate feedPanelCollectionViewCellDidSelectPreviousStory];
    }
}

- (void)feedPanelViewControllerDidSelectNextStory {
    if ([self.delegate respondsToSelector:@selector(feedPanelCollectionViewCellDidSelectNextStory)]) {
        [self.delegate feedPanelCollectionViewCellDidSelectNextStory];
    }
}

@end
