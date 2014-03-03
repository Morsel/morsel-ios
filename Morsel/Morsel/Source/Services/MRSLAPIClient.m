//
//  MorselAPIClient.m
//  Morsel
//
//  Created by Javier Otero on 1/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIClient.h"

#import "JSONResponseSerializerWithData.h"

@implementation MRSLAPIClient

#pragma mark - Class Methods

+ (instancetype)sharedClient {
    static MRSLAPIClient *_sharedClient = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        _sharedClient = [[MRSLAPIClient alloc] initWithBaseURL:[NSURL URLWithString:MORSEL_API_BASE_URL]];
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sharedClient.requestSerializer setValue:@"application/json"
                               forHTTPHeaderField:@"ACCEPT"];
        _sharedClient.responseSerializer = [JSONResponseSerializerWithData serializer];
    });

    return _sharedClient;
}

@end
