//
//  MRSLAPIService+Search.m
//  Morsel
//
//  Created by Javier Otero on 5/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Search.h"

#import "MRSLAPIClient.h"

#import "MRSLUser.h"

@implementation MRSLAPIService (Search)

- (void)searchWithQuery:(NSString *)query
                  maxID:(NSNumber *)maxOrNil
              orSinceID:(NSNumber *)sinceOrNil
               andCount:(NSNumber *)countOrNil
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil {
    if ([query length] > 0 && [query length] < 3) {
        DDLogError(@"Cannot search places. Query is less than minimum character length of 3.");
        if (failureOrNil) failureOrNil(nil);
        return;
    }
    NSMutableDictionary *userParams = [NSMutableDictionary dictionaryWithDictionary:@{ @"query": NSNullIfNil(query) }];
    if ([query length] == 0) userParams[@"promoted"] = @"true";

    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"user" : userParams}
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

    [[MRSLAPIClient sharedClient] performRequest:@"users/search"
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             [self importManagedObjectClass:[MRSLUser class]
                                                             withDictionary:responseObject
                                                                    success:successOrNil
                                                                    failure:failureOrNil];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

@end
