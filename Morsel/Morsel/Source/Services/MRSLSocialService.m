//
//  SocialService.m
//  Morsel
//
//  Created by Marty Trzpit on 1/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialService.h"

#import <Social/Social.h>

#import "MRSLItem.h"
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

- (void)shareMorselToFacebook:(MRSLItem *)item
             inViewController:(UIViewController *)viewController
                      success:(MRSLSocialSuccessBlock)successOrNil
                       cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    [self shareMorsel:item
            toService:SLServiceTypeFacebook
     inViewController:viewController
              success:successOrNil
               cancel:cancelBlockOrNil];
}

- (void)shareMorselToTwitter:(MRSLItem *)item
            inViewController:(UIViewController *)viewController
                     success:(MRSLSocialSuccessBlock)successOrNil
                      cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    [self shareMorsel:item
            toService:SLServiceTypeTwitter
     inViewController:viewController
              success:successOrNil
               cancel:cancelBlockOrNil];
}

- (void)shareMorsel:(MRSLItem *)item
          toService:(NSString *)serviceType
   inViewController:(UIViewController *)viewController
            success:(MRSLSocialSuccessBlock)successOrNil
             cancel:(MRSLSocialCancelBlock)cancelBlockOrNil {
    if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
        SLComposeViewController *slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        NSString *userNameOrTwitterHandle =  (item.morsel.creator.twitter_username && [serviceType isEqualToString:SLServiceTypeTwitter]) ? [NSString stringWithFormat:@"@%@", item.morsel.creator.twitter_username] : item.morsel.creator.fullName;
        NSString *shareText = @"";
        if ([serviceType isEqualToString:SLServiceTypeFacebook]) {
            shareText = [NSString stringWithFormat:@"“%@” from %@ on Morsel", item.morsel.title, userNameOrTwitterHandle];
            [slComposerSheet addURL:[NSURL URLWithString:item.morsel.facebook_mrsl ?: item.morsel.url]];
        } else if ([serviceType isEqualToString:SLServiceTypeTwitter]) {
            shareText = [NSString stringWithFormat:@"“%@” from %@ on @eatmorsel", item.morsel.title, userNameOrTwitterHandle];
            [slComposerSheet addURL:[NSURL URLWithString:item.morsel.twitter_mrsl ?: item.morsel.url]];
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
        [UIAlertView showAlertViewForErrorString:[NSString stringWithFormat:@"Please add a %@ Account to this device", (serviceType == SLServiceTypeFacebook) ? @"Facebook" : @"Twitter"]
                                        delegate:nil];
    }
}

@end
