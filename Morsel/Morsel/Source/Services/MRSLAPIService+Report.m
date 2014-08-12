//
//  MRSLAPIService+Report.m
//  Morsel
//
//  Created by Javier Otero on 8/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Report.h"

#import "MRSLAPIClient.h"

@implementation MRSLAPIService (Report)

- (void)sendReportable:(NSManagedObject <MRSLReportable> *)reportable
               success:(MRSLSuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] multipartFormRequestString:[reportable reportableUrlString]
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         if (successOrNil) successOrNil(YES);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         if ([operation.response statusCode] == 200) {
                                                             if (successOrNil) successOrNil(YES);
                                                         } else {
                                                             [self reportFailure:failureOrNil
                                                                    forOperation:operation
                                                                       withError:error
                                                                        inMethod:NSStringFromSelector(_cmd)];
                                                         }
                                                     }];
}

@end
