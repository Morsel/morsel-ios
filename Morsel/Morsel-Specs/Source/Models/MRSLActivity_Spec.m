//
//  MRSLActivity_Spec.m
//  Morsel
//
//  Created by Marty Trzpit on 3/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivity.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

#import "MRSLFactory+Activity.h"
#import "MRSLFactory+User.h"

SPEC_BEGIN(MRSLActivity_Spec)

describe(@"MRSLActivity", ^{
    beforeEach(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });

    afterEach(^{
        [MagicalRecord cleanUp];
    });

    __block MRSLActivity *activity;

    context(@"importing from JSON", ^{
        beforeEach(^{
            __block BOOL requestCompleted = NO;
            __block MRSLActivity *importedActivity = nil;
            [MRSLSpecUtil stubMorselAPIRequestsWithJSONFileName:@"mrsl-users-activities.json"
                                                 forRequestPath:@"/users/activities"];
            [_appDelegate.morselApiService getUserActivitiesForUser:nil
                                                              maxID:nil
                                                          orSinceID:nil
                                                           andCount:nil
                                                            success:^(NSArray *responseArray) {
                                                                NSNumber *firstActivityID = [responseArray firstObject];
                                                                importedActivity = [MRSLActivity MR_findFirstByAttribute:MRSLActivityAttributes.activityID
                                                                                                               withValue:firstActivityID];

                                                                requestCompleted = YES;
                                                            } failure:nil];
            [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
            activity = importedActivity;
        });

        it(@"should have an ID", ^{
            [[[activity activityID] should] equal:@4671917];
        });

        it(@"should have a creationDate", ^{
            [[[activity creationDate] should] beKindOfClass:[NSDate class]];
        });

        it(@"should have an actionType", ^{
            [[[activity actionType] should] equal:@"Like"];
        });

        describe(@"morsel", ^{
            let(morsel, ^id { return [activity morsel]; });

            it(@"should have an id", ^{
                [[[morsel morselID] should] equal:@402531];
            });

            it(@"should have a description", ^{
                [[[morsel morselDescription] should] equal:@"Voluptatem dolores beatae id labore ut corporis tempora id numquam in vel et nemo sed natus quos provident commodi quia quo officiis distinctio qui aut non iure nam illum reprehenderit debitis hic et esse molestiae nulla eaque excepturi quaerat eveniet nisi asperiores voluptate."];
            });

            it(@"should have a creation date", ^{
                [[[morsel creationDate] should] beNonNil];
            });

            it(@"should have photos", ^{
                [[[morsel morselPhotoURL] should] beNonNil];
            });
        });

        describe(@"creator", ^{
            let(creator, ^id { return [activity creator]; });

            it(@"should have an id", ^{
                [[[creator userID] should] equal:@8532];
            });

            it(@"should have a username", ^{
                [[[creator username] should] equal:@"turdferg"];
            });

            it(@"should have a first name", ^{
                [[[creator first_name] should] equal:@"Turd"];
            });

            it(@"should have a last name", ^{
                [[[creator last_name] should] equal:@"Ferguson"];
            });

            it(@"should have photos", ^{
                [[[creator profilePhotoURL] should] beNonNil];
            });
        });
    });
});

SPEC_END
