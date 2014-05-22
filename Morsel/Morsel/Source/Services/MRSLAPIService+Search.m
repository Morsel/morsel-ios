//
//  MRSLAPIService+Search.m
//  Morsel
//
//  Created by Javier Otero on 5/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Search.h"

@implementation MRSLAPIService (Search)

- (void)searchWithQuery:(NSString *)query
                  maxID:(NSNumber *)maxOrNil
              orSinceID:(NSNumber *)sinceOrNil
               andCount:(NSNumber *)countOrNil
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user" : @{@"query": NSNullIfNil(query),
                                                                                   @"promoted": ([query length] > 0) ? @"false" : @"true"}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] GET:@"users/search"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [self importUsersWithDictionary:responseObject
                                                          success:successOrNil];
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

@end
