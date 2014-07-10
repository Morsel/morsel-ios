//
//  MRSLMenuItem.h
//  Morsel
//
//  Created by Javier Otero on 7/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLMenuItem : NSObject

@property (nonatomic) NSInteger badgeCount;
@property (nonatomic, weak) NSString *name;
@property (nonatomic, weak) NSString *key;
@property (nonatomic, weak) NSString *iconImageName;

- (id)initWithName:(NSString *)name key:(NSString *)key icon:(NSString *)iconImageName;

@end
