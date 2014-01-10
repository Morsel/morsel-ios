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

/*
 
 api_key: MTP: Will always be the userID. Not necessary for create and signin/signup.
 
 profile image: 400 x 400
 
 auth_token: DO NOT USE YET.
 
 */

#warning Break out MorselAPIService to be separate Request classes

@interface MorselAPIService ()

@property (nonatomic) int morselsCreatedCount;

@property (nonatomic, strong) MorselAPISuccessBlock createPostFinalSuccessBlock;

@end

@implementation MorselAPIService

- (void)createUser:(MRSLUser *)user
           success:(MorselAPISuccessBlock)userSuccess
           failure:(MorselAPIFailureBlock)failure
{
    NSDictionary *parameters = @{@"user":@{@"email": user.emailAddress,
                                           @"password": user.password,
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
        
        [[NSUserDefaults standardUserDefaults] setObject:user.userID
                                                  forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
           NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
           
           [context MR_saveWithOptions:MRSaveParentContexts
                            completion:^(BOOL success, NSError *error)
            {
                if (error)
                {
                    NSLog(@"Error saving newly created user: %@", error);
                    failure(error);
                }
                else
                {
                    NSLog(@"New user created and saved successfully!");
                    [[NSNotificationCenter defaultCenter] postNotificationName:MorselServiceDidCreateUserNotification
                                                                        object:user];
                    if (userSuccess)
                    {
                        userSuccess(responseObject);
                    }
                }
            }];
        });
    }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"%s Request Error: %@", __PRETTY_FUNCTION__, error.userInfo[JSONResponseSerializerWithDataKey]);
        
        if (failure)
        {
            failure(error);
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
                if ([morsel.orderID intValue] != 0)
                {
                    NSLog(@"Morsel Order ID (%i) is not the first", [morsel.orderID intValue]);
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
         NSLog(@"Create Morsel Response: %@", responseObject);
         
         morsel.morselID = [NSNumber numberWithInt:[responseObject[@"id"] intValue]];
         if (successOrNil)
         {
             successOrNil(responseObject);
         }
     }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Create Morsel Request Error: %@", error.userInfo[JSONResponseSerializerWithDataKey]);
         
         if (failureOrNil)
         {
             failureOrNil(error);
         }
     }];
}

@end
