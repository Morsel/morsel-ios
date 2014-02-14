//
//  JSONResponseSerializerWithData.m
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    id JSONObject = [super responseObjectForResponse:response
                                                data:data
                                               error:error];

    if (*error != nil) {
        NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
        if (data == nil) {
            userInfo[JSONResponseSerializerWithDictionaryKey] = [NSDictionary dictionary];
            userInfo[JSONResponseSerializerWithServiceErrorInfoKey] = [NSDictionary dictionary];
        } else {
            NSError *error = nil;
            NSDictionary *errorDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:kNilOptions
                                                                              error:&error];
            if (!error) {
                MRSLServiceErrorInfo *serviceErrorInfo = [MRSLServiceErrorInfo serviceErrorInfoFromDictionary:errorDictionary];

                userInfo[JSONResponseSerializerWithDictionaryKey] = errorDictionary;
                userInfo[JSONResponseSerializerWithServiceErrorInfoKey] = serviceErrorInfo;
            }
        }
        NSError *newError = [NSError errorWithDomain:(*error).domain
                                                code:(*error).code
                                            userInfo:userInfo];
        (*error) = newError;
    }

    return JSONObject;
}

@end
