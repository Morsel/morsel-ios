//
//  MRSLMediaManager.h
//  Morsel
//
//  Created by Javier Otero on 4/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLMediaManager : NSObject

+ (instancetype)sharedManager;

- (void)queueCoverMediaForPosts:(NSArray *)posts;

@end
