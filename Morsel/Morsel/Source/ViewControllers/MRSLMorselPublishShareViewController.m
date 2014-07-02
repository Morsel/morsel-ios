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

# import <SDWebImage/SDWebImageManager.h>

@interface MRSLMorselPublishShareViewController ()
<UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *instagramSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *publishButton;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation MRSLMorselPublishShareViewController

#pragma mark - Action Methods

- (IBAction)publishMorsel:(id)sender {
    if ([[_morsel items] count] == 0) {
        [UIAlertView showAlertViewForErrorString:@"Sorry, it looks like this Morsel has no items!"
                                        delegate:nil];
        return;
    }
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
    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService publishMorsel:_morsel
                                   success:^(id responseObject) {
                                       if (weakSelf.instagramSwitch.isOn) [weakSelf sendToInstagram];
                                   } failure:^(NSError *error) {
                                       weakSelf.publishButton.enabled = YES;
                                       [UIAlertView showAlertViewForErrorString:@"Unable to publish morsel, please try again!"
                                                                       delegate:nil];
                                   }
                            sendToFacebook:_facebookSwitch.isOn
                             sendToTwitter:_twitterSwitch.isOn
                       willOpenInInstagram:_instagramSwitch.isOn];
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
                                                                          [weakSelf setOnSwitch:weakSelf.facebookSwitch
                                                                                      forNetwork:@"facebook"
                                                                                    shouldTurnOn:YES];
                                                                      } failure:^(NSError *error) {
                                                                          [weakSelf setOnSwitch:weakSelf.facebookSwitch
                                                                                      forNetwork:@"facebook"
                                                                                    shouldTurnOn:NO];
                                                                      }];
                        } else {
                            [weakSelf setOnSwitch:weakSelf.facebookSwitch
                                        forNetwork:@"facebook"
                                      shouldTurnOn:NO];
                        }
                    }];
                } else {
                    [weakSelf setOnSwitch:weakSelf.facebookSwitch
                                forNetwork:@"facebook"
                              shouldTurnOn:NO];
                }
            }
        }];
    }
}

- (IBAction)toggleInstagram:(UISwitch *)switchControler {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Instagram"
                                 properties:@{@"view": @"Publish",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
        [self setOnSwitch:_instagramSwitch
               forNetwork:@"instagram"
             shouldTurnOn:_instagramSwitch.isOn];
    } else {
        [self setOnSwitch:_instagramSwitch
                forNetwork:@"instagram"
              shouldTurnOn:NO];
        [UIAlertView showAlertViewWithTitle:@"Instagram not found"
                                    message:@"Please install Instagram to share your morsel there"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
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
                                                                  [weakSelf setOnSwitch:weakSelf.twitterSwitch
                                                                              forNetwork:@"twitter"
                                                                            shouldTurnOn:YES];
                                                              } failure:^(NSError *error) {
                                                                  [weakSelf setOnSwitch:weakSelf.twitterSwitch
                                                                              forNetwork:@"twitter"
                                                                            shouldTurnOn:NO];
                                                              }];
                } else {
                    [weakSelf setOnSwitch:weakSelf.twitterSwitch
                                forNetwork:@"twitter"
                              shouldTurnOn:NO];
                }
            }];
        } failure:^(NSError *error) {
            [weakSelf setOnSwitch:weakSelf.twitterSwitch
                        forNetwork:@"twitter"
                      shouldTurnOn:NO];
        }];
    }];
}

#pragma mark - Private Methods

- (void)sendToInstagram {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *photoCroppedData = [[_morsel coverItem] itemPhotoCropped];

        if (photoCroppedData) {
            NSString *photoFilePath = [NSString stringWithFormat:@"%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],@"tempinstgramphoto.igo"];
            if ([photoCroppedData writeToFile:photoFilePath
                                   atomically:YES]) {
                self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:photoFilePath]];
                self.documentInteractionController.UTI = @"com.instagram.exclusivegram";
                self.documentInteractionController.delegate = self;
                self.documentInteractionController.annotation = @{ @"InstagramCaption" : (self.morsel.title ? [NSString stringWithFormat:@"\"%@\" on @eatmorsel", self.morsel.title] : @"Posted on @eatmorsel") };
                [_documentInteractionController presentOpenInMenuFromRect:CGRectZero
                                                                   inView:self.view
                                                                 animated:YES];
            } else {
                [UIAlertView showAlertViewForErrorString:@"Unable to set Instagram photo. Please try again."
                                                delegate:nil];
            }
        }
    });
}

- (void)setOnSwitch:(UISwitch *)socialSwitch
          forNetwork:(NSString *)network
        shouldTurnOn:(BOOL)shouldTurnOn {
    if (shouldTurnOn) {
        [[MRSLEventManager sharedManager] track:@"Tapped Share Own Morsel"
                                     properties:@{@"view": @"Publish",
                                                  @"morsel_id": NSNullIfNil(self.morsel.morselID),
                                                  @"creator_id": NSNullIfNil(self.morsel.creator.userID),
                                                  @"social_type": network}];
    }
    [socialSwitch setEnabled:YES];
    [socialSwitch setOn:shouldTurnOn
               animated:YES];
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

#pragma mark - Dealloc

- (void)dealloc {
    if (self.documentInteractionController) {
        self.documentInteractionController.delegate = nil;
        self.documentInteractionController = nil;
    }
}

@end
