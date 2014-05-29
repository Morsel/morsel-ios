//
//  MRSLActivityRootViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 4/2/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityRootViewController.h"

NS_ENUM(NSUInteger, MRSLActivityRootViewControllerSegments) {
    MRSLActivityRootViewControllerSegmentNotifications = 0,
    MRSLActivityRootViewControllerSegmentActivity = 1
};

@interface MRSLActivityRootViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *notificationsActivitySegmentedControl;
@property (strong, nonatomic) UIViewController *notificationsViewController;
@property (strong, nonatomic) UIViewController *activityViewController;
@property (strong, nonatomic) UIViewController *currentViewController;

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;

@end

@implementation MRSLActivityRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIViewController *viewController = [self viewControllerForSegmentIndex:_notificationsActivitySegmentedControl.selectedSegmentIndex];
    [self addChildViewController:viewController];
    viewController.view.frame = self.view.bounds;
    [self.view addSubview:viewController.view];
    self.currentViewController = viewController;
}


#pragma mark - Private Methods

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl {
    UIViewController *viewController = [self viewControllerForSegmentIndex:segmentedControl.selectedSegmentIndex];
    [self addChildViewController:viewController];

    [self transitionFromViewController:self.currentViewController
                      toViewController:viewController
                              duration:0.3
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                [self.currentViewController.view removeFromSuperview];
                                viewController.view.frame = self.view.bounds;
                                [self.view addSubview:viewController.view];
                            } completion:^(BOOL finished) {
                                [viewController didMoveToParentViewController:self];
                                [self.currentViewController removeFromParentViewController];
                                self.currentViewController = viewController;
                            }];
}

- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    if (index == MRSLActivityRootViewControllerSegmentNotifications) {
        if (!_notificationsViewController) self.notificationsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"sb_MRSLNotificationsViewController"];
        return _notificationsViewController;
    } else if (index == MRSLActivityRootViewControllerSegmentActivity) {
        if (!_activityViewController) self.activityViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"sb_MRSLActivityViewController"];
        return _activityViewController;
    } else {
        return nil;
    }
}

@end
