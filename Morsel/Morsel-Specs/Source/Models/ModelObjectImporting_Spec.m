//
//  ModelObjectImporting_Spec.m
//  Morsel
//
//  Created by Javier Otero on 2/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

SPEC_BEGIN(ModelObjectImporting_Spec)

describe(@"Importing from the API", ^{
    beforeEach(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });

    afterEach(^{
        [MagicalRecord cleanUp];
    });

    describe(@"MRSLMorsel", ^{
        let(morsel, ^id{
            MRSLMorsel *_morsel = [MRSLMorsel MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            [_morsel setMorselID:@2];
            return _morsel;
        });

        beforeEach(^{
            __block BOOL requestCompleted = NO;
            [MRSLSpecUtil stubMorselAPIRequestsWithJSONFileName:@"mrsl-morsel-authenticated.json"
                                                 forRequestPath:@"/morsels/2"];

            [_appDelegate.morselApiService getMorsel:morsel
                                             success:^(id responseObject) {
                                                 requestCompleted = YES;
                                             } failure:nil];

            [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
        });

        it(@"has id of 2", ^{
            [[[morsel morselID] should] equal:@2];
        });

        it(@"has morselDescription 'This dish is crazy awesome!'", ^{
            [[[morsel morselDescription] should] equal:@"This dish is crazy awesome!"];
        });

        it(@"has creationDate that is of kind NSDate", ^{
            [[[morsel creationDate] should] beKindOfClass:[NSDate class]];
        });

        it(@"has morselPhotoURL", ^{
            [[[morsel morselPhotoURL] should] equal:@"https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/IMAGE_SIZE_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"];
        });

        it(@"has liked value", ^{
            [[[morsel liked] should] beFalse];
        });

        it(@"has url", ^{
            [[[morsel url] should] equal:@"http://eatmorsel.com/marty/1-butter/1"];
        });

        context(@"has comments", ^{
            let(morselWithComments, ^id{
                MRSLMorsel *_morselWithComments = [MRSLMorsel MR_createEntity];
                [_morselWithComments setMorselID:@40];
                return _morselWithComments;
            });
            let(comment, nil);

            beforeEach(^{
                __block BOOL requestCompleted = NO;
                __block MRSLComment *firstComment = nil;
                [MRSLSpecUtil stubMorselAPIRequestsWithJSONFileName:@"mrsl-comment.json"
                                                     forRequestPath:@"/morsels/40/comments"];

                [_appDelegate.morselApiService getComments:morselWithComments
                                                   success:^(NSArray *responseArray) {
                                                       firstComment = [[[morselWithComments comments] allObjects] firstObject];
                                                       requestCompleted = YES;
                                                   } failure:nil];

                [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
                comment = firstComment;
            });
            it(@"should have a valid comment", ^{
                [[@([[morselWithComments comments] count]) should] equal:@1];
                [[[comment commentID] should] equal:@4];
                [[[comment commentDescription] should] equal:@"Wow! Are those Swedish Fish caviar???!?!?!one!?!11!?1?!"];
                [[[comment creator] should] beNonNil];
                [[[comment creationDate] should] beKindOfClass:[NSDate class]];
            });
        });
    });

    describe(@"MRSLPost", ^{
        let(post, ^id{
            MRSLPost *existingPost = [MRSLPost MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            [existingPost setPostID:@1];
            return existingPost;
        });

        beforeEach(^{
            __block BOOL requestCompleted = NO;
            [MRSLSpecUtil stubMorselAPIRequestsWithJSONFileName:@"mrsl-post.json"
                                                 forRequestPath:@"/posts/1"];

            [_appDelegate.morselApiService getPost:post
                                           success:^(id responseObject) {
                                               requestCompleted = YES;
                                           } failure:nil];

            [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
        });

        it(@"has creator", ^{
            [[[post creator] should] beNonNil];
        });

        it(@"has id of 1", ^{
            [[theValue([post postIDValue]) should] equal:theValue(1)];
        });

        it(@"has title 'Butter Rocks!'", ^{
            [[[post title] should] equal:@"Butter Rocks!"];
        });

        it(@"has creationDate that is of kind NSDate", ^{
            [[[post creationDate] should] beKindOfClass:[NSDate class]];
        });

        it(@"has one morsel", ^{
            [[theValue([[post morsels] count]) should] equal:theValue(1)];
        });
    });

    describe(@"MRSLUser", ^{
        let(currentUser, nil);

        beforeEach(^{
            __block BOOL requestCompleted = NO;
            [MRSLSpecUtil stubMorselAPIRequestsWithJSONFileName:@"mrsl-user-with-auth-token.json"
                                                 forRequestPath:@"/users/sign_in"];

            [_appDelegate.morselApiService signInUserWithEmail:nil
                                                   andPassword:nil
                                                       success:^(id responseObject) {
                                                           requestCompleted = YES;
                                                       } failure:nil];

            [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
            currentUser = [MRSLUser currentUser];
        });

        it(@"has id of 3", ^{
            [[[currentUser userID] should] equal:@3];
        });

        it(@"has username 'turdferg'", ^{
            [[[currentUser username] should] equal:@"turdferg"];
        });

        it(@"has first_name 'Turd'", ^{
            [[[currentUser first_name] should] equal:@"Turd"];
        });

        it(@"has last_name 'Ferguson'", ^{
            [[[currentUser last_name] should] equal:@"Ferguson"];
        });

        it(@"has creationDate that is kind NSDate", ^{
            [[[currentUser creationDate] should] beKindOfClass:[NSDate class]];
        });

        it(@"has title 'Executive Chef at Jeopardy'", ^{
            [[[currentUser title] should] equal:@"Executive Chef at Jeopardy"];
        });

        it(@"has bio 'Suck It, Trebek'", ^{
            [[[currentUser bio] should] equal:@"Suck It, Trebek"];
        });

        it(@"has profilePhotoURL", ^{
            [[[currentUser profilePhotoURL] should] equal:@"https://morsel-staging.s3.amazonaws.com/user-images/user/3/IMAGE_SIZE_1389119757-batman.jpeg"];
        });

        it(@"has auth_token 'butt-sack'", ^{
            [[[currentUser auth_token] should] equal:@"butt-sack"];
        });

        it(@"has draft_count of 10", ^{
            [[[currentUser draft_count] should] equal:@10];
        });

        it(@"has like_count of 3", ^{
            [[[currentUser like_count] should] equal:@3];
        });

        it(@"has morsel_count of 1", ^{
            [[[currentUser morsel_count] should] equal:@1];
        });
    });
});

SPEC_END
