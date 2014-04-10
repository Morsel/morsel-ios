//
//  SocialService.h
//  Morsel
//
//  Created by Marty Trzpit on 1/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@class ACAccount;
@class SLRequestHandler;

@interface MRSLSocialService : NSObject

+ (instancetype)sharedService;

- (void)activateFacebookInView:(UIView *)view
                       success:(MorselSocialSuccessBlock)successOrNil
                       failure:(MorselSocialFailureBlock)failureOrNil;

- (void)activateTwitterInView:(UIView *)view
                      success:(MorselSocialSuccessBlock)successOrNil
                      failure:(MorselSocialFailureBlock)failureOrNil;

- (void)shareMorselToFacebook:(MRSLMorsel *)morsel
             inViewController:(UIViewController *)viewController
                      success:(MorselSocialSuccessBlock)successOrNil
                       cancel:(MorselSocialCancelBlock)cancelBlockOrNil;

- (void)shareMorselToTwitter:(MRSLMorsel *)morsel
            inViewController:(UIViewController *)viewController
                     success:(MorselSocialSuccessBlock)successOrNil
                      cancel:(MorselSocialCancelBlock)cancelBlockOrNil;

@end
