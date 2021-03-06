//
//  MRSLSocialConnectionsTableViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialConnectionsTableViewController.h"

#import "MRSLAPIService+Authentication.h"
#import "MRSLAPIService+Profile.h"

#import "MRSLSocialServiceFacebook.h"
#import "MRSLSocialServiceTwitter.h"
#import "MRSLSocialServiceInstagram.h"

#import "MRSLUser.h"
#import "MRSLSocialAuthentication.h"
#import "MRSLSocialUser.h"

@interface MRSLSocialConnectionsTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *facebookUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *instagramUsernameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *instagramSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoFollowSwitch;

@end

@implementation MRSLSocialConnectionsTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displaySocialConnectionInformation)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [self displaySocialConnectionInformation];
}

- (void)displaySocialConnectionInformation {
    if ([FBSession.activeSession isOpen]) {
        self.facebookUsernameLabel.text = @"";
        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialServiceFacebook sharedService] getFacebookUserInformation:^(NSDictionary *userInfo, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.facebookUsernameLabel.text = [NSString stringWithFormat:@"%@ %@", userInfo[@"first_name"], userInfo[@"last_name"]];
            });
        }];
    }
    self.facebookSwitch.on = [FBSession.activeSession isOpen];
    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialServiceTwitter sharedService] checkForValidTwitterAuthenticationWithSuccess:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.twitterSwitch setOn:success
                                 animated:NO];
            weakSelf.twitterUsernameLabel.text = [[MRSLSocialServiceTwitter sharedService] twitterUsername];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.twitterSwitch setOn:NO
                                   animated:NO];
        });
    }];
    [[MRSLSocialServiceInstagram sharedService] checkForValidInstagramAuthenticationWithSuccess:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.instagramSwitch setOn:success
                                   animated:NO];
            weakSelf.instagramUsernameLabel.text = [[MRSLSocialServiceInstagram sharedService] instagramUsername];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.instagramSwitch setOn:NO
                                   animated:NO];
        });
    }];
    self.autoFollowSwitch.on = [MRSLUser currentUser].auto_followValue;
}

- (IBAction)toggleFacebook:(UISwitch *)switchControl {
    if (![FBSession.activeSession isOpen]) {
        _facebookSwitch.enabled = NO;
        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialServiceFacebook sharedService] openFacebookSessionWithSessionStateHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (weakSelf) {
                if (!error && [session isOpen]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __weak __typeof(self) weakSelf = self;
                        [[MRSLSocialServiceFacebook sharedService] getFacebookUserInformation:^(NSDictionary *userInfo, NSError *error) {
                            weakSelf.facebookUsernameLabel.text = [NSString stringWithFormat:@"%@ %@", userInfo[@"first_name"], userInfo[@"last_name"]];
                        }];
                    });
                    [weakSelf toggleSwitch:weakSelf.facebookSwitch
                              shouldEnable:YES];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.facebookUsernameLabel.text = @"Connect with Facebook ➡︎";
                    });
                    [weakSelf toggleSwitch:weakSelf.facebookSwitch
                              shouldEnable:NO];
                    [MRSLSocialServiceFacebook sharedService].sessionStateHandlerBlock = nil;
                }
            }
        }];
    } else {
        [FBSession.activeSession closeAndClearTokenInformation];
        _facebookUsernameLabel.text = @"Connect with Facebook ➡︎";
        _facebookSwitch.on = NO;
    }
}

