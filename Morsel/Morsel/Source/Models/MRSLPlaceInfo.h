//
//  MRSLPlaceInfo.h
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLPlaceInfo : NSObject

@property (strong, nonatomic) NSString *primaryInfo;
@property (strong, nonatomic) NSString *secondaryInfo;

- (id)initWithPrimaryInfo:(NSString *)primaryInfo
           andSecondaryInfo:(NSString *)secondaryInfo;

@end
