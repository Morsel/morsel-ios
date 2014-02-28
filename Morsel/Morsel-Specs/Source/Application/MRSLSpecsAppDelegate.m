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

#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@implementation MRSLSpecsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];

    [self setupSpecTestingEnvironment];
    
    return YES;
}

- (void)setupSpecTestingEnvironment {
    self.defaultDateFormatter = [[NSDateFormatter alloc] init];
    [_defaultDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [_defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSS'Z'"];
    
    self.morselApiService = [[MorselAPIService alloc] init];

    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Morsel-Specs.sqlite"];
    [MRSLUser MR_truncateAll];
    [MRSLPost MR_truncateAll];
    [MRSLMorsel MR_truncateAll];
    [MRSLComment MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    [[NSManagedObjectContext MR_defaultContext] setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];

    UIViewController *viewController = [[UIStoryboard specsStoryboardInBundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void)resetDataStore {
    // Only exists to please compiler
}

@end
