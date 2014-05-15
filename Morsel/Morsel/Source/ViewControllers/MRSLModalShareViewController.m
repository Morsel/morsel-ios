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
@property (weak, nonatomic) IBOutlet UILabel *shareConfirmationLabel;

@property (strong, nonatomic) SLComposeViewController *mySLComposerSheet;

@end

@implementation MRSLModalShareViewController

#pragma mark - Action Methods

- (IBAction)shareToFacebook {
    _facebookButton.enabled = NO;
    [[MRSLEventManager sharedManager] track:@"Tapped Share Morsel"
                                 properties:@{@"view": @"share",
                                              @"morsel_id": NSNullIfNil(_item.morsel.morselID),
                                              @"creator_id": NSNullIfNil(_item.morsel.creator.userID),
                                              @"social_type": @"facebook"}];
    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialService sharedService] shareMorselToFacebook:_item.morsel
                                            inViewController:self
                                                     success:^(BOOL success) {
                                                         if (weakSelf && success) {
                                                             [weakSelf displaySuccess];
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
    [[MRSLEventManager sharedManager] track:@"Tapped Share Morsel"
                                 properties:@{@"view": @"share",
                                              @"morsel_id": NSNullIfNil(_item.morsel.morselID),
                                              @"creator_id": NSNullIfNil(_item.morsel.creator.userID),
                                              @"social_type": @"twitter"}];
    __weak __typeof(self) weakSelf = self;
    [[MRSLSocialService sharedService] shareMorselToTwitter:_item.morsel
                                           inViewController:self
                                                    success:^(BOOL success) {
                                                        if (weakSelf && success) {
                                                            [weakSelf displaySuccess];
                                                        } else {
                                                            weakSelf.twitterButton.enabled = YES;
                                                        }
                                                    } cancel:^{
                                                        if (weakSelf) {
                                                            weakSelf.twitterButton.enabled = YES;
                                                        }
                                                    }];
}

#pragma mark - Private Methods

- (void)displaySuccess {
    [_shareConfirmationLabel setHidden:NO];
    [UIView animateWithDuration:.3f
                     animations:^{
                         [_facebookButton setAlpha:0.f];
                         [_twitterButton setAlpha:0.f];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.3f
                                          animations:^{
                                              [_shareConfirmationLabel setAlpha:1.f];
                                          } completion:^(BOOL finished) {
                                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                  [self dismiss:nil];
                                              });
                                          }];
                     }];
}

@end
