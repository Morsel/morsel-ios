//
//  Constants.h
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Notification Constants

extern NSString *const MRSLServiceDidLogInGuestNotification;
extern NSString *const MRSLServiceDidLogInUserNotification;
extern NSString *const MRSLServiceShouldLogOutUserNotification;
extern NSString *const MRSLServiceDidLogOutUserNotification;
extern NSString *const MRSLServiceDidUpdateUserNotification;
extern NSString *const MRSLServiceDidUpdateUnreadAmountNotification;

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

extern NSString *const MRSLAppShouldDisplayLandingNotification;
extern NSString *const MRSLAppShouldDisplayFeedNotification;
extern NSString *const MRSLAppShouldDisplayMenuBarNotification;
extern NSString *const MRSLAppShouldDisplayBaseViewControllerNotification;
extern NSString *const MRSLAppShouldDisplayOnboardingNotification;
extern NSString *const MRSLAppShouldDisplayProfessionalSettingsNotification;
extern NSString *const MRSLAppShouldDisplayUserProfileNotification;
extern NSString *const MRSLAppShouldDisplayPlaceNotification;
extern NSString *const MRSLAppShouldDisplayMorselDetailNotification;
extern NSString *const MRSLAppShouldDisplayWebBrowserNotification;
extern NSString *const MRSLAppShouldDisplayEmailComposerNotification;
extern NSString *const MRSLAppShouldCallPhoneNumberNotification;

extern NSString *const MRSLRegisterRemoteNotificationsNotification;

#pragma mark - Social Constants

extern NSString *const MRSLFacebookReconnectingAccountNotification;
extern NSString *const MRSLFacebookReconnectedAccountNotification;
extern NSString *const MRSLFacebookReconnectAccountFailedNotification;

extern NSString *const MRSLInstagramReconnectingAccountNotification;
extern NSString *const MRSLInstagramReconnectedAccountNotification;
extern NSString *const MRSLInstagramReconnectAccountFailedNotification;

extern NSString *const MRSLTwitterReconnectingAccountNotification;
extern NSString *const MRSLTwitterReconnectedAccountNotification;
extern NSString *const MRSLTwitterReconnectAccountFailedNotification;

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
extern NSString *const MRSLMenuExploreKey;
extern NSString *const MRSLMenuNotificationsKey;
extern NSString *const MRSLMenuPlacesKey;
extern NSString *const MRSLMenuActivityKey;
extern NSString *const MRSLMenuFindKey;
extern NSString *const MRSLMenuSettingsKey;

#pragma mark - Image Constants

extern NSString *const MRSLImageSizeKey;

extern NSString *const MRSLProfileImageLargeRetinaKey;
extern NSString *const MRSLProfileImageLargeKey;
extern NSString *const MRSLProfileImageSmallRetinaKey;
extern NSString *const MRSLProfileImageSmallKey;

extern NSString *const MRSLItemImageLargeRetinaKey;
extern NSString *const MRSLItemImageLargeKey;
extern NSString *const MRSLItemImageSmallRetinaKey;
extern NSString *const MRSLItemImageSmallKey;

#pragma mark - Storyboard Constants

extern NSString *const MRSLStoryboardiPhoneActivityKey;
extern NSString *const MRSLStoryboardiPhoneExploreKey;
extern NSString *const MRSLStoryboardiPhoneFeedKey;
extern NSString *const MRSLStoryboardiPhoneLoginKey;
extern NSString *const MRSLStoryboardiPhoneMainKey;
extern NSString *const MRSLStoryboardiPhoneMediaManagementKey;
extern NSString *const MRSLStoryboardiPhoneMorselManagementKey;
extern NSString *const MRSLStoryboardiPhoneOnboardingKey;
extern NSString *const MRSLStoryboardiPhonePlacesKey;
extern NSString *const MRSLStoryboardiPhoneProfileKey;
extern NSString *const MRSLStoryboardiPhoneSettingsKey;
extern NSString *const MRSLStoryboardiPhoneSocialKey;
extern NSString *const MRSLStoryboardiPhoneSpecsKey;
extern NSString *const MRSLStoryboardiPhoneTemplatesKey;

