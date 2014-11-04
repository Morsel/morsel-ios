//
//  MorselAPIClient.h
//  Morsel
//
//  Created by Javier Otero on 1/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, MRSLAPIMethodType) {
    MRSLAPIMethodTypePOST,
    MRSLAPIMethodTypePUT,
    MRSLAPIMethodTypeDELETE
};

@class MRSLUser;

@interface MRSLAPIClient : AFHTTPRequestOperationManager

#pragma mark - Class Methods

+ (instancetype)sharedClient;

#pragma mark - Instance Methods

- (void)performRequest:(NSString *)urlString
            parameters:(NSDictionary *)parameters
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))successOrNil
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureOrNil;

- (void)multipartFormRequestString:(NSString *)urlString
                        withMethod:(MRSLAPIMethodType)apiMethodType
                    formParameters:(NSDictionary *)formParameters
                        parameters:(NSDictionary *)parameters
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
