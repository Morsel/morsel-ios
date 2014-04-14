//
//  MRSLFactory+Activity.m
//  Morsel
//
//  Created by Marty Trzpit on 3/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFactory+Activity.h"
#import "MRSLFactory+Item.h"

#import "MRSLActivity.h"

@implementation MRSLFactory (Activity)

+ (MRSLActivity *)activity {
    MRSLActivity *activity = [[MRSLActivity alloc] init];

    return activity;
}

+ (MRSLActivity *)itemLikeActivity {
    MRSLActivity *activity = [MRSLFactory activity];

    [activity setItem:[MRSLFactory item]];
    [activity setActionType:@"Like"];

    return activity;
}

@end
