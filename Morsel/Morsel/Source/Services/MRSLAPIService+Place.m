//
//  MRSLAPIService+Place.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Place.h"

#import "MRSLFoursquarePlace.h"

#import "MRSLPlace.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Place)

- (void)searchPlacesWithQuery:(NSString *)query
                  andLocation:(CLLocation *)location
                      success:(MRSLAPIArrayBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    if ([query length] < 3) {
        DDLogError(@"Cannot search places. Query is less than minimum character length of 3.");
        if (failureOrNil) failureOrNil(nil);
        return;
    }
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"query": query,
                                                                       @"lat_lon": [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude]}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] GET:@"places/suggest"
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
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)addUserToPlaceWithFoursquareID:(MRSLFoursquarePlace *)foursquarePlace
                             userTitle:(NSString *)title
                               success:(MRSLAPISuccessBlock)successOrNil
                               failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"place" : @{@"foursquare_venue_id": NSNullIfNil(foursquarePlace.foursquarePlaceID),
                                                                                    @"name": NSNullIfNil(foursquarePlace.name),
                                                                                    @"address": NSNullIfNil(foursquarePlace.address),
                                                                                    @"city": NSNullIfNil(foursquarePlace.city),
                                                                                    @"state": NSNullIfNil(foursquarePlace.state)},
                                                                       @"title": title}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] POST:@"places/join"
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                   if (successOrNil) successOrNil(responseObject);
                               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   [self reportFailure:failureOrNil
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
    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"places/%i", place.placeIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  [place MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                  if (successOrNil) successOrNil(responseObject);
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getPlacesForUser:(MRSLUser *)user
               withMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/places", user.userIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *placeIDs = [NSMutableArray array];
                                      NSArray *userPlacesArray = responseObject[@"data"];

                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [userPlacesArray enumerateObjectsUsingBlock:^(NSDictionary *placeDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLPlace *place = [MRSLPlace MR_findFirstByAttribute:MRSLPlaceAttributes.placeID
                                                                                          withValue:placeDictionary[@"id"]
                                                                                          inContext:localContext];
                                              if (!place) place = [MRSLPlace MR_createInContext:localContext];
                                              [place MR_importValuesForKeysWithObject:placeDictionary];
                                              [placeIDs addObject:placeDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(placeIDs);
                                      }];
                                  }
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getUsersForPlace:(MRSLPlace *)place
               withMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;
    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"places/%i/users", place.placeIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importUsersWithDictionary:responseObject
                                                          success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

@end