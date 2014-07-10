//
//  MRSLMenuItem.m
//  Morsel
//
//  Created by Javier Otero on 7/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMenuItem.h"

@implementation MRSLMenuItem

- (id)initWithName:(NSString *)name
               key:(NSString *)key
              icon:(NSString *)iconImageName {
    self = [super init];
    if (self) {
        self.badgeCount = 0;
        self.name = name;
        self.key = key;
        self.iconImageName = iconImageName;
    }
    return self;
}

@end
