//
//  UIDevice+Additions.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIDevice+Additions.h"

@implementation UIDevice (Additions)

+ (BOOL)currentDeviceIsIphone {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

+ (BOOL)currentDeviceIsIpad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

+ (BOOL)has35InchScreen {
    return [[UIDevice currentDevice] screenSize] == UIDeviceScreenSize35Inch;
}

+ (BOOL)has4InchScreen {
    return [[UIDevice currentDevice] screenSize] == UIDeviceScreenSize4Inch;
}

+ (BOOL)has47InchScreen {
    return [[UIDevice currentDevice] screenSize] == UIDeviceScreenSize47Inch;
}

+ (BOOL)has55InchScreen {
    return [[UIDevice currentDevice] screenSize] == UIDeviceScreenSize55Inch;
}

- (UIDeviceScreenSize)screenSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIDeviceScreenSizePad;
    }

    UIDeviceScreenSize screen = UIDeviceScreenSize35Inch;

    if ([[UIScreen mainScreen] bounds].size.height == 568.f) {
        screen = UIDeviceScreenSize4Inch;
    } else if ([[UIScreen mainScreen] bounds].size.height == 667.f) {
        screen = UIDeviceScreenSize47Inch;
    } else if ([[UIScreen mainScreen] bounds].size.height == 736.f) {
        screen = UIDeviceScreenSize55Inch;
    }

    return screen;
}

@end
