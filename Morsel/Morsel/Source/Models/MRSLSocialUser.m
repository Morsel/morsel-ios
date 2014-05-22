//
//  MRSLSocialUser.m
//  Morsel
//
//  Created by Javier Otero on 5/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialUser.h"

#import <AFOAuth1Client/AFOAuth1Client.h>
#import <FacebookSDK/FacebookSDK.h>

#import "MRSLSocialAuthentication.h"
#import "MRSLSocialServiceTwitter.h"

@implementation MRSLSocialUser

- (id)initWithUserInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        self.email = userInfo[@"email"];
        self.firstName = userInfo[@"first_name"];
        self.lastName = userInfo[@"last_name"];
        self.pictureURL = [NSURL URLWithString:userInfo[@"pictureURL"]];

        self.authentication = [[MRSLSocialAuthentication alloc] init];
        _authentication.provider = userInfo[@"provider"];
        _authentication.uid = userInfo[@"uid"];
        _authentication.email = userInfo[@"email"];
        if ([userInfo[@"provider"] isEqualToString:@"facebook"]) {
            _authentication.token = FBSession.activeSession.accessTokenData.accessToken;
        } else if ([userInfo[@"provider"] isEqualToString:@"twitter"]) {
            _authentication.token = [MRSLSocialServiceTwitter sharedService].oauth1Client.accessToken.key;
            _authentication.secret = [MRSLSocialServiceTwitter sharedService].oauth1Client.accessToken.secret;
        }
    }
    return self;
}

@end