#pragma mark - Storyboard Identifier Constants

extern NSString *const MRSLStoryboardActivityKey;
extern NSString *const MRSLStoryboardCommentsKey;
extern NSString *const MRSLStoryboardExploreKey;
extern NSString *const MRSLStoryboardFeedKey;
extern NSString *const MRSLStoryboardFeedPanelKey;
extern NSString *const MRSLStoryboardFeedPanelViewControllerKey;
extern NSString *const MRSLStoryboardFindFriendsKey;
extern NSString *const MRSLStoryboardFollowingPeopleKey;
extern NSString *const MRSLStoryboardImagePreviewViewControllerKey;
extern NSString *const MRSLStoryboardKeywordUsersViewControllerKey;
extern NSString *const MRSLStoryboardLikesKey;
extern NSString *const MRSLStoryboardTaggedUsersKey;
extern NSString *const MRSLStoryboardMediaPreviewKey;
extern NSString *const MRSLStoryboardModalShareViewControllerKey;
extern NSString *const MRSLStoryboardMorselAddTitleViewControllerKey;
extern NSString *const MRSLStoryboardMorselAddKey;
extern NSString *const MRSLStoryboardMorselEditKey;
extern NSString *const MRSLStoryboardMorselListKey;
extern NSString *const MRSLStoryboardMorselEditViewControllerKey;
extern NSString *const MRSLStoryboardNotificationsKey;
extern NSString *const MRSLStoryboardPlaceDetailViewControllerKey;
extern NSString *const MRSLStoryboardPlaceKey;
extern NSString *const MRSLStoryboardPlacesAddViewControllerKey;
extern NSString *const MRSLStoryboardPlaceViewControllerKey;
extern NSString *const MRSLStoryboardProfessionalSettingsKey;
extern NSString *const MRSLStoryboardProfessionalSettingsTableViewControllerKey;
extern NSString *const MRSLStoryboardProfileEditFieldsViewControllerKey;
extern NSString *const MRSLStoryboardProfileKey;
extern NSString *const MRSLStoryboardProfileViewControllerKey;
extern NSString *const MRSLStoryboardSettingsKey;
extern NSString *const MRSLStoryboardSignUpKey;
extern NSString *const MRSLStoryboardShareKey;
extern NSString *const MRSLStoryboardSocialComposeKey;
extern NSString *const MRSLStoryboardMorselDetailKey;
extern NSString *const MRSLStoryboardMorselDetailViewControllerKey;
extern NSString *const MRSLStoryboardWebBrowserKey;
extern NSString *const MRSLStoryboardTemplateSelectionKey;
extern NSString *const MRSLStoryboardTemplateSelectionViewControllerKey;
extern NSString *const MRSLStoryboardTemplateInfoViewControllerKey;
extern NSString *const MRSLStoryboardTemplateInfoKey;
extern NSString *const MRSLStoryboardOnboardingFeedKey;

#pragma mark - Storyboard Segue Constants

extern NSString *const MRSLStoryboardSegueAccountSettingsKey;
extern NSString *const MRSLStoryboardSegueCuisinesKey;
extern NSString *const MRSLStoryboardSegueDisplayLoginKey;
extern NSString *const MRSLStoryboardSegueDisplayResetPasswordKey;
extern NSString *const MRSLStoryboardSegueDisplaySignUpKey;
extern NSString *const MRSLStoryboardSegueEditItemTextKey;
extern NSString *const MRSLStoryboardSegueEditMorselTitleKey;
extern NSString *const MRSLStoryboardSegueFollowListKey;
extern NSString *const MRSLStoryboardSegueProfessionalSettingsKey;
extern NSString *const MRSLStoryboardSeguePublishMorselKey;
extern NSString *const MRSLStoryboardSeguePublishShareMorselKey;
extern NSString *const MRSLStoryboardSegueSelectPlaceKey;
extern NSString *const MRSLStoryboardSegueSetupProfessionalAccountKey;
extern NSString *const MRSLStoryboardSegueSpecialtiesKey;
extern NSString *const MRSLStoryboardSegueTemplateInfoKey;
extern NSString *const MRSLStoryboardSegueKeywordFollowersKey;
extern NSString *const MRSLStoryboardSegueEligibleUsersKey;

