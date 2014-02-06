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

#if defined(MORSEL_ALPHA)
#define TESTFLIGHT_APP_TOKEN @"5d37b39e-9417-4e2d-9401-05afbeabbc74"
#elif defined(MORSEL_BETA)
#define TESTFLIGHT_APP_TOKEN @"2965a315-a1b2-4fee-a287-f9722a75ad87"
#elif defined(RELEASE)
#define TESTFLIGHT_APP_TOKEN @"1e7bb15e-fd13-4dd1-bd2e-0aa617af22ae"
#else
#define TESTFLIGHT_APP_TOKEN @"872ef690-a80c-4b91-beb2-0d383bc19150"
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];

    self.morselApiService = [[MorselAPIService alloc] init];
    self.defaultDateFormatter = [[NSDateFormatter alloc] init];
    [_defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSS'Z'"];

    return YES;
}

#pragma mark - Data Methods

- (void)setupDatabase {
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Morsel.sqlite"];

    self.defaultContext = [NSManagedObjectContext MR_defaultContext];
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
