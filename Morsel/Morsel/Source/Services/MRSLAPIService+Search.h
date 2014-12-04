//
//  MRSLAPIService+Search.h
//  Morsel
//
//  Created by Javier Otero on 5/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

#import <CoreLocation/CoreLocation.h>

@interface MRSLAPIService (Search)

#pragma mark - Hashtags

- (void)searchHashtagsWithQuery:(NSString *)query
                          maxID:(NSNumber *)maxOrNil
                      orSinceID:(NSNumber *)sinceOrNil
                       andCount:(NSNumber *)countOrNil
                        success:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil;

#pragma mark - Morsels

- (void)searchMorselsWithHashtagQuery:(NSString *)hashtagQuery
                                maxID:(NSNumber *)maxOrNil
                            orSinceID:(NSNumber *)sinceOrNil
                             andCount:(NSNumber *)countOrNil
                              success:(MRSLAPIArrayBlock)successOrNil
                              failure:(MRSLFailureBlock)failureOrNil;

- (void)searchMorselsWithQuery:(NSString *)query
                         maxID:(NSNumber *)maxOrNil
                     orSinceID:(NSNumber *)sinceOrNil
                      andCount:(NSNumber *)countOrNil
                       success:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLFailureBlock)failureOrNil;

#pragma mark - Places

- (void)searchPlacesWithQuery:(NSString *)query
                  andLocation:(CLLocation *)location
                       orNear:(NSString *)near
                      success:(MRSLAPIArrayBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil;

#pragma mark - Users

- (void)searchUsersWithQuery:(NSString *)query
                       maxID:(NSNumber *)maxOrNil
                   orSinceID:(NSNumber *)sinceOrNil
                    andCount:(NSNumber *)countOrNil
                     success:(MRSLAPIArrayBlock)successOrNil
                     failure:(MRSLFailureBlock)failureOrNil;

@end
