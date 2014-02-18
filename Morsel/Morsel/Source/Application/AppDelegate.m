//
//  AppDelegate.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "AppDelegate.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <TestFlight.h>

#import "MorselAPIClient.h"

#import "MRSLUser.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];

    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];

    self.morselApiService = [[MorselAPIService alloc] init];
    self.defaultDateFormatter = [[NSDateFormatter alloc] init];
    [_defaultDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [_defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSS'Z'"];

    [self setupDatabase];

    [[MRSLEventManager sharedManager] track:@"Open app"
                          properties:@{@"view": @"AppDelegate"}];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([MRSLUser currentUser]) {
        [[Mixpanel sharedInstance].people increment:@"open_count"
                                by:@(1)];
    }
}

#pragma mark - Data Methods

- (void)setupDatabase {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel registerSuperPropertiesOnce:@{@"client_device": (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"ipad" : @"iphone"}];
    [mixpanel registerSuperProperties:@{@"client_version": [Util appMajorMinorPatchString]}];

    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Morsel.sqlite"];

    [[NSManagedObjectContext MR_defaultContext] setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
}

#pragma mark - Logout

- (void)resetDataStore {
    [[Mixpanel sharedInstance] reset];
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
