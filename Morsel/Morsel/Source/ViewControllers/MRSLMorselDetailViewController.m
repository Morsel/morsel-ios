//
//  MorselDetailViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/16/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLMorselDetailViewController.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLAddCommentViewController.h"
#import "MRSLMorselDetailPanelViewController.h"
#import "MRSLProfileImageView.h"
#import "MRSLProfileViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

static const CGFloat MRSLDetailSinglePageControlViewHeight = 0.f;
static const CGFloat MRSLDetailMultiPageControlViewHeight = 12.f;
static const CGFloat MRSLProfilePanelHiddenTriggeringOffset = 20.f;

@interface MRSLMorselDetailViewController ()
<UIScrollViewDelegate,
MorselDetailPanelViewControllerDelegate,
ProfileImageViewDelegate>

@property (nonatomic) int currentMorselID;

@property (nonatomic) MRSLPost *morselPost;

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSinceLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *progressionPageControl;
@property (weak, nonatomic) IBOutlet UIView *morselDetailNavigationView;
@property (weak, nonatomic) IBOutlet UIView *profilePanelView;
@property (weak, nonatomic) IBOutlet UIView *viewControllerPanelContainerView;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@end

@implementation MRSLMorselDetailViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [self layoutPanels];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(goBack)];
    [self.navigationItem setLeftBarButtonItem:backButton];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(postUpdated)
                                                 name:MRSLUserDidUpdatePostNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(morselDeleted:)
                                                 name:MRSLUserDidDeleteMorselNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_morsel.managedObjectContext) {
        self.timeSinceLabel.text = [_morsel.creationDate timeAgo];
    } else {
        self.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                withValue:@(_currentMorselID)];
        if (_morsel.managedObjectContext) {
            [self displayAndLayoutContent];
        }
    }
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_AddComment"]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Add Comment"
                              properties:@{@"view": @"Detail",
                                           @"morsel_id": NSNullIfNil(_morsel.morselID)}];
        UINavigationController *navController = [segue destinationViewController];
        MRSLAddCommentViewController *addCommentVC = [[navController viewControllers] firstObject];
        addCommentVC.morsel = _morsel;
    }
}

#pragma mark - Action Methods

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)layoutPanels {
    self.currentMorselID = _morsel.morselIDValue;

    [self displayAndLayoutContent];

    if ([_morselPost.morsels count] > 1) {
        NSArray *orderedMorselsArray = _morselPost.morselsArray;

        NSUInteger morselIndex = [orderedMorselsArray indexOfObject:_morsel];

        self.progressionPageControl.currentPage = morselIndex;

        NSMutableArray *panelArray = [NSMutableArray array];

        for (MRSLMorsel *morsel in orderedMorselsArray) {
            MRSLMorselDetailPanelViewController *morselDetailPanelVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselDetailPanel"];
            morselDetailPanelVC.morsel = morsel;
            [morselDetailPanelVC setScrollViewInsets:UIEdgeInsetsMake([_profilePanelView getHeight] + [_morselDetailNavigationView getHeight], 0.f, 0.f, 0.f)];
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
        MRSLMorselDetailPanelViewController *morselDetailPanelVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselDetailPanel"];
        morselDetailPanelVC.view.frame = CGRectMake(0.f, 0.f, _viewControllerPanelContainerView.frame.size.width, _viewControllerPanelContainerView.frame.size.height);
        morselDetailPanelVC.morsel = _morsel;
        morselDetailPanelVC.delegate = self;
        [morselDetailPanelVC setScrollViewInsets:UIEdgeInsetsMake([_profilePanelView getHeight] + [_morselDetailNavigationView getHeight], 0.f, 0.f, 0.f)];
        [self addChildViewController:morselDetailPanelVC];
        [self.viewControllerPanelContainerView addSubview:morselDetailPanelVC.view];
    }
}

- (void)displayAndLayoutContent {
    self.morselPost = _morsel.post;

    NSUInteger postMorselCount = [_morselPost.morsels count];

    if (postMorselCount > 1) {
        self.progressionPageControl.numberOfPages = postMorselCount;
        [self.morselDetailNavigationView setHeight:MRSLDetailMultiPageControlViewHeight];
    } else {
        self.progressionPageControl.hidden = YES;
        [self.morselDetailNavigationView setHeight:MRSLDetailSinglePageControlViewHeight];
    }

    CGFloat navigationViewHeight = [_morselDetailNavigationView getHeight];

    [self.profilePanelView setY:navigationViewHeight];
    [self.viewControllerPanelContainerView setHeight:([self.view getHeight] - 60.f)];

    self.title = _morselPost.title ?: @"Morsel";
    self.timeSinceLabel.text = [_morsel.creationDate timeAgo];
    self.authorNameLabel.text = [_morselPost.creator fullName];

    self.profileImageView.user = _morselPost.creator;
    self.profileImageView.delegate = self;
    [_profileImageView addCornersWithRadius:20.f];
}

- (void)changePage:(UIPageControl *)pageControl {
    [self displayPanelForPage:pageControl.currentPage
                     animated:YES];
}

- (void)displayUserProfileForUser:(MRSLUser *)user {
    MRSLProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_ProfileViewController"];
    profileVC.user = user;

    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

#pragma mark - NSNotification

- (void)postUpdated {
    self.title = _morselPost.title ?: @"Morsel";
}

- (void)morselDeleted:(NSNotification *)notification {
    if (!_morselPost.managedObjectContext || [_morselPost.morsels count] == 0) {
        self.morsel = nil;
        self.morselPost = nil;
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        int deletedMorselID = [(NSNumber *)notification.object intValue];

        [self reset];
        self.previousExists = NO;

        if (deletedMorselID == _currentMorselID) {
            self.morsel = [_morselPost.morselsArray firstObject];
            self.currentMorselID = _morsel.morselIDValue;
        }

        [self layoutPanels];
    }
}

#pragma mark - ProfileImageViewDelegate

- (void)profileImageViewDidSelectUser:(MRSLUser *)user {
    [self displayUserProfileForUser:user];
}

#pragma mark - MorselDetailPanelViewControllerDelegate

- (void)morselDetailPanelViewDidSelectAddComment {
    [self performSegueWithIdentifier:@"seg_AddComment"
                              sender:nil];
}

- (void)morselDetailPanelViewDidSelectUser:(MRSLUser *)user {
    [self displayUserProfileForUser:user];
}

- (void)morselDetailPanelViewScrollOffsetChanged:(CGFloat)offset {
    CGFloat profilePanelY = [_morselDetailNavigationView getHeight];

    if (offset > MRSLProfilePanelHiddenTriggeringOffset) {
        profilePanelY = -[_profilePanelView getHeight];
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
        MRSLMorselDetailPanelViewController *previousDetailPanelViewController = [self.swipeViewControllers objectAtIndex:self.previousPage];
        previousDetailPanelViewController.delegate = nil;
    }

    MRSLMorselDetailPanelViewController *detailPanelViewController = [self.swipeViewControllers objectAtIndex:page];
    detailPanelViewController.delegate = self;
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
