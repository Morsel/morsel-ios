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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self saveData];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveData];
}

- (void)saveData
{
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    [managedObjectContext MR_saveWithOptions:MRSaveParentContexts
                                  completion:^(BOOL success, NSError *error)
    {
        NSLog(@"Data saved to persistent store!");
    }];
}

@end
