//
//  ModelController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "ModelController.h"

#import <CoreData/CoreData.h>

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
    self.morselApiService = [[MorselAPIService alloc] init];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Morsel.sqlite"];
    
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

@end
