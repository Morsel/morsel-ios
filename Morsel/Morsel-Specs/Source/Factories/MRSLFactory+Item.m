//
//  MRSLFactory+Item.m
//  Morsel
//
//  Created by Marty Trzpit on 3/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFactory+Item.h"
#import "MRSLItem.h"

@implementation MRSLFactory (Item)

+ (MRSLItem *)item {
    MRSLItem *item = [[MRSLItem alloc] init];
    return item;
}

@end
