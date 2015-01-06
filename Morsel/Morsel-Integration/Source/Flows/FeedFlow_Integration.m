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
        [OHHTTPStubs removeAllStubs];
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });

    afterEach(^{
        [MagicalRecord cleanUp];
    });
    beforeAll(^{
        [tester navigateToLoginPage];
        [tester performLogIn];
    });
    afterAll(^{
        [tester returnToLoggedOutHomeScreen];
    });
});

SPEC_END
