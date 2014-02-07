//
//  JSONResponseSerializerWithData.h
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "AFURLResponseSerialization.h"

#import "MRSLServiceErrorInfo.h"

/// NSError userInfo key that will contain raw response dictionary
static NSString *const JSONResponseSerializerWithDictionaryKey = @"JSONResponseSerializerWithDictionaryKey";
/// NSError userInfo key that will contain
static NSString *const JSONResponseSerializerWithServiceErrorInfoKey = @"JSONResponseSerializerWithServiceErrorInfoKey";

@interface JSONResponseSerializerWithData : AFJSONResponseSerializer

@end
