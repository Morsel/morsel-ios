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

@property (strong, nonatomic) MRSLSocialAuthentication *socialAuthentication;

+ (instancetype)sharedService;

#pragma mark - Authentication and User Information Methods

- (void)checkForValidFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler;
- (void)checkForPublishPermissions:(MRSLSocialSuccessBlock)canPublish;
- (void)openFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler;
- (void)requestPublishPermissionsWithCompletion:(FBSessionRequestPermissionResultHandler)completionOrNil;
- (void)restoreFacebookSessionWithAuthentication:(MRSLSocialAuthentication *)authentication;

- (void)getFacebookUserInformation:(MRSLSocialUserInfoBlock)facebookUserInfo;
- (void)getFacebookFriendUIDs:(MRSLSocialUIDStringBlock)uidBlock;

- (NSString *)facebookUsername;

#pragma mark - Share Methods

- (void)shareMorsel:(MRSLMorsel *)morsel
            success:(MRSLSocialSuccessBlock)successOrNil
             cancel:(MRSLSocialCancelBlock)cancelBlockOrNil;

- (void)reset;

@end
