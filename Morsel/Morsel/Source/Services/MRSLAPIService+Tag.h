//
//  MRSLAPIService+Tag.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Tag)

#pragma mark - Tag Services

- (void)getCuisineUsers:(MRSLKeyword *)cuisine
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getSpecialtyUsers:(MRSLKeyword *)specialty
                  success:(MRSLAPIArrayBlock)successOrNil
                  failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getUserCuisines:(MRSLUser *)user
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getUserSpecialties:(MRSLUser *)user
                   success:(MRSLAPIArrayBlock)successOrNil
                   failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)createTagForKeyword:(MRSLKeyword *)keyword
                    success:(MRSLAPISuccessBlock)successOrNil
                    failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)deleteTag:(MRSLTag *)tag
          success:(MRSLDataSuccessBlock)successOrNil
          failure:(MRSLAPIFailureBlock)failureOrNil;

@end
