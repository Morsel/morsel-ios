//
//  MRSLSocialServiceTwitter.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFOAuth1Client/AFOAuth1Client.h>

@class ACAccount, MRSLSocialAuthentication;

NS_ENUM(NSUInteger, CreateMorselActionSheet) {
    CreateMorselActionSheetSettings = 1,
    CreateMorselActionSheetFacebookAccounts,
    CreateMorselActionSheetTwitterAccounts
};

@interface MRSLSocialServiceTwitter : NSObject

@property (strong, nonatomic) AFOAuth1Client *oauth1Client;
@property (strong, nonatomic) MRSLSocialAuthentication *socialAuthentication;

+ (instancetype)sharedService;

#pragma mark - Authentication Methods

- (void)authenticateWithTwitterWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                   failure:(MRSLSocialFailureBlock)failureOrNil;
- (void)checkForValidTwitterAuthenticationWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                              failure:(MRSLSocialFailureBlock)failureOrNil;
- (void)restoreTwitterWithAuthentication:(MRSLSocialAuthentication *)authentication
                            shouldCreate:(BOOL)shouldCreate;

#pragma mark - User Methods

- (void)getTwitterUserInformation:(MRSLSocialUserInfoBlock)userInfoBlockOrNil;
- (void)getTwitterFollowingUIDs:(MRSLSocialUIDStringBlock)uidBlockOrNil;

- (void)postStatus:(NSString *)status
           success:(MRSLSocialSuccessBlock)successOrNil
           failure:(MRSLSocialFailureBlock)failureOrNil;

- (NSString *)twitterUsername;

#pragma mark - Reset Methods

- (void)reset;

@end
