//
//  MRSLAPIService+Place.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Place.h"

#import "MRSLAPIClient.h"

#import "MRSLFoursquarePlace.h"

#import "MRSLPlace.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Place)

- (void)addUserToPlaceWithFoursquareID:(MRSLFoursquarePlace *)foursquarePlace
                             userTitle:(NSString *)title
                               success:(MRSLAPISuccessBlock)successOrNil
                               failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"place" : @{
                                                                               @"name": NSNullIfNil(foursquarePlace.name),
                                                                               @"address": NSNullIfNil(foursquarePlace.address),
                                                                               @"city": NSNullIfNil(foursquarePlace.city),
                                                                               @"state": NSNullIfNil(foursquarePlace.state)},
                                                                       @"title": title}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"places/%@/employment", foursquarePlace.foursquarePlaceID]
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         if (successOrNil) successOrNil(responseObject);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)getPlace:(MRSLPlace *)place
         success:(MRSLAPISuccessBlock)successOrNil
         failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"places/%i", place.placeIDValue]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             [place MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                             if (successOrNil) successOrNil(responseObject);
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

- (void)getPlacesForUser:(MRSLUser *)user
                    page:(NSNumber *)pageOrNil
                   count:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"users/%i/places", user.userIDValue]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             [self importManagedObjectClass:[MRSLPlace class]
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

- (void)getUsersForPlace:(MRSLPlace *)place
                    page:(NSNumber *)pageOrNil
                   count:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;
    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"places/%i/users", place.placeIDValue]
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
