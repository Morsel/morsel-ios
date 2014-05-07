//
//  MRSLSocialAuthentication.h
//  Morsel
//
//  Created by Javier Otero on 5/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLSocialAuthentication : NSObject

@property (nonatomic) BOOL *isTokenShortLived;

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *provider;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *secret;
@property (strong, nonatomic) NSString *uid;

@end
