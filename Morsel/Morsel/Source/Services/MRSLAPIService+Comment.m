//
//  MRSLAPIService+Comment.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Comment.h"

#import "MRSLAPIClient.h"

#import "MRSLComment.h"
#import "MRSLItem.h"

@implementation MRSLAPIService (Comment)

#pragma mark - Comment Services

- (void)getComments:(MRSLItem *)item
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

    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"items/%i/comments", item.itemIDValue]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             [self importManagedObjectClass:[MRSLComment class]
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

- (void)addCommentWithDescription:(NSString *)description
                         toMorsel:(MRSLItem *)item
                          success:(MRSLAPISuccessBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"comment": @{@"description": NSNullIfNil(description)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"items/%i/comments", item.itemIDValue]
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         MRSLComment *comment = [MRSLComment MR_findFirstByAttribute:MRSLCommentAttributes.commentID
                                                                                                           withValue:responseObject[@"data"][@"id"]];
                                                         if (!comment) comment = [MRSLComment MR_createEntity];
                                                         [comment MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         item.comment_count = @(item.comment_countValue + 1);
                                                         [comment.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                         if (successOrNil) successOrNil(comment);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)deleteComment:(MRSLComment *)comment
              success:(MRSLSuccessBlock)successOrNil
              failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    MRSLItem *item = comment.item;
    item.comment_count = @(item.comment_countValue - 1);
    int commentID = comment.commentIDValue;
    [comment MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"items/%i/comments/%i", item.itemIDValue, commentID]
                                                  withMethod:MRSLAPIMethodTypeDELETE
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:nil
                                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
