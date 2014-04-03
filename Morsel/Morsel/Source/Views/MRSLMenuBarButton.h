//
//  MRSLTabBarButton.h
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLStandardButton.h"

typedef NS_ENUM(NSUInteger, MRSLMenuBarButtonType) {
    MRSLMenuBarButtonTypeFeed,
    MRSLMenuBarButtonTypeProfile,
    MRSLMenuBarButtonTypeMyStuff,
    MRSLMenuBarButtonTypeActivity,
    MRSLMenuBarButtonTypeLogout
};

@interface MRSLMenuBarButton : MRSLStandardButton

@property (nonatomic) MRSLMenuBarButtonType menuBarButtonType;

@end
