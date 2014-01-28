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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    return YES;
}
/*
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[ModelController sharedController] saveDataToStoreWithSuccess:nil
                                                           failure:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[ModelController sharedController] saveDataToStoreWithSuccess:nil
                                                           failure:nil];
}
*/
@end
