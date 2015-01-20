//
//  MRSLAPIService+Collection.h
//  Morsel
//
//  Created by Javier Otero on 1/20/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Collection)

- (void)getCollectionsForUser:(MRSLUser *)user
                      success:(MRSLAPIArrayBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil;

- (void)getMorselsForCollection:(MRSLCollection *)collection
                        success:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil;

- (void)getCollection:(MRSLCollection *)collection
              success:(MRSLAPISuccessBlock)successOrNil
              failure:(MRSLFailureBlock)failureOrNil;

- (void)deleteCollection:(MRSLCollection *)collection
                 success:(MRSLSuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

- (void)updateCollection:(MRSLCollection *)collection
                 success:(MRSLAPISuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

- (void)createCollection:(MRSLCollection *)collection
                 success:(MRSLAPISuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil;

@end
