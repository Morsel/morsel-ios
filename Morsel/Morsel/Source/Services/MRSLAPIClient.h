//
//  MorselAPIClient.h
//  Morsel
//
//  Created by Javier Otero on 1/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

@class MRSLUser;

@interface MRSLAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
