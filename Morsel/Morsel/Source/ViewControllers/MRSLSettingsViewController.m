//
//  MRSLSettingsViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSettingsViewController.h"
#import "MRSLUser.h"

@interface MRSLSettingsViewController ()
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;

@end

@implementation MRSLSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.accessibilityLabel = @"Settings";
    self.mp_eventView = @"settings";
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillAppear:animated];

    [MRSLUser refreshCurrentUserWithSuccess:nil
                                    failure:nil];
}

- (IBAction)logOut:(id)sender {
    [UIAlertView showAlertViewWithTitle:@"Logout"
                                message:@"Are you sure you want to logout?"
                               delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Yes", nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Log Out",
                                                  @"settings_item": @"logout",
                                                  @"_view": self.mp_eventView}];
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceShouldLogOutUserNotification
                                                            object:nil];
    }
}

@end
