//
//  UIDevice+Additions.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIDevice+Additions.h"

@implementation UIDevice (Additions)

+ (BOOL)currentDeviceSystemVersionIsAtLeastIOS6 {
    return ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending);
}

+ (BOOL)currentDeviceSystemVersionIsAtLeastIOS7 {
    return ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending);
}

+ (BOOL)currentDeviceIsIpad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

@end
