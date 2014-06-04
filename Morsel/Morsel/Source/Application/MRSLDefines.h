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

typedef NS_ENUM(NSUInteger, MRSLProfileImageSizeType) {
    MRSLProfileImageSizeTypeSmall,
    MRSLProfileImageSizeTypeMedium
};

typedef NS_ENUM(NSUInteger, MRSLItemImageSizeType) {
    MRSLItemImageSizeTypeLarge,
    MRSLItemImageSizeTypeThumbnail,
    MRSLItemImageSizeTypeFull
};

typedef NS_ENUM(NSUInteger, MRSLIndustryType) {
    MRSLIndustryTypeChef,
    MRSLIndustryTypeMedia,
    MRSLIndustryTypeDiner
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
    MRSLDataSortTypeSortOrder
};

typedef NS_ENUM(NSUInteger, MRSLDataSourceType) {
    MRSLDataSourceTypeMorsel,
    MRSLDataSourceTypePlace,
    MRSLDataSourceTypeTag,
    MRSLDataSourceTypeActivityItem,
    MRSLDataSourceTypeUser
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
static const int MRSLMaximumMorselsToDisplayInMorselAdd = 5;
static const int MRSLMaximumMorselsToDisplayInMorselPreview = 12;
static const int MRSLStatsTagViewTag = 9991;

#pragma mark - Build Specific

#if defined(MORSEL_ALPHA)
#define TESTFLIGHT_APP_TOKEN @"5d37b39e-9417-4e2d-9401-05afbeabbc74"
#define MIXPANEL_TOKEN @"41dd2e748949236fef948e1fab8c22fb"
#elif defined(MORSEL_BETA)
#define TESTFLIGHT_APP_TOKEN @"2965a315-a1b2-4fee-a287-f9722a75ad87"
#define MIXPANEL_TOKEN @"f3c03a3b048ff1779730a445d63ac2de"
#elif defined(RELEASE)
#define TESTFLIGHT_APP_TOKEN @"1e7bb15e-fd13-4dd1-bd2e-0aa617af22ae"
#define MIXPANEL_TOKEN @"f3c03a3b048ff1779730a445d63ac2de"
#else
#define TESTFLIGHT_APP_TOKEN @"872ef690-a80c-4b91-beb2-0d383bc19150"
#define MIXPANEL_TOKEN @"fc91c2a6f8d8388f077f6b9618e90499"
#endif

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

#define TWITTER_BASE_URL @"https://www.twitter.com"

#ifdef SPEC_TESTING
#import "MRSLSpecsAppDelegate.h"
    #define _appDelegate ((MRSLSpecsAppDelegate *)[[UIApplication sharedApplication] delegate])
#else
#import "MRSLAppDelegate.h"
    #define _appDelegate ((MRSLAppDelegate *)[[UIApplication sharedApplication] delegate])
#endif

#define NSNullIfNil(obj) ((obj == nil) ? [NSNull null] : obj)
#define MRSLIsNull(obj) ([obj isEqual:[NSNull null]])

#pragma mark - Services

#import "MRSLAPIClient.h"
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
#import "UIStoryboard+Morsel.h"
#import "UIView+Additions.h"