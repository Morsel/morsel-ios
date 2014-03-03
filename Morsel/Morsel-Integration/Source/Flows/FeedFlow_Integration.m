//
//  FeedFlow_Integration.m
//  Morsel
//
//  Created by Javier Otero on 2/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "KIFUITestActor+Additions.h"

#warning Use mock data

KIF_SPEC_BEGIN(FeedFlowIntegration)

describe(@"The feed", ^{
    beforeAll(^{
        [tester navigateToLoginPage];
        [tester performLogIn];
    });
    afterAll(^{
        [tester returnToLoggedOutHomeScreen];
    });
    context(@"when user taps a morsel", ^{
        beforeAll(^{
            [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Loading"];
            [tester tapViewWithAccessibilityLabel:@"Feed"];
        });
        it(@"should display morsel detail", ^{
            [tester waitForViewWithAccessibilityLabel:@"Morsel Detail"];
        });
        context(@"then user returns to feed and taps same morsel", ^{
            beforeAll(^{
                [tester tapViewWithAccessibilityLabel:@"Back"];
                [tester waitForViewWithAccessibilityLabel:@"Feed"];
                [tester tapViewWithAccessibilityLabel:@"Feed"];
            });
            afterAll(^{
                [tester tapViewWithAccessibilityLabel:@"Back"];
            });
            it(@"should display morsel detail", ^{
                [tester waitForViewWithAccessibilityLabel:@"Morsel Detail"];
            });
            it(@"should have title", ^{
                [tester waitForViewWithAccessibilityLabel:@"Story Title"];
            });
        });
    });
});

KIF_SPEC_END
