//
//  MRSLSpecsAppDelegate.m
//  Morsel
//
//  Created by Javier Otero on 2/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSpecsAppDelegate.h"

#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>

#import "MRSLAPIClient.h"

#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@implementation MRSLSpecsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [Mixpanel sharedInstanceWithToken:@""];

    [self setupSpecTestingEnvironment];
    
    return YES;
}

- (void)setupSpecTestingEnvironment {
    self.defaultDateFormatter = [[NSDateFormatter alloc] init];
    [self.defaultDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [self.defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSS'Z'"];
    
    self.morselApiService = [[MRSLAPIService alloc] init];

    [self setupDatabase];

#ifdef INTEGRATION_TESTING
    UIViewController *viewController = [[UIStoryboard mainStoryboard] instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
#else
    UIViewController *viewController = [[UIStoryboard specsStoryboardInBundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
#endif
}

- (void)setupDatabase {
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Morsel-Specs.sqlite"];
    [MRSLUser MR_truncateAll];
    [MRSLPost MR_truncateAll];
    [MRSLMorsel MR_truncateAll];
    [MRSLComment MR_truncateAll];

    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    [[NSManagedObjectContext MR_defaultContext] setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
}

- (void)resetDataStore {
    [[Mixpanel sharedInstance] reset];
    [[MRSLAPIClient sharedClient].operationQueue cancelAllOperations];

    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];

    NSURL *persistentStoreURL = [NSPersistentStore MR_urlForStoreName:@"Morsel-Specs.sqlite"];
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
