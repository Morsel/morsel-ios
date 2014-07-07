//
//  MRSLDefines.h
//  Morsel
//
//  Created by Javier Otero on 12/17/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#pragma mark - Frameworks

#import <CocoaLumberjack/DDLog.h>
#import <Mixpanel/Mixpanel.h>
#import "Rollbar.h"

#pragma mark - Blocks

typedef void (^ MRSLSuccessBlock)(BOOL success);
typedef void (^ MRSLFailureBlock)(NSError *error);
typedef void (^ MRSLAPIArrayBlock)(NSArray *responseArray);
typedef void (^ MRSLAPILikeBlock)(BOOL doesLike);
typedef void (^ MRSLAPIFollowBlock)(BOOL doesFollow);
typedef void (^ MRSLAPISuccessBlock)(id responseObject);
typedef void (^ MRSLAPIExistsBlock)(BOOL exists, NSError *error);
typedef void (^ MRSLAPIValidationBlock)(BOOL isAvailable, NSError *error);
typedef void (^ MRSLImageProcessingBlock)(BOOL success);
typedef void (^ MRSLSocialSuccessBlock)(BOOL success);
typedef void (^ MRSLSocialFailureBlock)(NSError *error);
typedef void (^ MRSLSocialUserInfoBlock)(NSDictionary *userInfo, NSError *error);
typedef void (^ MRSLSocialUIDStringBlock)(NSString *uids, NSError *error);
typedef void (^ MRSLSocialCancelBlock)();
typedef void (^ MRSLDataURLResponseErrorBlock)(NSData *data, NSURLResponse *response, NSError *error);
typedef void (^ MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock)(NSArray *objectIDs, NSError *error);
typedef void (^ MRSLRemoteRequestBlock)(NSNumber *maxID, NSNumber *sinceID, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock);

#pragma mark - Enum

typedef NS_ENUM(NSUInteger, MRSLMorselStatusType) {
    MRSLMorselStatusTypeDrafts,
    MRSLMorselStatusTypePublished
};

typedef NS_ENUM (NSUInteger, MRSLScrollDirection) {
    MRSLScrollDirectionNone,
    MRSLScrollDirectionLeft,
    MRSLScrollDirectionRight,
    MRSLScrollDirectionUp,
    MRSLScrollDirectionDown
};

typedef NS_ENUM(NSUInteger, MRSLImageSizeType) {
    MRSLImageSizeTypeLarge,
    MRSLImageSizeTypeSmall,
    MRSLImageSizeTypeFull
};

typedef NS_ENUM(NSUInteger, MRSLSocialAlertViewType) {
    MRSLSocialAlertViewTypeFacebook = 1,
    MRSLSocialAlertViewTypeTwitter
};

typedef NS_ENUM(NSUInteger, MRSLSocialAccountType) {
    MRSLSocialAccountTypeFacebook = 1,
    MRSLSocialAccountTypeTwitter
};

typedef NS_ENUM(NSUInteger, MRSLDataSortType) {
    MRSLDataSortTypeCreationDate,
    MRSLDataSortTypeName,
    MRSLDataSortTypeLastName,
    MRSLDataSortTypeSortOrder,
    MRSLDataSortTypeLikedDate,
    MRSLDataSortTypeNone
};

typedef NS_ENUM(NSUInteger, MRSLDataSourceType) {
    MRSLDataSourceTypeMorsel,
    MRSLDataSourceTypePlace,
    MRSLDataSourceTypeTag,
    MRSLDataSourceTypeActivityItem,
    MRSLDataSourceTypeUser
};

typedef NS_ENUM(NSUInteger, MRSLStatusType) {
    MRSLStatusTypeNone,
    MRSLStatusTypeLoading,
    MRSLStatusTypeNoResults,
    MRSLStatusTypeMoreCharactersRequired
};

#pragma mark - Media Capture Values

// It is assumed the standard image to be passed through will be 5 MP (approx. 1920 x 2560 resolution).
// All calculations for captured image cropping, scaling, and centering will hinge on these numbers

static const CGFloat standardCameraDimensionPortraitMultiplier = 6.f;
static const CGFloat standardCameraDimensionLandscapeMultiplier = 4.f;
static const CGFloat minimumCameraMaxDimension = 1920.f;
static const CGFloat xCenteringLandscapeContent = 320.f;
static const CGFloat yCameraImagePreviewOffset = 78.f;
static const CGFloat croppedImageHeightOffset = 106.f;
static const CGFloat MRSLUserProfileImageLargeDimensionSize = 72.f;
static const CGFloat MRSLUserProfileImageThumbDimensionSize = 40.f;
static const CGFloat MRSLItemImageFullDimensionSize = 640.f;
static const CGFloat MRSLItemImageLargeDimensionSize = 320.f;
static const CGFloat MRSLItemImageThumbDimensionSize = 50.f;
static const CGFloat MRSLProfileThumbDimensionThreshold = 90.f;
static const int MRSLMaximumMorselsToDisplayInMorselAdd = 5;
static const int MRSLMaximumMorselsToDisplayInMorselPreview = 12;
static const int MRSLStatsTagViewTag = 9991;

