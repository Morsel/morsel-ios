//
//  MorselDetailViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/16/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselDetailViewController.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "AddCommentViewController.h"
#import "ModelController.h"
#import "MorselDetailPanelViewController.h"
#import "ProfileImageView.h"
#import "ProfileViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MorselDetailViewController ()
    <UIScrollViewDelegate,
     MorselDetailPanelViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *progressionPageControl;
@property (weak, nonatomic) IBOutlet UIView *morselDetailNavigationView;
@property (weak, nonatomic) IBOutlet UIView *profilePanelView;

@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@property (nonatomic, strong) MorselDetailPanelViewController *morselDetailPanelVC;

@end

@implementation MorselDetailViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_morsel && _morsel.post) {
        NSUInteger postMorselCount = [_morsel.post.morsels count];

        if (postMorselCount > 1) {
            self.progressionPageControl.numberOfPages = postMorselCount;
        } else {
            self.progressionPageControl.hidden = YES;
            [self.morselDetailNavigationView setHeight:64.f];
        }

        self.postTitleLabel.text = _morsel.post.title ?: @"Morsel";
        self.timeSinceLabel.text = [_morsel.creationDate dateTimeAgo];
        self.authorNameLabel.text = [_morsel.post.author fullName];

        self.profileImageView.user = _morsel.post.author;
        [_profileImageView addCornersWithRadius:20.f];

        //int morselIndex = (int)[_morsel.post.morsels indexOfObject:_morsel];

        MorselDetailPanelViewController *morselDetailPanelVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"MorselDetailPanel"];
        morselDetailPanelVC.view.frame = CGRectMake(0.f, 76.f, 320.f, 492.f);
        morselDetailPanelVC.morsel = _morsel;
        morselDetailPanelVC.delegate = self;
        
        self.morselDetailPanelVC = morselDetailPanelVC;
        
        [self addChildViewController:morselDetailPanelVC];
        [self.view addSubview:morselDetailPanelVC.view];
        
        [self.view bringSubviewToFront:_profilePanelView];
        [self.view bringSubviewToFront:_morselDetailNavigationView];
    }
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddComment"]) {
        AddCommentViewController *addCommentVC = [segue destinationViewController];
        addCommentVC.morsel = _morsel;
    }
}

#pragma mark - Action Methods

- (IBAction)displayUserProfile {
    ProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileVC.user = _morsel.post.author;

    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MorselDetailPanelViewControllerDelegate

- (void)morselDetailPanelViewDidSelectAddComment {
    [self performSegueWithIdentifier:@"AddComment"
                              sender:nil];
}

- (void)morselDetailPanelViewScrollOffsetChanged:(CGFloat)offset {
    CGFloat profilePanelY = 80.f;
    
    if (offset > 40.f) {
        profilePanelY = -20.f;
    }
    
    [UIView animateWithDuration:.2f animations:^{
        [_profilePanelView setY:profilePanelY];
    }];
}

#pragma mark - Destruction

- (void)dealloc {
    [_morselDetailPanelVC removeFromParentViewController];
    [_morselDetailPanelVC.view removeFromSuperview];
}

@end
