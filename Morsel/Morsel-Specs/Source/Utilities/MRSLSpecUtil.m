//
//  MRSLSpecUtil.m
//  Morsel
//
//  Created by Javier Otero on 2/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSpecUtil.h"

@implementation MRSLSpecUtil

/*
 The entire purpose of this method is to ensure stub collisions do not occur on similar API requests
 */

+ (void)stubItemAPIRequestsWithJSONFileName:(NSString *)fileName
                             forRequestPath:(NSString *)urlParametersToMatch {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSString *requestToStub = [NSString stringWithFormat:@"%@%@", request.URL.host, urlParametersToMatch];
        NSRange apiRequestRange = [request.URL.absoluteString rangeOfString:requestToStub];
        return (apiRequestRange.location != NSNotFound);
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString *jsonPath = [[NSBundle bundleForClass:self] pathForResource:[fileName stringByDeletingPathExtension]
                                                                      ofType:[fileName pathExtension]];
        return [OHHTTPStubsResponse responseWithFileAtPath:jsonPath
                                                statusCode:200
                                                   headers:@{@"Content-Type": @"application/json"}];
    }];
};

@end
