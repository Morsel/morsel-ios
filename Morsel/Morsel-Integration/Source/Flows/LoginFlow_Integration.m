//
//  LoginFlow_Integration.m
//
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Item. All rights reserved.
//

#import "KIFUITestActor+Additions.h"

KIF_SPEC_BEGIN(LoginFlowIntegration)

describe(@"The login flow", ^{
    beforeEach(^{
        [tester navigateToLoginPage];
    });
    afterEach(^{
        [tester returnToLoggedOutHomeScreen];
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

KIF_SPEC_END