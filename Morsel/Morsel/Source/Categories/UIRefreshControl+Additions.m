//
//  UIRefreshControl+Additions.m
//  Morsel
//
//  Created by Marty Trzpit on 7/16/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIRefreshControl+Additions.h"

@implementation UIRefreshControl (Additions)

+ (instancetype)MRSL_refreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];

    [refreshControl setTintColor:[UIColor morselPrimaryDark]];

    return refreshControl;
}

@end
