//
//  Defines.h
//  Morsel
//
//  Created by Javier Otero on 12/17/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

//#import <CocoaLumberjack/DDLog.h>

#import "Constants.h"
#import "CoreData+MagicalRecord.h"

typedef void (^ MorselAPISuccessBlock)(id responseObject);
typedef void (^ MorselAPIFailureBlock)(NSError *error);

/*
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif
*/