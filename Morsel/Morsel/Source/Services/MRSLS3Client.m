//
//  MRSLS3Client.m
//  Morsel
//
//  Created by Marty Trzpit on 7/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLS3Client.h"

@implementation MRSLS3Client

+ (instancetype)sharedClient {
    static MRSLS3Client *_sharedClient = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        _sharedClient = [[MRSLS3Client alloc] initWithBaseURL:[NSURL URLWithString:S3_BASE_URL]];
        _sharedClient.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/xml"];
    });

    return _sharedClient;
}

@end
