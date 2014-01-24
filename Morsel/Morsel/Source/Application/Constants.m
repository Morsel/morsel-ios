//
//  Constants.m
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "Constants.h"

NSString *const MorselServiceDidCreateUserNotification = @"MorselServiceDidCreateUserNotification";
NSString *const MorselServiceDidLogInNewUserNotification = @"MorselServiceDidLogInNewUserNotification";
NSString *const MorselServiceDidLogInExistingUserNotification = @"MorselServiceDidLogInExistingUserNotification";
NSString *const MorselShowBottomBarNotification = @"MorselShowBottomBarNotification";
NSString *const MorselHideBottomBarNotification = @"MorselHideBottomBarNotification";

#ifdef DEBUG
int ddLogLevel = LOG_LEVEL_DEBUG;
#else
int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@implementation Constants

@end
