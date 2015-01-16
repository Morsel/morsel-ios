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

#import <SDWebImage/SDWebImageManager.h>

@interface MRSLMorselPublishShareViewController ()
<UIDocumentInteractionControllerDelegate>

@property (nonatomic) int morselID;
@property (nonatomic) int checksRequired;
@property (nonatomic) int checksCompleted;

@property (nonatomic) BOOL publishing;

@property (strong, nonatomic) NSMutableArray *checksFailed;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *instagramSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *publishButton;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation MRSLMorselPublishShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_eventView = @"publish_morsel";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appBecameActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reEnableFacebook)
                                                 name:MRSLFacebookReconnectedAccountNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reEnableTwitter)
                                                 name:MRSLTwitterReconnectedAccountNotification
                                               object:nil];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    _morsel = morsel;
    self.morselID = morsel.morselIDValue;
}

#pragma mark - Notification Methods

- (void)appBecameActive {
    self.twitterButton.enabled = YES;
    self.facebookButton.enabled = YES;
}

- (void)reEnableFacebook {
    [self.facebookSwitch setOn:YES
                      animated:YES];
}

- (void)reEnableTwitter {
    [self.twitterSwitch setOn:YES
                     animated:YES];
}

#pragma mark - Action Methods

- (IBAction)publishMorsel:(id)sender {
    _publishButton.enabled = NO;

    self.checksFailed = [NSMutableArray array];
    if (_facebookSwitch.isOn) self.checksRequired++;
    if (_twitterSwitch.isOn) self.checksRequired++;

    if (self.checksRequired > 0) {
        [self performPublishPreflightCheck];
    } else {
        [self finalizePublish];
    }
}

- (IBAction)toggleFacebook {
    _facebookButton.enabled = NO;

    if (!_facebookSwitch.isOn) {
        if (![FBSession.activeSession isOpen]) {
            __weak __typeof(self) weakSelf = self;
            [[MRSLSocialServiceFacebook sharedService] openFacebookSessionWithSessionStateHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    if (!error && [session isOpen]) {
                        // This must be dispatched after, otherwise it will trigger before the app has resumed.
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [strongSelf checkForFacebookPublishPermissionsWithCompletion:^(BOOL success) {
                                [strongSelf updateFacebookSwitch:success];
                            }];
                        });
                    } else {
                        [strongSelf toggleSwitch:strongSelf.facebookSwitch
                                      forNetwork:@"facebook"
                                    shouldTurnOn:NO];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            strongSelf.facebookButton.enabled = YES;
                        });
                        [MRSLSocialServiceFacebook sharedService].sessionStateHandlerBlock = nil;
                    }
                }
            }];
        } else {
            __weak __typeof(self) weakSelf = self;
            [self checkForFacebookPublishPermissionsWithCompletion:^(BOOL success) {
                [weakSelf updateFacebookSwitch:success];
            }];
        }
    } else {
        [self toggleSwitch:_facebookSwitch
                forNetwork:@"facebook"
              shouldTurnOn:NO];
        self.facebookButton.enabled = YES;
    }
}

- (IBAction)toggleTwitter {
    _twitterButton.enabled = NO;
    if (!_twitterSwitch.isOn) {
        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialServiceTwitter sharedService] checkForValidTwitterAuthenticationWithSuccess:^(BOOL success) {
            [weakSelf toggleSwitch:weakSelf.twitterSwitch
                        forNetwork:@"twitter"
                      shouldTurnOn:success];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.twitterButton.enabled = YES;
            });
        } failure:^(NSError *error) {
            [[MRSLSocialServiceTwitter sharedService] authenticateWithTwitterWithSuccess:^(BOOL success) {
                if (success) {
                    [weakSelf toggleSwitch:weakSelf.twitterSwitch
                                forNetwork:@"twitter"
                              shouldTurnOn:YES];
                } else {
                    [weakSelf toggleSwitch:weakSelf.twitterSwitch
                                forNetwork:@"twitter"
                              shouldTurnOn:NO];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.twitterButton.enabled = YES;
                });
            } failure:^(NSError *error) {
                [weakSelf toggleSwitch:weakSelf.twitterSwitch
                            forNetwork:@"twitter"
                          shouldTurnOn:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.twitterButton.enabled = YES;
                });
            }];
        }];
    } else {
        [self toggleSwitch:_twitterSwitch
                forNetwork:@"twitter"
              shouldTurnOn:NO];
        self.twitterButton.enabled = YES;
    }
}

