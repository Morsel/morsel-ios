//
//  Constants.m
//  Morsel
//
//  Created by Javier Otero on 1/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLConstants.h"

#pragma mark - Notification Constants

NSString *const MRSLServiceDidLogInGuestNotification = @"MRSLServiceDidLogInGuestNotification";
NSString *const MRSLServiceDidLogInUserNotification = @"MRSLServiceDidLogInUserNotification";
NSString *const MRSLServiceShouldLogOutUserNotification = @"MRSLServiceShouldLogOutUserNotification";
NSString *const MRSLServiceDidLogOutUserNotification = @"MRSLServiceDidLogOutUserNotification";
NSString *const MRSLServiceDidUpdateUserNotification = @"MRSLServiceDidUpdateUserNotification";
NSString *const MRSLServiceDidUpdateUnreadAmountNotification = @"MRSLServiceDidUpdateUnreadAmountNotification";

NSString *const MRSLUserDidBeginCreateMorselNotification = @"MRSLUserDidBeginCreateMorselNotification";
NSString *const MRSLUserDidUpdateUserNotification = @"MRSLUserDidUpdateUserNotification";
NSString *const MRSLUserDidUpdateItemNotification = @"MRSLUserDidUpdateItemNotification";
NSString *const MRSLUserDidUpdateMorselNotification = @"MRSLUserDidUpdateMorselNotification";
NSString *const MRSLUserDidPublishMorselNotification = @"MRSLUserDidPublishMorselNotification";
NSString *const MRSLUserDidCreateMorselNotification = @"MRSLUserDidCreateMorselNotification";
NSString *const MRSLUserDidDeleteMorselNotification = @"MRSLUserDidDeleteMorselNotification";

NSString *const MRSLItemUploadDidFailNotification = @"MRSLItemUploadDidFailNotification";

NSString *const MRSLModalWillDisplayNotification = @"MRSLModalWillDisplayNotification";
NSString *const MRSLModalWillDismissNotification = @"MRSLModalWillDismissNotification";

NSString *const MRSLAppShouldDisplayLandingNotification = @"MRSLAppShouldDisplayLandingNotification";
NSString *const MRSLAppShouldDisplayFeedNotification = @"MRSLAppShouldDisplayFeedNotification";
NSString *const MRSLAppShouldDisplayMenuBarNotification = @"MRSLAppShouldDisplayMenuBarNotification";
NSString *const MRSLAppShouldDisplayBaseViewControllerNotification = @"MRSLAppShouldDisplayBaseViewControllerNotification";
NSString *const MRSLAppShouldDisplayOnboardingNotification = @"MRSLAppShouldDisplayOnboardingNotification";
NSString *const MRSLAppShouldDisplayProfessionalSettingsNotification = @"MRSLAppShouldDisplayProfessionalSettingsNotification";
NSString *const MRSLAppShouldDisplayUserProfileNotification = @"MRSLAppShouldDisplayUserProfileNotification";
NSString *const MRSLAppShouldDisplayPlaceNotification = @"MRSLAppShouldDisplayPlaceNotification";
NSString *const MRSLAppShouldDisplayMorselDetailNotification = @"MRSLAppShouldDisplayMorselDetailNotification";
NSString *const MRSLAppShouldDisplayWebBrowserNotification = @"MRSLAppShouldDisplayWebBrowserNotification";
NSString *const MRSLAppShouldDisplayEmailComposerNotification = @"MRSLAppShouldDisplayEmailComposerNotification";
NSString *const MRSLAppShouldCallPhoneNumberNotification = @"MRSLAppShouldCallPhoneNumberNotification";

NSString *const MRSLRegisterRemoteNotificationsNotification = @"MRSLRegisterRemoteNotificationsNotification";

#pragma mark - Social Constants

NSString *const MRSLFacebookReconnectingAccountNotification = @"MRSLFacebookReconnectingAccountNotification";
NSString *const MRSLFacebookReconnectedAccountNotification = @"MRSLFacebookReconnectedAccountNotification";
NSString *const MRSLFacebookReconnectAccountFailedNotification = @"MRSLFacebookReconnectAccountFailedNotification";

NSString *const MRSLInstagramReconnectingAccountNotification = @"MRSLInstagramReconnectingAccountNotification";
NSString *const MRSLInstagramReconnectedAccountNotification = @"MRSLInstagramReconnectedAccountNotification";
NSString *const MRSLInstagramReconnectAccountFailedNotification = @"MRSLInstagramReconnectAccountFailedNotification";

NSString *const MRSLTwitterReconnectingAccountNotification = @"MRSLTwitterReconnectingAccountNotification";
NSString *const MRSLTwitterReconnectedAccountNotification = @"MRSLTwitterReconnectedAccountNotification";
NSString *const MRSLTwitterReconnectAccountFailedNotification = @"MRSLTwitterReconnectAccountFailedNotification";

