//
//  Constants.h
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const MRSLServiceDidLogInUserNotification;
extern NSString *const MRSLServiceShouldLogOutUserNotification;
extern NSString *const MRSLServiceDidLogOutUserNotification;
extern NSString *const MRSLServiceDidUpdateUserNotification;
extern NSString *const MRSLServiceWillPurgeDataNotification;
extern NSString *const MRSLServiceWillRestoreDataNotification;

extern NSString *const MRSLUserDidCreateCommentNotification;
extern NSString *const MRSLUserDidBeginCreateMorselNotification;
extern NSString *const MRSLUserDidUpdateMorselNotification;
extern NSString *const MRSLUserDidDeleteMorselNotification;
extern NSString *const MRSLUserDidUpdatePostNotification;
extern NSString *const MRSLUserDidPublishPostNotification;

extern NSString *const MRSLMorselUploadDidCompleteNotification;
extern NSString *const MRSLMorselUploadDidFailNotification;

extern NSString *const MRSLModalWillDisplayNotification;
extern NSString *const MRSLModalWillDismissNotification;

extern NSString *const MRSLAppShouldDisplayFeedNotification;
extern NSString *const MRSLAppShouldDisplayStoryAddNotification;
extern NSString *const MRSLAppShouldDisplayMenuBarNotification;
extern NSString *const MRSLAppShouldDisplayUserProfileNotification;

extern NSString *const MRSLAppDidRequestNewPreferredStatusBarStyle;
extern NSString *const MRSLAppTouchPhaseDidBeginNotification;

extern int LOG_LEVEL_DEF;

@interface MRSLConstants : NSObject

@end
