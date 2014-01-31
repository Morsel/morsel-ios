//
//  ModelController.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MorselAPIService.h"

@class MRSLUser;

@interface ModelController : NSObject

@property (nonatomic, strong) MorselAPIService *morselApiService;
@property (nonatomic, strong) NSDateFormatter *defaultDateFormatter;
// Default Context that will persist objects created and managed within to disk
@property (nonatomic, strong) NSManagedObjectContext *defaultContext;

+ (instancetype)sharedController;

// User Methods

- (MRSLUser *)currentUser;
- (MRSLUser *)userWithID:(NSNumber *)userID;

// Morsel Methods

- (MRSLMorsel *)morselWithID:(NSNumber *)morselID;

// Post Methods

- (MRSLPost *)postWithID:(NSNumber *)postID;

- (void)getFeedWithSuccess:(MorselAPIArrayBlock)successOrNil
                   failure:(MorselAPIFailureBlock)failureOrNil;

- (void)getUserPosts:(MRSLUser *)user
             success:(MorselAPIArrayBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

// Data Methods
// Saves data in default context into the persistent store.
- (void)saveDataToStoreWithSuccess:(MorselDataSuccessBlock)successOrNil
                           failure:(MorselDataFailureBlock)failureOrNil;
- (void)resetDataStore;

@end
