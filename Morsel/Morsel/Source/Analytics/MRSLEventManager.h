//
//  MRSLEventManager.h
//  Morsel
//
//  Created by Javier Otero on 2/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLEventManager : NSObject

+ (instancetype)sharedManager;

- (void)track:(NSString *)event;

- (void)track:(NSString *)event
   properties:(NSDictionary *)properties;

@end
