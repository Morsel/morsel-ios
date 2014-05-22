//
//  MorselAPIService.h
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONResponseSerializerWithData.h"

@class MRSLComment, MRSLItem, MRSLKeyword, MRSLMorsel, MRSLTag, MRSLUser;

@interface MRSLAPIService : NSObject

#pragma mark - Parameters

- (NSMutableDictionary *)parametersWithDictionary:(NSDictionary *)dictionaryOrNil
                             includingMRSLObjects:(NSArray *)objects
                           requiresAuthentication:(BOOL)requiresAuthentication;

#pragma mark - Importing Helpers

- (void)importTagsWithDictionary:(NSDictionary *)responseDictionary
                         success:(MRSLAPIArrayBlock)successOrNil;

- (void)importKeywordsWithDictionary:(NSDictionary *)responseDictionary
                             success:(MRSLAPIArrayBlock)successOrNil;

- (void)importUsersWithDictionary:(NSDictionary *)responseDictionary
                          success:(MRSLAPIArrayBlock)successOrNil;

#pragma mark - Errors

- (void)reportFailure:(MRSLFailureBlock)failureOrNil
            withError:(NSError *)error
             inMethod:(NSString *)methodName;

@end
