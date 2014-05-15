//
//  MRSLAPIService+Comment.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Comment.h"

#import "MRSLComment.h"
#import "MRSLItem.h"

@implementation MRSLAPIService (Comment)

#pragma mark - Comment Services

- (void)getComments:(MRSLItem *)item
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"items/%i/comments", item.itemIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      NSArray *commentsArray = responseObject[@"data"];
                                      DDLogDebug(@"%lu comments available for Morsel!", (unsigned long)[commentsArray count]);

                                      [commentsArray enumerateObjectsUsingBlock:^(NSDictionary *commentDictionary, NSUInteger idx, BOOL *stop) {
                                          MRSLComment *comment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                                                            withValue:commentDictionary[@"id"]];
                                          if (!comment) comment = [MRSLComment MR_createEntity];
                                          [comment MR_importValuesForKeysWithObject:commentDictionary];
                                      }];
                                      if (successOrNil) successOrNil(commentsArray);
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)addCommentWithDescription:(NSString *)description
                         toMorsel:(MRSLItem *)item
                          success:(MRSLAPISuccessBlock)successOrNil
                          failure:(MRSLAPIFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"comment": @{@"description": NSNullIfNil(description)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"items/%i/comments", item.itemIDValue]
                            parameters:parameters
                               success: ^(AFHTTPRequestOperation * operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                   MRSLComment *comment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                                                     withValue:responseObject[@"data"][@"id"]];
                                   if (!comment) comment = [MRSLComment MR_createEntity];
                                   [comment MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                   item.comment_count = @(item.comment_countValue + 1);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidCreateCommentNotification
                                                                                           object:item];
                                   });
                                   if (successOrNil) successOrNil(responseObject);
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                   [self reportFailure:failureOrNil
                                             withError:error
                                              inMethod:NSStringFromSelector(_cmd)];
                               }];
}

@end
