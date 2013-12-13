//
//  MorselAPIService.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MorselAPIService.h"

#import "MorselAPIClient.h"

#import "MRSLUser.h"

#import "JSONResponseSerializerWithData.h"

/*
 
 api_key: MTP: Will always be the userID. Not necessary for create and signin/signup.
 
 profile image: 400 x 400
 
 auth_token: DO NOT USE YET.
 
 */

@implementation MorselAPIService

- (void)createUser:(MRSLUser *)user
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
                                        name:@"user[profile]"
                                    fileName:@"profile.jpg"
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
                }
                else
                {
                    NSLog(@"New user created and saved successfully!");
                    [[NSNotificationCenter defaultCenter] postNotificationName:MorselServiceDidCreateUserNotification
                                                                        object:user];
                }
            }];
        });
    }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"%s Request Error: %@", __PRETTY_FUNCTION__, error.userInfo[JSONResponseSerializerWithDataKey]);
        NSLog(@"%s Request Response: %@", __PRETTY_FUNCTION__, operation.response);
    }];
}

@end
