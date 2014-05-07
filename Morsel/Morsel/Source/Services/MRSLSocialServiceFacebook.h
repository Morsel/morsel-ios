//
//  MRSLSocialServiceFacebook.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FacebookSDK/FacebookSDK.h>

@interface MRSLSocialServiceFacebook : NSObject

+ (instancetype)sharedService;

- (void)checkForValidFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler;;
- (void)openFacebookSessionWithSessionStateHandler:(FBSessionStateHandler)handler;
- (void)getFacebookUserInformation:(MRSLSocialUserInfoBlock)facebookUserInfo;

- (void)reset;

- (void)activateFacebookWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                            failure:(MRSLSocialFailureBlock)failureOrNil __deprecated;

@end