NSString *const MRSLTwitterCredentialsKey = @"MRSLTwitterCredentialsKey";
NSString *const MRSLInstagramAccountTypeKey = @"MRSLInstagramAccountTypeKey";

#pragma mark - Keyword Constants

NSString *const MRSLKeywordCuisinesType = @"cuisines";
NSString *const MRSLKeywordSpecialtiesType = @"specialties";

#pragma mark - Menu Constants

NSString *const MRSLMenuProfileKey = @"profile";
NSString *const MRSLMenuAddKey = @"morseladd";
NSString *const MRSLMenuDraftsKey = @"morseldrafts";
NSString *const MRSLMenuFeedKey = @"feed";
NSString *const MRSLMenuExploreKey = @"explore";
NSString *const MRSLMenuNotificationsKey = @"notifications";
NSString *const MRSLMenuPlacesKey = @"places";
NSString *const MRSLMenuActivityKey = @"activity";
NSString *const MRSLMenuFindKey = @"find";
NSString *const MRSLMenuSettingsKey = @"settings";

#pragma mark - Image Constants

NSString *const MRSLImageSizeKey = @"IMAGE_SIZE";

NSString *const MRSLProfileImageLargeRetinaKey = @"_144x144";
NSString *const MRSLProfileImageLargeKey = @"_72x72";
NSString *const MRSLProfileImageSmallRetinaKey = @"_80x80";
NSString *const MRSLProfileImageSmallKey = @"_40x40";

NSString *const MRSLItemImageLargeRetinaKey = @"_640x640";
NSString *const MRSLItemImageLargeKey = @"_320x320";
NSString *const MRSLItemImageSmallRetinaKey = @"_100x100";
NSString *const MRSLItemImageSmallKey = @"_50x50";

#pragma mark - Storyboard Constants

NSString *const MRSLStoryboardiPhoneActivityKey = @"Activity";
NSString *const MRSLStoryboardiPhoneExploreKey = @"Explore";
NSString *const MRSLStoryboardiPhoneFeedKey = @"Feed";
NSString *const MRSLStoryboardiPhoneLoginKey = @"Login";
NSString *const MRSLStoryboardiPhoneMainKey = @"Main";
NSString *const MRSLStoryboardiPhoneMediaManagementKey = @"MediaManagement";
NSString *const MRSLStoryboardiPhoneMorselManagementKey = @"MorselManagement";
NSString *const MRSLStoryboardiPhoneOnboardingKey = @"Onboarding";
NSString *const MRSLStoryboardiPhonePlacesKey = @"Places";
NSString *const MRSLStoryboardiPhoneProfileKey = @"Profile";
NSString *const MRSLStoryboardiPhoneSettingsKey = @"Settings";
NSString *const MRSLStoryboardiPhoneSocialKey = @"Social";
NSString *const MRSLStoryboardiPhoneSpecsKey = @"Specs_iPhone";
NSString *const MRSLStoryboardiPhoneTemplatesKey = @"Templates";

#pragma mark - Storyboard Identifier Constants

