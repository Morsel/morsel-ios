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
#if MRSL_INTEGRATION_RECORDING_NETWORK
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
#if MRSL_INTEGRATION_RECORDING_NETWORK
        return ([cassette recordingForRequest:request] != nil);
#else
        return YES;
#endif
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        VCRRecording *recording = [cassette recordingForRequest:request];
        NSAssert((recording != nil), @"VCRRecording not found for stubbed request. Should make sure integration-cassette.json includes accurate data.");
        return [OHHTTPStubsResponse responseWithData:recording.data
                                          statusCode:(int)recording.statusCode
                                             headers:recording.headerFields];
    }];
}

+ (void)saveVCR {
#if MRSL_INTEGRATION_RECORDING_NETWORK
    [VCR save:[self vcrFilePath]];
#endif
}

+ (NSString *)vcrFilePath {
    NSString *vcrCassetteFilePath = nil;
#if MRSL_INTEGRATION_RECORDING_NETWORK
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePathArray lastObject];
    vcrCassetteFilePath = [cachePath stringByAppendingPathComponent:@"integration-cassette.json"];
#else
    vcrCassetteFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"integration-cassette"
                                                                           ofType:@"json"];
#endif
    return vcrCassetteFilePath;
}

@end
