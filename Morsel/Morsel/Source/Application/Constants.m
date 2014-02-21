//
//  Constants.m
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "Constants.h"

NSString *const MRSLServiceDidLogInUserNotification = @"MRSLServiceDidLogInUserNotification";
NSString *const MRSLServiceDidLogOutUserNotification = @"MRSLServiceDidLogOutUserNotification";
NSString *const MRSLServiceDidUpdateUserNotification = @"MRSLServiceDidUpdateUserNotification";
NSString *const MRSLServiceWillPurgeDataNotification = @"MRSLServiceWillPurgeDataNotification";
NSString *const MRSLServiceWillRestoreDataNotification = @"MRSLServiceWillRestoreDataNotification";

NSString *const MRSLShouldDisplaySideBarNotification = @"MRSLShouldDisplaySideBarNotification";

NSString *const MRSLUserDidCreateCommentNotification = @"MRSLUserDidCreateCommentNotification";
NSString *const MRSLUserDidBeginCreateMorselNotification = @"MRSLUserDidBeginCreateMorselNotification";
NSString *const MRSLUserDidUpdateMorselNotification = @"MRSLUserDidUpdateMorselNotification";
NSString *const MRSLUserDidDeleteMorselNotification = @"MRSLUserDidDeleteMorselNotification";
NSString *const MRSLUserDidUpdatePostNotification = @"MRSLUserDidUpdatePostNotification";

NSString *const MRSLMorselUploadDidCompleteNotification = @"MRSLMorselUploadDidCompleteNotification";
NSString *const MRSLMorselUploadDidFailNotification = @"MRSLMorselUploadDidFailNotification";

#ifdef DEBUG
int LOG_LEVEL_DEF = LOG_LEVEL_DEBUG;
#else
int LOG_LEVEL_DEF = LOG_LEVEL_DEBUG;
#endif

@implementation Constants

@end
