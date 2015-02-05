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

@interface MRSLAPIClient ()

@property (nonatomic) int requestCount;

@end

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
        [_sharedClient.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        _sharedClient.responseSerializer = [JSONResponseSerializerWithData serializer];
    });

    return _sharedClient;
}

#pragma mark - Instance Methods

- (NSString *)routeRequestURLForIntegrationCheck:(NSString *)fullUrlString {
#if defined(INTEGRATION_TESTING)
    self.requestCount++;
    NSString *queryString = ([fullUrlString rangeOfString:@"?"].location == NSNotFound) ? @"?" : @"&";
    fullUrlString = [NSString stringWithFormat:@"%@%@integration=%i", fullUrlString, queryString, self.requestCount];
#endif
    return fullUrlString;
}

- (void)registerOperation:(AFHTTPRequestOperation *)requestOperation {
    for (AFHTTPRequestOperation *operation in self.operationQueue.operations) {
        if ([[operation.request.URL absoluteString] isEqualToString:[requestOperation.request.URL absoluteString]]) {
            DDLogDebug(@"Found duplicate operation. Cancelling previous with name: (%@)", [operation.request.URL absoluteString]);
            [operation cancel];
            break;
        }
    }
    [[MRSLAPIClient sharedClient].operationQueue addOperation:requestOperation];
}

- (void)performRequest:(NSString *)urlString
            parameters:(NSDictionary *)parameters
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))successOrNil
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureOrNil {


    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json"
             forHTTPHeaderField:@"ACCEPT"];
    NSError *error = nil;
    NSString *fullUrlString = [self routeRequestURLForIntegrationCheck:[[NSURL URLWithString:urlString relativeToURL:[self baseURL]] absoluteString]];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET"
                                                              URLString:fullUrlString
                                                             parameters:parameters
                                                                  error:&error];
    if (error) DDLogError(@"MRSLAPIClient: General request error: %@", error);
    AFHTTPRequestOperation *operation = [[MRSLAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                              success:successOrNil
                                                                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                  if (failureOrNil && error.code != -999) failureOrNil(operation, error);
                                                                                              }];
    [self registerOperation:operation];
}

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
    NSError *error = nil;
    NSString *fullUrlString = [self routeRequestURLForIntegrationCheck:[[NSURL URLWithString:urlString relativeToURL:[self baseURL]] absoluteString]];
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:[self apiMethodStringWithType:apiMethodType]
                                                                           URLString:fullUrlString
                                                                          parameters:parameters
                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                               [self appendParameters:formParameters
                                                                           toFormData:formData
                                                                             withName:nil];
                                                           }
                                                                               error:&error];
    if (error) DDLogError(@"MRSLAPIClient: Multipart form request error: %@", error);
    AFHTTPRequestOperation *operation = [[MRSLAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                              success:successOrNil
                                                                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                  if (failureOrNil && error.code != -999) failureOrNil(operation, error);
                                                                                              }];
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
