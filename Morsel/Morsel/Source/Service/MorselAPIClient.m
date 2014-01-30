//
//  MorselAPIClient.m
//  Morsel
//
//  Created by Javier Otero on 1/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselAPIClient.h"

#import "JSONResponseSerializerWithData.h"

// @"https://morsel-api-staging.herokuapp.com/";

static NSString *const MORSEL_STAGING_BASE_URL = @"http://api-staging.eatmorsel.com/";
static NSString *const MORSEL_PRODUCTION_BASE_URL = @"https://api.eatmorsel.com/";

@implementation MorselAPIClient

#pragma mark - Class Methods

+ (instancetype)sharedClient {
    static MorselAPIClient *_sharedClient = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        _sharedClient = [[MorselAPIClient alloc] initWithBaseURL:[NSURL URLWithString:MORSEL_STAGING_BASE_URL]];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        _sharedClient.responseSerializer = [JSONResponseSerializerWithData serializer];
    });

    return _sharedClient;
}

@end
