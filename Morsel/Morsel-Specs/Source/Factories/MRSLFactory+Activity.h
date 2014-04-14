//
//  MRSLFactory+Activity.h
//  Morsel
//
//  Created by Marty Trzpit on 3/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFactory.h"

@class MRSLActivity;

@interface MRSLFactory (Activity)

+ (MRSLActivity *)activity;

+ (MRSLActivity *)itemLikeActivity;

@end
