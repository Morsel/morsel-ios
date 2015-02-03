//
//  MRSLSpecUtil.m
//  Morsel
//
//  Created by Javier Otero on 2/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLVCRManager.h"

#import <VCRURLConnection/VCR.h>
#import <VCRURLConnection/VCRCassette.h>
#import <VCRURLConnection/VCRCassetteManager.h>

@interface MRSLVCRManager (Private)

+ (NSString *)vcrFilePath;

@end

@implementation MRSLVCRManager

+ (void)setupVCR {
#if MRSL_RECORDING
    [VCR start];
#endif
    VCRCassette *cassette = nil;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:[self vcrFilePath]]) {
        cassette = [[VCRCassette alloc] initWithData:[NSData dataWithContentsOfFile:[self vcrFilePath]]];
    } else {
        cassette = [[VCRCassetteManager defaultManager] currentCassette];
    }

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return ([cassette recordingForRequest:request] != nil);
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        VCRRecording *recording = [cassette recordingForRequest:request];
        return [OHHTTPStubsResponse responseWithData:recording.data
                                          statusCode:(int)recording.statusCode
                                             headers:recording.headerFields];
    }];
}

+ (void)saveVCR {
#if MRSL_RECORDING
    [VCR save:[self vcrFilePath]];
#endif
}

+ (NSString *)vcrFilePath {
    NSString *vcrCassetteFilePath = nil;
#if MRSL_RECORDING
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePathArray lastObject];
    vcrCassetteFilePath = [cachePath stringByAppendingPathComponent:@"integration-cassette.json"];
#else
    vcrCassetteFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"integration-cassette"
                                                          ofType:@"json"];
#endif
    return vcrCassetteFilePath;
}

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
