//
//  CollectionFlow_Integration.m
//  Morsel
//
//  Created by Javier Otero on 2/3/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "KIFUITestActor+Additions.h"

SPEC_BEGIN(CollectionFlowIntegration)

describe(@"The collection flow", ^{
    beforeAll(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
        [tester navigateToLoginPage];
        [tester performLogIn];
    });
    afterAll(^{
        [tester returnToLoggedOutHomeScreen];
        [MRSLVCRManager saveVCR];
        [tester waitForTimeInterval:MRSL_ACTOR_DEFAULT_WAIT];
    });

    context(@"when navigating to current user profile", ^{
        beforeAll(^{
            [tester navigateToCurrentUserProfile];
        });
        it(@"should display collections tab", ^{
            [tester waitForViewWithAccessibilityLabel:@"Collections"];
        });
    });

    context(@"when navigating to collections tab of current user", ^{
        it(@"should display add a collection", ^{
            [tester waitForTimeInterval:MRSL_ACTOR_DEFAULT_WAIT];
            [tester waitAndTapViewWithAccessibilityLabel:@"Collections"];
            [tester waitForViewWithAccessibilityLabel:@"Add a collection"];
        });
    });

    context(@"when selecting add a collection from current user's profile", ^{
        it(@"should display create collection view", ^{
            [tester waitAndTapViewWithAccessibilityLabel:@"Add a collection"];
            [tester waitForViewWithAccessibilityLabel:@"Create collection"];
            [tester waitAndTapViewWithAccessibilityLabel:@"Back"];
        });
    });

    context(@"when adding a collection", ^{
        context(@"when entering valid title and description", ^{
            it(@"should create collection", ^{
                [tester waitAndTapViewWithAccessibilityLabel:@"Add a collection"];
                [tester waitForViewWithAccessibilityLabel:@"Create collection"];
                [tester enterText:@"My collection" intoViewWithAccessibilityLabel:@"Give your collection a title"];
                [tester enterText:@"The description of my collection." intoViewWithAccessibilityLabel:@"Give your collection a description"];
                [tester waitAndTapViewWithAccessibilityLabel:@"Create"];
                [tester waitForViewWithAccessibilityLabel:@"javierotero"];
            });
            context(@"when returning to profile the new collection", ^{
                it(@"should have title", ^{
                    [tester waitForViewWithAccessibilityLabel:@"javierotero"];
                    [tester waitForTimeInterval:MRSL_ACTOR_DEFAULT_WAIT];
                    [tester tapItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] inCollectionViewWithAccessibilityIdentifier:@"BaseRemoteCollectionView"];
                    [tester waitForViewWithAccessibilityLabel:@"My collection"];
                    [tester waitAndTapViewWithAccessibilityLabel:@"Back"];
                });
            });
        });
        context(@"when entering invalid title", ^{
            it(@"should display error", ^{
                [tester tapItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1] inCollectionViewWithAccessibilityIdentifier:@"BaseRemoteCollectionView"];
                [tester waitForViewWithAccessibilityLabel:@"Create collection"];
                [tester enterText:@"" intoViewWithAccessibilityLabel:@"Give your collection a title"];
                [tester waitAndTapViewWithAccessibilityLabel:@"Create"];
                [tester waitForViewWithAccessibilityLabel:@"Invalid Title"];
                [tester waitAndTapViewWithAccessibilityLabel:@"Close"];
                [tester waitAndTapViewWithAccessibilityLabel:@"Back"];
            });
        });
    });

    context(@"when selecting a collection from current user's profile", ^{
        pending(@"should display collection detail view", ^{

        });
        pending(@"should display the description of the collection", ^{

        });
        pending(@"should display no morsels", ^{

        });
    });

    context(@"when navigating to the feed", ^{
        pending(@"should display add to collection icon", ^{

        });
        pending(@"should display add to collection in action sheet", ^{

        });
        context(@"when tapping add to collection icon", ^{
            pending(@"should display add to collection view", ^{

            });
            pending(@"should display 1 collection", ^{

            });
            context(@"when tapping add icon", ^{
                pending(@"should display create collection view", ^{

                });
                context(@"when tapping create", ^{
                    pending(@"should create the collection and display the feed", ^{

                    });
                });
            });
        });
    });

    context(@"when adding a morsel to a collection", ^{
        pending(@"should be able to add to multiple collections", ^{

        });
    });

    context(@"when navigating to user samusaran", ^{
        pending(@"should not display edit controls in collection detail", ^{

        });
    });

    context(@"when navigating to a collection belonging to current user", ^{
        pending(@"should display 2 morsels", ^{

        });
        context(@"when deleting 2 morsels", ^{
            pending(@"should display no morsels", ^{

            });
        });
        context(@"when selecting bottom right icon", ^{
            pending(@"should display actionsheet with edit option", ^{

            });
            pending(@"should display actionsheet with delete option", ^{

            });
            pending(@"should display actionsheet with cancel option", ^{
                
            });
            context(@"when selecting edit option", ^{
                pending(@"should display create collection view", ^{
                    
                });
                pending(@"should display save instead of edit in top right", ^{
                    
                });
            });
            context(@"when selecting delete option", ^{
                pending(@"should delete collection and display profile view", ^{
                    
                });
            });
        });
    });
});

SPEC_END
