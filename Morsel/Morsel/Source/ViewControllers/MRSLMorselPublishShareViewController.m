//
//  MRSLMorselPublishShareViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/18/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselPublishShareViewController.h"

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Authentication.h"
#import "MRSLSocialServiceFacebook.h"
#import "MRSLSocialServiceTwitter.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLSocialUser.h"
#import "MRSLUser.h"

@interface MRSLMorselPublishShareViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *publishButton;

@end

@implementation MRSLMorselPublishShareViewController

#pragma mark - Action Methods

- (IBAction)publishMorsel:(id)sender {
    for (MRSLItem *item in _morsel.itemsArray) {
        if (item.didFailUploadValue) {
            [UIAlertView showAlertViewForErrorString:@"Sorry, it looks like an item failed to upload, return to the previous screen to try again!"
                                            delegate:nil];
            return;
        } else if (item.isUploadingValue) {
            [UIAlertView showAlertViewForErrorString:@"Sorry, not all items are finished uploading. Please try again in a moment!"
                                            delegate:nil];
            return;
        }
    }
    _publishButton.enabled = NO;
    _morsel.draft = @NO;
    [_appDelegate.apiService publishMorsel:_morsel
                                   success:nil
                                   failure:^(NSError *error) {
                                       _publishButton.enabled = YES;
                                       [UIAlertView showAlertViewForErrorString:@"Unable to publish morsel, please try again!"
                                                                       delegate:nil];
                                   }
                            sendToFacebook:_facebookSwitch.isOn
                             sendToTwitter:_twitterSwitch.isOn];
}

- (IBAction)toggleFacebook:(UISwitch *)switchControl {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Facebook"
                                 properties:@{@"view": @"Publish",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    if (![FBSession.activeSession isOpen]) {
        _facebookSwitch.enabled = NO;

        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialServiceFacebook sharedService] openFacebookSessionWithSessionStateHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (weakSelf) {
                if (!error && [session isOpen]) {
                    [[MRSLSocialServiceFacebook sharedService] getFacebookUserInformation:^(NSDictionary *userInfo, NSError *error) {
                        if (!error) {
                            MRSLSocialUser *socialUser = [[MRSLSocialUser alloc] initWithUserInfo:userInfo];
                            [_appDelegate.apiService createUserAuthentication:socialUser.authentication
                                                                      success:^(id responseObject) {
                                                                          [weakSelf toggleSwitch:weakSelf.facebookSwitch
                                                                                      forNetwork:@"facebook"
                                                                                    shouldEnable:YES];
                                                                      } failure:^(NSError *error) {
                                                                          [weakSelf toggleSwitch:weakSelf.facebookSwitch
                                                                                      forNetwork:@"facebook"
                                                                                    shouldEnable:NO];
                                                                      }];
                        } else {
                            [weakSelf toggleSwitch:weakSelf.facebookSwitch
                                        forNetwork:@"facebook"
                                      shouldEnable:NO];
                        }
                    }];
                } else {
                    [weakSelf toggleSwitch:weakSelf.facebookSwitch
                                forNetwork:@"facebook"
                              shouldEnable:NO];
                }
            }
        }];
    }
}

- (IBAction)toggleTwitter:(UISwitch *)switchControl {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Twitter"
                                 properties:@{@"view": @"Publish",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    _twitterSwitch.enabled = NO;

    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialServiceTwitter sharedService] checkForValidTwitterAuthenticationWithSuccess:^(BOOL success) {
        weakSelf.twitterSwitch.enabled = YES;
    } failure:^(NSError *error) {
        [[MRSLSocialServiceTwitter sharedService] authenticateWithTwitterWithSuccess:^(BOOL success) {
            [[MRSLSocialServiceTwitter sharedService] getTwitterUserInformation:^(NSDictionary *userInfo, NSError *error) {
                if (!error) {
                    MRSLSocialUser *socialUser = [[MRSLSocialUser alloc] initWithUserInfo:userInfo];
                    [_appDelegate.apiService createUserAuthentication:socialUser.authentication
                                                              success:^(id responseObject) {
                                                                  [weakSelf toggleSwitch:weakSelf.twitterSwitch
                                                                              forNetwork:@"twitter"
                                                                            shouldEnable:YES];
                                                              } failure:^(NSError *error) {
                                                                  [weakSelf toggleSwitch:weakSelf.twitterSwitch
                                                                              forNetwork:@"twitter"
                                                                            shouldEnable:NO];
                                                              }];
                } else {
                    [weakSelf toggleSwitch:weakSelf.twitterSwitch
                                forNetwork:@"twitter"
                              shouldEnable:NO];
                }
            }];
        } failure:^(NSError *error) {
            [weakSelf toggleSwitch:weakSelf.twitterSwitch
                        forNetwork:@"twitter"
                      shouldEnable:NO];
        }];
    }];
}

#pragma mark - Private Methods

- (void)toggleSwitch:(UISwitch *)socialSwitch
          forNetwork:(NSString *)network
        shouldEnable:(BOOL)shouldEnable {
    if (shouldEnable) {
        [[MRSLEventManager sharedManager] track:@"Tapped Share Own Morsel"
                                     properties:@{@"view": @"Publish",
                                                  @"morsel_id": NSNullIfNil(self.morsel.morselID),
                                                  @"creator_id": NSNullIfNil(self.morsel.creator.userID),
                                                  @"social_type": network}];
    }
    [socialSwitch setEnabled:YES];
    [socialSwitch setOn:shouldEnable
               animated:YES];
}

@end
