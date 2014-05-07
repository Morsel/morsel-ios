//
//  MRSLSocialUser.h
//  Morsel
//
//  Created by Javier Otero on 5/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSLSocialAuthentication;

@interface MRSLSocialUser : NSObject

@property (strong, nonatomic) MRSLSocialAuthentication *authentication;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSURL *pictureURL;

- (id)initWithUserInfo:(NSDictionary *)userInfo;

@end