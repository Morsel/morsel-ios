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

#warning Possibly break out MorselAPIService to be separate Request classes to avoid this becoming colossal
#warning Improve error handling for parameter dictionary elements being nil

@interface MorselAPIService ()

#pragma mark - Morsel Creation Properties

@property (nonatomic) int morselsCreatedCount;

@property (nonatomic, strong) MorselAPISuccessBlock createPostFinalSuccessBlock;

@end

@implementation MorselAPIService

#pragma mark - User Sign Up and Sign In Services

- (void)createUser:(MRSLUser *)user
      withPassword:(NSString *)password
           success:(MorselAPISuccessBlock)userSuccessOrNil
           failure:(MorselAPIFailureBlock)failureOrNil
{
    NSDictionary *parameters = @{@"user":@{@"username": user.userName,
                                           @"email": user.emailAddress,
                                           @"password": password,
                                           @"first_name": user.firstName,
                                           @"last_name": user.lastName,
                                           @"title": user.occupationTitle}};
    
    [[MorselAPIClient sharedClient] POST:@"users"
                              parameters:parameters
               constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        if (user.profileImage)
        {
            [formData appendPartWithFileData:user.profileImage
                                        name:@"user[photo]"
                                    fileName:@"photo.jpg"
                                    mimeType:@"image/jpeg"];
        }
    }
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
        
        user.userID = [NSNumber numberWithInt:[responseObject[@"id"] intValue]];
        user.authToken = responseObject[@"auth_token"];
        
        [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                                  forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MorselServiceDidCreateUserNotification
                                                            object:user];
        if (userSuccessOrNil)
        {
            userSuccessOrNil(responseObject);
        }
    }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

- (void)signInUserWithEmail:(NSString *)emailAddress
                andPassword:(NSString *)password
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil
{
    NSDictionary *parameters = @{@"user":@{@"email": emailAddress,
                                           @"password": password}};
    
    [[MorselAPIClient sharedClient] POST:@"users/sign_in"
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
         
         NSNumber *userID = [NSNumber numberWithInt:[responseObject[@"id"] intValue]];
         
         MRSLUser *existingUser = [[ModelController sharedController] userWithID:userID];
         
         if (existingUser)
         {
             DDLogDebug(@"User existed on device. Updating information.");
             
             [existingUser setWithDictionary:responseObject];
             
             [[NSUserDefaults standardUserDefaults] setObject:existingUser.userID
                                                       forKey:@"userID"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:MorselServiceDidLogInExistingUserNotification
                                                                 object:nil];
         }
         else
         {
             DDLogDebug(@"User did not exist on device. Creating new.");
             
             MRSLUser *user = [MRSLUser MR_createInContext:[ModelController sharedController].defaultContext];
             [user setWithDictionary:responseObject];
             
             [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                                       forKey:@"userID"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:MorselServiceDidLogInNewUserNotification
                                                                 object:nil];
         }
         
         if (successOrNil) successOrNil(responseObject);
     }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

#pragma mark - User Services

- (void)updateUser:(MRSLUser *)user
           success:(MorselAPISuccessBlock)userSuccessOrNil
           failure:(MorselAPIFailureBlock)failureOrNil
{
    NSDictionary *parameters = @{@"user":@{@"username": user.userName,
                                           @"email": user.emailAddress,
                                           @"first_name": user.firstName,
                                           @"last_name": user.lastName,
                                           @"title": user.occupationTitle},
                                 @"api_key": [ModelController sharedController].currentUser.userID};
    
    [[MorselAPIClient sharedClient] PUT:[NSString stringWithFormat:@"users/%i", [user.userID intValue]]
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

         if (userSuccessOrNil)
         {
             userSuccessOrNil(responseObject);
         }
     }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)getUserProfile:(MRSLUser *)user
               success:(MorselAPISuccessBlock)userSuccessOrNil
               failure:(MorselAPIFailureBlock)failureOrNil
{
    NSDictionary *parameters = @{@"api_key": [ModelController sharedController].currentUser.userID};
    
    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i", [user.userID intValue]]
                             parameters:parameters
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
        
        [user setWithDictionary:responseObject];
        
        if (userSuccessOrNil)
        {
            userSuccessOrNil(responseObject);
        }
    }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - Morsel Services

- (void)createMorsel:(MRSLMorsel *)morsel
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:[ModelController sharedController].currentUser.userID, @"api_key", nil];
    
    NSMutableDictionary *morselDictionary = [NSMutableDictionary dictionary];
    
    if (morsel.morselDescription)
    {
        [morselDictionary setObject:morsel.morselDescription
                             forKey:@"description"];
    }
    
