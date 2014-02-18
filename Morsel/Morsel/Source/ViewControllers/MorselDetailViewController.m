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
#import "MorselDetailPanelViewController.h"
#import "ProfileImageView.h"
#import "ProfileViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

static const CGFloat MRSLDetailSingleNavigationBarHeight = 64.f;
static const CGFloat MRSLDetailProgressionNavigationBarHeight = 80.f;
static const CGFloat MRSLProfilePanelHiddenY = -20.f;
static const CGFloat MRSLProfilePanelHiddenTriggeringOffset = 40.f;

@interface MorselDetailViewController ()
<UIScrollViewDelegate,
MorselDetailPanelViewControllerDelegate,
ProfileImageViewDelegate>

@property (nonatomic) int currentMorselID;

@property (nonatomic) MRSLPost *morselPost;

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *progressionPageControl;
@property (weak, nonatomic) IBOutlet UIView *morselDetailNavigationView;
@property (weak, nonatomic) IBOutlet UIView *profilePanelView;
@property (weak, nonatomic) IBOutlet UIView *viewControllerPanelContainerView;

@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@end

@implementation MorselDetailViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_morsel && _morsel.post) {
        self.currentMorselID = _morsel.morselIDValue;
        self.morselPost = _morsel.post;

        NSUInteger postMorselCount = [_morselPost.morsels count];

        if (postMorselCount > 1) {
            self.progressionPageControl.numberOfPages = postMorselCount;
            [self.morselDetailNavigationView setHeight:MRSLDetailProgressionNavigationBarHeight];
        } else {
            self.progressionPageControl.hidden = YES;
            [self.morselDetailNavigationView setHeight:MRSLDetailSingleNavigationBarHeight];
        }

        CGFloat navigationViewHeight = [_morselDetailNavigationView getHeight];

        [self.profilePanelView setY:navigationViewHeight];
        [self.viewControllerPanelContainerView setY:navigationViewHeight];
        [self.viewControllerPanelContainerView setHeight:[self.view getHeight] - navigationViewHeight];

        self.postTitleLabel.text = _morselPost.title ?: @"Morsel";
        self.timeSinceLabel.text = [_morsel.creationDate timeAgo];
        self.authorNameLabel.text = [_morselPost.creator fullName];

        self.profileImageView.user = _morselPost.creator;
        self.profileImageView.delegate = self;
        [_profileImageView addCornersWithRadius:20.f];

        if ([_morselPost.morsels count] > 1) {
            NSArray *orderedMorselsArray = _morselPost.morselsArray;

            NSUInteger morselIndex = [orderedMorselsArray indexOfObject:_morsel];

            self.progressionPageControl.currentPage = morselIndex;

            NSMutableArray *panelArray = [NSMutableArray array];

            for (MRSLMorsel *morsel in orderedMorselsArray) {
                MorselDetailPanelViewController *morselDetailPanelVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"MorselDetailPanel"];
                morselDetailPanelVC.morsel = morsel;
                [panelArray addObject:morselDetailPanelVC];
            }

            [self addSwipeCollectionViewControllers:panelArray
                                withinContainerView:_viewControllerPanelContainerView];
            [self displayPanelForPage:morselIndex
                             animated:NO];

            [self.progressionPageControl addTarget:self
                                            action:@selector(changePage:)
                                  forControlEvents:UIControlEventValueChanged];
        } else {
            MorselDetailPanelViewController *morselDetailPanelVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"MorselDetailPanel"];
            morselDetailPanelVC.view.frame = CGRectMake(0.f, 0.f, _viewControllerPanelContainerView.frame.size.width, _viewControllerPanelContainerView.frame.size.height);
            morselDetailPanelVC.morsel = _morsel;
            morselDetailPanelVC.delegate = self;

            [self addChildViewController:morselDetailPanelVC];
            [self.viewControllerPanelContainerView addSubview:morselDetailPanelVC.view];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(morselDeleted:)
                                                     name:MRSLUserDidDeleteMorselNotification
                                                   object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_morsel) {
        self.timeSinceLabel.text = [_morsel.creationDate timeAgo];
    }
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddComment"]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Add Comment"
                              properties:@{@"view": @"MorselDetailViewController",
                                           @"morsel_id": _morsel.morselID}];
        AddCommentViewController *addCommentVC = [segue destinationViewController];
        addCommentVC.morsel = _morsel;
    }
}

#pragma mark - Action Methods

- (void)changePage:(UIPageControl *)pageControl {
    [self displayPanelForPage:pageControl.currentPage
                     animated:YES];
}

- (void)displayUserProfileForUser:(MRSLUser *)user {
    ProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileVC.user = user;

    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

- (IBAction)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSNotification

- (void)morselDeleted:(NSNotification *)notification {
    if (!_morselPost || [_morselPost.morsels count] == 0) {
        self.morsel = nil;
        self.morselPost = nil;
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        int deletedMorselID = [(NSNumber *)notification.object intValue];

        [self reset];

        if (deletedMorselID == _currentMorselID) {
            self.morsel = [_morselPost.morselsArray firstObject];
            self.currentMorselID = _morsel.morselIDValue;
        } else {
            self.morsel = _morsel;
        }
    }
}

#pragma mark - ProfileImageViewDelegate

- (void)profileImageViewDidSelectUser:(MRSLUser *)user {
    [self displayUserProfileForUser:user];
}

#pragma mark - MorselDetailPanelViewControllerDelegate

- (void)morselDetailPanelViewDidSelectAddComment {
    [self performSegueWithIdentifier:@"AddComment"
                              sender:nil];
}

- (void)morselDetailPanelViewDidSelectUser:(MRSLUser *)user {
    [self displayUserProfileForUser:user];
}

- (void)morselDetailPanelViewScrollOffsetChanged:(CGFloat)offset {
    CGFloat profilePanelY = [_morselDetailNavigationView getHeight];

    if (offset > MRSLProfilePanelHiddenTriggeringOffset) {
        profilePanelY = MRSLProfilePanelHiddenY;
    }

    [UIView animateWithDuration:.2f animations:^{
        [_profilePanelView setY:profilePanelY];
    }];
}

#pragma mark - MRSLDetailHorizontalSwipePanelsViewController+Additions

- (void)didUpdateCurrentPage:(NSUInteger)page {
    self.progressionPageControl.currentPage = page;

    self.morsel = [_morselPost.morselsArray objectAtIndex:page];
    self.currentMorselID = _morsel.morselIDValue;

    if (self.previousExists) {
        MorselDetailPanelViewController *previousDetailPanelViewController = [self.swipeViewControllers objectAtIndex:self.previousPage];
        previousDetailPanelViewController.delegate = nil;
    }

    MorselDetailPanelViewController *detailPanelViewController = [self.swipeViewControllers objectAtIndex:page];
    detailPanelViewController.delegate = self;
}

@end
