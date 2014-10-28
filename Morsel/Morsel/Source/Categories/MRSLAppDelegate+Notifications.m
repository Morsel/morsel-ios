//
//  MRSLAppDelegate+Notifications.m
//  Morsel
//
//  Created by Marty Trzpit on 10/15/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAppDelegate+Notifications.h"

@implementation MRSLAppDelegate (Notifications)

- (void)MRSL_registerRemoteNotifications {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)
                                                                                        categories:nil]];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

- (void)MRSL_uploadDeviceToken:(NSData *)deviceToken {
    NSCharacterSet *angleBrackets = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    NSString *deviceTokenSansBrackets = [[deviceToken description] stringByTrimmingCharactersInSet:angleBrackets];

#warning Upload deviceTokenSansBrackets to API
}

@end
