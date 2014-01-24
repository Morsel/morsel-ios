//
//  AppDelegate.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "AppDelegate.h"

#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>

#import "ModelController.h"

// DDLogLevel must be declared here to avoid MagicalRecord.h extern conflict 

#ifdef DEBUG
int ddLogLevel = LOG_LEVEL_DEBUG;
#else
int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor morselDarkContent], UITextAttributeTextColor,
      [UIFont helveticaNeueLTStandardThinCondensedFontOfSize:24.f], UITextAttributeFont, nil]];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[ModelController sharedController] saveDataToStore];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[ModelController sharedController] saveDataToStore];
}

@end
