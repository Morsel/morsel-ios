//
//  MRSLSocialAuthentication.m
//  Morsel
//
//  Created by Javier Otero on 5/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSocialAuthentication.h"

#import "MRSLAPIService+Authentication.h"

@implementation MRSLSocialAuthentication

- (BOOL)isValid {
    return (_authenticationID != nil);
}

- (void)API_validateAuthentication:(MRSLSuccessBlock)validOrNil {
    if (![self isValid]) {
        if (validOrNil) validOrNil(NO);
        return;
    }
    [_appDelegate.apiService getUserAuthentication:self
                                           success:^(id responseObject) {
                                               if (validOrNil) validOrNil(YES);
                                           } failure:^(NSError *error) {
                                               if (validOrNil) validOrNil(NO);
                                           }];
}

@end
