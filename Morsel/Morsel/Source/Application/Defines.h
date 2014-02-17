//
//  Defines.h
//  Morsel
//
//  Created by Javier Otero on 12/17/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#pragma mark - Frameworks

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <CocoaLumberjack/DDLog.h>
#import <Mixpanel/Mixpanel.h>

#pragma mark - Blocks

typedef void (^ MorselImageDownloadSuccessBlock)(UIImage *image);
typedef void (^ MorselImageDownloadFailureBlock)(NSError *error);
typedef void (^ MorselModelSuccessBlock)(NSNumber *objectID);
typedef void (^ MorselModelFailureBlock)(NSError *error);
typedef void (^ MorselDataSuccessBlock)(BOOL success);
typedef void (^ MorselDataFailureBlock)(NSError *error);
typedef void (^ MorselAPIArrayBlock)(NSArray *responseArray);
typedef void (^ MorselAPILikeBlock)(BOOL doesLike);
typedef void (^ MorselAPISuccessBlock)(id responseObject);
typedef void (^ MorselAPIFailureBlock)(NSError *error);
typedef void (^ MorselDataURLResponseErrorBlock)(NSData *data, NSURLResponse *response, NSError *error);

#pragma mark - Media Capture Values

// It is assumed the standard image to be passed through will be 5 MP (approx. 1920 x 2560 resolution).
// All calculations for captured image cropping, scaling, and centering will hinge on these numbers

static const int standardCameraDimensionPortraitMultiplier = 6.f;
static const int standardCameraDimensionLandscapeMultiplier = 4.f;
static const int minimumCameraMaxDimension = 1920.f;
static const int xCenteringLandscapeContent = 320.f;
static const int yCameraImagePreviewOffset = 78.f;
static const int croppedImageHeightOffset = 106.f;

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

#define _appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define NULLIFNIL(obj) ((obj == nil) ? [NSNull null] : obj)

#pragma mark - Imports

#import "AppDelegate.h"
#import "Constants.h"
#import "CoreData+MagicalRecord.h"
#import "Util.h"
#import "MorselAPIService.h"
#import "MRSLEventManager.h"

#import "UIAlertView+Additions.h"
#import "UIColor+Morsel.h"
#import "UIFont+Morsel.h"
#import "UIImage+Resize.h"
#import "UIStoryboard+Morsel.h"
#import "UIView+Additions.h"