//
//  ModelController.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MorselAPIService.h"

@class MRSLUser;

@interface ModelController : NSObject

@property (nonatomic, strong) MorselAPIService *morselApiService;

+ (instancetype)sharedController;

- (MRSLUser *)currentUser;
- (MRSLUser *)userWithID:(NSNumber *)userID;

@end
