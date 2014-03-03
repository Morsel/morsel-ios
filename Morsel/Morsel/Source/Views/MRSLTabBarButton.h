//
//  MRSLTabBarButton.h
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStandardButton.h"

typedef NS_ENUM(NSUInteger, MRSLTabBarButtonType) {
    MRSLTabBarButtonTypeHome,
    MRSLTabBarButtonTypeActivity,
    MRSLTabBarButtonTypeAdd,
    MRSLTabBarButtonTypeMyStuff,
    MRSLTabBarButtonTypeMore
};

@interface MRSLTabBarButton : MRSLStandardButton

@property (nonatomic) MRSLTabBarButtonType tabBarButtonType;

@end