- (IBAction)toggleInstagram:(UISwitch *)switchControl {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
        [self toggleSwitch:_instagramSwitch
                forNetwork:@"instagram"
              shouldTurnOn:_instagramSwitch.isOn];
    } else {
        [self toggleSwitch:_instagramSwitch
                forNetwork:@"instagram"
              shouldTurnOn:NO];
        [UIAlertView showAlertViewWithTitle:@"Instagram not found"
                                    message:@"Please install Instagram to share your morsel there"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
    }
}

#pragma mark - Private Methods

- (void)performPublishPreflightCheck {
    if (_facebookSwitch.isOn) {
        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialServiceFacebook sharedService] checkForPublishPermissions:^(BOOL canPublish) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if (!canPublish) [strongSelf.checksFailed addObject:@"Facebook"];
                [strongSelf verifyPublishPreflight];
            }
        }];
    }
    if (_twitterSwitch.isOn) {
        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialServiceTwitter sharedService] checkForValidTwitterAuthenticationWithSuccess:^(BOOL success) {
            if (!success) [weakSelf.checksFailed addObject:@"Twitter"];
            [weakSelf verifyPublishPreflight];
        } failure:^(NSError *error) {
            [weakSelf.checksFailed addObject:@"Twitter"];
            [weakSelf verifyPublishPreflight];
        }];
    }
}

- (void)verifyPublishPreflight {
    if (_publishing) return;
    self.checksCompleted++;

    DDLogDebug(@"Publish preflight check %i out of %i completed with %i failures", self.checksCompleted, self.checksRequired, (int)[self.checksFailed count]);

    BOOL readyToPublish = (self.checksCompleted == self.checksRequired);

    if (readyToPublish && [self.checksFailed count] > 0) {

        if ([self.checksFailed containsObject:@"Facebook"]) {
            [self.facebookSwitch setOn:NO
                              animated:YES];
        }
        if ([self.checksFailed containsObject:@"Twitter"]) {
            [self.twitterSwitch setOn:NO
                             animated:YES];
        }
        self.publishing = NO;

        self.publishButton.enabled = YES;
    } else if (readyToPublish && [self.checksFailed count] == 0) {
        [self finalizePublish];
    }
}

- (void)finalizePublish {
    DDLogDebug(@"All checks passed. Publishing morsel!");
    self.publishing = YES;
    _morsel.draft = @NO;

    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Publish",
                                              @"_view": self.mp_eventView,
                                              @"morsel_id": NSNullIfNil(self.morsel.morselID),
                                              @"creator_id": NSNullIfNil(self.morsel.creator.userID),
                                              @"share_to_facebook": _facebookSwitch.isOn ? @"true" : @"false",
                                              @"share_to_twitter": _twitterSwitch.isOn ? @"true" : @"false",
                                              @"share_to_instagram": _instagramSwitch.isOn ? @"true" : @"false"}];

    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService publishMorsel:_morsel
                                   success:^(id responseObject) {
                                       [MRSLEventManager sharedManager].morsels_published++;
                                       if (weakSelf.instagramSwitch.isOn) [weakSelf prepareForInstagram];
                                   } failure:^(NSError *error) {
                                       weakSelf.publishButton.enabled = YES;
                                       [UIAlertView showAlertViewForErrorString:@"Unable to publish morsel, please try again!"
                                                                       delegate:nil];
                                   }
                            sendToFacebook:_facebookSwitch.isOn
                             sendToTwitter:_twitterSwitch.isOn
                       willOpenInInstagram:_instagramSwitch.isOn];
}

