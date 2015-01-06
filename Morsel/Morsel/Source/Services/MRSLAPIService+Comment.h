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
               page:(NSNumber *)pageOrNil
              count:(NSNumber *)countOrNil
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLFailureBlock)failureOrNil;

- (void)addCommentWithDescription:(NSString *)description
                         toMorsel:(MRSLItem *)item
                          success:(MRSLAPISuccessBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil;

- (void)deleteComment:(MRSLComment *)comment
              success:(MRSLSuccessBlock)successOrNil
              failure:(MRSLFailureBlock)failureOrNil;

@end
