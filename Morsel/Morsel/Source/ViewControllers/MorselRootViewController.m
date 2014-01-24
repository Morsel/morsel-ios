//
//  MorselRootViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/17/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselRootViewController.h"

#import "CreateMorselViewController.h"
#import "HomeViewController.h"
#import "ModelController.h"
#import "ProfileViewController.h"

#import "MRSLUser.h"

@interface MorselRootViewController ()

@property (nonatomic, strong) NSMutableArray *navigationControllers;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (weak, nonatomic) IBOutlet UIView *morselTabBarView;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *createMorselButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@end

@implementation MorselRootViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationControllers = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showBottomBar)
                                                 name:MorselShowBottomBarNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideBottomBar)
                                                 name:MorselHideBottomBarNotification
                                               object:nil];
    
    MRSLUser *currentUser = [ModelController sharedController].currentUser;
    
    if (!currentUser)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userCreated:)
                                                     name:MorselServiceDidCreateUserNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedIn:)
                                                     name:MorselServiceDidLogInNewUserNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoggedIn:)
                                                     name:MorselServiceDidLogInExistingUserNotification
                                                   object:nil];
        
        double delayInSeconds = 0.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
        {
            [self performSegueWithIdentifier:@"DisplaySignUp"
                                      sender:nil];
        });
    }
    else
    {
#warning Should attempt to log user in (if data connection is present) and if there is an error, display login screen
        
        [self displayHome];
    }
}

#pragma mark - Private Methods

- (IBAction)displayHome
{
    if (_currentViewController)
    {
        [_currentViewController removeFromParentViewController];
        [_currentViewController.view removeFromSuperview];
        
        self.currentViewController = nil;
    }
    
    _profileButton.enabled = YES;
    _homeButton.enabled = NO;
    
    UINavigationController *homeNC = [self getNavControllerWithClass:[HomeViewController class]];
    
    if (!homeNC)
    {
        homeNC = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"Home"];
        
        [self.navigationControllers addObject:homeNC];
        
        [self addChildViewController:homeNC];
        [self.view addSubview:homeNC.view];
        
        [self.view bringSubviewToFront:_morselTabBarView];
    }
    else
    {
        [self addChildViewController:homeNC];
        [self.view addSubview:homeNC.view];
        
        [self.view bringSubviewToFront:_morselTabBarView];
    }
    
    self.currentViewController = homeNC;
}

- (IBAction)displayProfile
{
    if (_currentViewController)
    {
        [_currentViewController removeFromParentViewController];
        [_currentViewController.view removeFromSuperview];
        
        self.currentViewController = nil;
    }
    
    _profileButton.enabled = NO;
    _homeButton.enabled = YES;
    
    UINavigationController *profileNC = [self getNavControllerWithClass:[ProfileViewController class]];
    
    if (!profileNC)
    {
        profileNC = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"Profile"];
        
        [self.navigationControllers addObject:profileNC];
        
        [self addChildViewController:profileNC];
        [self.view addSubview:profileNC.view];
        
        [self.view bringSubviewToFront:_morselTabBarView];
    }
    else
    {
        [self addChildViewController:profileNC];
        [self.view addSubview:profileNC.view];
        
        [self.view bringSubviewToFront:_morselTabBarView];
    }
    
    self.currentViewController = profileNC;
}

- (UINavigationController *)getNavControllerWithClass:(Class)class
{
    __block UINavigationController *foundNC = nil;
    
    [_navigationControllers enumerateObjectsUsingBlock:^(UINavigationController *navigationController, NSUInteger idx, BOOL *stop)
    {
        if ([navigationController isKindOfClass:[UINavigationController class]])
        {
            if ([navigationController.viewControllers count] > 0)
            {
                if ([[navigationController.viewControllers objectAtIndex:0] isKindOfClass:class])
                {
                    foundNC = navigationController;
                    *stop = YES;
                }
            }
        }
    }];
    
    return foundNC;
}

- (void)hideBottomBar
{
    [UIView animateWithDuration:.2f animations:^
    {
        [_morselTabBarView setY:self.view.frame.size.height];
    }];
}

- (void)showBottomBar
{
    [UIView animateWithDuration:.2f animations:^
     {
         [_morselTabBarView setY:self.view.frame.size.height - [_morselTabBarView getHeight]];
     }];
}

- (void)userCreated:(NSNotification *)notification
{
    [self syncDataAndPresentHome];
}

- (void)userLoggedIn:(NSNotification *)notification
{
    [self syncDataAndPresentHome];
}

- (void)syncDataAndPresentHome
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MorselServiceDidCreateUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MorselServiceDidLogInExistingUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MorselServiceDidLogInNewUserNotification object:nil];
    
    [self displayHome];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    [[ModelController sharedController] saveDataToStore];
}

@end