- (IBAction)toggleTwitter:(UISwitch *)switchControl {
    _twitterSwitch.enabled = NO;

    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialServiceTwitter sharedService] checkForValidTwitterAuthenticationWithSuccess:^(BOOL success) {
        [_appDelegate.apiService deleteUserAuthentication:[MRSLSocialServiceTwitter sharedService].socialAuthentication
                                                  success:^(id responseObject) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          weakSelf.twitterUsernameLabel.text = @"Connect with Twitter ➡︎";
                                                      });
                                                      [weakSelf toggleSwitch:weakSelf.twitterSwitch
                                                                shouldEnable:NO];
                                                      [[MRSLSocialServiceTwitter sharedService] reset];
                                                  } failure:^(NSError *error) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          weakSelf.twitterUsernameLabel.text = @"Connect with Twitter ➡︎";
                                                      });
                                                      [weakSelf toggleSwitch:weakSelf.twitterSwitch
                                                                shouldEnable:NO];
                                                  }];
    } failure:^(NSError *error) {
        [[MRSLSocialServiceTwitter sharedService] authenticateWithTwitterWithSuccess:^(BOOL success) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.twitterUsernameLabel.text = [[MRSLSocialServiceTwitter sharedService] twitterUsername];
                });
                [weakSelf toggleSwitch:weakSelf.twitterSwitch
                          shouldEnable:YES];
            } else {
                [weakSelf toggleSwitch:weakSelf.twitterSwitch
                          shouldEnable:NO];
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.twitterUsernameLabel.text = @"Connect with Twitter ➡︎";
            });
            [weakSelf toggleSwitch:weakSelf.twitterSwitch
                      shouldEnable:NO];
        }];
    }];
}

- (IBAction)toggleInstagram:(UISwitch *)switchControl {
    _instagramSwitch.enabled = NO;

    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialServiceInstagram sharedService] checkForValidInstagramAuthenticationWithSuccess:^(BOOL success) {
        [_appDelegate.apiService deleteUserAuthentication:[MRSLSocialServiceInstagram sharedService].socialAuthentication
                                                  success:^(id responseObject) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          weakSelf.instagramUsernameLabel.text = @"Connect with Instagram ➡︎";
                                                      });
                                                      [weakSelf toggleSwitch:weakSelf.instagramSwitch
                                                                shouldEnable:NO];
                                                      [[MRSLSocialServiceInstagram sharedService] reset];
                                                  } failure:^(NSError *error) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          weakSelf.instagramUsernameLabel.text = @"Connect with Instagram ➡︎";
                                                      });
                                                      [weakSelf toggleSwitch:weakSelf.instagramSwitch
                                                                shouldEnable:NO];
                                                  }];
    } failure:^(NSError *error) {
        [[MRSLSocialServiceInstagram sharedService] authenticateWithInstagramWithSuccess:^(BOOL success) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.instagramUsernameLabel.text = [[MRSLSocialServiceInstagram sharedService] instagramUsername];
                });
                [weakSelf toggleSwitch:weakSelf.instagramSwitch
                          shouldEnable:YES];
            } else {
                [weakSelf toggleSwitch:weakSelf.instagramSwitch
                          shouldEnable:NO];
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.instagramUsernameLabel.text = @"Connect with Instagram ➡︎";
            });
            [weakSelf toggleSwitch:weakSelf.instagramSwitch
                      shouldEnable:NO];
        }];
    }];
}

- (IBAction)toggleAutoFollow {
    _autoFollowSwitch.enabled = NO;

    BOOL shouldAutoFollow = ![MRSLUser currentUser].auto_followValue;
    [_autoFollowSwitch setOn:shouldAutoFollow
                    animated:NO];
    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService updateAutoFollow:shouldAutoFollow
                                      success:^(id responseObject) {
                                          weakSelf.autoFollowSwitch.enabled = YES;
                                          [MRSLUser currentUser].auto_follow = @(shouldAutoFollow);
                                      } failure:^(NSError *error) {
                                          weakSelf.autoFollowSwitch.enabled = YES;
                                          [weakSelf.autoFollowSwitch setOn:!shouldAutoFollow
                                                                  animated:NO];
                                      }];
}

#pragma mark - Private Methods

- (void)toggleSwitch:(UISwitch *)socialSwitch
        shouldEnable:(BOOL)shouldEnable {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [socialSwitch setEnabled:YES];
        [socialSwitch setOn:shouldEnable
                   animated:YES];

    });
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor morselDefaultCellBackgroundColor]];

    [cell addDefaultBorderForDirections:MRSLBorderNorth];
    if ([self.tableView isLastRowInSectionForIndexPath:indexPath]) {
        [cell addDefaultBorderForDirections:MRSLBorderSouth];
    }
}

@end
