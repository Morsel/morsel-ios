//
//  MRSLFactory+Morsel.m
//  Morsel
//
//  Created by Marty Trzpit on 3/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFactory+Morsel.h"
#import "MRSLMorsel.h"

@implementation MRSLFactory (Morsel)

+ (MRSLMorsel *)morsel {
    MRSLMorsel *morsel = [[MRSLMorsel alloc] init];
    return morsel;
}

@end
