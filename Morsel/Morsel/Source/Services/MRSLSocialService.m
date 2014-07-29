//
//  SocialService.m
//  Morsel
//
//  Created by Marty Trzpit on 1/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialService.h"

#import <Social/Social.h>

#import "MRSLSocialServiceFacebook.h"
#import "MRSLSocialServiceTwitter.h"
#import "MRSLSocialComposeViewController.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@implementation MRSLSocialService

#pragma mark - Class Methods

+ (instancetype)sharedService {
    static MRSLSocialService *_sharedService = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedService = [[MRSLSocialService alloc] init];
    });
    return _sharedService;
}

#pragma mark - Instance Methods

- (void)shareMorselToFacebook:(MRSLMorsel *)morsel
             inViewController:(UIViewController *)viewController
                      success:(MRSLSocialSuccessBlock)successOrNil
                       cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        [self shareMorsel:morsel
                toService:SLServiceTypeFacebook
         inViewController:viewController
                  success:successOrNil
                   cancel:cancelBlockOrNil];
    } else {
        [[MRSLSocialServiceFacebook sharedService] shareMorsel:morsel
                                                       success:successOrNil
                                                        cancel:cancelBlockOrNil];
    }
}

- (void)shareMorselToTwitter:(MRSLMorsel *)morsel
            inViewController:(UIViewController *)viewController
                     success:(MRSLSocialSuccessBlock)successOrNil
                      cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        [self shareMorsel:morsel
                toService:SLServiceTypeTwitter
         inViewController:viewController
                  success:successOrNil
                   cancel:cancelBlockOrNil];
    } else {
        [[MRSLSocialServiceTwitter sharedService] checkForValidTwitterAuthenticationWithSuccess:^(BOOL success) {
            [self shareMorsel:morsel
                  withService:MRSLSocialAccountTypeTwitter
             inViewController:viewController
                      success:successOrNil
                       cancel:cancelBlockOrNil];
        } failure:^(NSError *error) {
            [[MRSLSocialServiceTwitter sharedService] authenticateWithTwitterWithSuccess:^(BOOL success) {
                [self shareMorsel:morsel
                      withService:MRSLSocialAccountTypeTwitter
                 inViewController:viewController
                          success:successOrNil
                           cancel:cancelBlockOrNil];
            } failure:nil];
        }];
    }
}

- (void)shareTextToTwitter:(NSString *)text
          inViewController:(UIViewController *)viewController
                   success:(MRSLSocialSuccessBlock)successOrNil
                    cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    UINavigationController *shareNavNC = [[UIStoryboard socialStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardSocialComposeKey];
    MRSLSocialComposeViewController *socialComposeVC = [shareNavNC.viewControllers firstObject];
    socialComposeVC.title = @"Post to Twitter";
    socialComposeVC.placeholderText = text;
    socialComposeVC.accountType = MRSLSocialAccountTypeTwitter;
    socialComposeVC.successBlock = successOrNil;
    socialComposeVC.cancelBlock = cancelBlockOrNil;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                            object:shareNavNC];
    });
}

- (void)shareMorsel:(MRSLMorsel *)morsel
        withService:(MRSLSocialAccountType)accountType
   inViewController:(UIViewController *)viewController
            success:(MRSLSocialSuccessBlock)successOrNil
             cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    UINavigationController *shareNavNC = [[UIStoryboard socialStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardSocialComposeKey];
    MRSLSocialComposeViewController *socialComposeVC = [shareNavNC.viewControllers firstObject];
    socialComposeVC.morsel = morsel;
    socialComposeVC.accountType = accountType;
    socialComposeVC.successBlock = successOrNil;
    socialComposeVC.cancelBlock = cancelBlockOrNil;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                            object:shareNavNC];
    });
}

- (void)shareMorsel:(MRSLMorsel *)morsel
          toService:(NSString *)serviceType
   inViewController:(UIViewController *)viewController
            success:(MRSLSocialSuccessBlock)successOrNil
             cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
        SLComposeViewController *slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        NSString *userNameOrTwitterHandle =  ([serviceType isEqualToString:SLServiceTypeTwitter]) ? [morsel.creator fullNameOrTwitterHandle] : morsel.creator.fullName;
        NSString *shareText = @"";
        if ([serviceType isEqualToString:SLServiceTypeFacebook]) {
            shareText = [NSString stringWithFormat:@"“%@” from %@ on Morsel", morsel.title, userNameOrTwitterHandle];
            [slComposerSheet addURL:[NSURL URLWithString:morsel.facebook_mrsl ?: morsel.url]];
        } else if ([serviceType isEqualToString:SLServiceTypeTwitter]) {
            shareText = [NSString stringWithFormat:@"“%@” from %@ on @eatmorsel", morsel.title, userNameOrTwitterHandle];
            [slComposerSheet addURL:[NSURL URLWithString:morsel.twitter_mrsl ?: morsel.url]];
        }
        [slComposerSheet setInitialText:shareText];
        [viewController presentViewController:slComposerSheet
                                     animated:YES
                                   completion:nil];
        [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {;
            if (result == SLComposeViewControllerResultDone) {
                if (successOrNil) successOrNil(YES);
            } else {
                if (cancelBlockOrNil) cancelBlockOrNil();
            }
            if (![UIDevice currentDeviceSystemVersionIsAtLeastIOS7] && [serviceType isEqualToString:SLServiceTypeTwitter]) {
                // Corrects an issue where Twitter compose sheet is not correctly dismissing in iOS 6. Known Apple bug that was resolved in iOS 7.
                [viewController dismissViewControllerAnimated:YES
                                                   completion:nil];
            }
        }];
    } else {
        [UIAlertView showAlertViewForErrorString:[NSString stringWithFormat:@"Please add a %@ account to this device", (serviceType == SLServiceTypeFacebook) ? @"Facebook" : @"Twitter"]
                                        delegate:nil];
    }
}

@end
