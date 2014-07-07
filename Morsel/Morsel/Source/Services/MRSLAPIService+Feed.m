//
//  MRSLAPIService+Feed.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Feed.h"

#import "MRSLAPIClient.h"

#import "MRSLMorsel.h"

@implementation MRSLAPIService (Feed)

#pragma mark - Feed Services

- (void)getFeedWithMaxID:(NSNumber *)maxOrNil
               orSinceID:(NSNumber *)sinceOrNil
                andCount:(NSNumber *)countOrNil
                 success:(MRSLAPIArrayBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
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

    [[MRSLAPIClient sharedClient] GET:@"feed"
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *feedItemIDs = [NSMutableArray array];
                                      NSArray *feedItemsArray = responseObject[@"data"];
                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [feedItemsArray enumerateObjectsUsingBlock:^(NSDictionary *feedItemDictionary, NSUInteger idx, BOOL *stop) {
                                              if ([[feedItemDictionary[@"subject_type"] lowercaseString] isEqualToString:@"morsel"]) {
                                                  if (![feedItemDictionary[@"subject"] isEqual:[NSNull null]]) {
                                                      NSDictionary *morselDictionary = feedItemDictionary[@"subject"];
                                                      MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                                     withValue:morselDictionary[@"id"]
                                                                                                     inContext:localContext];
                                                      if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                                                      [morsel MR_importValuesForKeysWithObject:morselDictionary];
                                                      morsel.feedItemID = feedItemDictionary[@"id"];
                                                      morsel.feedItemFeatured = @([feedItemDictionary[@"featured"] boolValue]);
                                                      [feedItemIDs addObject:morselDictionary[@"id"]];
                                                  }
                                              }
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(feedItemIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

@end
