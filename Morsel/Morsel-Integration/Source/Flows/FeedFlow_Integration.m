//
//  FeedFlow_Integration.m
//  Morsel
//
//  Created by Javier Otero on 2/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "KIFUITestActor+Additions.h"

KIF_SPEC_BEGIN(FeedFlowIntegration)

describe(@"The feed", ^{
    beforeAll(^{
        [tester navigateToLoginPage];
        [tester performLogIn];
    });
    afterAll(^{
        [tester returnToLoggedOutHomeScreen];
    });
});

KIF_SPEC_END
