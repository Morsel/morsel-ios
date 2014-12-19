//
//  MRSLAPIService+Search.m
//  Morsel
//
//  Created by Javier Otero on 5/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Search.h"

#import "MRSLAPIClient.h"

#import "MRSLFoursquarePlace.h"

#import "MRSLKeyword.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Search)

#pragma mark - Hashtags

- (void)searchHashtagsWithQuery:(NSString *)query
                           page:(NSNumber *)pageOrNil
                          count:(NSNumber *)countOrNil
                        success:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil {
    if ([query length] > 0 && [query length] < 3) {
        query = @"";
    }
    NSMutableDictionary *keywordParams = [NSMutableDictionary dictionaryWithDictionary:@{ @"query": NSNullIfNil(query) }];
    if ([query length] == 0) keywordParams[@"promoted"] = @"true";

    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"keyword" : keywordParams}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] performRequest:@"hashtags/search"
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             [self importManagedObjectClass:[MRSLKeyword class]
                                                             withDictionary:responseObject
                                                                    success:successOrNil
                                                                    failure:failureOrNil];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

#pragma mark - Morsels

- (void)searchMorselsWithHashtagQuery:(NSString *)hashtagQuery
                                 page:(NSNumber *)pageOrNil
                                count:(NSNumber *)countOrNil
                              success:(MRSLAPIArrayBlock)successOrNil
                              failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"hashtags/%@/morsels", hashtagQuery]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             [self importManagedObjectClass:[MRSLMorsel class]
                                                             withDictionary:responseObject
                                                                    success:successOrNil
                                                                    failure:failureOrNil];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

- (void)searchMorselsWithQuery:(NSString *)query
                          page:(NSNumber *)pageOrNil
                         count:(NSNumber *)countOrNil
                       success:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLFailureBlock)failureOrNil {
    if ([query length] > 0 && [query length] < 3) {
        DDLogError(@"Cannot search morsels. Query is less than minimum character length of 3.");
        if (failureOrNil) failureOrNil(nil);
        return;
    }
    NSDictionary *queryDictionary = ([query length] == 0) ? nil : @{@"morsel" : @{ @"query": NSNullIfNil(query) }};

    NSMutableDictionary *parameters = [self parametersWithDictionary:queryDictionary
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] performRequest:@"morsels/search"
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             [self importManagedObjectClass:[MRSLMorsel class]
                                                             withDictionary:responseObject
                                                                    success:successOrNil
                                                                    failure:failureOrNil];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

#pragma mark - Places

- (void)searchPlacesWithQuery:(NSString *)query
                  andLocation:(CLLocation *)location
                       orNear:(NSString *)near
                      success:(MRSLAPIArrayBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    if ([query length] < 3) {
        DDLogError(@"Cannot search places. Query is less than minimum character length of 3.");
        if (failureOrNil) failureOrNil(nil);
        return;
    }

    // if near passed, used instead of lat_lon
    NSDictionary *locationDictionary = nil;
    if ([near length] > 0) {
        locationDictionary = @{@"query": query,
                               @"near": near};
    } else {
        locationDictionary = @{@"query": query,
                               @"lat_lon": [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude]};
    }
    NSMutableDictionary *parameters = [self parametersWithDictionary:locationDictionary
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] performRequest:@"places/suggest"
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             NSArray *foursquareArray = responseObject[@"data"][@"minivenues"];
                                             __block NSMutableArray *foursquarePlaces = [NSMutableArray array];
                                             [foursquareArray enumerateObjectsUsingBlock:^(NSDictionary *venueDictionary, NSUInteger idx, BOOL *stop) {
                                                 MRSLFoursquarePlace *foursquarePlace = [[MRSLFoursquarePlace alloc] initWithDictionary:venueDictionary];
                                                 [foursquarePlaces addObject:foursquarePlace];
                                             }];
                                             if (successOrNil) successOrNil(foursquarePlaces);
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

#pragma mark - Users

- (void)searchUsersWithQuery:(NSString *)query
                        page:(NSNumber *)pageOrNil
                       count:(NSNumber *)countOrNil
                     success:(MRSLAPIArrayBlock)successOrNil
                     failure:(MRSLFailureBlock)failureOrNil {
    if ([query length] > 0 && [query length] < 3) {
        query = @"";
    }
    NSMutableDictionary *userParams = [NSMutableDictionary dictionaryWithDictionary:@{ @"query": NSNullIfNil(query) }];
    if ([query length] == 0) userParams[@"promoted"] = @"true";

    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user" : userParams}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] performRequest:@"users/search"
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             [self importManagedObjectClass:[MRSLUser class]
                                                             withDictionary:responseObject
                                                                    success:successOrNil
                                                                    failure:failureOrNil];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

@end
