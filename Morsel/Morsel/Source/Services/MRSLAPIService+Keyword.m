//
//  MRSLAPIService+Keyword.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Keyword.h"

#import "MRSLAPIClient.h"

#import "MRSLKeyword.h"

@implementation MRSLAPIService (Keyword)

#pragma mark - Keyword Services

- (void)getCuisinesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLFailureBlock)failureOrNil {
    [self getKeywordsOfType:MRSLKeywordCuisinesType
                    success:successOrNil
                    failure:failureOrNil];
}

- (void)getSpecialtiesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil {
    [self getKeywordsOfType:MRSLKeywordSpecialtiesType
                    success:successOrNil
                    failure:failureOrNil];
}

- (void)getKeywordsOfType:(NSString *)tagType
                  success:(MRSLAPIArrayBlock)successOrNil
                  failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] GET:tagType
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importKeywordsWithDictionary:responseObject
                                                             success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

@end
