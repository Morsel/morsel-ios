//
//  Constants.m
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLConstants.h"

#pragma mark - Notification Constants

NSString *const MRSLServiceDidLogInUserNotification = @"MRSLServiceDidLogInUserNotification";
NSString *const MRSLServiceShouldLogOutUserNotification = @"MRSLServiceShouldLogOutUserNotification";
NSString *const MRSLServiceDidLogOutUserNotification = @"MRSLServiceDidLogOutUserNotification";
NSString *const MRSLServiceDidUpdateUserNotification = @"MRSLServiceDidUpdateUserNotification";

NSString *const MRSLUserDidCreateCommentNotification = @"MRSLUserDidCreateCommentNotification";
NSString *const MRSLUserDidBeginCreateMorselNotification = @"MRSLUserDidBeginCreateMorselNotification";
NSString *const MRSLUserDidUpdateUserNotification = @"MRSLUserDidUpdateUserNotification";
NSString *const MRSLUserDidUpdateItemNotification = @"MRSLUserDidUpdateItemNotification";
NSString *const MRSLUserDidUpdateMorselNotification = @"MRSLUserDidUpdateMorselNotification";
NSString *const MRSLUserDidPublishMorselNotification = @"MRSLUserDidPublishMorselNotification";
NSString *const MRSLUserDidDeleteMorselNotification = @"MRSLUserDidDeleteMorselNotification";

NSString *const MRSLItemUploadDidCompleteNotification = @"MRSLItemUploadDidCompleteNotification";
NSString *const MRSLItemUploadDidFailNotification = @"MRSLItemUploadDidFailNotification";

NSString *const MRSLModalWillDisplayNotification = @"MRSLModalWillDisplayNotification";
NSString *const MRSLModalWillDismissNotification = @"MRSLModalWillDismissNotification";

NSString *const MRSLAppShouldDisplayFeedNotification = @"MRSLAppShouldDisplayFeedNotification";
NSString *const MRSLAppShouldDisplayMorselAddNotification = @"MRSLAppShouldDisplayMorselAddNotification";
NSString *const MRSLAppShouldDisplayMenuBarNotification = @"MRSLAppShouldDisplayMenuBarNotification";
NSString *const MRSLAppShouldDisplayBaseViewControllerNotification = @"MRSLAppShouldDisplayBaseViewControllerNotification";
NSString *const MRSLAppShouldDisplayUserProfileNotification = @"MRSLAppShouldDisplayUserProfileNotification";
NSString *const MRSLAppShouldDisplayWebBrowserNotification = @"MRSLAppShouldDisplayWebBrowserNotification";

NSString *const MRSLAppDidRequestNewPreferredStatusBarStyle = @"MRSLAppDidRequestNewPreferredStatusBarStyle";

NSString *const MRSLAppTouchPhaseDidBeginNotification = @"MRSLAppTouchPhaseDidBeginNotification";

#pragma mark - Social Constants

NSString *const MRSLTwitterCredentialsKey = @"MRSLTwitterCredentialsKey";
NSString *const MRSLInstagramAccountTypeKey = @"MRSLInstagramAccountTypeKey";

#pragma mark - Keyword Constants

NSString *const MRSLKeywordCuisinesType = @"cuisines";
NSString *const MRSLKeywordSpecialtiesType = @"specialties";

#pragma mark - Debugging Constants

#ifdef DEBUG
int LOG_LEVEL_DEF = LOG_LEVEL_DEBUG;
#else
int LOG_LEVEL_DEF = LOG_LEVEL_ERROR;
#endif

@implementation MRSLConstants

@end
