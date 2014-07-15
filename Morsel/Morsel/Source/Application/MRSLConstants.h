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

extern NSString *const MRSLUserDidBeginCreateMorselNotification;
extern NSString *const MRSLUserDidUpdateUserNotification;
extern NSString *const MRSLUserDidUpdateItemNotification;
extern NSString *const MRSLUserDidUpdateMorselNotification;
extern NSString *const MRSLUserDidPublishMorselNotification;
extern NSString *const MRSLUserDidCreateMorselNotification;
extern NSString *const MRSLUserDidDeleteMorselNotification;

extern NSString *const MRSLItemUploadDidFailNotification;

extern NSString *const MRSLModalWillDisplayNotification;
extern NSString *const MRSLModalWillDismissNotification;

extern NSString *const MRSLAppShouldDisplayMenuBarNotification;
extern NSString *const MRSLAppShouldDisplayBaseViewControllerNotification;
extern NSString *const MRSLAppShouldDisplayProfessionalSettingsNotification;
extern NSString *const MRSLAppShouldDisplayUserProfileNotification;
extern NSString *const MRSLAppShouldDisplayWebBrowserNotification;
extern NSString *const MRSLAppShouldDisplayEmailComposerNotification;
extern NSString *const MRSLAppShouldCallPhoneNumberNotification;

extern NSString *const MRSLAppDidRequestNewPreferredStatusBarStyle;

#pragma mark - Social Constants

extern NSString *const MRSLTwitterCredentialsKey;
extern NSString *const MRSLInstagramAccountTypeKey;

#pragma mark - Keyword Constants

extern NSString *const MRSLKeywordCuisinesType;
extern NSString *const MRSLKeywordSpecialtiesType;

#pragma mark - Menu Constants

extern NSString *const MRSLMenuProfileKey;
extern NSString *const MRSLMenuAddKey;
extern NSString *const MRSLMenuDraftsKey;
extern NSString *const MRSLMenuFeedKey;
extern NSString *const MRSLMenuNotificationsKey;
extern NSString *const MRSLMenuPlacesKey;
extern NSString *const MRSLMenuPeopleKey;
extern NSString *const MRSLMenuFindKey;
extern NSString *const MRSLMenuSettingsKey;

#pragma mark - Debugging Constants

extern int LOG_LEVEL_DEF;

@interface MRSLConstants : NSObject

@end
