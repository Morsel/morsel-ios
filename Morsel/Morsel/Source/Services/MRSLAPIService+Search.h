//
//  MRSLAPIService+Search.h
//  Morsel
//
//  Created by Javier Otero on 5/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Search)

- (void)searchWithQuery:(NSString *)query
                  maxID:(NSNumber *)maxOrNil
              orSinceID:(NSNumber *)sinceOrNil
               andCount:(NSNumber *)countOrNil
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLAPIFailureBlock)failureOrNil;

@end
