//
//  MRSLAPIService+Templates.h
//  Morsel
//
//  Created by Javier Otero on 8/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@class MRSLTemplate;

@interface MRSLAPIService (Templates)

- (void)getTemplatesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil;

- (void)createMorselWithTemplate:(MRSLTemplate *)morselTemplate
                         success:(MRSLAPISuccessBlock)successOrNil
                         failure:(MRSLFailureBlock)failureOrNil;

@end
