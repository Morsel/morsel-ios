//
//  Constants.h
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CocoaLumberjack/DDLog.h>

extern NSString *const MRSLServiceDidLogInUserNotification;
extern NSString *const MRSLServiceDidLogOutUserNotification;
extern NSString *const MRSLServiceDidUpdateUserNotification;
extern NSString *const MRSLShouldDisplaySideBarNotification;
extern NSString *const MRSLUserDidCreateCommentNotification;
extern NSString *const MRSLUserDidCreateMorselNotification;
extern NSString *const MRSLUserDidUpdateMorselNotification;
extern NSString *const MRSLUserDidDeleteMorselNotification;

extern int LOG_LEVEL_DEF;

@interface Constants : NSObject

@end
