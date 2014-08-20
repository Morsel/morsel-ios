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
@property (weak, nonatomic) NSString *name;
@property (weak, nonatomic) NSString *key;
@property (weak, nonatomic) NSString *iconImageName;

- (id)initWithName:(NSString *)name key:(NSString *)key icon:(NSString *)iconImageName;

@end
