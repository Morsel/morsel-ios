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
#import "MRSLAppDelegate+Notifications.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <AFOAuth1Client/AFOAuth1Client.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <DBChooser/DBChooser.h>
#import <FacebookSDK/FacebookSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "MRSLAPIService+Authentication.h"

#import "MRSLAPIClient.h"
#import "MRSLS3Client.h"
#import "MRSLS3Service.h"
#import "MRSLSocialServiceFacebook.h"
#import "MRSLSocialServiceInstagram.h"
#import "MRSLSocialServiceTwitter.h"
#import "NSMutableArray+Additions.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLRemoteDevice.h"
#import "MRSLUser.h"

@interface MRSLAppDelegate ()

@property (nonatomic) __block UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation MRSLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    if (ROLLBAR_ENVIRONMENT) {
        RollbarConfiguration *rollbarConfiguration = [RollbarConfiguration configuration];
        [rollbarConfiguration setEnvironment:ROLLBAR_ENVIRONMENT];

        [Rollbar initWithAccessToken:ROLLBAR_ACCESS_TOKEN
                       configuration:rollbarConfiguration];
    }

    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];

    [[MRSLSocialServiceFacebook sharedService] checkForValidFacebookSessionWithSessionStateHandler:nil];

    [MRSLAppDelegate setupTheme];

    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];

    [self setupMorselEnvironment];

    [self setupRouteHandler];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUserInformation)
                                                 name:MRSLServiceDidLogInUserNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MRSL_registerRemoteNotifications)
                                                 name:MRSLRegisterRemoteNotificationsNotification
                                               object:nil];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self MRSL_uploadDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogError(@"Error registering for remote notifications. Error: %@", error);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[MRSLEventManager sharedManager] startSession];
    // Handle the user leaving the app while the Facebook login dialog is being shown
    [FBAppCall handleDidBecomeActive];
    [application endBackgroundTask:_backgroundTaskIdentifier];

    [MRSLUser API_refreshCurrentUserWithSuccess:nil
                                        failure:nil];
    [MRSLUser API_updateNotificationsAmount:nil
                                    failure:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[MRSLEventManager sharedManager] endSession];
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void) {
        [application endBackgroundTask:_backgroundTaskIdentifier];
        [[MRSLAPIClient sharedClient].operationQueue cancelAllOperations];
        [[MRSLS3Client sharedClient].operationQueue cancelAllOperations];
    }];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        // This was a Chooser response and handleOpenURL automatically ran the
        // completion block
        return YES;
    } else {
        NSString *fbID = [NSString stringWithFormat:@"fb%@://", FACEBOOK_APP_ID];
        if ([url.absoluteString rangeOfString:fbID].location != NSNotFound) {
            DDLogDebug(@"Facebook Callback URL: %@", url);
            [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        } else if ([url.absoluteString rangeOfString:TWITTER_CALLBACK].location != NSNotFound) {
            DDLogDebug(@"Twitter Callback URL: %@", url);
            NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification
                                                                         object:nil
                                                                       userInfo:[NSDictionary dictionaryWithObject:url
                                                                                                            forKey:kAFApplicationLaunchOptionsURLKey]];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        } else if ([url.absoluteString rangeOfString:INSTAGRAM_CALLBACK].location != NSNotFound) {
            DDLogDebug(@"Instagram Callback URL: %@", url);
            NSString *replacingCallbackString = [NSString stringWithFormat:@"%@?code=", INSTAGRAM_CALLBACK];
            NSString *authCode = [url.absoluteString stringByReplacingOccurrencesOfString:replacingCallbackString withString:@""];
            [[MRSLSocialServiceInstagram sharedService] completeAuthenticationWithCode:authCode];
        }
        return [self handleRouteForURL:url
                     sourceApplication:sourceApplication];
    }
}

#pragma mark - Instance Methods

- (void)setupMorselEnvironment {
    self.defaultDateFormatter = [[NSDateFormatter alloc] init];
    [_defaultDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [_defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSS'Z'"];
    self.apiService = [[MRSLAPIService alloc] init];
    self.s3Service = [[MRSLS3Service alloc] init];

    [self setupDatabase];

    UIViewController *viewController = [[UIStoryboard mainStoryboard] instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void)refreshUserInformation {
    MRSLUser *currentUser = [MRSLUser currentUser];
    if (!currentUser) return;
    [MRSLUser API_refreshCurrentUserWithSuccess:^(id responseObject) {
        [self.apiService getUserAuthenticationsWithSuccess:nil
                                                   failure:nil];
    } failure:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLRegisterRemoteNotificationsNotification
                                                        object:nil];
    [MRSLUser API_updateNotificationsAmount:nil
                                    failure:nil];
    [currentUser setThirdPartySettings];
}

#pragma mark - Data Methods

- (void)setupDatabase {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel registerSuperPropertiesOnce:@{@"client_device": [UIDevice currentDeviceIsIpad] ? @"ipad" : @"iphone"}];
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
    } else {
        [[Mixpanel sharedInstance] identify:[Mixpanel sharedInstance].distinctId];
    }
}

#pragma mark - Logout

- (void)resetThirdPartySettings {
    [MRSLUser resetThirdPartySettings];
}

- (void)resetSocialConnections {
    [[MRSLSocialServiceFacebook sharedService] reset];
    [[MRSLSocialServiceTwitter sharedService] reset];
    [[MRSLSocialServiceInstagram sharedService] reset];
}

- (void)resetDataStore {
    [[MRSLRemoteDevice currentRemoteDevice] API_deleteWithSuccess:nil
                                                          failure:nil];
    [[Mixpanel sharedInstance] reset];
    [[MRSLAPIClient sharedClient].operationQueue cancelAllOperations];
    [[MRSLS3Client sharedClient].operationQueue cancelAllOperations];

    [self resetSocialConnections];
    [self resetThirdPartySettings];

    [NSMutableArray resetFeedIDArray];

    NSHTTPCookie *cookie = nil;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

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
