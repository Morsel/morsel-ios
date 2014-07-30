//
//  MorselAPIService.h
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

#import "JSONResponseSerializerWithData.h"

@class MRSLComment, MRSLItem, MRSLKeyword, MRSLMorsel, MRSLPlace, MRSLTag, MRSLUser;

@interface MRSLAPIService : NSObject

#pragma mark - Parameters

- (NSMutableDictionary *)parametersWithDictionary:(NSDictionary *)dictionaryOrNil
                             includingMRSLObjects:(NSArray *)objects
                           requiresAuthentication:(BOOL)requiresAuthentication;
- (NSDictionary *)parametersToDataWithDictionary:(NSDictionary *)parameters;

#pragma mark - Importing Helpers

- (void)importManagedObjectClass:(Class)objectClass
                  withDictionary:(NSDictionary *)responseDictionary
                         success:(MRSLAPIArrayBlock)successOrNil
                         failure:(MRSLFailureBlock)failureOrNil;

- (void)importFeedObjectsWithDictionary:(NSDictionary *)responseDictionary
                                success:(MRSLAPIArrayBlock)successOrNil;

- (void)importLikeablesWithDictionary:(NSDictionary *)responseDictionary
                              success:(MRSLAPIArrayBlock)successOrNil;

#pragma mark - Errors

- (void)reportFailure:(MRSLFailureBlock)failureOrNil
         forOperation:(AFHTTPRequestOperation *)operation
            withError:(NSError *)error
             inMethod:(NSString *)methodName;

@end
