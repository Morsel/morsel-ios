//
//  MRSLIntegrationAppDelegate.m
//  Morsel
//
//  Created by Javier Otero on 7/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLIntegrationAppDelegate.h"

#import "MRSLAppDelegate+CustomURLSchemes.h"

#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>

#if MRSL_RECORDING
#import <VCRURLConnection/VCR.h>
#endif

#import "MRSLAPIClient.h"
#import "MRSLS3Client.h"
#import "MRSLS3Service.h"
#import "MRSLComment.h"
#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@implementation MRSLIntegrationAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [Mixpanel sharedInstanceWithToken:@""];

    [self setupSpecTestingEnvironment];
    [self setupRouteHandler];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleRouteForURL:url
                 sourceApplication:sourceApplication];
}

- (void)setupSpecTestingEnvironment {
    self.defaultDateFormatter = [[NSDateFormatter alloc] init];
    [self.defaultDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [self.defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSS'Z'"];

    self.apiService = [[MRSLAPIService alloc] init];
    self.s3Service = [[MRSLS3Service alloc] init];

    [MagicalRecord setupCoreDataStackWithInMemoryStore];

    UIViewController *viewController = [[UIStoryboard mainStoryboard] instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void)resetSocialConnections {
    // Blank on purpose
}

- (void)resetDataStore {
    // Blank on purpose
}

@end
