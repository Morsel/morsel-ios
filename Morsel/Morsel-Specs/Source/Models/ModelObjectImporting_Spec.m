//
//  ModelObjectImporting_Spec.m
//  Morsel
//
//  Created by Javier Otero on 2/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLComment.h"
#import "MRSLCollection.h"
#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

#import "MRSLAPIService+Comment.h"
#import "MRSLAPIService+Collection.h"
#import "MRSLAPIService+Item.h"
#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Registration.h"

SPEC_BEGIN(ModelObjectImporting_Spec)

describe(@"Importing from the API", ^{
    beforeEach(^{
        [OHHTTPStubs removeAllStubs];
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
    });

    afterEach(^{
        [MagicalRecord cleanUp];
    });

    describe(@"MRSLItem", ^{
        let(item, ^id{
            MRSLItem *_item = [MRSLItem MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            [_item setItemID:@2];
            return _item;
        });

        beforeEach(^{
            __block BOOL requestCompleted = NO;
            [MRSLSpecUtil stubItemAPIRequestsWithJSONFileName:@"mrsl-item-authenticated.json"
                                               forRequestPath:@"/items/2"];

            [_appDelegate.apiService getItem:item
                                     success:^(id responseObject) {
                                         requestCompleted = YES;
                                     } failure:nil];

            [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
        });

        it(@"has id of 2", ^{
            [[[item itemID] should] equal:@2];
        });

        it(@"has itemDescription 'This dish is crazy awesome!'", ^{
            [[[item itemDescription] should] equal:@"This dish is crazy awesome!"];
        });

        it(@"has creationDate that is of kind NSDate", ^{
            [[[item creationDate] should] beKindOfClass:[NSDate class]];
        });

        it(@"has itemPhotoURL", ^{
            [[[item itemPhotoURL] should] equal:@"https://morsel-staging.s3.amazonaws.com/item-images/item/2/IMAGE_SIZE_648922f4-8850-4402-8ff8-8ffc1e2f8c01.png"];
        });

        it(@"has url", ^{
            [[[item url] should] equal:@"http://eatmorsel.com/marty/1-butter/1"];
        });

        context(@"has comments", ^{
            let(itemWithComments, ^id{
                MRSLItem *_itemWithComments = [MRSLItem MR_createEntity];
                [_itemWithComments setItemID:@40];
                [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                return _itemWithComments;
            });
            let(comment, ^id{ return nil; });

            beforeEach(^{
                __block BOOL requestCompleted = NO;
                __block MRSLComment *firstComment = nil;
                [MRSLSpecUtil stubItemAPIRequestsWithJSONFileName:@"mrsl-comment.json"
                                                   forRequestPath:@"/items/40/comments"];

                [_appDelegate.apiService getComments:itemWithComments
                                                page:nil
                                               count:nil
                                             success:^(NSArray *responseArray) {
                                                 firstComment = [[[itemWithComments comments] allObjects] firstObject];
                                                 requestCompleted = YES;
                                             } failure:nil];

                [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
                comment = firstComment;
            });
            it(@"should have a valid comment", ^{
                [[@([[itemWithComments comments] count]) should] equal:@1];
                [[[comment commentID] should] equal:@4];
                [[[comment commentDescription] should] equal:@"Wow! Are those Swedish Fish caviar???!?!?!one!?!11!?1?!"];
                [[[comment creator] should] beNonNil];
                [[[comment creationDate] should] beKindOfClass:[NSDate class]];
            });
        });
    });

    describe(@"MRSLMorsel", ^{
        let(morsel, ^id{
            MRSLMorsel *existingMorsel = [MRSLMorsel MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            [existingMorsel setMorselID:@1];
            return existingMorsel;
        });

        beforeEach(^{
            __block BOOL requestCompleted = NO;
            [MRSLSpecUtil stubItemAPIRequestsWithJSONFileName:@"mrsl-morsel.json"
                                               forRequestPath:@"/morsels/1"];

            [_appDelegate.apiService getMorsel:morsel
                                      orWithID:nil
                                       success:^(id responseObject) {
                                           requestCompleted = YES;
                                       } failure:nil];

            [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
        });

        it(@"has creator", ^{
            [[[morsel creator] should] beNonNil];
        });

        it(@"has liked value", ^{
            [[[morsel liked] should] beTrue];
        });

        it(@"has id of 1", ^{
            [[theValue([morsel morselIDValue]) should] equal:theValue(1)];
        });

        it(@"has title 'Butter Rocks!'", ^{
            [[[morsel title] should] equal:@"Butter Rocks!"];
        });

        it(@"has creationDate that is of kind NSDate", ^{
            [[[morsel creationDate] should] beKindOfClass:[NSDate class]];
        });

        it(@"has one item", ^{
            [[theValue([[morsel items] count]) should] equal:theValue(1)];
        });
    });

    describe(@"MRSLUser", ^{
        let(currentUser, ^id{ return nil; });

        beforeEach(^{
            __block BOOL requestCompleted = NO;
            [MRSLSpecUtil stubItemAPIRequestsWithJSONFileName:@"mrsl-user-with-auth-token.json"
                                               forRequestPath:@"/users/sign_in"];

            [_appDelegate.apiService signInUserWithEmailOrUsername:nil
                                                       andPassword:nil
                                                  orAuthentication:nil
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

        it(@"has liked_item_count of 3", ^{
            [[[currentUser liked_item_count] should] equal:@3];
        });

        it(@"has morsel_count of 1", ^{
            [[[currentUser morsel_count] should] equal:@1];
        });
    });

    describe(@"MRSLCollection", ^{
        let(collection, ^id{
            MRSLCollection *existingCollection = [MRSLCollection MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            [existingCollection setCollectionID:@5];
            return existingCollection;
        });

        beforeEach(^{
            __block BOOL requestCompleted = NO;
            [MRSLSpecUtil stubItemAPIRequestsWithJSONFileName:@"mrsl-collection.json"
                                               forRequestPath:@"/collections/5"];

            [_appDelegate.apiService getCollection:collection
                                           success:^(id responseObject) {
                                               requestCompleted = YES;
                                           }
                                           failure:nil];
            
            [[expectFutureValue(theValue(requestCompleted)) shouldEventuallyBeforeTimingOutAfter(MRSL_DEFAULT_TIMEOUT)] beTrue];
        });

        it(@"has a title", ^{
            [[[collection title] should] equal:@"This is my bitchin' collection!"];
        });

        it(@"has an optional text description", ^{
            [[[collection collectionDescription] should] equal:@"Here's some bitchin' stuff I've been following"];
        });

        it(@"has a single owner", ^{
            [[[collection creator] should] beNonNil];
        });

        it(@"is a group of morsels", ^{
            [[collection morselsArray] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [[obj should] beKindOfClass:[MRSLMorsel class]];
            }];
        });

        it(@"has one morsel", ^{
            [[@([[collection morsels] count]) should] equal:@1];
        });

        it(@"has morsels with a sort order", ^{
            [[collection morselsArray] enumerateObjectsUsingBlock:^(MRSLMorsel *morsel, NSUInteger idx, BOOL *stop) {
                [[[morsel sort_order] should] equal:@1];
            }];
        });
    });
});

SPEC_END
