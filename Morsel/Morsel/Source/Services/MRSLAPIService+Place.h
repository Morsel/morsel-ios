//
//  MRSLAPIService+Place.h
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@class MRSLFoursquarePlace;

@interface MRSLAPIService (Place)

- (void)addUserToPlaceWithFoursquareID:(MRSLFoursquarePlace *)foursquarePlace
                             userTitle:(NSString *)title
                               success:(MRSLAPISuccessBlock)successOrNil
                               failure:(MRSLFailureBlock)failureOrNil;

- (void)getPlace:(MRSLPlace *)place
         success:(MRSLAPISuccessBlock)successOrNil
         failure:(MRSLFailureBlock)failureOrNil;

- (void)getPlacesForUser:(MRSLUser *)user
                    page:(NSNumber *)pageOrNil
                   count:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

- (void)getUsersForPlace:(MRSLPlace *)place
                    page:(NSNumber *)pageOrNil
                   count:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

@end
