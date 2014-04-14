//
//  MRSLCustomURLScheme_Spec.m
//  Morsel
//
//  Created by Marty Trzpit on 4/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

SPEC_BEGIN(MRSLCustomURLScheme_Spec)

describe(@"Item Custom URL Schemes", ^{
    beforeEach(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });

    afterEach(^{
        [MagicalRecord cleanUp];
    });

    __block id viewController;
    describe(@"item://users/:user_id", ^{
        let(customURL, ^id{
            return @"item://users/123";
        });
        beforeEach(^{
            __block BOOL requestCompleted = NO;
            __block id localViewController = nil;

            id rootVC = _appDelegate.window.rootViewController;
            [rootVC stub:@selector(presentViewController:animated:completion:) withBlock:^id(NSArray *params) {
                id navigationControllerToPresent = params[0];
                localViewController = [navigationControllerToPresent topViewController];
                requestCompleted = YES;
                return nil;
            }];

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:customURL]];

            [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
            viewController = localViewController;
        });

        describe(@"pushed Profile Page", ^{
            it(@"should be a MRSLProfileViewController", ^{
                [[theValue([viewController isKindOfClass:NSClassFromString(@"MRSLProfileViewController")]) should] beTrue];
            });

            it(@"should have a valid User", ^{
                [[[viewController user] should] beNonNil];
            });
        });
    });
});

SPEC_END
