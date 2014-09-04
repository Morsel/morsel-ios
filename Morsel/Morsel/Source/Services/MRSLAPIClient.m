//
//  MorselAPIClient.m
//  Morsel
//
//  Created by Javier Otero on 1/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIClient.h"

#import "JSONResponseSerializerWithData.h"

#import "MRSLUser.h"

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

#pragma mark - Instance Methods

- (void)multipartFormRequestString:(NSString *)urlString
                        withMethod:(MRSLAPIMethodType)apiMethodType
                    formParameters:(NSDictionary *)formParameters
                        parameters:(NSDictionary *)parameters
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))successOrNil
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureOrNil {
    if ([MRSLUser isCurrentUserGuest]) {
        if (failureOrNil) failureOrNil(nil, nil);
        return;
    }
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json"
             forHTTPHeaderField:@"ACCEPT"];
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:[self apiMethodStringWithType:apiMethodType]
                                                                           URLString:[[NSURL URLWithString:urlString relativeToURL:[self baseURL]] absoluteString]
                                                                          parameters:parameters
                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                               [self appendParameters:formParameters
                                                                           toFormData:formData
                                                                             withName:nil];
                                                           }];
    AFHTTPRequestOperation *operation = [[MRSLAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                              success:successOrNil
                                                                                              failure:failureOrNil];
    [[MRSLAPIClient sharedClient].operationQueue addOperation:operation];
}

- (void)appendParameters:(NSDictionary *)formParameters
              toFormData:(id<AFMultipartFormData>)formData
                withName:(NSString *)name {
    [formParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *dataKey = (name) ? [NSString stringWithFormat:@"%@[%@]", name, key] : key;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self appendParameters:obj
                        toFormData:formData
                          withName:dataKey];
        } else if ([obj isKindOfClass:[NSData class]]) {
            if ([key isEqualToString:@"photo"]) {
                [formData appendPartWithFileData:obj
                                            name:dataKey
                                        fileName:@"photo.jpg"
                                        mimeType:@"image/jpeg"];
            } else {
                [formData appendPartWithFormData:obj
                                            name:dataKey];
            }
        } else {
            DDLogError(@"Unable to append unsupported object to multipart form parameters: %@", obj);
        }
    }];
}

#pragma mark - Utility Methods

- (NSString *)apiMethodStringWithType:(MRSLAPIMethodType)apiMethodType {
    switch (apiMethodType) {
        case MRSLAPIMethodTypePOST:
            return @"POST";
            break;
        case MRSLAPIMethodTypePUT:
            return @"PUT";
            break;
        case MRSLAPIMethodTypeDELETE:
            return @"DELETE";
            break;
        default:
            return @"";
            break;
    }
}

@end
