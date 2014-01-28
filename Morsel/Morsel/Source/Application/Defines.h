//
//  Defines.h
//  Morsel
//
//  Created by Javier Otero on 12/17/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <CocoaLumberjack/DDLog.h>

#import "Constants.h"
#import "CoreData+MagicalRecord.h"
#import "Util.h"

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

// It is assumed the standard image to be passed through will be 5 MP (approx. 1920 x 2560 resolution).
// All calculations for captured image cropping, scaling, and centering will hinge on these numbers

static const int standardCameraDimensionPortraitMultiplier = 6.f;
static const int standardCameraDimensionLandscapeMultiplier = 4.f;
static const int minimumCameraMaxDimension = 1920.f;
static const int xCenteringLandscapeContent = 320.f;
static const int yCameraImagePreviewOffset = 78.f;
static const int croppedImageHeightOffset = 106.f;