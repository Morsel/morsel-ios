//
//  MRSLNotificationsRootViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 4/2/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLNotificationsRootViewController.h"

#import "MRSLNotificationsTableViewController.h"
#import "MRSLFollowableActivityTableViewController.h"
#import "MRSLMyActivityTableViewController.h"

#import "MRSLSegmentedButtonView.h"

NS_ENUM(NSUInteger, MRSLNotificationsRootViewControllerSegments) {
    MRSLNotificationsRootViewControllerSegmentNotifications = 0,
    MRSLNotificationsRootViewControllerSegmentFollowing = 1,
    MRSLNotificationsRootViewControllerSegmentMyActivity = 2
};


@interface MRSLNotificationsRootViewController ()
<MRSLSegmentedButtonViewDelegate>

@property (strong, nonatomic) MRSLNotificationsTableViewController *notificationsViewController;
@property (strong, nonatomic) MRSLFollowableActivityTableViewController *followableActivityTableViewController;
@property (strong, nonatomic) MRSLMyActivityTableViewController *myActivityTableViewController;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (nonatomic) enum MRSLNotificationsRootViewControllerSegments selectedSegment;

@property (weak, nonatomic) IBOutlet MRSLSegmentedButtonView *segmentedButtonView;
@property (nonatomic, weak) IBOutlet UIView *containerView;

@end

@implementation MRSLNotificationsRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.segmentedButtonView setDelegate:self];
    [self.segmentedButtonView setSelectedIndex:_selectedSegment];
}


#pragma mark - Private Methods

- (void)displayContentController:(UIViewController *)content didMoveToParentViewController:(BOOL)didMoveToParentViewController {
    [self.currentViewController.view removeFromSuperview];
    content.view.frame = self.containerView.bounds;
    [self.containerView addSubview:content.view];
    if (didMoveToParentViewController) [content didMoveToParentViewController:self];
}

- (void)hideContentController:(UIViewController *)content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)toggleViewController:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    
    if (self.currentViewController) {
        [self displayContentController:viewController didMoveToParentViewController:YES];
        [self hideContentController:self.currentViewController];
    } else {
        [self displayContentController:viewController didMoveToParentViewController:YES];
    }
    self.currentViewController = viewController;
}

- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    if (index == MRSLNotificationsRootViewControllerSegmentNotifications)
        return [self notificationsTableViewController];
    else if (index == MRSLNotificationsRootViewControllerSegmentFollowing)
        return [self followableActivityTableViewController];
    else if (index == MRSLNotificationsRootViewControllerSegmentMyActivity)
        return [self myActivityTableViewController];
    else
        return nil;
}

- (MRSLNotificationsTableViewController *)notificationsTableViewController {
    if (_notificationsViewController) return _notificationsViewController;
    _notificationsViewController = [[MRSLNotificationsTableViewController alloc] init];

    return _notificationsViewController;
}

- (MRSLFollowableActivityTableViewController *)followableActivityTableViewController {
    if (_followableActivityTableViewController) return _followableActivityTableViewController;
    _followableActivityTableViewController = [[MRSLFollowableActivityTableViewController alloc] init];

    return _followableActivityTableViewController;
}

- (MRSLMyActivityTableViewController *)myActivityTableViewController {
    if (_myActivityTableViewController) return _myActivityTableViewController;
    _myActivityTableViewController = [[MRSLMyActivityTableViewController alloc] init];

    return _myActivityTableViewController;
}


#pragma mark - MRSLSegmentedButtonViewDelegate

- (void)segmentedButtonViewDidSelectIndex:(NSInteger)index {
    if (_currentViewController && _selectedSegment == index) return;
    self.selectedSegment = index;

    [self toggleViewController:[self viewControllerForSegmentIndex:index]];
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *childViewController, NSUInteger idx, BOOL *stop) {
        [childViewController willMoveToParentViewController:nil];
        [childViewController removeFromParentViewController];
        [childViewController.view removeFromSuperview];
    }];
    self.notificationsViewController = nil;
    self.followableActivityTableViewController = nil;
    self.myActivityTableViewController = nil;
}

@end
