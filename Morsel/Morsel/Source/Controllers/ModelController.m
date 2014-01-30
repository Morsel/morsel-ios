//
//  ModelController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "ModelController.h"

#import <CoreData/CoreData.h>

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

#import "MorselAPIService.h"

@interface ModelController ()

@property (nonatomic, strong) NSNumber *userID;

@end

@implementation ModelController

#pragma mark - Class Methods

+ (instancetype)sharedController
{
    static id _sharedController;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^
    {
        _sharedController = [[self alloc] init];
    });
    
    return _sharedController;
}

#pragma mark - Instance Methods

- (id)init
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Morsel.sqlite"];
    
    // Create Persistent store for MorselPosts
    
    self.defaultDateFormatter = [[NSDateFormatter alloc] init];
    [_defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSS'Z'"];
    
    self.morselApiService = [[MorselAPIService alloc] init];
    
    self.defaultContext = [NSManagedObjectContext MR_defaultContext];
    
    return self;
}

#pragma mark - User Methods

- (MRSLUser *)currentUser
{
    if (!self.userID)
    {
        self.userID = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
        
        if (!self.userID) return nil;
    }
    
    MRSLUser *user = [self userWithID:self.userID];
    
    return user;
}

- (MRSLUser *)userWithID:(NSNumber *)userID
{
    MRSLUser *user = nil;
    
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userID == %i", [userID intValue]];
    
    NSArray *userArray = [MRSLUser MR_findAllWithPredicate:userPredicate];
    
    if ([userArray count] > 0)
    {
        user = [userArray firstObject];
    }
    
    return user;
}

#pragma mark - Morsel Methods

- (MRSLMorsel *)morselWithID:(NSNumber *)morselID
{
    MRSLMorsel *morsel = nil;
    
    NSPredicate *postPredicate = [NSPredicate predicateWithFormat:@"morselID == %i", [morselID intValue]];
    
    NSArray *morselArray = [MRSLMorsel MR_findAllWithPredicate:postPredicate];
    
    if ([morselArray count] > 0)
    {
        morsel = [morselArray firstObject];
    }
    
    return morsel;
}

#pragma mark - Post Methods

- (MRSLPost *)postWithID:(NSNumber *)postID
{
    MRSLPost *post = nil;
    
    NSPredicate *postPredicate = [NSPredicate predicateWithFormat:@"postID == %i", [postID intValue]];
    
    NSArray *postArray = [MRSLPost MR_findAllWithPredicate:postPredicate];
    
    if ([postArray count] > 0)
    {
        post = [postArray firstObject];
    }
    
    return post;
}

- (void)getFeedWithSuccess:(MorselAPIArrayBlock)successOrNil
                   failure:(MorselAPIFailureBlock)failureOrNil
{
    [self.morselApiService retrieveFeedWithSuccess:^(NSArray *responseArray)
    {
        if (successOrNil) successOrNil(responseArray);
        
        [responseArray enumerateObjectsUsingBlock:^(NSDictionary *postDictionary, NSUInteger idx, BOOL *stop)
        {
            MRSLPost *foundPost = [self postWithID:[NSNumber numberWithInt:[postDictionary[@"id"] intValue]]];
            
            if (!foundPost)
            {
                MRSLPost *post = [MRSLPost MR_createInContext:_defaultContext];
                [post setWithDictionary:postDictionary];
                [_defaultContext MR_saveToPersistentStoreAndWait];
            }
            else
            {
                [foundPost setWithDictionary:postDictionary];
                [_defaultContext MR_saveToPersistentStoreAndWait];
            }
        }];
    }
                                           failure:^(NSError *error)
    {
        if (failureOrNil) failureOrNil(error);
    }];
}

- (void)getUserPosts:(MRSLUser *)user
             success:(MorselAPIArrayBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil
{
    [self.morselApiService retrieveUserPosts:user
                                     success:^(NSArray *responseArray)
     {
         if (successOrNil) successOrNil(responseArray);
         
         [responseArray enumerateObjectsUsingBlock:^(NSDictionary *postDictionary, NSUInteger idx, BOOL *stop)
          {
              MRSLPost *foundPost = [self postWithID:[NSNumber numberWithInt:[postDictionary[@"id"] intValue]]];
              
              if (!foundPost)
              {
                  MRSLPost *post = [MRSLPost MR_createInContext:_defaultContext];
                  [post setWithDictionary:postDictionary];
                  
                  [_defaultContext MR_saveToPersistentStoreAndWait];
              }
              else
              {
                  [foundPost setWithDictionary:postDictionary];
                  [_defaultContext MR_saveToPersistentStoreAndWait];
              }
          }];
     }
                                           failure:^(NSError *error)
     {
         if (failureOrNil) failureOrNil(error);
     }];
}

#pragma mark - Data Methods

- (void)saveDataToStoreWithSuccess:(MorselDataSuccessBlock)successOrNil
                           failure:(MorselDataFailureBlock)failureOrNil
{
    [_defaultContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error)
    {
        if (success)
        {
            DDLogDebug(@"Data saved to persistent store!");
            
            if (successOrNil) successOrNil(success);
        }
        else
        {
            if (error)
            {
                DDLogError(@"Error saving data to persistent store: %@", error.userInfo);
                if (successOrNil) failureOrNil(error);
            }
        }
    }];
}

@end
