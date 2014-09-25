//
//  UIDevice+Additions.h
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

typedef NS_ENUM(NSInteger, UIDeviceScreenSize) {
    UIDeviceScreenSize35Inch = 0,
    UIDeviceScreenSize4Inch,
    UIDeviceScreenSize47Inch,
    UIDeviceScreenSize55Inch,
    UIDeviceScreenSizePad
};

@interface UIDevice (Additions)

+ (BOOL)currentDeviceIsIphone;
+ (BOOL)currentDeviceIsIpad;
+ (BOOL)has35InchScreen;
+ (BOOL)has4InchScreen;
+ (BOOL)has47InchScreen;
+ (BOOL)has55InchScreen;

- (UIDeviceScreenSize)screenSize;

@end
