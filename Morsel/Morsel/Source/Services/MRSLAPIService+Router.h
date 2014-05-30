//
//  MRSLAPIService+Router.h
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Router)

- (void)getUserData:(MRSLUser *)user
  forDataSourceType:(MRSLDataSourceType)dataSourceType
          withMaxID:(NSNumber *)maxOrNil
          orSinceID:(NSNumber *)sinceOrNil
           andCount:(NSNumber *)countOrNil
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLFailureBlock)failureOrNil;

- (void)getPlaceData:(MRSLPlace *)place
   forDataSourceType:(MRSLDataSourceType)dataSourceType
           withMaxID:(NSNumber *)maxOrNil
           orSinceID:(NSNumber *)sinceOrNil
            andCount:(NSNumber *)countOrNil
             success:(MRSLAPIArrayBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil;

@end
