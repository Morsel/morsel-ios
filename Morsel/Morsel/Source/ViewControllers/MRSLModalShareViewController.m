//
//  MRSLModalShareViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLModalShareViewController.h"

#import "MRSLSocialService.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface MRSLModalShareViewController ()

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *shareStatusLabel;

@property (strong, nonatomic) SLComposeViewController *mySLComposerSheet;

@end

@implementation MRSLModalShareViewController

#pragma mark - Action Methods

- (IBAction)shareToFacebook {
    _facebookButton.enabled = NO;
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Share Morsel",
                                              @"_view": @"share",
                                              @"morsel_id": NSNullIfNil(_item.morsel.morselID),
                                              @"creator_id": NSNullIfNil(_item.morsel.creator.userID),
                                              @"social_type": @"facebook"}];
    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialService sharedService] shareMorselToFacebook:_item.morsel
                                            inViewController:self
                                                     success:^(BOOL success) {
                                                         if (weakSelf && success) {
                                                             [MRSLEventManager sharedManager].morsels_shared_to_fb++;
                                                             weakSelf.shareStatusLabel.text = @"Shared to Facebook";
                                                         } else {
                                                             weakSelf.facebookButton.enabled = YES;
                                                         }
                                                     } cancel:^{
                                                         if (weakSelf) {
                                                             weakSelf.facebookButton.enabled = YES;
                                                         }
                                                     }];
}

- (IBAction)shareToTwitter {
    _twitterButton.enabled = NO;
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Share Morsel",
                                              @"_view": @"share",
                                              @"morsel_id": NSNullIfNil(_item.morsel.morselID),
                                              @"creator_id": NSNullIfNil(_item.morsel.creator.userID),
                                              @"social_type": @"twitter"}];
    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialService sharedService] shareMorselToTwitter:_item.morsel
                                           inViewController:self
                                                    success:^(BOOL success) {
                                                        if (weakSelf && success) {
                                                            [MRSLEventManager sharedManager].morsels_shared_to_twitter++;
                                                            weakSelf.shareStatusLabel.text = @"Shared to Twitter";
                                                        } else {
                                                            weakSelf.twitterButton.enabled = YES;
                                                        }
                                                    } cancel:^{
                                                        if (weakSelf) {
                                                            weakSelf.twitterButton.enabled = YES;
                                                        }
                                                    }];
}

- (IBAction)saveToClipboard {
    NSString *morselShareURL = _item.morsel.clipboard_mrsl ?: _item.morsel.url;
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString:morselShareURL];
    _shareStatusLabel.text = @"Copied share link to clipboard";
}

@end
