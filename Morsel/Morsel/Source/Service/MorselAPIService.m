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
    NSDictionary *parameters = @{@"user":@{@"email": user.emailAddress,
                                           @"password": password,
                                           @"first_name": user.firstName,
                                           @"last_name": user.lastName}};
    
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
             
             [existingUser setWithDictionary:responseObject
                                   inContext:[ModelController sharedController].defaultContext];
             
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
             [user setWithDictionary:responseObject
                           inContext:[ModelController sharedController].defaultContext];
             
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

#pragma mark - Morsel Services

- (void)createPost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil
{
    self.createPostFinalSuccessBlock = successOrNil;
    self.morselsCreatedCount = 0;
    
    MRSLMorsel *initialMorsel = [post.morsels firstObject];
    
    NSDictionary *parameters = @{@"morsel":@{@"description": initialMorsel.morselDescription},
                                 @"post_title": post.title,
                                 @"api_key": [ModelController sharedController].currentUser.userID};
    
    [self createMorsel:initialMorsel
        withParameters:parameters
               success:^(id responseObject)
    {
        post.postID = [NSNumber numberWithInt:[responseObject[@"post_id"] intValue]];
        
        DDLogDebug(@"First Morsel successful and associated to Post: %i", [post.postID intValue]);
        
        self.morselsCreatedCount += 1;
        
        if (_morselsCreatedCount == [post.morsels count])
        {
            DDLogDebug(@"All Morsels associated with Post created!");
            
            if (successOrNil)
            {
                successOrNil(nil);
            }
            
            self.createPostFinalSuccessBlock = nil;
        }
        else
        {
            for (MRSLMorsel *morsel in post.morsels)
            {
                if ([morsel.sortOrder intValue] != 0)
                {
                    DDLogDebug(@"Morsel Sort Order (%i) is not the first", [morsel.sortOrder intValue]);
                    [self appendMorsel:morsel toPost:post];
                }
            }
        }
    }
               failure:^(NSError *error)
    {
        DDLogDebug(@"First Morsel creation failed. Aborting Post creation process.");
        [self reportFailure:failureOrNil
                  withError:error
                   inMethod:NSStringFromSelector(_cmd)];
    }];
}

- (void)appendMorsel:(MRSLMorsel *)morsel toPost:(MRSLPost *)post
{
    DDLogDebug(@"Appending Morsel to Post: %i", [post.postID intValue]);
    
    NSDictionary *parameters = @{@"morsel":@{@"description": morsel.morselDescription},
                                 @"post_id": post.postID,
                                 @"api_key": [ModelController sharedController].currentUser.userID};
    
    [self createMorsel:morsel
        withParameters:parameters
               success:^(id responseObject)
    {
        DDLogDebug(@"Morsel (%i) successfully appended to Post: %i", [morsel.morselID intValue], [post.postID intValue]);
        self.morselsCreatedCount += 1;
        
        if (_morselsCreatedCount == [post.morsels count])
        {
            DDLogDebug(@"All Morsels associated with Post created!");
            self.createPostFinalSuccessBlock(nil);
            self.createPostFinalSuccessBlock = nil;
        }
    }
               failure:^(NSError *error)
    {
#warning If one of the Morsels fail, should that trigger the entire Post to fail as well?
        DDLogError(@"Morsel (%i) creation failed and not associated to Post: %i", [morsel.morselID intValue], [post.postID intValue]);
    }];
}

- (void)createMorsel:(MRSLMorsel *)morsel
      withParameters:(NSDictionary *)parameters
             success:(MorselAPISuccessBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil
{
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
         
         morsel.morselID = [NSNumber numberWithInt:[responseObject[@"id"] intValue]];
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

#pragma mark - General Methods

- (void)reportFailure:(MorselAPIFailureBlock)failureOrNil
            withError:(NSError *)error
             inMethod:(NSString *)methodName
{
    DDLogError(@"%@ Request Error: %@", methodName, error.userInfo[JSONResponseSerializerWithDataKey]);
    
    if (failureOrNil) failureOrNil(error);
}

@end
