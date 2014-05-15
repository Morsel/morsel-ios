//
//  MRSLAPIService+Keyword.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Keyword.h"

#import "MRSLKeyword.h"

@implementation MRSLAPIService (Keyword)

#pragma mark - Keyword Services

- (void)getCuisinesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLAPIFailureBlock)failureOrNil {
    [self getKeywordsOfType:MRSLKeywordCuisinesType
                    success:successOrNil
                    failure:failureOrNil];
}

- (void)getSpecialtiesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                          failure:(MRSLAPIFailureBlock)failureOrNil {
    [self getKeywordsOfType:MRSLKeywordSpecialtiesType
                    success:successOrNil
                    failure:failureOrNil];
}

- (void)getKeywordsOfType:(NSString *)tagType
                  success:(MRSLAPIArrayBlock)successOrNil
                  failure:(MRSLAPIFailureBlock)failureOrNil {
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
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

@end