#pragma mark - Storyboard Reuse Identifier Constants

extern NSString *const MRSLStoryboardRUIDBasicInfoCellKey;
extern NSString *const MRSLStoryboardRUIDCommentCellKey;
extern NSString *const MRSLStoryboardRUIDContactCellKey;
extern NSString *const MRSLStoryboardRUIDEmptyCellKey;
extern NSString *const MRSLStoryboardRUIDFeedCoverCellKey;
extern NSString *const MRSLStoryboardRUIDFeedLoadingMoreFooterKey;
extern NSString *const MRSLStoryboardRUIDFeedPageCellKey;
extern NSString *const MRSLStoryboardRUIDFeedPanelCellKey;
extern NSString *const MRSLStoryboardRUIDFeedShareCellKey;
extern NSString *const MRSLStoryboardRUIDFoursquarePlaceCellKey;
extern NSString *const MRSLStoryboardRUIDHeaderCellKey;
extern NSString *const MRSLStoryboardRUIDHoursCellKey;
extern NSString *const MRSLStoryboardRUIDInfoCellKey;
extern NSString *const MRSLStoryboardRUIDInstructionCellKey;
extern NSString *const MRSLStoryboardRUIDKeywordCellKey;
extern NSString *const MRSLStoryboardRUIDLoadingCellKey;
extern NSString *const MRSLStoryboardRUIDLocationDisabledCellKey;
extern NSString *const MRSLStoryboardRUIDItemPreviewCellKey;
extern NSString *const MRSLStoryboardRUIDMenuOptionCellKey;
extern NSString *const MRSLStoryboardRUIDMoreCharactersCellKey;
extern NSString *const MRSLStoryboardRUIDMorselCellKey;
extern NSString *const MRSLStoryboardRUIDMorselItemCellKey;
extern NSString *const MRSLStoryboardRUIDMorselPreviewCellKey;
extern NSString *const MRSLStoryboardRUIDMorselTaggedUsersCellKey;
extern NSString *const MRSLStoryboardRUIDActivityTableViewCellKey;
extern NSString *const MRSLStoryboardRUIDToggleKeywordTableViewCellKey;
extern NSString *const MRSLStoryboardRUIDNoResultsCellKey;
extern NSString *const MRSLStoryboardRUIDPanelCellKey;
extern NSString *const MRSLStoryboardRUIDPlaceCellKey;
extern NSString *const MRSLStoryboardRUIDPreviousCommentCellKey;
extern NSString *const MRSLStoryboardRUIDPreviousLoadingKey;
extern NSString *const MRSLStoryboardRUIDSectionFooterKey;
extern NSString *const MRSLStoryboardRUIDSectionHeaderKey;
extern NSString *const MRSLStoryboardRUIDUserCellKey;
extern NSString *const MRSLStoryboardRUIDUserFollowCellKey;
extern NSString *const MRSLStoryboardRUIDUserEligibleCellKey;
extern NSString *const MRSLStoryboardRUIDUserLikedItemCellKey;
extern NSString *const MRSLStoryboardRUIDTemplateCell;
extern NSString *const MRSLStoryboardRUIDTemplateInfoCell;
extern NSString *const MRSLStoryboardRUIDMorselAddCell;
extern NSString *const MRSLStoryboardRUIDMorselInfoCell;
extern NSString *const MRSLStoryboardRUIDPushNotificationSettingCellKey;

#pragma mark - Debugging Constants

extern int LOG_LEVEL_DEF;

@interface MRSLConstants : NSObject

@end
