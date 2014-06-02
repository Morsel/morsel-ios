//
//  MRSLPlaceInfo.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlaceInfo.h"

@implementation MRSLPlaceInfo

- (id)initWithPrimaryInfo:(NSString *)primaryInfo
           andSecondaryInfo:(NSString *)secondaryInfo {
    self = [super init];
    if (self) {
        self.primaryInfo = primaryInfo;
        self.secondaryInfo = secondaryInfo;
    }
    return self;
}

@end
