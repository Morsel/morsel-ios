//
//  NSMutableArray+Feed.h
//  Morsel
//
//  Created by Javier Otero on 3/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Feed)

+ (NSMutableArray *)feedIDArray;
+ (NSString *)feedIDPath;
+ (void)resetFeedIDArray;

- (void)saveFeedIDArray;

@end
