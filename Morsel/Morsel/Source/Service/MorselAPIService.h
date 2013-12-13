//
//  MorselAPIService.h
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSLUser;

@interface MorselAPIService : NSObject

- (void)createUser:(MRSLUser *)user;

@end
