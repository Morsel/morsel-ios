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

NSString *const MRSLAppShouldDisplayMenuBarNotification = @"MRSLAppShouldDisplayMenuBarNotification";
NSString *const MRSLAppShouldDisplayBaseViewControllerNotification = @"MRSLAppShouldDisplayBaseViewControllerNotification";
NSString *const MRSLAppShouldDisplayProfessionalSettingsNotification = @"MRSLAppShouldDisplayProfessionalSettingsNotification";
NSString *const MRSLAppShouldDisplayUserProfileNotification = @"MRSLAppShouldDisplayUserProfileNotification";
NSString *const MRSLAppShouldDisplayWebBrowserNotification = @"MRSLAppShouldDisplayWebBrowserNotification";
NSString *const MRSLAppShouldDisplayEmailComposerNotification = @"MRSLAppShouldDisplayEmailComposerNotification";
NSString *const MRSLAppShouldCallPhoneNumberNotification = @"MRSLAppShouldCallPhoneNumberNotification";

#pragma mark - Social Constants

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

NSString *const MRSLStoryboardiPhoneActivityKey = @"Activity_iPhone";
NSString *const MRSLStoryboardiPhoneFeedKey = @"Feed_iPhone";
NSString *const MRSLStoryboardiPhoneLoginKey = @"Login_iPhone";
NSString *const MRSLStoryboardiPhoneMainKey = @"Main_iPhone";
NSString *const MRSLStoryboardiPhoneMediaManagementKey = @"MediaManagement_iPhone";
NSString *const MRSLStoryboardiPhoneMorselManagementKey = @"MorselManagement_iPhone";
NSString *const MRSLStoryboardiPhonePlacesKey = @"Places_iPhone";
NSString *const MRSLStoryboardiPhoneProfileKey = @"Profile_iPhone";
NSString *const MRSLStoryboardiPhoneSettingsKey = @"Settings_iPhone";
NSString *const MRSLStoryboardiPhoneSocialKey = @"Social_iPhone";
NSString *const MRSLStoryboardiPhoneSpecsKey = @"Specs_iPhone";

#pragma mark - Storyboard Identifier Constants

NSString *const MRSLStoryboardActivityKey = @"sb_Activity";
NSString *const MRSLStoryboardCaptureMultipleMediaViewControllerKey = @"sb_MRSLCaptureMultipleMediaViewController";
NSString *const MRSLStoryboardCaptureSingleMediaViewControllerKey = @"sb_MRSLCaptureSingleMediaViewController";
NSString *const MRSLStoryboardCommentsKey = @"sb_Comments";
NSString *const MRSLStoryboardFeedKey = @"sb_Feed";
NSString *const MRSLStoryboardFeedPanelViewControllerKey = @"sb_MRSLFeedPanelViewController";
NSString *const MRSLStoryboardFindFriendsKey = @"sb_FindFriends";
NSString *const MRSLStoryboardFollowingPeopleKey = @"sb_FollowingPeople";
NSString *const MRSLStoryboardImagePreviewViewControllerKey = @"sb_MRSLImagePreviewViewController";
NSString *const MRSLStoryboardKeywordUsersViewControllerKey = @"sb_MRSLKeywordUsersViewController";
NSString *const MRSLStoryboardLikesKey = @"sb_Likes";
NSString *const MRSLStoryboardModalDescriptionViewControllerKey = @"sb_MRSLModalDescriptionViewController";
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
NSString *const MRSLStoryboardSocialComposeKey = @"sb_SocialCompose" ;
NSString *const MRSLStoryboardUserMorselsFeedViewControllerKey = @"sb_MRSLUserMorselsFeedViewController";
NSString *const MRSLStoryboardWebBrowserKey = @"sb_WebBrowser";

#pragma mark - Storyboard Segue Constants

NSString *const MRSLStoryboardSegueAccountSettingsKey = @"seg_AccountSettings";
NSString *const MRSLStoryboardSegueCuisinesKey = @"seg_Cuisines";
NSString *const MRSLStoryboardSegueDisplayImagePreviewKey = @"seg_DisplayImagePreview";
NSString *const MRSLStoryboardSegueDisplayLoginKey = @"seg_DisplayLogin";
NSString *const MRSLStoryboardSegueDisplaySignUpKey = @"seg_DisplaySignUp";
NSString *const MRSLStoryboardSegueEditItemTextKey = @"seg_EditItemText";
NSString *const MRSLStoryboardSegueEditMorselTitleKey = @"seg_EditMorselTitle";
NSString *const MRSLStoryboardSegueFollowListKey = @"seg_FollowList";
NSString *const MRSLStoryboardSegueProfessionalSettingsKey = @"seg_ProfessionalSettings";
NSString *const MRSLStoryboardSeguePublishMorselKey = @"seg_PublishMorsel";
NSString *const MRSLStoryboardSeguePublishShareMorselKey = @"seg_PublishShareMorsel";
NSString *const MRSLStoryboardSegueSelectPlaceKey = @"seg_SelectPlace";
NSString *const MRSLStoryboardSegueSetupProfessionalAccountKey = @"seg_SetupProfessionalAccount";
NSString *const MRSLStoryboardSegueSpecialtiesKey = @"seg_Specialties";

#pragma mark - Storyboard Reuse Identifier Constants

NSString *const MRSLStoryboardRUIDBasicInfoCellKey = @"ruid_BasicInfoCell";
NSString *const MRSLStoryboardRUIDCommentCellKey = @"ruid_CommentCell";
NSString *const MRSLStoryboardRUIDContactCellKey = @"ruid_ContactCell";
NSString *const MRSLStoryboardRUIDEmptyCellKey = @"ruid_EmptyCell";
NSString *const MRSLStoryboardRUIDFeedCoverCellKey = @"ruid_FeedCoverCell";
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
NSString *const MRSLStoryboardRUIDMediaItemCellKey = @"ruid_MediaItemCell";
NSString *const MRSLStoryboardRUIDMediaPreviewCellKey = @"ruid_MediaPreviewCell";
NSString *const MRSLStoryboardRUIDMenuOptionCellKey = @"ruid_MenuOptionCell";
NSString *const MRSLStoryboardRUIDMoreCharactersCellKey = @"ruid_MoreCharactersCell";
NSString *const MRSLStoryboardRUIDMorselCellKey = @"ruid_MorselCell";
NSString *const MRSLStoryboardRUIDMorselItemCellKey = @"ruid_MorselItemCell";
NSString *const MRSLStoryboardRUIDMorselPreviewCellKey = @"ruid_MorselPreviewCell";
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
NSString *const MRSLStoryboardRUIDUserLikedItemCellKey = @"ruid_UserLikedItemCell";

#pragma mark - Storyboard Source Identifiers
/*
    Reserved area to avoid warnings from StoryboardLint if identifiers are not included in Storyboard or IB files.
*/

NSString *const MRSLStoryboardRUIDSectionHeaderKey = @"srcuid_SectionHeader";

#pragma mark - Debugging Constants

#ifdef DEBUG
int LOG_LEVEL_DEF = LOG_LEVEL_DEBUG;
#else
int LOG_LEVEL_DEF = LOG_LEVEL_ERROR;
#endif

@implementation MRSLConstants

@end
