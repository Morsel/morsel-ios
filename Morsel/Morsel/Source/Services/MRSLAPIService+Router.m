//
//  MRSLAPIService+Router.m
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Router.h"

#import "MRSLAPIService+Like.h"
#import "MRSLAPIService+Morsel.h"

@implementation MRSLAPIService (Router)

- (void)getUserData:(MRSLUser *)user
  forDataSourceType:(MRSLDataSourceType)dataSourceType
          withMaxID:(NSNumber *)maxOrNil
          orSinceID:(NSNumber *)sinceOrNil
           andCount:(NSNumber *)countOrNil
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLFailureBlock)failureOrNil {
    switch (dataSourceType) {
        case MRSLDataSourceTypeMorsel:
            [_appDelegate.apiService getUserMorsels:user
                                          withMaxID:maxOrNil
                                          orSinceID:sinceOrNil
                                           andCount:countOrNil
                                      includeDrafts:NO
                                            success:successOrNil
                                            failure:failureOrNil];
            break;
        case MRSLDataSourceTypeActivityItem:
            [_appDelegate.apiService getLikedItemsForUser:user
                                          maxID:maxOrNil
                                          orSinceID:sinceOrNil
                                           andCount:countOrNil
                                            success:successOrNil
                                            failure:failureOrNil];
            break;
        default:
            if (failureOrNil) failureOrNil(nil);
            DDLogError(@"MRSLAPIService+Router received unsupported MRSLDataSourceType: %@", [MRSLUtil stringForDataSourceType:dataSourceType]);
            break;
    }
}

@end
