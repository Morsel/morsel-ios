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
    __weak __typeof(self) weakSelf = self;
    _facebookSwitch.enabled = NO;
    if (![FBSession.activeSession isOpen]) {
        [[MRSLSocialServiceFacebook sharedService] openFacebookSessionWithSessionStateHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (weakSelf) {
                if (!error && [session isOpen]) {
                    // This must be dispatched after, otherwise it will trigger before the app has resumed.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf checkForFacebookPublishPermissions];
                    });
                } else {
                    [weakSelf setOnSwitch:weakSelf.facebookSwitch
                               forNetwork:@"facebook"
                             shouldTurnOn:NO];
                }
            }
        }];
    } else {
        [self checkForFacebookPublishPermissions];
    }
}

- (IBAction)toggleInstagram:(UISwitch *)switchControl {
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
            if (success) {
                [weakSelf setOnSwitch:weakSelf.twitterSwitch
                           forNetwork:@"twitter"
                         shouldTurnOn:YES];
            } else {
                [weakSelf setOnSwitch:weakSelf.twitterSwitch
                           forNetwork:@"twitter"
                         shouldTurnOn:NO];
            }
        } failure:^(NSError *error) {
            [weakSelf setOnSwitch:weakSelf.twitterSwitch
                       forNetwork:@"twitter"
                     shouldTurnOn:NO];
        }];
    }];
}

#pragma mark - Private Methods

- (void)checkForFacebookPublishPermissions {
    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialServiceFacebook sharedService] checkForPublishPermissions:^(BOOL canPublish) {
        if (weakSelf) {
            if (!canPublish) {
                [[MRSLSocialServiceFacebook sharedService] requestPublishPermissionsWithCompletion:^(FBSession *session, NSError *error) {
                    if ([FBSession.activeSession.permissions
                         indexOfObject:@"publish_actions"] != NSNotFound) {
                        [weakSelf setOnSwitch:weakSelf.facebookSwitch
                                   forNetwork:@"facebook"
                                 shouldTurnOn:YES];
                    } else {
                        [weakSelf setOnSwitch:weakSelf.facebookSwitch
                                   forNetwork:@"facebook"
                                 shouldTurnOn:NO];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [UIAlertView showOKAlertViewWithTitle:@"Publish Permission Required"
                                                          message:@"Morsel has not been granted authorization to post to Facebook on your behalf."];
                        });
                    }
                }];
            } else {
                weakSelf.facebookSwitch.enabled = YES;
            }
        }
    }];
}

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

#pragma mark - Dealloc

- (void)dealloc {
    if (self.documentInteractionController) {
        self.documentInteractionController.delegate = nil;
        self.documentInteractionController = nil;
    }
}

@end
