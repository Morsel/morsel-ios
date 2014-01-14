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

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

#import "JSONResponseSerializerWithData.h"

#warning Break out MorselAPIService to be separate Request classes

@interface MorselAPIService ()

@property (nonatomic) int morselsCreatedCount;

@property (nonatomic, strong) MorselAPISuccessBlock createPostFinalSuccessBlock;

@end

@implementation MorselAPIService

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
        NSLog(@"%s Response: %@", __PRETTY_FUNCTION__, responseObject);
        
        user.userID = [NSNumber numberWithInt:[responseObject[@"id"] intValue]];
        user.authToken = responseObject[@"auth_token"];
        
        [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                                  forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
           NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
           
           [context MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error)
            {
                if (error)
                {
                    NSLog(@"Error saving newly created user: %@", error);
                    failureOrNil(error);
                }
                else
                {
                    NSLog(@"New user created and saved successfully!");
                    [[NSNotificationCenter defaultCenter] postNotificationName:MorselServiceDidCreateUserNotification
                                                                        object:user];
                    if (userSuccessOrNil)
                    {
                        userSuccessOrNil(responseObject);
                    }
                }
            }];
        });
    }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"%s Request Error: %@", __PRETTY_FUNCTION__, error.userInfo[JSONResponseSerializerWithDataKey]);
        
        if (failureOrNil)
        {
            failureOrNil(error);
        }
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
         NSLog(@"%s Response: %@", __PRETTY_FUNCTION__, responseObject);
         
         NSNumber *userID = [NSNumber numberWithInt:[responseObject[@"id"] intValue]];
         
         MRSLUser *existingUser = [[ModelController sharedController] userWithID:userID];
         
         if (existingUser)
         {
             NSLog(@"User existed on device. Updating information.");
             
             NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
             
             [existingUser setWithDictionary:responseObject
                                   inContext:context
                                     success:^ (NSNumber *uniqueObjectID)
             {
                 NSLog(@"Existing user logged in and saved successfully!");
                 
                 [[NSUserDefaults standardUserDefaults] setObject:uniqueObjectID
                                                           forKey:@"userID"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:MorselServiceDidLogInExistingUserNotification
                                                                     object:nil];
                 if (successOrNil)
                 {
                     successOrNil(responseObject);
                 }
             }
                                     failure:^(NSError *error)
             {
                 NSLog(@"Error saving existing logged in user: %@", error);
                 
                 if (failureOrNil)
                 {
                     failureOrNil(error);
                 }
             }];
         }
         else
         {
             NSLog(@"User did not exist on device. Creating new.");
             
             NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
             
             MRSLUser *user = [MRSLUser MR_createInContext:context];
             [user setWithDictionary:responseObject
                           inContext:context
                             success:^(NSNumber *uniqueObjectID)
             {
                 [[NSUserDefaults standardUserDefaults] setObject:uniqueObjectID
                                                           forKey:@"userID"];
                 BOOL didSync = [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 NSLog(@"New user logged in and saved successfully (%@)!", didSync ? @"YES" : @"NO");
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:MorselServiceDidLogInNewUserNotification
                                                                     object:nil];
                 
                 if (successOrNil)
                 {
                     successOrNil(responseObject);
                 }
             }
                             failure:^(NSError *error)
             {
                 NSLog(@"Error saving newly logged in user: %@", error);
                 failureOrNil(error);
             }];
         }
     }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%s Request Error: %@", __PRETTY_FUNCTION__, error.userInfo[JSONResponseSerializerWithDataKey]);
         
         if (failureOrNil)
         {
             failureOrNil(error);
         }
     }];
}

- (void)createPost:(MRSLPost *)post
           success:(MorselAPISuccessBlock)successOrNil
           failure:(MorselAPIFailureBlock)failureOrNil
{
    NSLog(@"Creating first Morsel in Post");
    
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
        
        NSLog(@"First Morsel successful and associated to Post: %i", [post.postID intValue]);
        
        self.morselsCreatedCount += 1;
        
        if (_morselsCreatedCount == [post.morsels count])
        {
            NSLog(@"All Morsels associated with Post created!");
            
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
                    NSLog(@"Morsel Sort Order (%i) is not the first", [morsel.sortOrder intValue]);
                    [self appendMorsel:morsel toPost:post];
                }
            }
        }
    }
               failure:^(NSError *error)
    {
        NSLog(@"First Morsel creation failed. Aborting Post creation process.");
        if (failureOrNil)
        {
           failureOrNil(error);
        }
    }];
}

- (void)appendMorsel:(MRSLMorsel *)morsel toPost:(MRSLPost *)post
{
    NSLog(@"Appending Morsel to Post: %i", [post.postID intValue]);
    
    NSDictionary *parameters = @{@"morsel":@{@"description": morsel.morselDescription},
                                 @"post_id": post.postID,
                                 @"api_key": [ModelController sharedController].currentUser.userID};
    
    [self createMorsel:morsel
        withParameters:parameters
               success:^(id responseObject)
    {
        NSLog(@"Morsel (%i) successfully appended to Post: %i", [morsel.morselID intValue], [post.postID intValue]);
        self.morselsCreatedCount += 1;
        
        if (_morselsCreatedCount == [post.morsels count])
        {
            NSLog(@"All Morsels associated with Post created!");
            self.createPostFinalSuccessBlock(nil);
            self.createPostFinalSuccessBlock = nil;
        }
    }
               failure:^(NSError *error)
    {
#warning If one of the Morsels fail, should that trigger the entire Post to fail as well?
        NSLog(@"Morsel (%i) creation failed and not associated to Post: %i", [morsel.morselID intValue], [post.postID intValue]);
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
         NSLog(@"%s Response: %@", __PRETTY_FUNCTION__, responseObject);
         
         morsel.morselID = [NSNumber numberWithInt:[responseObject[@"id"] intValue]];
         if (successOrNil)
         {
             successOrNil(responseObject);
         }
     }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%s Request Error: %@", __PRETTY_FUNCTION__, error.userInfo[JSONResponseSerializerWithDataKey]);
         
         if (failureOrNil)
         {
             failureOrNil(error);
         }
     }];
}

@end
