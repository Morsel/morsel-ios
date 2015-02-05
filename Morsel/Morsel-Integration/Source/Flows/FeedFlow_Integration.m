//
//  FeedFlow_Integration.m
//  Morsel
//
//  Created by Javier Otero on 2/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "KIFUITestActor+Additions.h"

SPEC_BEGIN(FeedFlowIntegration)

describe(@"The feed", ^{
    beforeEach(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
        [tester navigateToLoginPage];
    });
    afterEach(^{
        [tester returnToLoggedOutHomeScreen];
    });
    afterAll(^{
        [MRSLVCRManager saveVCR];
        [tester waitForTimeInterval:MRSL_ACTOR_DEFAULT_WAIT];
    });
});

SPEC_END
