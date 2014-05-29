//
//  MRSLAPIService+Keyword.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Keyword)

#pragma mark - Keyword Services

- (void)getCuisinesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLFailureBlock)failureOrNil;

- (void)getSpecialtiesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil;

@end
