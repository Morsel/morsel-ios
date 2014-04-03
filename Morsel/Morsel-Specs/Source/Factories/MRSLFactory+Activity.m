//
//  MRSLFactory+Activity.m
//  Morsel
//
//  Created by Marty Trzpit on 3/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFactory+Activity.h"
#import "MRSLFactory+Morsel.h"

#import "MRSLActivity.h"

@implementation MRSLFactory (Activity)

+ (MRSLActivity *)activity {
    MRSLActivity *activity = [[MRSLActivity alloc] init];

    return activity;
}

+ (MRSLActivity *)morselLikeActivity {
    MRSLActivity *activity = [MRSLFactory activity];

    [activity setMorsel:[MRSLFactory morsel]];
    [activity setActionType:@"Like"];

    return activity;
}

@end
