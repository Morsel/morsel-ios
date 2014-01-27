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

- (MRSLUser *)currentUser;
- (MRSLUser *)userWithID:(NSNumber *)userID;
- (MRSLPost *)postWithID:(NSNumber *)postID;

- (void)getFeedWithSuccess:(MorselAPIArrayBlock)successOrNil
                   failure:(MorselAPIFailureBlock)failureOrNil;

- (void)getUserPosts:(MRSLUser *)user
             success:(MorselAPIArrayBlock)successOrNil
             failure:(MorselAPIFailureBlock)failureOrNil;

// Saves data in default context into the persistent store.
- (void)saveDataToStore;

@end
