//
//  MRSLMorselSettingsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselPublishViewController.h"

#import "MRSLSocialService.h"
#import "MRSLItemImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLMorselPublishViewController ()
<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *coverMorselImageView;

@property (strong, nonatomic) UIBarButtonItem *publishButton;

@end

@implementation MRSLMorselPublishViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _coverMorselImageView.item = [_morsel coverItem];
    _morselTitleLabel.text = _morsel.title;
    [_morselTitleLabel addStandardShadow];
}

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
                                sendToFacebook:_facebookButton.selected
                                 sendToTwitter:_twitterButton.selected];
}

- (IBAction)toggleFacebook:(UIButton *)button {
    MRSLUser *currentUser = [MRSLUser currentUser];
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Facebook"
                                 properties:@{@"view": @"Publish",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];

    if ([currentUser facebook_uid]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Facebook"
                                     properties:@{@"view": @"Publish",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
        //  api already has a token, so just toggle the button
        [button setSelected:!button.selected];
    } else {
        _facebookButton.enabled = NO;

        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialService sharedService] activateFacebookWithSuccess:^(BOOL success) {
            if (weakSelf) {
                [[MRSLEventManager sharedManager] track:@"Tapped Share Own Morsel"
                                             properties:@{@"view": @"Publish",
                                                          @"morsel_id": NSNullIfNil(weakSelf.morsel.morselID),
                                                          @"creator_id": NSNullIfNil(weakSelf.morsel.creator.userID),
                                                          @"social_type": @"facebook"}];
                [weakSelf.facebookButton setEnabled:YES];
                [weakSelf.facebookButton setSelected:!weakSelf.facebookButton.selected];
            }
        } failure:^(NSError *error) {
            if (weakSelf) {
                [weakSelf.facebookButton setEnabled:YES];
            }
        }];
    }
}

- (IBAction)toggleTwitter:(UIButton *)button {
    [[MRSLEventManager sharedManager] track:@"Tapped Toggle Twitter"
                                 properties:@{@"view": @"Publish",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    MRSLUser *currentUser = [MRSLUser currentUser];

    if ([currentUser twitter_username]) {
        [[MRSLEventManager sharedManager] track:@"User Already Authorized with Twitter"
                                     properties:@{@"view": @"Publish",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
        //  api already has a token, so just toggle the button
        [button setSelected:!button.selected];
    } else {
        _twitterButton.enabled = NO;

        __weak __typeof(self) weakSelf = self;
        [[MRSLSocialService sharedService] activateTwitterWithSuccess:^(BOOL success) {
            if (weakSelf) {
                [[MRSLEventManager sharedManager] track:@"Tapped Share Own Morsel"
                                             properties:@{@"view": @"Publish",
                                                          @"morsel_id": NSNullIfNil(weakSelf.morsel.morselID),
                                                          @"creator_id": NSNullIfNil(weakSelf.morsel.creator.userID),
                                                          @"social_type": @"twitter"}];
                [weakSelf.twitterButton setEnabled:YES];
                [weakSelf.twitterButton setSelected:!weakSelf.twitterButton.selected];
            }
        } failure:^(NSError *error) {
            if (weakSelf) {
                [weakSelf.twitterButton setEnabled:YES];
            }
        }];
    }
}

@end
