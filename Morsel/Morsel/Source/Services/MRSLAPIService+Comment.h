//
//  MRSLAPIService+Comment.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Comment)

#pragma mark - Comment Services

- (void)getComments:(MRSLItem *)item
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)addCommentWithDescription:(NSString *)description
                         toMorsel:(MRSLItem *)item
                          success:(MRSLAPISuccessBlock)successOrNil
                          failure:(MRSLAPIFailureBlock)failureOrNil;

@end
