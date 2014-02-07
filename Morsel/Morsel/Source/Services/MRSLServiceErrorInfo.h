//
//  MRSLServiceErrorInfo.h
//  Morsel
//
//  Created by Javier Otero on 2/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLServiceErrorInfo : NSObject

+ (MRSLServiceErrorInfo *)serviceErrorInfoFromDictionary:(NSDictionary *)dictionary;

- (NSUInteger)metaStatusCode;
- (NSString *)metaInfo;
- (NSString *)errorInfo;

@end
