//
//  MRSLAppDelegate+Notifications.h
//  Morsel
//
//  Created by Marty Trzpit on 10/15/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAppDelegate.h"

@interface MRSLAppDelegate (Notifications)

- (void)MRSL_registerRemoteNotifications;

- (void)MRSL_uploadDeviceToken:(NSData *)deviceToken;

@end
