//
//  MRSLAPIService+Place.h
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

#import <CoreLocation/CoreLocation.h>

@class MRSLFoursquarePlace;

@interface MRSLAPIService (Place)

- (void)searchPlacesWithQuery:(NSString *)query
                  andLocation:(CLLocation *)location
                       orNear:(NSString *)near
                      success:(MRSLAPIArrayBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil;

- (void)addUserToPlaceWithFoursquareID:(MRSLFoursquarePlace *)foursquarePlace
                             userTitle:(NSString *)title
                               success:(MRSLAPISuccessBlock)successOrNil
                               failure:(MRSLFailureBlock)failureOrNil;

- (void)getPlace:(MRSLPlace *)place
         success:(MRSLAPISuccessBlock)successOrNil
         failure:(MRSLFailureBlock)failureOrNil;

- (void)getPlacesForUser:(MRSLUser *)user
               withMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

- (void)getUsersForPlace:(MRSLPlace *)place
               withMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

@end
