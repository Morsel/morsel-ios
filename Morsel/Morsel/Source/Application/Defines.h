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
typedef void (^ MorselAPIArrayBlock)(NSArray *responseArray);
typedef void (^ MorselAPILikeBlock)(BOOL doesLike);
typedef void (^ MorselAPISuccessBlock)(id responseObject);
typedef void (^ MorselAPIFailureBlock)(NSError *error);

static const int minimumCameraMaxDimension = 1920.f;
static const int yPreviewOffset = 52.f;
static const int croppedHeightOffset = 106.f;