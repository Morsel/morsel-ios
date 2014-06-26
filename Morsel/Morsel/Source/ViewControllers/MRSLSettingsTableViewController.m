//
//  MRSLSettingsTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSettingsTableViewController.h"

#import <MessageUI/MFMailComposeViewController.h>

#import "MRSLUser.h"
#import "MRSLUtil.h"

NS_ENUM(NSUInteger, MRSLSettingsTableViewSections) {
    MRSLSettingsTableViewSectionSetupProfessionalAccount,
    MRSLSettingsTableViewSectionProfessionalSettings,
    MRSLSettingsTableViewSectionUserSettings,
    MRSLSettingsTableViewSectionSupport
};

@interface MRSLSettingsTableViewController ()
<UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *appVersionLabel;

- (IBAction)displayContactMorsel;
- (IBAction)displayTermsOfService;
- (IBAction)displayPrivacyPolicy;

@end

@implementation MRSLSettingsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.appVersionLabel setText:[MRSLUtil appVersionBuildString]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  Any VCs in Settings that deal w/ a User will deal w/ current_user
    if ([segue.destinationViewController respondsToSelector:@selector(setUser:)]) {
        [segue.destinationViewController setUser:(id)[MRSLUser currentUser]]; // Casting to id to get rid of "incompatible pointer types" warning
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"seg_SetupProfessionalAccount"]) {
        [UIAlertView showAlertViewWithTitle:@"Professional Account"
                                    message:@"Professional accounts allow chefs, sommeliers, and other restaurant professionals to connect with their restaurants and give more insight into who they are. Setup your professional account now?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Continue", nil];
        return NO;
    }

    return YES;
}

- (IBAction)displayContactMorsel {
    if ([MFMailComposeViewController canSendMail]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayEmailComposerNotification
                                                            object:@{
                                                                     @"title": @"Contact Morsel",
                                                                     @"subject": @"Morsel iOS App Support",
                                                                     @"body": [NSString stringWithFormat:@"<br /><br />--<br />%@", [MRSLUtil supportDiagnostics]]}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": @"Contact Morsel",
                                                                                                                       @"url": [NSURL URLWithString:[NSString stringWithFormat:@"%@/contact?%@", MORSEL_BASE_URL, [MRSLUtil supportDiagnosticsURLParams]]]}];
    }
}

- (IBAction)displayTermsOfService {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": @"Terms of Service",
                                                                                                                   @"url": [NSURL URLWithString:[NSString stringWithFormat:@"%@/terms_text", MORSEL_BASE_URL]]}];
}

- (IBAction)displayPrivacyPolicy {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": @"Privacy Policy",
                                                                                                                   @"url": [NSURL URLWithString:[NSString stringWithFormat:@"%@/privacy_text", MORSEL_BASE_URL]]}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == MRSLSettingsTableViewSectionSetupProfessionalAccount) {
        return [[MRSLUser currentUser] isProfessional] ? 0 : 1;
    } else if (section == MRSLSettingsTableViewSectionProfessionalSettings) {
        return [[MRSLUser currentUser] isProfessional] ? 1 : 0;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //  Update the current_user to a pro account
        [MRSLUser updateCurrentUserToProfessional];

        //  Push Pro Settings
        [self performSegueWithIdentifier:@"seg_ProfessionalSettings"
                                  sender:nil];
    }

    //  Since the only alertView that self is a delegate for is the one shown
    //  for the 'Setup Professional Account' cell, we can safely assume that
    //  that's the row we want to deselect.
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:MRSLSettingsTableViewSectionSetupProfessionalAccount]
                                  animated:YES];
}

@end
