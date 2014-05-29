//
//  MRSLSocialServiceInstagram.h
//  Morsel
//
//  Created by Javier Otero on 5/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFOAuth2Client/AFOAuth2Client.h>
#import <NXOAuth2Client/NXOAuth2.h>

@class MRSLSocialAuthentication;

@interface MRSLSocialServiceInstagram : NSObject

@property (strong, nonatomic) AFOAuth2Client *oauth2Client;
@property (strong, nonatomic) MRSLSocialAuthentication *socialAuthentication;
@property (strong, nonatomic) AFOAuthCredential *instagramCredentials;

+ (instancetype)sharedService;

#pragma mark - Authentication Methods

- (void)authenticateWithInstagramWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                     failure:(MRSLSocialFailureBlock)failureOrNil;
- (void)completeAuthenticationWithCode:(NSString *)code;
- (void)checkForValidInstagramAuthenticationWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                                failure:(MRSLSocialFailureBlock)failureOrNil;
- (void)restoreInstagramWithAuthentication:(MRSLSocialAuthentication *)authentication
                              shouldCreate:(BOOL)shouldCreate;

#pragma mark - User Methods

- (void)getInstagramUserInformation:(MRSLSocialUserInfoBlock)userInfoBlockOrNil;
- (void)getInstagramFollowingUIDs:(MRSLSocialUIDStringBlock)uidBlockOrNil;

- (NSString *)instagramUsername;

#pragma mark - Reset Methods

- (void)reset;

@end
