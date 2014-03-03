//
//  MRSLTabBarButton.h
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselStandardButton.h"

typedef NS_ENUM(NSUInteger, MRSLTabBarButtonType) {
    MRSLTabBarButtonTypeHome,
    MRSLTabBarButtonTypeActivity,
    MRSLTabBarButtonTypeAdd,
    MRSLTabBarButtonTypeMyStuff,
    MRSLTabBarButtonTypeMore
};

@interface MRSLTabBarButton : MorselStandardButton

@property (nonatomic) MRSLTabBarButtonType tabBarButtonType;

@end
