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
#import <TestFlight.h>

#import "MorselAPIClient.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];

    [self setupDatabase];

    self.morselApiService = [[MorselAPIService alloc] init];
    self.defaultDateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [_defaultDateFormatter setTimeZone:gmt];
    [_defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSS'Z'"];

    return YES;
}

#pragma mark - Data Methods

- (void)setupDatabase {
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Morsel.sqlite"];
}

#pragma mark - Logout

- (void)resetDataStore {
    [[MorselAPIClient sharedClient].operationQueue cancelAllOperations];

    NSURL *persistentStoreURL = [NSPersistentStore MR_urlForStoreName:@"Morsel.sqlite"];
    NSURL *shmURL = [NSURL URLWithString:[[persistentStoreURL absoluteString] stringByAppendingString:@"-shm"]];
    NSURL *walURL = [NSURL URLWithString:[[persistentStoreURL absoluteString] stringByAppendingString:@"-wal"]];
    NSError *error = nil;

    [MagicalRecord cleanUp];

    [[NSFileManager defaultManager] removeItemAtURL:persistentStoreURL
                                              error:&error];
    [[NSFileManager defaultManager] removeItemAtURL:shmURL
                                              error:&error];
    [[NSFileManager defaultManager] removeItemAtURL:walURL
                                              error:&error];
    if (error) {
        DDLogError(@"Error resetting data store: %@", error);
    } else {
        [self setupDatabase];
    }
}

@end
