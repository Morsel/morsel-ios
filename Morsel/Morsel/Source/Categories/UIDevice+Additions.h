//
//  UIDevice+Additions.h
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIDeviceScreenSize) {
    UIDeviceScreenSize35Inch = 0,
    UIDeviceScreenSize4Inch,
    UIDeviceScreenSizePad
};

@interface UIDevice (Additions)

+ (BOOL)currentDeviceSystemVersionIsAtLeastIOS6;
+ (BOOL)currentDeviceSystemVersionIsAtLeastIOS7;
+ (BOOL)currentDeviceIsIpad;

- (UIDeviceScreenSize)screenSize;

@end