#pragma mark - Build Specific

#if defined(MORSEL_ALPHA)
#define MIXPANEL_TOKEN @"41dd2e748949236fef948e1fab8c22fb"
#define ROLLBAR_ENVIRONMENT @"alpha"
#elif defined(MORSEL_BETA)
#define MIXPANEL_TOKEN @"f3c03a3b048ff1779730a445d63ac2de"
#define ROLLBAR_ENVIRONMENT @"beta"
#elif defined(RELEASE)
#define MIXPANEL_TOKEN @"f3c03a3b048ff1779730a445d63ac2de"
#define ROLLBAR_ENVIRONMENT @"production"
#else
#define MIXPANEL_TOKEN @"fc91c2a6f8d8388f077f6b9618e90499"
#define ROLLBAR_ENVIRONMENT @"debug"
#endif

#define ROLLBAR_ACCESS_TOKEN @"80ee8af968f646898f1c1a6d6253b347"
#define ROLLBAR_VERSION @"v0.1.2"

#pragma mark - Defines

#if defined (SPEC_TESTING) || defined (INTEGRATION_TESTING)

#define MORSEL_API_BASE_URL @"DUMMY_BASE_URL"

#elif (defined(MORSEL_BETA) || defined(RELEASE))

#define MORSEL_API_BASE_URL @"https://api.eatmorsel.com"
#define MORSEL_BASE_URL @"http://www.eatmorsel.com"

#else

#define MORSEL_API_BASE_URL @"http://api-staging.eatmorsel.com"
#define MORSEL_BASE_URL @"http://staging.eatmorsel.com"

#endif

#define MORSEL_SUPPORT_EMAIL @"Morsel Support <support@eatmorsel.com>"

#define TWITTER_BASE_URL @"https://www.twitter.com"

#ifdef SPEC_TESTING
#import "MRSLSpecsAppDelegate.h"
    #define _appDelegate ((MRSLSpecsAppDelegate *)[[UIApplication sharedApplication] delegate])
#else
#import "MRSLAppDelegate.h"
    #define _appDelegate ((MRSLAppDelegate *)[[UIApplication sharedApplication] delegate])
#endif

#pragma mark - Macros

#define CASE(str)                       if ([__s__ isEqualToString:(str)])
#define SWITCH(s)                       for (NSString *__s__ = (s); ; )
#define DEFAULT
#define NSNullIfNil(obj) ((obj == nil) ? [NSNull null] : obj)
#define MRSLIsNull(obj) ([obj isEqual:[NSNull null]])

#pragma mark - Social

#if (defined(MORSEL_BETA) || defined(RELEASE))

#define FACEBOOK_APP_ID @"1402286360015732"
#define FACEBOOK_PUBLISH_AUDIENCE FBSessionDefaultAudienceFriends

#define TWITTER_CONSUMER_KEY @"ETEvZdAoQ4pzi1boCxdZoA"
#define TWITTER_CONSUMER_SECRET @"0CBD7gMuymBSBCqpy8G7uuLwyD7peyeUetAQZhUqu0"
#define TWITTER_CALLBACK @"tw-morsel://success"

#define INSTAGRAM_CONSUMER_KEY @"39d91666b98c41cfa69e14d70794a09b"
#define INSTAGRAM_CONSUMER_SECRET @"0887a6cfbea54cdea71ad7b7b3dc1a29"
#define INSTAGRAM_CALLBACK @"insta-morsel://success"

#else

#define FACEBOOK_APP_ID @"1406459019603393"
#define FACEBOOK_PUBLISH_AUDIENCE FBSessionDefaultAudienceOnlyMe

#define TWITTER_CONSUMER_KEY @"OWJtM9wGQSSdMctOI0gHkQ"
#define TWITTER_CONSUMER_SECRET @"21EsTV2n8QjBUGZPfYx5JPKnxjicxboV0IHflBZB6w"
#define TWITTER_CALLBACK @"tw-morsel-staging://success"

#define INSTAGRAM_CONSUMER_KEY @"2a431459c80145edb6608eaafddfb8ed"
#define INSTAGRAM_CONSUMER_SECRET @"29edc5d19e8f4a3eac53d8e9a0c101e1"
#define INSTAGRAM_CALLBACK @"insta-morsel-staging://success"

#endif

#pragma mark - Services

#import "MRSLAPIService.h"

#pragma mark - Events

#import "MRSLEventManager.h"

#pragma mark - General

#import "MRSLConstants.h"
#import "MRSLUtil.h"
#import "MRSLBaseViewController.h"

#pragma mark - Data

#import "CoreData+MagicalRecord.h"

#pragma mark - Categories

#import "UIAlertView+Additions.h"
#import "UIColor+Morsel.h"
#import "UIDevice+Additions.h"
#import "UIFont+Morsel.h"
#import "UIImage+Resize.h"
#import "NSMutableString+Additions.h"
#import "NSString+Additions.h"
#import "UIStoryboard+Morsel.h"
#import "UIView+Additions.h"