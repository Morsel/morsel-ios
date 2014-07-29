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

- (void)getLikedItemsForUser:(MRSLUser *)user
                       maxID:(NSNumber *)maxOrNil
                   orSinceID:(NSNumber *)sinceOrNil
                    andCount:(NSNumber *)countOrNil
                     success:(MRSLAPIArrayBlock)successOrNil
                     failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"type": @"Item"}
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

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"users/%i/likeables", user.userIDValue]
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

- (void)getItemLikes:(MRSLItem *)item
             success:(MRSLAPIArrayBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"items/%i/likers", item.itemIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  __block NSMutableArray *itemLikers = [NSMutableArray array];
                                  NSArray *likerUsersArray = responseObject[@"data"];
                                  [likerUsersArray enumerateObjectsUsingBlock:^(NSDictionary *userDictionary, NSUInteger idx, BOOL *stop) {

                                      MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                               withValue:userDictionary[@"id"]];
                                      if (!user) user = [MRSLUser MR_createEntity];
                                      [user MR_importValuesForKeysWithObject:userDictionary];
                                      [itemLikers addObject:user];
                                  }];
                                  if (successOrNil) successOrNil(itemLikers);
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)likeItem:(MRSLItem *)item
      shouldLike:(BOOL)shouldLike
         didLike:(MRSLAPILikeBlock)likeBlockOrNil
         failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (shouldLike) {
        item.like_count = @(item.like_countValue + 1);
        [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"items/%i/like", item.itemIDValue]
                                                      withMethod:MRSLAPIMethodTypePOST
                                                  formParameters:[self parametersToDataWithDictionary:parameters]
                                                      parameters:nil
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             if (likeBlockOrNil) likeBlockOrNil(YES);
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                             if ([operation.response statusCode] == 200 || [[serviceErrorInfo.errorInfo lowercaseString] isEqualToString:@"item: already liked"]) {
                                                                 if (likeBlockOrNil) likeBlockOrNil(YES);
                                                             } else {
                                                                 [self reportFailure:failureOrNil
                                                                        forOperation:operation
                                                                           withError:error
                                                                            inMethod:NSStringFromSelector(_cmd)];
                                                             }
                                                         }];
    } else {
        item.like_count = @(item.like_countValue - 1);
        [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"items/%i/like", item.itemIDValue]
                                                      withMethod:MRSLAPIMethodTypeDELETE
                                                  formParameters:[self parametersToDataWithDictionary:parameters]
                                                      parameters:nil
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             if (likeBlockOrNil) likeBlockOrNil(NO);
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                             if ([operation.response statusCode] == 200  || [[serviceErrorInfo.errorInfo lowercaseString] isEqualToString:@"item: not liked"]) {
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
