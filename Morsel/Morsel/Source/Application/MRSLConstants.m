//
//  Constants.m
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLConstants.h"

NSString *const MRSLServiceDidLogInUserNotification = @"MRSLServiceDidLogInUserNotification";
NSString *const MRSLServiceShouldLogOutUserNotification = @"MRSLServiceShouldLogOutUserNotification";
NSString *const MRSLServiceDidLogOutUserNotification = @"MRSLServiceDidLogOutUserNotification";
NSString *const MRSLServiceDidUpdateUserNotification = @"MRSLServiceDidUpdateUserNotification";
NSString *const MRSLServiceWillPurgeDataNotification = @"MRSLServiceWillPurgeDataNotification";
NSString *const MRSLServiceWillRestoreDataNotification = @"MRSLServiceWillRestoreDataNotification";

NSString *const MRSLUserDidCreateCommentNotification = @"MRSLUserDidCreateCommentNotification";
NSString *const MRSLUserDidBeginCreateMorselNotification = @"MRSLUserDidBeginCreateMorselNotification";
NSString *const MRSLUserDidUpdateMorselNotification = @"MRSLUserDidUpdateMorselNotification";
NSString *const MRSLUserDidDeleteMorselNotification = @"MRSLUserDidDeleteMorselNotification";
NSString *const MRSLUserDidUpdatePostNotification = @"MRSLUserDidUpdatePostNotification";
NSString *const MRSLUserDidPublishPostNotification = @"MRSLUserDidPublishPostNotification";

NSString *const MRSLMorselUploadDidCompleteNotification = @"MRSLMorselUploadDidCompleteNotification";
NSString *const MRSLMorselUploadDidFailNotification = @"MRSLMorselUploadDidFailNotification";

NSString *const MRSLModalWillDisplayNotification = @"MRSLModalWillDisplayNotification";
NSString *const MRSLModalWillDismissNotification = @"MRSLModalWillDismissNotification";

NSString *const MRSLAppShouldDisplayFeedNotification = @"MRSLAppShouldDisplayFeedNotification";
NSString *const MRSLAppShouldDisplayStoryAddNotification = @"MRSLAppShouldDisplayStoryAddNotification";
NSString *const MRSLAppShouldDisplayMenuBarNotification = @"MRSLAppShouldDisplayMenuBarNotification";

NSString *const MRSLAppDidRequestNewPreferredStatusBarStyle = @"MRSLAppDidRequestNewPreferredStatusBarStyle";

NSString *const MRSLAppTouchPhaseDidBeginNotification = @"MRSLAppTouchPhaseDidBeginNotification";

#ifdef DEBUG
int LOG_LEVEL_DEF = LOG_LEVEL_DEBUG;
#else
int LOG_LEVEL_DEF = LOG_LEVEL_ERROR;
#endif

@implementation MRSLConstants

@end
