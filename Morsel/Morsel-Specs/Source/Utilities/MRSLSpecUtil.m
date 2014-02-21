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

+ (void)stubMorselAPIRequestsWithJSONFileName:(NSString *)fileName
                                forRequestPath:(NSString *)urlParametersToMatch {

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        NSRange apiHostRange = [MORSEL_API_BASE_URL rangeOfString:request.URL.host];
        BOOL stagingAndParametersMatch = (apiHostRange.location != NSNotFound);

        NSString *requestToStub = [NSString stringWithFormat:@"%@%@?", request.URL.host, urlParametersToMatch];

        NSString *requestAbsoluteString = request.URL.absoluteString;
        NSRange apiRequestRange = [requestAbsoluteString rangeOfString:requestToStub];
        stagingAndParametersMatch = (apiRequestRange.location != NSNotFound);

        return stagingAndParametersMatch;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString *jsonPath = [[NSBundle bundleForClass:self] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];

        return [OHHTTPStubsResponse responseWithFileAtPath:jsonPath statusCode:200 headers:nil];
    }];
};

@end
