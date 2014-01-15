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
typedef void (^ MorselAPISuccessBlock)(id responseObject);
typedef void (^ MorselAPIFailureBlock)(NSError *error);

/*
 
// Unable to define due to MagicalRecord.h extern conflict
 
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif
 
*/