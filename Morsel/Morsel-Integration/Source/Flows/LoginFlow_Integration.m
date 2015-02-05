//
//  LoginFlow_Integration.m
//
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Item. All rights reserved.
//

#import "KIFUITestActor+Additions.h"

SPEC_BEGIN(LoginFlowIntegration)

describe(@"The login flow", ^{
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
    context(@"when a correct login", ^{
        beforeEach(^{
            [tester performLogIn];
        });
        it(@"should login and display feed", ^{
            [tester waitForViewWithAccessibilityLabel:@"Feed"];
        });
    });
});

SPEC_END