NSString *const MRSLStoryboardActivityKey = @"sb_Activity";
NSString *const MRSLStoryboardCommentsKey = @"sb_Comments";
NSString *const MRSLStoryboardExploreKey = @"sb_Explore";
NSString *const MRSLStoryboardFeedKey = @"sb_Feed";
NSString *const MRSLStoryboardFeedPanelKey = @"sb_FeedPanel";
NSString *const MRSLStoryboardFeedPanelViewControllerKey = @"sb_MRSLFeedPanelViewController";
NSString *const MRSLStoryboardFindFriendsKey = @"sb_FindFriends";
NSString *const MRSLStoryboardFollowingPeopleKey = @"sb_FollowingPeople";
NSString *const MRSLStoryboardImagePreviewViewControllerKey = @"sb_MRSLImagePreviewViewController";
NSString *const MRSLStoryboardKeywordUsersViewControllerKey = @"sb_MRSLKeywordUsersViewController";
NSString *const MRSLStoryboardLikesKey = @"sb_Likes";
NSString *const MRSLStoryboardTaggedUsersKey = @"sb_TaggedUsers";
NSString *const MRSLStoryboardMediaPreviewKey = @"sb_MediaPreview";
NSString *const MRSLStoryboardModalShareViewControllerKey = @"sb_MRSLModalShareViewController";
NSString *const MRSLStoryboardMorselAddTitleViewControllerKey = @"sb_MRSLMorselAddTitleViewController";
NSString *const MRSLStoryboardMorselAddKey = @"sb_MorselAdd";
NSString *const MRSLStoryboardMorselEditKey = @"sb_MorselEdit";
NSString *const MRSLStoryboardMorselListKey = @"sb_MorselList";
NSString *const MRSLStoryboardMorselEditViewControllerKey = @"sb_MRSLMorselEditViewController";
NSString *const MRSLStoryboardNotificationsKey = @"sb_Notifications";
NSString *const MRSLStoryboardPlaceDetailViewControllerKey = @"sb_MRSLPlaceDetailViewController";
NSString *const MRSLStoryboardPlaceKey = @"sb_Place";
NSString *const MRSLStoryboardPlacesAddViewControllerKey = @"sb_MRSLPlacesAddViewController";
NSString *const MRSLStoryboardPlaceViewControllerKey = @"sb_MRSLPlaceViewController";
NSString *const MRSLStoryboardProfessionalSettingsKey = @"sb_ProfessionalSettings";
NSString *const MRSLStoryboardProfessionalSettingsTableViewControllerKey = @"sb_MRSLProfessionalSettingsTableViewController";
NSString *const MRSLStoryboardProfileEditFieldsViewControllerKey = @"sb_MRSLProfileEditFieldsViewController";
NSString *const MRSLStoryboardProfileKey = @"sb_Profile";
NSString *const MRSLStoryboardProfileViewControllerKey = @"sb_MRSLProfileViewController";
NSString *const MRSLStoryboardSettingsKey = @"sb_Settings";
NSString *const MRSLStoryboardSignUpKey = @"sb_SignUp";
NSString *const MRSLStoryboardShareKey = @"sb_Share";
NSString *const MRSLStoryboardSocialComposeKey = @"sb_SocialCompose" ;
NSString *const MRSLStoryboardMorselDetailKey = @"sb_MorselDetail";
NSString *const MRSLStoryboardMorselDetailViewControllerKey = @"sb_MRSLMorselDetailViewController";
NSString *const MRSLStoryboardWebBrowserKey = @"sb_WebBrowser";
NSString *const MRSLStoryboardTemplateSelectionKey = @"sb_TemplateSelection";
NSString *const MRSLStoryboardTemplateSelectionViewControllerKey = @"sb_MRSLTemplateSelectionViewController";
NSString *const MRSLStoryboardTemplateInfoViewControllerKey = @"sb_MRSLTemplateInfoViewController";
NSString *const MRSLStoryboardTemplateInfoKey = @"sb_TemplateInfo";
NSString *const MRSLStoryboardOnboardingFeedKey = @"sb_OnboardingFeed";

#pragma mark - Storyboard Segue Constants

NSString *const MRSLStoryboardSegueAccountSettingsKey = @"seg_AccountSettings";
NSString *const MRSLStoryboardSegueCuisinesKey = @"seg_Cuisines";
NSString *const MRSLStoryboardSegueDisplayLoginKey = @"seg_DisplayLogin";
NSString *const MRSLStoryboardSegueDisplayResetPasswordKey = @"seg_DisplayResetPassword";
NSString *const MRSLStoryboardSegueDisplaySignUpKey = @"seg_DisplaySignUp";
NSString *const MRSLStoryboardSegueEditItemTextKey = @"seg_EditItemText";
NSString *const MRSLStoryboardSegueEditMorselTitleKey = @"seg_EditMorselTitle";
NSString *const MRSLStoryboardSegueFollowListKey = @"seg_FollowList";
NSString *const MRSLStoryboardSegueProfessionalSettingsKey = @"seg_ProfessionalSettings";
NSString *const MRSLStoryboardSeguePublishShareMorselKey = @"seg_PublishShareMorsel";
NSString *const MRSLStoryboardSegueSelectPlaceKey = @"seg_SelectPlace";
NSString *const MRSLStoryboardSegueSetupProfessionalAccountKey = @"seg_SetupProfessionalAccount";
NSString *const MRSLStoryboardSegueSpecialtiesKey = @"seg_Specialties";
NSString *const MRSLStoryboardSegueTemplateInfoKey = @"seg_DisplayTemplateInfo";
NSString *const MRSLStoryboardSegueKeywordFollowersKey = @"seg_DisplayKeywordFollowers";
NSString *const MRSLStoryboardSegueEligibleUsersKey = @"seg_DisplayEligibleUsers";

#pragma mark - Storyboard Reuse Identifier Constants

