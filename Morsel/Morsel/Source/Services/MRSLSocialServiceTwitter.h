//
//  MRSLSocialServiceTwitter.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFOAuth1Client/AFOAuth1Client.h>

@class ACAccount;

NS_ENUM(NSUInteger, CreateMorselActionSheet) {
    CreateMorselActionSheetSettings = 1,
    CreateMorselActionSheetFacebookAccounts,
    CreateMorselActionSheetTwitterAccounts
};

@interface MRSLSocialServiceTwitter : NSObject

@property (strong, nonatomic) AFOAuth1Client *twitterClient;

+ (instancetype)sharedService;

- (void)authenticateWithTwitterWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                                   failure:(MRSLSocialFailureBlock)failureOrNil;

- (void)getTwitterUserInformation:(MRSLSocialUserInfoBlock)userInfoBlockOrNil;




- (void)activateTwitterWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                           failure:(MRSLSocialFailureBlock)failureOrNil __deprecated;

@end
