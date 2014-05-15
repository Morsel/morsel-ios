//
//  MRSLSocialServiceFacebook.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FacebookSDK/FacebookSDK.h>

@class MRSLSocialAuthentication;

@interface MRSLSocialServiceFacebook : NSObject

+ (instancetype)sharedService;

- (void)checkForValidFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler;
- (void)openFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler;
- (void)restoreFacebookSessionWithAuthentication:(MRSLSocialAuthentication *)authentication;
- (void)getFacebookUserInformation:(MRSLSocialUserInfoBlock)facebookUserInfo;
- (void)shareMorsel:(MRSLMorsel *)morsel
            success:(MRSLSocialSuccessBlock)successOrNil
             cancel:(MRSLSocialCancelBlock)cancelBlockOrNil;
- (void)reset;

@end
