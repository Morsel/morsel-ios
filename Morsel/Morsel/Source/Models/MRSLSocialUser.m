//
//  MRSLSocialUser.m
//  Morsel
//
//  Created by Javier Otero on 5/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialUser.h"

#import <FacebookSDK/FacebookSDK.h>

#import "MRSLSocialAuthentication.h"

@implementation MRSLSocialUser

- (id)initWithUserInfo:(NSDictionary *)userInfo {
    self = [super init];
    if (self) {
        self.email = userInfo[@"email"];
        self.firstName = userInfo[@"first_name"];
        self.lastName = userInfo[@"last_name"];
        self.pictureURL = [NSURL URLWithString:userInfo[@"pictureURL"]];

        if ([FBSession.activeSession isOpen]) {
            self.authentication = [[MRSLSocialAuthentication alloc] init];
            _authentication.provider = userInfo[@"provider"];
            _authentication.uid = userInfo[@"uid"];
            _authentication.token = FBSession.activeSession.accessTokenData.accessToken;
            _authentication.email = userInfo[@"email"];
        }
    }
    return self;
}

@end
