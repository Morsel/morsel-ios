//
//  MRSLAPIService+Activity.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Activity)

#pragma mark - Activity Services

- (void)getUserActivitiesForUser:(MRSLUser *)user
                            page:(NSNumber *)pageOrNil
                           count:(NSNumber *)countOrNil
                         success:(MRSLAPIArrayBlock)successOrNil
                         failure:(MRSLFailureBlock)failureOrNil;

- (void)getFollowablesActivitiesForUser:(MRSLUser *)user
                                   page:(NSNumber *)pageOrNil
                                  count:(NSNumber *)countOrNil
                                success:(MRSLAPIArrayBlock)successOrNil
                                failure:(MRSLFailureBlock)failureOrNil;

@end
