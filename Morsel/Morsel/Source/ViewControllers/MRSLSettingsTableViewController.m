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

@interface MRSLSettingsTableViewController ()

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

@end
