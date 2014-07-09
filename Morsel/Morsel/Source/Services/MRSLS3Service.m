//
//  MRSLS3Service.m
//  Morsel
//
//  Created by Marty Trzpit on 7/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLS3Service.h"
#import "MRSLPresignedUpload.h"
#import "MRSLS3Client.h"
#import <XMLDictionary/XMLDictionary.h>

@implementation MRSLS3Service

- (void)uploadImageData:(NSData *)imageData
     forPresignedUpload:(MRSLPresignedUpload *)presignedUpload
                success:(MRSLAPISuccessBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil {
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                           URLString:presignedUpload.url
                                                                          parameters:[presignedUpload params]
                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                               [formData appendPartWithFileData:imageData
                                                                                           name:@"file"
                                                                                       fileName:@"photo.jpg"
                                                                                       mimeType:@"image/jpeg"];
                                                           }];

    AFHTTPRequestOperation *operation = [[MRSLS3Client sharedClient] HTTPRequestOperationWithRequest:request
                                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                 // Example of response: {
                                                                                                 //    Bucket = "bucket-name";
                                                                                                 //    ETag = "\"dc1130f5b4bc0fe069691299724de049\"";
                                                                                                 //    Key = "item-photos/some-id/dbb6a58c-photo.jpg";
                                                                                                 //    Location = "https://bucket-name.s3.amazonaws.com/item-photos/some-id/dbb6a58c-photo.jpg";
                                                                                                 //    "__name" = PostResponse;
                                                                                                 // }
                                                                                                 NSDictionary *dictionary = [NSDictionary dictionaryWithXMLData:responseObject];
                                                                                                 DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), dictionary);
                                                                                                 if (successOrNil) successOrNil(dictionary);
                                                                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                 DDLogError(@"Request error in method (%@) with userInfo: %@", NSStringFromSelector(_cmd), error.userInfo);
                                                                                                 if (failureOrNil) failureOrNil(nil);
                                                                                             }];
    [[MRSLS3Client sharedClient].operationQueue addOperation:operation];}

@end
