//
//  MRSLTabBarButton.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTabBarButton.h"

@implementation MRSLTabBarButton

- (void)setUp {
    CGFloat verticalSpacing = 6.f;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.f, -[self.imageView getWidth], - ([self.imageView getHeight] + verticalSpacing), 0.f);
    self.imageEdgeInsets = UIEdgeInsetsMake(-([self.titleLabel getHeight] + verticalSpacing), 0.f, 0.f, -[self.titleLabel getWidth]);
}

- (void)setValue:(id)value
          forKey:(NSString *)key {
    if ([key isEqualToString:@"buttonType"])
    {
        self.tabBarButtonType = [value intValue];
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

@end
