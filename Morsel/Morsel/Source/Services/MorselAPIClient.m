//
//  MorselAPIClient.m
//  Morsel
//
//  Created by Javier Otero on 1/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselAPIClient.h"

#import "JSONResponseSerializerWithData.h"

#if (defined(MORSEL_BETA) || defined(RELEASE))

#define MORSEL_API_BASE_URL @"https://api.eatmorsel.com/"

#else

#define MORSEL_API_BASE_URL @"http://api-staging.eatmorsel.com/"

#endif


@implementation MorselAPIClient

#pragma mark - Class Methods

+ (instancetype)sharedClient {
    static MorselAPIClient *_sharedClient = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        _sharedClient = [[MorselAPIClient alloc] initWithBaseURL:[NSURL URLWithString:MORSEL_API_BASE_URL]];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sharedClient.requestSerializer setValue:@"application/json"
                               forHTTPHeaderField:@"ACCEPT"];
        _sharedClient.responseSerializer = [JSONResponseSerializerWithData serializer];
    });

    return _sharedClient;
}

@end