#warning Use Morsel Sort Order object instead
    /*
    if (morsel.sortOrder)
    {
        [morselDictionary setObject:morsel.sortOrder
                             forKey:@"sort_order"];
    }
    */
    if ([morselDictionary count] > 0)
    {
        [parameters setObject:morselDictionary
                       forKey:@"morsel"];
    }
    
    if (morsel.post)
    {
        [parameters setObject:morsel.post.postID
                       forKey:@"post_id"];
    }
    
    [[MorselAPIClient sharedClient] POST:@"morsels"
                              parameters:parameters
               constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         if (morsel.morselPicture)
         {
             [formData appendPartWithFileData:morsel.morselPicture
                                         name:@"morsel[photo]"
                                     fileName:@"photo.jpg"
                                     mimeType:@"image/jpeg"];
         }
     }
                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
         
         morsel.draft = [NSNumber numberWithBool:NO];
         
         [morsel setWithDictionary:responseObject];
         
         if (successOrNil)
         {
             successOrNil(responseObject);
         }
     }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

- (void)likeMorsel:(MRSLMorsel *)morsel
        shouldLike:(BOOL)shouldLike
           didLike:(MorselAPILikeBlock)didLike
           failure:(MorselAPIFailureBlock)failureOrNil
{
    if (shouldLike)
    {
        [[MorselAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/like", [morsel.morselID intValue]]
                                  parameters:@{@"api_key": [ModelController sharedController].currentUser.userID}
                                     success:nil
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if ([operation.response statusCode] == 200)
             {
                 didLike(YES);
             }
             else
             {
                 [self reportFailure:failureOrNil
                           withError:error
                            inMethod:NSStringFromSelector(_cmd)];
             }
         }];
    }
    else
    {
        [[MorselAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i/like", [morsel.morselID intValue]]
                                    parameters:@{@"api_key": [ModelController sharedController].currentUser.userID}
                                       success:nil
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if ([operation.response statusCode] == 200)
             {
                 didLike(NO);
             }
             else
             {
                 [self reportFailure:failureOrNil
                           withError:error
                            inMethod:NSStringFromSelector(_cmd)];
             }
         }];
    }
}

#pragma mark - Feed Services

- (void)retrieveFeedWithSuccess:(MorselAPIArrayBlock)success
                        failure:(MorselAPIFailureBlock)failureOrNil
{
    [[MorselAPIClient sharedClient] GET:@"posts"
                             parameters:@{@"api_key": [ModelController sharedController].currentUser.userID}
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
        
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            success(responseObject);
        }
    }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

- (void)retrieveUserPosts:(MRSLUser *)user
                  success:(MorselAPIArrayBlock)success
                  failure:(MorselAPIFailureBlock)failureOrNil
{
    [[MorselAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/posts", [user.userID intValue]]
                             parameters:@{@"user_id": user.userID,
                                          @"api_key": user.userID}
                                success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
         
         if ([responseObject isKindOfClass:[NSArray class]])
         {
             success(responseObject);
         }
     }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self reportFailure:failureOrNil
                   withError:error
                    inMethod:NSStringFromSelector(_cmd)];
     }];
}

#pragma mark - General Methods

- (void)reportFailure:(MorselAPIFailureBlock)failureOrNil
            withError:(NSError *)error
             inMethod:(NSString *)methodName
{
    DDLogError(@"%@ Request Error: %@", methodName, error.userInfo[JSONResponseSerializerWithDataKey]);
    
    if (failureOrNil) failureOrNil(error);
}

@end
