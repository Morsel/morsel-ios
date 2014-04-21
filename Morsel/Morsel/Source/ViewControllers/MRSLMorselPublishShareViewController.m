//
//  MRSLMorselPublishShareViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/18/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselPublishShareViewController.h"

#import "MRSLSocialService.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselPublishShareViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *publishButton;

@end

@implementation MRSLMorselPublishShareViewController

#pragma mark - Private Methods

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
    [_appDelegate.itemApiService publishMorsel:_morsel
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
    MRSLUser *currentUser = [MRSLUser currentUser];
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Facebook"
                                 properties:@{@"view": @"Publish",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    if ([currentUser facebook_uid]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Facebook"
                                     properties:@{@"view": @"Publish",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    } else {
        _facebookSwitch.enabled = NO;

        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialService sharedService] activateFacebookWithSuccess:^(BOOL success) {
            if (weakSelf) {
                [[MRSLEventManager sharedManager] track:@"Tapped Share Own Morsel"
                                             properties:@{@"view": @"Publish",
                                                          @"morsel_id": NSNullIfNil(weakSelf.morsel.morselID),
                                                          @"creator_id": NSNullIfNil(weakSelf.morsel.creator.userID),
                                                          @"social_type": @"facebook"}];
                [weakSelf.facebookSwitch setEnabled:YES];
                [weakSelf.facebookSwitch setOn:YES
                                      animated:YES];
            }
        } failure:^(NSError *error) {
            if (weakSelf) {
                [weakSelf.facebookSwitch setEnabled:YES];
                [weakSelf.facebookSwitch setOn:NO
                                      animated:YES];
            }
        }];
    }
}

- (IBAction)toggleTwitter:(UISwitch *)switchControl {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Twitter"
                                 properties:@{@"view": @"Publish",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    MRSLUser *currentUser = [MRSLUser currentUser];

    if ([currentUser twitter_username]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Twitter"
                                     properties:@{@"view": @"Publish",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    } else {
        _twitterSwitch.enabled = NO;

        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialService sharedService] activateTwitterWithSuccess:^(BOOL success) {
            if (weakSelf) {
                [[MRSLEventManager sharedManager] track:@"Tapped Share Own Morsel"
                                             properties:@{@"view": @"Publish",
                                                          @"morsel_id": NSNullIfNil(weakSelf.morsel.morselID),
                                                          @"creator_id": NSNullIfNil(weakSelf.morsel.creator.userID),
                                                          @"social_type": @"twitter"}];
                [weakSelf.twitterSwitch setEnabled:YES];
                [weakSelf.twitterSwitch setOn:YES
                                     animated:YES];
            }
        } failure:^(NSError *error) {
            if (weakSelf) {
                [weakSelf.twitterSwitch setEnabled:YES];
                [weakSelf.twitterSwitch setOn:NO
                                     animated:YES];
            }
        }];
    }
}

@end
