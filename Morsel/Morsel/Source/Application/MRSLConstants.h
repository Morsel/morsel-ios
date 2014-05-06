//
//  Constants.h
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Notification Constants

extern NSString *const MRSLServiceDidLogInUserNotification;
extern NSString *const MRSLServiceShouldLogOutUserNotification;
extern NSString *const MRSLServiceDidLogOutUserNotification;
extern NSString *const MRSLServiceDidUpdateUserNotification;

extern NSString *const MRSLUserDidCreateCommentNotification;
extern NSString *const MRSLUserDidBeginCreateMorselNotification;
extern NSString *const MRSLUserDidUpdateUserNotification;
extern NSString *const MRSLUserDidUpdateItemNotification;
extern NSString *const MRSLUserDidUpdateMorselNotification;
extern NSString *const MRSLUserDidPublishMorselNotification;
extern NSString *const MRSLUserDidDeleteMorselNotification;

extern NSString *const MRSLItemUploadDidCompleteNotification;
extern NSString *const MRSLItemUploadDidFailNotification;

extern NSString *const MRSLModalWillDisplayNotification;
extern NSString *const MRSLModalWillDismissNotification;

extern NSString *const MRSLAppShouldDisplayFeedNotification;
extern NSString *const MRSLAppShouldDisplayMorselAddNotification;
extern NSString *const MRSLAppShouldDisplayMenuBarNotification;
extern NSString *const MRSLAppShouldDisplayUserProfileNotification;

extern NSString *const MRSLAppDidRequestNewPreferredStatusBarStyle;
extern NSString *const MRSLAppTouchPhaseDidBeginNotification;

#pragma mark - Keyword Constants

extern NSString *const MRSLKeywordCuisinesType;
extern NSString *const MRSLKeywordSpecialtiesType;

#pragma mark - Debugging Constants

extern int LOG_LEVEL_DEF;

@interface MRSLConstants : NSObject

@end
