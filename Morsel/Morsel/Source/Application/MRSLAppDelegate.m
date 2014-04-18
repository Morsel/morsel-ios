//
//  MRSLAppDelegate.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLAppDelegate.h"
#import "MRSLAppDelegate+SetupAppearance.h"
#import "MRSLAppDelegate+CustomURLSchemes.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <TestFlight.h>

#import "NSMutableArray+Feed.h"

#import "MRSLAPIClient.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@implementation MRSLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];

    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];

    [MRSLAppDelegate setupTheme];

    [self setupMorselEnvironment];

    [self setupRouteHandler];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([MRSLUser currentUser]) {
        [[Mixpanel sharedInstance].people increment:@"open_count"
                                                 by:@(1)];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleRouteForURL:url
                 sourceApplication:sourceApplication];
}

#pragma mark - Instance Methods

- (void)setupMorselEnvironment {
    self.defaultDateFormatter = [[NSDateFormatter alloc] init];
    [_defaultDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [_defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSS'Z'"];
    self.itemApiService = [[MRSLAPIService alloc] init];

    [self setupDatabase];

    UIViewController *viewController = [[UIStoryboard mainStoryboard] instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

#pragma mark - Data Methods

- (void)setupDatabase {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel registerSuperPropertiesOnce:@{@"client_device": (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"ipad" : @"iphone"}];
    [mixpanel registerSuperProperties:@{@"client_version": [MRSLUtil appMajorMinorPatchString]}];

    [MagicalRecord initialize];
    [MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
    [MagicalRecord setupAutoMigratingCoreDataStack];

    [[NSManagedObjectContext MR_defaultContext] setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];

    if ([MRSLUser currentUser]) {
        // Delete items that do not have a localUUID, itemID, photo data, and belong to the current user. They didn't make it nor will they ever be able to be synced with any existing items.
        NSPredicate *localOrphanedPredicate = [NSPredicate predicateWithFormat:@"((itemPhotoFull != nil) AND (localUUID == nil) AND (itemID == nil) AND (morsel.creator.userID == %i))", [MRSLUser currentUser].userIDValue];
        NSArray *localOrphanedMorsels = [MRSLItem MR_findAllWithPredicate:localOrphanedPredicate];
        if ([localOrphanedMorsels count] > 0) {
            DDLogDebug(@"Local orphaned Morsels found. Removing %lu", (unsigned long)[localOrphanedMorsels count]);
            [MRSLItem MR_deleteAllMatchingPredicate:localOrphanedPredicate];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }

        // Finds any items that have their upload flag set to YES. This is due to the app quitting before success/failure blocks of the item image upload was able to complete.
        NSArray *items = [MRSLItem MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(isUploading == YES)"]];
        [items enumerateObjectsUsingBlock:^(MRSLItem *item, NSUInteger idx, BOOL *stop) {
            item.isUploading = @NO;
            item.didFailUpload = @YES;
        }];
    }
}

#pragma mark - Logout

- (void)resetDataStore {
    [[Mixpanel sharedInstance] reset];
    [[MRSLAPIClient sharedClient].operationQueue cancelAllOperations];

    [NSMutableArray resetFeedIDArray];

    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];

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
