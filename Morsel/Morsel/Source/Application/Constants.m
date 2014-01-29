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

#ifdef DEBUG
int LOG_LEVEL_DEF = LOG_LEVEL_DEBUG;
#else
int LOG_LEVEL_DEF = LOG_LEVEL_ERROR;
#endif

@implementation Constants

@end
