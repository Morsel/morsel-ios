//
//  MRSLAPIService+Like.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Like.h"

#import "MRSLAPIClient.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Like)

#pragma mark - Like Services

- (void)getLikedMorselsForUser:(MRSLUser *)user
                         maxID:(NSNumber *)maxOrNil
                       sinceID:(NSNumber *)sinceOrNil
                         count:(NSNumber *)countOrNil
                       success:(MRSLAPIArrayBlock)successOrNil
                       failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"type": @"Morsel"}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"users/%i/likeables", user.userIDValue]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             [self importLikeablesWithDictionary:responseObject
                                                                         success:successOrNil];
                                         } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

- (void)getMorselLikers:(MRSLMorsel *)morsel
                  maxID:(NSNumber *)maxOrNil
                sinceID:(NSNumber *)sinceOrNil
                  count:(NSNumber *)countOrNil
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    if (maxOrNil && sinceOrNil) {
        DDLogError(@"Attempting to call with both max and since IDs set. Ignoring both values.");
    } else if (maxOrNil && !sinceOrNil) {
        parameters[@"max_id"] = maxOrNil;
    } else if (!maxOrNil && sinceOrNil) {
        parameters[@"since_id"] = sinceOrNil;
    }
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"morsels/%i/likers", morsel.morselIDValue]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             [self importManagedObjectClass:[MRSLUser class]
                                                             withDictionary:responseObject
                                                                    success:successOrNil
                                                                    failure:failureOrNil];
                                         } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

- (void)likeMorsel:(MRSLMorsel *)morsel
        shouldLike:(BOOL)shouldLike
           didLike:(MRSLAPILikeBlock)likeBlockOrNil
           failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (shouldLike) {
        morsel.like_count = @(morsel.like_countValue + 1);
        [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"morsels/%i/like", morsel.morselIDValue]
                                                      withMethod:MRSLAPIMethodTypePOST
                                                  formParameters:[self parametersToDataWithDictionary:parameters]
                                                      parameters:nil
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             if (likeBlockOrNil) likeBlockOrNil(YES);
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                             if ([operation.response statusCode] == 200 || ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"already liked"].location != NSNotFound)) {
                                                                 if (likeBlockOrNil) likeBlockOrNil(YES);
                                                             } else {
                                                                 [self reportFailure:failureOrNil
                                                                        forOperation:operation
                                                                           withError:error
                                                                            inMethod:NSStringFromSelector(_cmd)];
                                                             }
                                                         }];
    } else {
        morsel.like_count = @(morsel.like_countValue - 1);
        [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"morsels/%i/like", morsel.morselIDValue]
                                                      withMethod:MRSLAPIMethodTypeDELETE
                                                  formParameters:[self parametersToDataWithDictionary:parameters]
                                                      parameters:nil
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             if (likeBlockOrNil) likeBlockOrNil(NO);
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                             if ([operation.response statusCode] == 200  || ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"not liked"].location != NSNotFound)) {
                                                                 if (likeBlockOrNil) likeBlockOrNil(NO);
                                                             } else {
                                                                 [self reportFailure:failureOrNil
                                                                        forOperation:operation
                                                                           withError:error
                                                                            inMethod:NSStringFromSelector(_cmd)];
                                                             }
                                                         }];
    }
}

@end
