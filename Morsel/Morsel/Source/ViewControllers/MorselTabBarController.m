//
//  MorselTabBarController.m
//  Morsel
//
//  Created by Javier Otero on 12/17/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MorselTabBarController.h"

#import "CreateMorselViewController.h"
#import "ModelController.h"

@interface MorselTabBarController () <UITabBarControllerDelegate>

@end

@implementation MorselTabBarController

#pragma mark - Instance Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
}

#pragma mark - Private Methods

- (IBAction)cancelCreateMorsel:(UIStoryboardSegue *)segue
{
    // Segue unwind left intentionally blank
}

- (IBAction)postMorsel:(UIStoryboardSegue *)segue
{
    // Segue unwind left intentionally blank
}

- (void)userCreated:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)userLoggedIn:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([[viewController title] isEqualToString:@"CreateMorsel"])
    {
        [self performSegueWithIdentifier:@"CreateMorsel"
                                  sender:nil];
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
