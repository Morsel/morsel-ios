//
//  MRSLServiceErrorInfo.m
//  Morsel
//
//  Created by Javier Otero on 2/6/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLServiceErrorInfo.h"

@interface MRSLServiceErrorInfo ()

@property (strong, nonatomic) NSDictionary *meta;
@property (strong, nonatomic) NSDictionary *errors;

@end

@implementation MRSLServiceErrorInfo

/*
 
 meta

 status
 message


 errors

 username
 email or password
 base (or) record (object level)
 api (critical or denied)
 photo
 description
 item
 comment
 

 data
 
 NOT USED 


 */

#pragma mark - Class Methods

+ (MRSLServiceErrorInfo *)serviceErrorInfoFromDictionary:(NSDictionary *)dictionary {
    MRSLServiceErrorInfo *serviceErrorInfo = [[MRSLServiceErrorInfo alloc] initWithDictionary:dictionary];

    return serviceErrorInfo;
}

#pragma mark - Instance Methods

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (![dictionary[@"meta"] isEqual:[NSNull null]]) {
            self.meta = dictionary[@"meta"];
        }
        if (![dictionary[@"errors"] isEqual:[NSNull null]]) {
            self.errors = dictionary[@"errors"];
        }
    }

    return self;
}

- (NSString *)description {
    return [self errorInfo];
}

- (NSUInteger)metaStatusCode {
    NSNumber *metaNumber = _meta[@"status"];

    return [metaNumber integerValue];
}

- (NSString *)metaInfo {
    NSString *metaInfo = [NSString stringWithFormat:@"%@ : %@", _meta[@"status"], _meta[@"message"]];

    return metaInfo;
}

- (NSString *)errorInfo {
    __block NSMutableString *errorInformation = [NSMutableString string];

    [_errors enumerateKeysAndObjectsUsingBlock:^(NSString *errorTypeKey, NSArray *errorArray, BOOL *stop) {
        NSString *errorDescription = [NSString stringWithFormat:@"%@: %@", [errorTypeKey capitalizedString], ([errorArray isKindOfClass:[NSArray class]]) ? [errorArray componentsJoinedByString:@".\n"] : errorArray];
        [errorInformation appendString:errorDescription];
    }];

    if (([errorInformation length] == 0 || !_errors) && _meta) {
        errorInformation = [[self metaInfo] mutableCopy];
    }

    return errorInformation;
}

@end
