//
//  MorselAPIService.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselAPIService.h"

#import "ModelController.h"
#import "MorselAPIClient.h"
#import "JSONResponseSerializerWithData.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

/*

 Current Response Schema - 01.29.2014
  {
    "data": {} or [],
    "meta": {
        "total_results": 1245
    },
    "errors": {
        "username": [
                     "is too long",
                     "cannot contain special characters"
                     ],
        "email": [
                  "is invalid"
                  ]
    }
}
 */

@interface MorselAPIService ()

@end

@implementation MorselAPIService

#pragma mark - User Sign Up and Sign In Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
           success:(MorselAPISuccessBlock)userSuccessOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
        @"user" : @{
            @"username" : user.userName,
            @"email" : user.emailAddress,
            @"password" : password,
            @"first_name" : user.firstName,
            @"last_name" : user.lastName,
            @"title" : user.occupationTitle
        }
    };

    [[MorselAPIClient sharedClient] POST:@"users"
                              parameters:parameters
               constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        if (user.profileImage) {
            DDLogDebug(@"Profile Image included for User!");
            [formData appendPartWithFileData:user.profileImage
                                        name:@"user[photo]"
                                    fileName:@"photo.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success: ^(AFHTTPRequestOperation * operation, id responseObject) {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        user.userID = [NSNumber numberWithInt:[responseObject[@"data"][@"id"] intValue]];
        user.authToken = responseObject[@"data"][@"auth_token"];

        [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                                  forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                            object:user];
        if (userSuccessOrNil) userSuccessOrNil(responseObject[@"data"]);
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

- (void)signInUserWithEmail:(NSString *)emailAddress
                andPassword:(NSString *)password
                    success:(MorselAPISuccessBlock)successOrNil
                    failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
        @"user" : @{
            @"email" : emailAddress,
            @"password" : password
        }
    };

    [[MorselAPIClient sharedClient] POST:@"users/sign_in"
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        NSNumber *userID = [NSNumber numberWithInt:[responseObject[@"data"][@"id"] intValue]];

        MRSLUser *existingUser = [[ModelController sharedController] userWithID:userID];

        if (existingUser) {
            DDLogDebug(@"User existed on device. Updating information.");

            [existingUser setWithDictionary:responseObject[@"data"]];

            [[NSUserDefaults standardUserDefaults] setObject:existingUser.userID
                                                      forKey:@"userID"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                object:nil];
        } else {
            DDLogDebug(@"User did not exist on device. Creating new.");

            MRSLUser *user = [MRSLUser MR_createInContext:[ModelController sharedController].defaultContext];
            [user setWithDictionary:responseObject[@"data"]];

            [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                                      forKey:@"userID"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceDidLogInUserNotification
                                                                object:nil];
        }

        if (successOrNil) successOrNil(responseObject);
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - User Services

- (void)updateUser:(MRSLUser *)user
           success:(MorselAPISuccessBlock)userSuccessOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
        @"user" : @{
            @"username" : user.userName,
            @"email" : user.emailAddress,
            @"first_name" : user.firstName,
            @"last_name" : user.lastName,
            @"title" : user.occupationTitle
        },
        @"api_key" : [ModelController sharedController].currentUser.userID
    };

    [[MorselAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", [user.userID intValue]]
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        if (userSuccessOrNil) userSuccessOrNil(responseObject);
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

- (void)getUserProfile:(MRSLUser *)user
               success:(MorselAPISuccessBlock)userSuccessOrNil
               failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
        @"api_key" : [ModelController sharedController].currentUser.userID
    };

    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i", [user.userID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        [user setWithDictionary:responseObject[@"data"]];

        if (userSuccessOrNil) userSuccessOrNil(responseObject);
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - Post Services

- (void)updatePost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
        @"post" : @{
            @"title" : post.title
        },
        @"api_key" : [ModelController sharedController].currentUser.userID
    };

    [[MorselAPIClient sharedClient] PUT:[NSString stringWithFormat:@"posts/%i", [post.postID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        [post setWithDictionary:responseObject[@"data"]];

        if (successOrNil) successOrNil(responseObject);
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

- (void)getPost:(MRSLPost *)post
        success:(MorselAPISuccessBlock)successOrNil
        failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
        @"api_key" : [ModelController sharedController].currentUser.userID
    };

    int postID = [post.postID intValue];

    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"posts/%i", [post.postID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        if (post) {
            [post setWithDictionary:responseObject[@"data"]];
        } else {
            MRSLPost *faultedPost = [[ModelController sharedController] postWithID:[NSNumber numberWithInt:postID]];

            if (faultedPost) [faultedPost setWithDictionary:responseObject[@"data"]];
        }

        if (successOrNil) successOrNil(responseObject);
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - Morsel Services

- (void)createMorsel:(MRSLMorsel *)morsel
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:[ModelController sharedController].currentUser.userID, @"api_key", nil];

    NSMutableDictionary *morselDictionary = [NSMutableDictionary dictionary];

    if (morsel.morselDescription) {
        [morselDictionary setObject:morsel.morselDescription
                             forKey:@"description"];
    }

    if ([morselDictionary count] > 0) {
        [parameters setObject:morselDictionary
                       forKey:@"morsel"];
    }

    if (morsel.post) {
        [parameters setObject:morsel.post.postID
                       forKey:@"post_id"];
        [parameters setObject:morsel.post.title
                       forKey:@"post_title"];
    }

    [[MorselAPIClient sharedClient] POST:@"morsels"
                              parameters:parameters
               constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        if (morsel.morselPicture) {
            [formData appendPartWithFileData:morsel.morselPicture
                                        name:@"morsel[photo]"
                                    fileName:@"photo.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success: ^(AFHTTPRequestOperation * operation, id responseObject) {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        morsel.draft = @NO;

        [morsel setWithDictionary:responseObject[@"data"]];

        if (successOrNil) successOrNil(responseObject);
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

- (void)updateMorsel:(MRSLMorsel *)morsel
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    NSDictionary *parameters = @{
        @"morsel" : @{
            @"description" : morsel.morselDescription,
            @"post_id" : morsel.post.postID
        },
        @"api_key" : [ModelController sharedController].currentUser.userID
    };

    [[MorselAPIClient sharedClient] PUT:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        [morsel setWithDictionary:responseObject[@"data"]];

        if (successOrNil) successOrNil(responseObject);
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MorselDataSuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil {
    [[MorselAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i", [morsel.morselID intValue]]
                                parameters:@{@"api_key": [ModelController sharedController].currentUser.userID}
                                   success:nil
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if ([operation.response statusCode] == 200) {
            int morselID = [morsel.morselID intValue];

            DDLogDebug(@"Morsel %i deleted from server. Attempting local.", morselID);

            [morsel.post removeMorsel:morsel];

            BOOL morselDeletedLocally = [morsel MR_deleteEntity];

            DDLogDebug(@"Morsel %i also deleted locally? %@", morselID, (morselDeletedLocally) ? @"YES" : @"NO");

            successOrNil(YES);
        } else {
            [self reportFailure:failureOrNil
                      withError:error
                       inMethod:NSStringFromSelector(_cmd)];
        }
    }];
}

- (void)likeMorsel:(MRSLMorsel *)morsel
        shouldLike:(BOOL)shouldLike
           didLike:(MorselAPILikeBlock)didLike
           failure:(MorselAPIFailureBlock)failureOrNil {
    if (shouldLike) {
        [[MorselAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/like", [morsel.morselID intValue]]
                                  parameters:@{@"api_key": [ModelController sharedController].currentUser.userID}
                                     success:nil
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if ([operation.response statusCode] == 200) {
                didLike(YES);
            } else {
                [self reportFailure:failureOrNil
                          withError:error
                           inMethod:NSStringFromSelector(_cmd)];
            }
        }];
    } else {
        [[MorselAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i/like", [morsel.morselID intValue]]
                                    parameters:@{@"api_key": [ModelController sharedController].currentUser.userID}
                                       success:nil
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if ([operation.response statusCode] == 200) {
                didLike(NO);
            } else {
                [self reportFailure:failureOrNil
                          withError:error
                           inMethod:NSStringFromSelector(_cmd)];
            }
        }];
    }
}

#pragma mark - Feed Services

- (void)retrieveFeedWithSuccess:(MorselAPIArrayBlock)success
                        failure:(MorselAPIFailureBlock)failureOrNil {
    [[MorselAPIClient sharedClient] GET:@"posts"
                             parameters:@{@"api_key": [ModelController sharedController].currentUser.userID}
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
            success(responseObject[@"data"]);
        }
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

- (void)retrieveUserPosts:(MRSLUser *)user
                  success:(MorselAPIArrayBlock)success
                  failure:(MorselAPIFailureBlock)failureOrNil {
    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/posts", [user.userID intValue]]
                             parameters:@{@"user_id": user.userID,
                                          @"api_key": user.userID}
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

        if ([responseObject isKindOfClass:[NSArray class]]) {
            success(responseObject);
        }
    } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - General Methods

- (void)reportFailure:(MorselAPIFailureBlock)failureOrNil
            withError:(NSError *)error
             inMethod:(NSString *)methodName {
    NSDictionary *userInfoDictionary = error.userInfo[JSONResponseSerializerWithDataKey];

    if (!userInfoDictionary) {
        DDLogError(@"%@ Request Error: %@", methodName, error.userInfo);
    } else {
        DDLogError(@"%@ Request Error: %@", methodName, userInfoDictionary[@"errors"]);
    }

    if (failureOrNil)
        failureOrNil(error);
}

@end
