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
#import "MRSLAPIService+Place.h"
#import "MRSLAPIService+Tag.h"

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
            [_appDelegate.apiService getMorselsForUser:user
                                             withMaxID:maxOrNil
                                             orSinceID:sinceOrNil
                                              andCount:countOrNil
                                            onlyDrafts:NO
                                               success:successOrNil
                                               failure:failureOrNil];
            break;
        case MRSLDataSourceTypeLikedMorsel:
            [_appDelegate.apiService getLikedMorselsForUser:user
                                                      maxID:maxOrNil
                                                  orSinceID:sinceOrNil
                                                   andCount:countOrNil
                                                    success:successOrNil
                                                    failure:failureOrNil];
            break;
        case MRSLDataSourceTypePlace:
            [_appDelegate.apiService getPlacesForUser:user
                                            withMaxID:maxOrNil
                                            orSinceID:sinceOrNil
                                             andCount:countOrNil
                                              success:successOrNil
                                              failure:failureOrNil];
            break;
        case MRSLDataSourceTypeTag:
            [_appDelegate.apiService getUserTags:user
                                         success:successOrNil
                                         failure:failureOrNil];
            break;
        default:
            if (failureOrNil) failureOrNil(nil);
            DDLogError(@"MRSLAPIService+Router received unsupported MRSLDataSourceType: %@", [MRSLUtil stringForDataSourceType:dataSourceType]);
            break;
    }
}

- (void)getPlaceData:(MRSLPlace *)place
   forDataSourceType:(MRSLDataSourceType)dataSourceType
           withMaxID:(NSNumber *)maxOrNil
           orSinceID:(NSNumber *)sinceOrNil
            andCount:(NSNumber *)countOrNil
             success:(MRSLAPIArrayBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil {
    switch (dataSourceType) {
        case MRSLDataSourceTypeMorsel:
            [_appDelegate.apiService getMorselsForPlace:place
                                             withMaxID:maxOrNil
                                             orSinceID:sinceOrNil
                                              andCount:countOrNil
                                               success:successOrNil
                                               failure:failureOrNil];
            break;
        case MRSLDataSourceTypeUser:
            [_appDelegate.apiService getUsersForPlace:place
                                            withMaxID:maxOrNil
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
