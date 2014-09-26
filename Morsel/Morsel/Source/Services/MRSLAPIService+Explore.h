//
//  MRSLAPIService+Explore.h
//  Morsel
//
//  Created by Javier Otero on 9/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Explore)

- (void)getExploreWithMaxID:(NSNumber *)maxOrNil
                  orSinceID:(NSNumber *)sinceOrNil
                   andCount:(NSNumber *)countOrNil
                    success:(MRSLAPIArrayBlock)successOrNil
                    failure:(MRSLFailureBlock)failureOrNil;

@end
