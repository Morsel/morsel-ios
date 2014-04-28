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

typedef void (^ MRSLDataSuccessBlock)(BOOL success);
typedef void (^ MRSLAPIArrayBlock)(NSArray *responseArray);
typedef void (^ MRSLAPILikeBlock)(BOOL doesLike);
typedef void (^ MRSLAPIFollowBlock)(BOOL doesFollow);
typedef void (^ MRSLAPISuccessBlock)(id responseObject);
typedef void (^ MRSLAPIFailureBlock)(NSError *error);
typedef void (^ MRSLSocialSuccessBlock)(BOOL success);
typedef void (^ MRSLSocialFailureBlock)(NSError *error);
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

#else

#define MORSEL_API_BASE_URL @"http://api-staging.eatmorsel.com"

#endif

#ifdef SPEC_TESTING
#import "MRSLSpecsAppDelegate.h"
    #define _appDelegate ((MRSLSpecsAppDelegate *)[[UIApplication sharedApplication] delegate])
#else
#import "MRSLAppDelegate.h"
    #define _appDelegate ((MRSLAppDelegate *)[[UIApplication sharedApplication] delegate])
#endif

#define NSNullIfNil(obj) ((obj == nil) ? [NSNull null] : obj)
#define MRSLIsNull(obj) ([obj isEqual:[NSNull null]])

#pragma mark - Imports

#import "MRSLConstants.h"
#import "MRSLUtil.h"
#import "MRSLAPIService.h"
#import "MRSLEventManager.h"
#import "MRSLBaseViewController.h"

#import "CoreData+MagicalRecord.h"

#import "UIAlertView+Additions.h"
#import "UIColor+Morsel.h"
#import "UIDevice+Additions.h"
#import "UIFont+Morsel.h"
#import "UIImage+Resize.h"
#import "UIStoryboard+Morsel.h"
#import "UIView+Additions.h"