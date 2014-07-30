//
//  MRSLSettingsTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSettingsTableViewController.h"

#import "MRSLAPIService+Registration.h"

#import <MessageUI/MFMailComposeViewController.h>

#import "MRSLSectionView.h"
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
    if ([identifier isEqualToString:MRSLStoryboardSegueSetupProfessionalAccountKey]) {
        [UIAlertView showAlertViewWithTitle:@"Professional Account"
                                    message:@"Professional accounts allow chefs, sommeliers, and other restaurant professionals to connect with their restaurants and give more insight into who they are. Setup your professional account now?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Continue", nil];
        return NO;
    } else if ([identifier isEqualToString:MRSLStoryboardSegueAccountSettingsKey] && ![[MRSLUser currentUser] passwordSetValue]) {
        MRSLUser *currentUser = [MRSLUser currentUser];
        // Password not set, show alertview and return NO
        [UIAlertView showAlertViewWithTitle:@"Account Settings"
                                    message:[NSString stringWithFormat:@"In order to make secure changes to your account a password is required. Since you never set a password, we'll send an email to %@ to set one.", currentUser.email]
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Send Email", nil];
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

- (IBAction)displaySoftwareAcknowledgements:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayWebBrowserNotification object:@{@"title": @"Software Acknowledgements",
                                                                                                                   @"url": [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Acknowledgements" ofType:@"html"]],
                                                                                                                   @"hideToolbar": @YES
                                                                                                                   }];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [MRSLSectionView sectionViewWithTitle:[self tableView:tableView titleForHeaderInSection:section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.tableView hasHeaderForSection:section] ? MRSLSectionViewDefaultHeight : 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor morselDefaultCellBackgroundColor]];

    if (indexPath.section == MRSLSettingsTableViewSectionSetupProfessionalAccount || indexPath.section == MRSLSettingsTableViewSectionProfessionalSettings) {
        [cell addDefaultBorderForDirections:MRSLBorderNorth|MRSLBorderSouth];
    } else if (!([self.tableView isLastRowInSectionForIndexPath:indexPath] && ![self.tableView isLastSectionForIndexPath:indexPath])) {
        [cell addDefaultBorderForDirections:MRSLBorderSouth];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:MRSLSettingsTableViewSectionUserSettings]
                                  animated:YES];
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:MRSLSettingsTableViewSectionSetupProfessionalAccount]
                                  animated:YES];

    if (buttonIndex == [alertView cancelButtonIndex]) return;

    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Send Email"]) {
        [_appDelegate.apiService forgotPasswordWithEmail:[MRSLUser currentUser].email
                                                 success:^(id responseObject) {
                                                     [UIAlertView showOKAlertViewWithTitle:@"Email Sent!"
                                                                                   message:@"Check your inbox for a link to reset your password"];
                                                 } failure:^(NSError *error) {
                                                     [UIAlertView showAlertViewForErrorString:@"Please try again"
                                                                                     delegate:nil];
                                                 }];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Continue"]) {
        //  Update the current_user to a pro account
        [MRSLUser updateCurrentUserToProfessional];

        //  Push Pro Settings
        [self performSegueWithIdentifier:MRSLStoryboardSegueProfessionalSettingsKey
                                  sender:nil];

    }
}

@end
