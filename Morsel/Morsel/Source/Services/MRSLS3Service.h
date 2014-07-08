//
//  MRSLS3Service.h
//  Morsel
//
//  Created by Marty Trzpit on 7/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSLPresignedUpload;

@interface MRSLS3Service : NSObject

- (void)uploadImageData:(NSData *)imageData
     forPresignedUpload:(MRSLPresignedUpload *)presignedUpload
                success:(MRSLAPISuccessBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil;


@end