NSString *const MRSLStoryboardRUIDBasicInfoCellKey = @"ruid_BasicInfoCell";
NSString *const MRSLStoryboardRUIDCommentCellKey = @"ruid_CommentCell";
NSString *const MRSLStoryboardRUIDContactCellKey = @"ruid_ContactCell";
NSString *const MRSLStoryboardRUIDEmptyCellKey = @"ruid_EmptyCell";
NSString *const MRSLStoryboardRUIDFeedCoverCellKey = @"ruid_FeedCoverCell";
NSString *const MRSLStoryboardRUIDFeedLoadingMoreFooterKey = @"ruid_FeedLoadingMoreFooter";
NSString *const MRSLStoryboardRUIDFeedPageCellKey = @"ruid_FeedPageCell";
NSString *const MRSLStoryboardRUIDFeedPanelCellKey = @"ruid_FeedPanelCell";
NSString *const MRSLStoryboardRUIDFeedShareCellKey = @"ruid_FeedShareCell";
NSString *const MRSLStoryboardRUIDFoursquarePlaceCellKey = @"ruid_FoursquarePlaceCell";
NSString *const MRSLStoryboardRUIDHeaderCellKey = @"ruid_HeaderCell";
NSString *const MRSLStoryboardRUIDHoursCellKey = @"ruid_HoursCell";
NSString *const MRSLStoryboardRUIDInfoCellKey = @"ruid_InfoCell";
NSString *const MRSLStoryboardRUIDInstructionCellKey = @"ruid_InstructionCell";
NSString *const MRSLStoryboardRUIDKeywordCellKey = @"ruid_KeywordCell";
NSString *const MRSLStoryboardRUIDLoadingCellKey = @"ruid_LoadingCell";
NSString *const MRSLStoryboardRUIDLocationDisabledCellKey = @"ruid_LocationDisabledCell";
NSString *const MRSLStoryboardRUIDItemPreviewCellKey = @"ruid_ItemPreviewCell";
NSString *const MRSLStoryboardRUIDMenuOptionCellKey = @"ruid_MenuOptionCell";
NSString *const MRSLStoryboardRUIDMoreCharactersCellKey = @"ruid_MoreCharactersCell";
NSString *const MRSLStoryboardRUIDMorselCellKey = @"ruid_MorselCell";
NSString *const MRSLStoryboardRUIDMorselItemCellKey = @"ruid_MorselItemCell";
NSString *const MRSLStoryboardRUIDMorselPreviewCellKey = @"ruid_MorselPreviewCell";
NSString *const MRSLStoryboardRUIDMorselTaggedUsersCellKey = @"ruid_MorselTaggedUsersCell";
NSString *const MRSLStoryboardRUIDActivityTableViewCellKey = @"ruid_MRSLActivityTableViewCell";
NSString *const MRSLStoryboardRUIDToggleKeywordTableViewCellKey = @"ruid_ToggleKeywordTableViewCell";
NSString *const MRSLStoryboardRUIDNoResultsCellKey = @"ruid_NoResultsCell";
NSString *const MRSLStoryboardRUIDPanelCellKey = @"ruid_PanelCell";
NSString *const MRSLStoryboardRUIDPlaceCellKey = @"ruid_PlaceCell";
NSString *const MRSLStoryboardRUIDPreviousCommentCellKey = @"ruid_PreviousCommentCell";
NSString *const MRSLStoryboardRUIDPreviousLoadingKey = @"ruid_PreviousLoading";
NSString *const MRSLStoryboardRUIDSectionFooterKey = @"ruid_SectionFooter";
NSString *const MRSLStoryboardRUIDUserCellKey = @"ruid_UserCell";
NSString *const MRSLStoryboardRUIDUserFollowCellKey = @"ruid_UserFollowCell";
NSString *const MRSLStoryboardRUIDUserEligibleCellKey = @"ruid_UserEligibleCell";
NSString *const MRSLStoryboardRUIDUserLikedMorselCellKey = @"ruid_UserLikedMorselCell";
NSString *const MRSLStoryboardRUIDTemplateCell = @"ruid_TemplateCell";
NSString *const MRSLStoryboardRUIDTemplateInfoCell = @"ruid_TemplateInfoCell";
NSString *const MRSLStoryboardRUIDMorselAddCell = @"ruid_MorselAddCell";
NSString *const MRSLStoryboardRUIDMorselInfoCell = @"ruid_MorselInfoCell";
NSString *const MRSLStoryboardRUIDPushNotificationSettingCellKey = @"ruid_PushNotificationSettingCell";

#pragma mark - Storyboard Source Identifiers
/*
    Reserved area to avoid warnings from StoryboardLint if identifiers are not included in Storyboard or IB files.
*/

NSString *const MRSLStoryboardRUIDSectionHeaderKey = @"srcuid_SectionHeader";

#pragma mark - Debugging Constants

#if (defined(MORSEL_DEBUG) || defined(MORSEL_ALPHA))
int LOG_LEVEL_DEF = LOG_LEVEL_DEBUG;
#else
int LOG_LEVEL_DEF = LOG_LEVEL_ERROR;
#endif

#pragma mark - Misc. Constants

NSString *const MRSLDefaultEmptyUserName = @"Morsel User";

@implementation MRSLConstants

@end
