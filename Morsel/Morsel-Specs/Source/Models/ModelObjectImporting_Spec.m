//
//  ModelObjectImporting_Spec.m
//  Morsel
//
//  Created by Javier Otero on 2/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "MRSLComment.h"
#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

SPEC_BEGIN(ModelObjectImporting_Spec)

describe(@"Importing from the API", ^{
    describe(@"MRSLMorsel", ^{
        __block MRSLMorsel *morsel = [MRSLMorsel MR_createEntity];
        morsel.morselID = @2;

        beforeAll(^{
            MRSLPost *morselPost = [MRSLPost MR_createEntity];
            morselPost.postID = @40;
            morselPost.title = @"GET DOWN";
            
            [MRSLSpecUtil stubMorselAPIRequestsWithJSONFileName:@"mrsl-morsel-authenticated.json"
                                                 forRequestPath:@"/morsels/2"];
            [_appDelegate.morselApiService getMorsel:morsel
                                             success:nil
                                             failure:nil];
        });
        it(@"has id of 2", ^{
            [[expectFutureValue(theValue([morsel morselIDValue])) shouldEventually] equal:theValue(2)];
        });
        it(@"has morselDescription 'This dish is crazy awesome!'", ^{
            [[[morsel morselDescription] shouldEventually] equal:@"This dish is crazy awesome!"];
        });
        it(@"has creationDate that is of kind NSDate", ^{
            [[[morsel creationDate] shouldEventually] beKindOfClass:[NSDate class]];
        });
        it(@"has morselPhotoURL", ^{
            [[[morsel morselPhotoURL] shouldEventually] equal:@"https://morsel-staging.s3.amazonaws.com/morsel-images/morsel/2/IMAGE_SIZE_1389112483-morsel.png"];
        });
        it(@"has liked value", ^{
            [[[morsel liked] shouldEventually] beFalse];
        });
        it(@"has url", ^{
            [[[morsel url] shouldEventually] equal:@"http://eatmorsel.com/marty/1-butter/1"];
        });
        it(@"should have a valid post", ^{
            [[[morsel post] shouldEventually] beNonNil];
            [[[[morsel post] title] shouldEventually] equal:@"GET DOWN"];
        });

        context(@"has comments", ^{
            __block MRSLMorsel *morselWithComments = [MRSLMorsel MR_createEntity];
            morselWithComments.morselID = @40;

            __block MRSLComment *comment = nil;
            beforeAll(^{
                [MRSLSpecUtil stubMorselAPIRequestsWithJSONFileName:@"mrsl-comment.json"
                                                     forRequestPath:@"/morsels/40/comments"];
                [_appDelegate.morselApiService getComments:morselWithComments
                                                   success:^(NSArray *responseArray) {
                                                       comment = [[[morselWithComments comments] allObjects] firstObject];
                                                   } failure:nil];
            });
            it(@"should have a valid comment", ^{
                [[expectFutureValue(theValue([[morselWithComments comments] count])) shouldEventually] equal:theValue(1)];
                [[expectFutureValue(theValue([comment commentIDValue])) shouldEventually] equal:theValue(4)];
                [[[comment commentDescription] shouldEventually] equal:@"Wow! Are those Swedish Fish caviar???!?!?!one!?!11!?1?!"];
                [[[comment creator] shouldEventually] beNonNil];
                [[[comment creationDate] shouldEventually] beKindOfClass:[NSDate class]];
            });
        });
    });

    describe(@"MRSLPost", ^{
        __block MRSLPost *post = [MRSLPost MR_createEntity];
        post.postID = @1;

        beforeAll(^{
            [MRSLSpecUtil stubMorselAPIRequestsWithJSONFileName:@"mrsl-post.json"
                                                 forRequestPath:@"/posts/1"];
            [_appDelegate.morselApiService getPost:post
                                           success:nil
                                           failure:nil];
        });
        it(@"has creator", ^{
            [[[post creator] shouldEventually] beNonNil];
        });
        it(@"has id of 40", ^{
            [[expectFutureValue(theValue([post postIDValue])) shouldEventually] equal:theValue(1)];
        });
        it(@"has title 'Butter Rocks!'", ^{
            [[[post title] shouldEventually] equal:@"Butter Rocks!"];
        });
        it(@"has creationDate that is of kind NSDate", ^{
            [[[post creationDate] shouldEventually] beKindOfClass:[NSDate class]];
        });
        it(@"has one morsel", ^{
            [[expectFutureValue(theValue([[post morsels] count])) shouldEventually] equal:theValue(1)];
        });
    });

    describe(@"MRSLUser", ^{
        beforeAll(^{
            [MRSLSpecUtil stubMorselAPIRequestsWithJSONFileName:@"mrsl-user-with-auth-token.json"
                                                 forRequestPath:@"/users/sign_in"];

            [_appDelegate.morselApiService signInUserWithEmail:nil
                                                   andPassword:nil
                                                       success:nil
                                                       failure:nil];
        });
        it(@"has id of 3", ^{
            [[expectFutureValue(theValue([[MRSLUser currentUser] userIDValue])) shouldEventually] equal:theValue(3)];
        });
        it(@"has username 'turdferg'", ^{
            [[[[MRSLUser currentUser] username] shouldEventually] equal:@"turdferg"];
        });
        it(@"has first_name 'Turd'", ^{
            [[[[MRSLUser currentUser] first_name] shouldEventually] equal:@"Turd"];
        });
        it(@"has last_name 'Ferguson'", ^{
            [[[[MRSLUser currentUser] last_name] shouldEventually] equal:@"Ferguson"];
        });
        it(@"has creationDate that is kind NSDate", ^{
            [[[[MRSLUser currentUser] creationDate] shouldEventually] beKindOfClass:[NSDate class]];
        });
        it(@"has title 'Executive Chef at Jeopardy'", ^{
            [[[[MRSLUser currentUser] title] shouldEventually] equal:@"Executive Chef at Jeopardy"];
        });
        it(@"has bio 'Suck It, Trebek'", ^{
            [[[[MRSLUser currentUser] bio] shouldEventually] equal:@"Suck It, Trebek"];
        });
        it(@"has profilePhotoURL", ^{
            [[[[MRSLUser currentUser] profilePhotoURL] shouldEventually] equal:@"https://morsel-staging.s3.amazonaws.com/user-images/user/3/IMAGE_SIZE_1389119757-batman.jpeg"];
        });
        it(@"has auth_token 'butt-sack'", ^{
            [[[[MRSLUser currentUser] auth_token] shouldEventually] equal:@"butt-sack"];
        });
        it(@"has draft_count of 10", ^{
            [[expectFutureValue(theValue([[MRSLUser currentUser] draft_countValue])) shouldEventually] equal:theValue(10)];
        });
        it(@"has like_count of 3", ^{
            [[expectFutureValue(theValue([[MRSLUser currentUser] like_countValue])) shouldEventually] equal:theValue(3)];
        });
        it(@"has morsel_count of 1", ^{
            [[expectFutureValue(theValue([[MRSLUser currentUser] morsel_countValue])) shouldEventually] equal:theValue(1)];
        });
    });
});

SPEC_END
