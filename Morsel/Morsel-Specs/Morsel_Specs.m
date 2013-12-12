//
//  Morsel_Specs.m
//  Morsel-Specs
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <Kiwi/Kiwi.h>

SPEC_BEGIN(TestSpec)

describe(@"Kiwi", ^{
    it(@"should work", ^{
        [[@YES should] beTrue];
    });
});

SPEC_END
