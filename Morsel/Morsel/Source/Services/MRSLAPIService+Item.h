//
//  MRSLAPIService+Item.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Item)

#pragma mark - Item Services

- (void)createItem:(MRSLItem *)item
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)getItem:(MRSLItem *)item
        success:(MRSLAPISuccessBlock)successOrNil
        failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)updateItem:(MRSLItem *)item
         andMorsel:(MRSLMorsel *)morselOrNil
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)updateItemImage:(MRSLItem *)item
                success:(MRSLAPISuccessBlock)successOrNil
                failure:(MRSLAPIFailureBlock)failureOrNil;

- (void)deleteItem:(MRSLItem *)item
           success:(MRSLDataSuccessBlock)successOrNil
           failure:(MRSLAPIFailureBlock)failureOrNil;

@end
