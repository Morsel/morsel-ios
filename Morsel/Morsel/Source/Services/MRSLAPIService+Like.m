//
//  MRSLAPIService+Like.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Like.h"

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
                     failure:(MRSLAPIFailureBlock)failureOrNil {
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
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *itemIDs = [NSMutableArray array];
                                      NSArray *likeablesArray = responseObject[@"data"];
                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [likeablesArray enumerateObjectsUsingBlock:^(NSDictionary *itemDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                             withValue:itemDictionary[@"morsel"][@"id"]
                                                                                             inContext:localContext];
                                              if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                                              [morsel MR_importValuesForKeysWithObject:itemDictionary[@"morsel"]];
                                              MRSLItem *item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                                       withValue:itemDictionary[@"id"]
                                                                                       inContext:localContext];
                                              if (!item) item = [MRSLItem MR_createInContext:localContext];
                                              [item MR_importValuesForKeysWithObject:itemDictionary];
                                              [itemIDs addObject:itemDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(itemIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getItemLikes:(MRSLItem *)item
             success:(MRSLAPIArrayBlock)successOrNil
             failure:(MRSLAPIFailureBlock)failureOrNil {
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
                                      NSString *authToken = nil;
                                      if (!user) {
                                          user = [MRSLUser MR_createEntity];
                                      } else {
                                          authToken = [user.auth_token copy];
                                      }
                                      [user MR_importValuesForKeysWithObject:userDictionary];
                                      if (!user.auth_token && authToken) user.auth_token = authToken;
                                      [itemLikers addObject:user];
                                  }];
                                  if (successOrNil) successOrNil(itemLikers);
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)likeItem:(MRSLItem *)item
      shouldLike:(BOOL)shouldLike
         didLike:(MRSLAPILikeBlock)likeBlockOrNil
         failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (shouldLike) {
        item.like_count = @(item.like_countValue + 1);
        [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"items/%i/like", item.itemIDValue]
                                parameters:parameters
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       if (likeBlockOrNil) likeBlockOrNil(YES);
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                       if ([operation.response statusCode] == 200 || [serviceErrorInfo.errorInfo isEqualToString:@"Item: already liked"]) {
                                           if (likeBlockOrNil) likeBlockOrNil(YES);
                                       } else {
                                           [self reportFailure:failureOrNil
                                                     withError:error
                                                      inMethod:NSStringFromSelector(_cmd)];
                                       }
                                   }];
    } else {
        item.like_count = @(item.like_countValue - 1);
        [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"items/%i/like", item.itemIDValue]
                                  parameters:parameters
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if (likeBlockOrNil) likeBlockOrNil(NO);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                         if ([operation.response statusCode] == 200  || [serviceErrorInfo.errorInfo isEqualToString:@"Item: not liked"]) {
                                             if (likeBlockOrNil) likeBlockOrNil(NO);
                                         } else {
                                             [self reportFailure:failureOrNil
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }
                                     }];
    }
}

@end