- (void)checkForFacebookPublishPermissionsWithCompletion:(MRSLSocialSuccessBlock)successOrNil {
    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialServiceFacebook sharedService] checkForPublishPermissions:^(BOOL canPublish) {
        if (weakSelf) {
            if (!canPublish) {
                [[MRSLSocialServiceFacebook sharedService] requestPublishPermissionsWithCompletion:^(FBSession *session, NSError *error) {
                    if ([FBSession.activeSession.permissions
                         indexOfObject:@"publish_actions"] != NSNotFound) {
                        if (successOrNil) successOrNil(YES);
                    } else {
                        if (successOrNil) successOrNil(NO);
                    }
                }];
            } else {
                if (successOrNil) successOrNil(YES);
            }
        }
    }];
}

- (void)updateFacebookSwitch:(BOOL)shouldEnable {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf) {
            weakSelf.facebookButton.enabled = shouldEnable;

            [weakSelf toggleSwitch:weakSelf.facebookSwitch
                        forNetwork:@"facebook"
                      shouldTurnOn:shouldEnable];
            if (!shouldEnable) {
                [UIAlertView showOKAlertViewWithTitle:@"Publish Permission Required"
                                              message:@"Morsel has not been granted authorization to post to Facebook on your behalf."];
            }
        }
    });
}

- (void)prepareForInstagram {
    __weak __typeof(self) weakSelf = self;
    NSData *coverPhotoData = [self.morsel downloadCoverPhotoIfNilWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [weakSelf sendDataToInstagram:[weakSelf.morsel coverItem].itemPhotoFull];
        } else {
            [UIAlertView showAlertViewForErrorString:@"There was an error preparing your Instagram photo. Please try again."
                                            delegate:nil];
        }
    }];

    if (coverPhotoData) [self sendDataToInstagram:coverPhotoData];
}

- (void)sendDataToInstagram:(NSData *)photoData {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *watermarkedImage = [UIImage MRSL_applyWatermarkToImage:[UIImage imageWithData:photoData]];

        NSString *photoFilePath = [NSString stringWithFormat:@"%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],@"tempinstgramphoto.igo"];
        if([UIImageJPEGRepresentation(watermarkedImage, 1.f) writeToFile:photoFilePath
                                                              atomically:YES]) {
            weakSelf.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:photoFilePath]];
            weakSelf.documentInteractionController.UTI = @"com.instagram.exclusivegram";
            weakSelf.documentInteractionController.delegate = weakSelf;
            weakSelf.documentInteractionController.annotation = @{ @"InstagramCaption" : [weakSelf.morsel instagramString]};
            [_documentInteractionController presentOpenInMenuFromRect:CGRectZero
                                                               inView:weakSelf.view
                                                             animated:YES];
        } else {
            [UIAlertView showAlertViewForErrorString:@"There was an error preparing your Instagram photo. Please try again."
                                            delegate:nil];
        }
    });
}

- (void)toggleSwitch:(UISwitch *)socialSwitch
          forNetwork:(NSString *)network
        shouldTurnOn:(BOOL)shouldTurnOn {
    dispatch_async(dispatch_get_main_queue(), ^{
        [socialSwitch setEnabled:YES];
        [socialSwitch setOn:shouldTurnOn
                   animated:YES];
    });
}


#pragma mark - UIDocumentInteractionControllerDelegate Methods

- (void)documentInteractionController:(UIDocumentInteractionController *)controller
        willBeginSendingToApplication:(NSString *)application {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSUserDefaults standardUserDefaults] setInteger:[self.morsel.morselID integerValue]
                                                   forKey:@"recentlyPublishedMorselID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidPublishMorselNotification
                                                            object:_morsel];
    });
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

@end
