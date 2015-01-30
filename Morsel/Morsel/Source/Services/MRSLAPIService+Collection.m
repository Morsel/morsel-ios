//
//  MRSLAPIService+Collection.m
//  Morsel
//
//  Created by Javier Otero on 1/20/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLAPIService+Collection.h"

#import "MRSLAPIClient.h"

#import "MRSLCollection.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Collection)

- (void)getCollectionsForUser:(MRSLUser *)user
                         page:(NSNumber *)pageOrNil
                        count:(NSNumber *)countOrNil
                      success:(MRSLAPIArrayBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;
    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"users/%i/collections", user.userIDValue]
                                      parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                          [self importManagedObjectClass:[MRSLCollection class]
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

- (void)getMorselsForCollection:(MRSLCollection *)collection
                           page:(NSNumber *)pageOrNil
                          count:(NSNumber *)countOrNil
                        success:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;
    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"collections/%i/morsels", collection.collectionIDValue]
                                      parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                          [self importManagedObjectClass:[MRSLMorsel class]
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

- (void)getCollection:(MRSLCollection *)collection
              success:(MRSLAPISuccessBlock)successOrNil
              failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    int collectionID = collection.collectionIDValue;
    __block MRSLCollection *collectionToGet = collection;

    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"collections/%i", collectionID]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                             if (!collectionToGet || !collectionToGet.managedObjectContext) {
                                                 collectionToGet = [MRSLCollection MR_findFirstByAttribute:MRSLCollectionAttributes.collectionID
                                                                                                 withValue:@(collectionID)];
                                             }
                                             if (collectionToGet) {
                                                 [collectionToGet MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                 if (successOrNil) successOrNil(collectionToGet);
                                             } else {
                                                 if (failureOrNil) failureOrNil(nil);
                                             }
                                         } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

- (void)deleteCollection:(MRSLCollection *)collection
                 success:(MRSLSuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    int collectionID = collection.collectionIDValue;
    NSManagedObjectContext *context = collection.managedObjectContext;
    if (!context) return;
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"collectionID == %i", collectionID];
    [MRSLCollection MR_deleteAllMatchingPredicate:itemPredicate
                                        inContext:context];
    [context MR_saveToPersistentStoreAndWait];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"collections/%i", collectionID]
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

- (void)updateCollection:(MRSLCollection *)collection
                 success:(MRSLAPISuccessBlock)successOrNil
                 failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[collection]
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"collections/%i", collection.collectionIDValue]
                                                  withMethod:MRSLAPIMethodTypePUT
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                                         [collection MR_importValuesForKeysWithObject:responseObject[@"data"]];

                                                         if (successOrNil) successOrNil(collection);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)createCollectionWithTitle:(NSString *)titleOrNil
                      description:(NSString *)descriptionOrNil
                          success:(MRSLAPISuccessBlock)successOrNil
                          failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"collection": @{@"title" : NSNullIfNil(titleOrNil),
                                                                                        @"description": NSNullIfNil(descriptionOrNil)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] multipartFormRequestString:@"collections"
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         MRSLCollection *createdCollection = [MRSLCollection MR_findFirstByAttribute:MRSLCollectionAttributes.collectionID
                                                                                                                           withValue:responseObject[@"data"][@"id"]];
                                                         if (!createdCollection) createdCollection = [MRSLCollection MR_createEntity];
                                                         [createdCollection MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         if (successOrNil) successOrNil(createdCollection);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)addMorsel:(MRSLMorsel *)morsel
     toCollection:(MRSLCollection *)collection
         withNote:(NSString *)noteOrNil
          success:(MRSLAPISuccessBlock)successOrNil
          failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"collection_id": NSNullIfNil(collection.collectionID),
                                                                       @"note": NSNullIfNil(noteOrNil)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"morsels/%i/collect", morsel.morselIDValue]
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [collection addMorselsObject:morsel];
                                                         });
                                                         if (successOrNil) successOrNil(responseObject);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                         if (serviceErrorInfo) {
                                                             if ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"already in this collection"].location != NSNotFound) {
                                                                 [UIAlertView showOKAlertViewWithTitle:@"Error"
                                                                                               message:@"The morsel is already in this collection."];
                                                             } else if ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"not published"].location != NSNotFound) {
                                                                 [UIAlertView showOKAlertViewWithTitle:@"Error"
                                                                                               message:@"A collection can only contain published morsels."];
                                                             } else if ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"not authorized"].location != NSNotFound) {
                                                                 [UIAlertView showOKAlertViewWithTitle:@"Error"
                                                                                               message:@"You can only add to collections you own."];
                                                             }
                                                         }
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)removeMorsel:(MRSLMorsel *)morsel
      fromCollection:(MRSLCollection *)collection
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"collection_id": NSNullIfNil(collection.collectionID)}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"morsels/%i/collect", morsel.morselIDValue]
                                                  withMethod:MRSLAPIMethodTypeDELETE
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [collection addMorselsObject:morsel];
                                                         });
                                                         if (successOrNil) successOrNil(responseObject);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                         if (serviceErrorInfo) {
                                                             if ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"not in this collection"].location != NSNotFound) {
                                                                 [UIAlertView showOKAlertViewWithTitle:@"Error"
                                                                                               message:@"The morsel is not in this collection."];
                                                             } else if ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"not authorized"].location != NSNotFound) {
                                                                 [UIAlertView showOKAlertViewWithTitle:@"Error"
                                                                                               message:@"You can only remove morsels from collections you own."];
                                                             }
                                                         }
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

@end
