//
//  MRSLAPIService+Item.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Item.h"

#import "MRSLAPIClient.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Item)

#pragma mark - Item Services

- (void)createItem:(MRSLItem *)item
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLFailureBlock)failureOrNil {
    if (!item) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[item]
                                              requiresAuthentication:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidBeginCreateMorselNotification
                                                            object:nil];
    });

    NSString *itemLocalUUID = [item.localUUID copy];

    parameters[@"prepare_presigned_upload"] = @"true";

    __block MRSLItem *localItem = item;

    [[MRSLAPIClient sharedClient] multipartFormRequestString:@"items"
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                                         if (!localItem || !localItem.managedObjectContext) {
                                                             localItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.localUUID
                                                                                                 withValue:itemLocalUUID];
                                                         }
                                                         if (localItem && localItem.managedObjectContext) {
                                                             [localItem MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                             [localItem.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                             if (successOrNil) successOrNil(localItem);
                                                         } else {
                                                             if (failureOrNil) failureOrNil(nil);
                                                         }
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         if (!item || !item.managedObjectContext) {
                                                             localItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.localUUID
                                                                                                 withValue:itemLocalUUID];
                                                         }
                                                         if (localItem) {
                                                             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                             if (serviceErrorInfo) {
                                                                 if ([[serviceErrorInfo.errorInfo lowercaseString] rangeOfString:@"already exists"].location != NSNotFound) {
                                                                     [localItem MR_deleteEntity];
                                                                     [localItem.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                                     return;
                                                                 }
                                                             }
                                                             localItem.didFailUpload = @YES;
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:MRSLItemUploadDidFailNotification
                                                                                                                     object:localItem];
                                                             });
                                                             [self reportFailure:failureOrNil
                                                                    forOperation:operation
                                                                       withError:error
                                                                        inMethod:NSStringFromSelector(_cmd)];
                                                         }
                                                     }];
}

- (void)getItem:(MRSLItem *)item
     parameters:(NSDictionary *)additionalParametersOrNil
        success:(MRSLAPISuccessBlock)successOrNil
        failure:(MRSLFailureBlock)failureOrNil {
    if (!item) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:additionalParametersOrNil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    int itemID = item.itemIDValue;
    __block MRSLItem *itemToGet = item;

    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"items/%i", itemID]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                             if (!itemToGet || !itemToGet.managedObjectContext) {
                                                 itemToGet = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                                     withValue:@(itemID)];
                                             }
                                             if (itemToGet) {
                                                 [itemToGet MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                 if (successOrNil) successOrNil(itemToGet);
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

- (void)getItem:(MRSLItem *)item
        success:(MRSLAPISuccessBlock)successOrNil
        failure:(MRSLFailureBlock)failureOrNil {
    [self getItem:item
       parameters:nil
          success:successOrNil
          failure:failureOrNil];
}

- (void)updateItem:(MRSLItem *)item
         andMorsel:(MRSLMorsel *)morselOrNil
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLFailureBlock)failureOrNil {
    if (!item) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[item]
                                              requiresAuthentication:YES];
    if (morselOrNil) {
        [parameters addEntriesFromDictionary:@{@"new_morsel_id": NSNullIfNil(morselOrNil.morselID),
                                               @"morsel_id": NSNullIfNil(item.morsel.morselID)}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdateItemNotification
                                                            object:item];
    });

    int itemID = item.itemIDValue;
    __block MRSLItem *itemToUpdate = item;

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"items/%i", itemID]
                                                  withMethod:MRSLAPIMethodTypePUT
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         if (!itemToUpdate || !itemToUpdate.managedObjectContext) {
                                                             itemToUpdate = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                                                    withValue:@(itemID)];
                                                         }
                                                         [itemToUpdate MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         if (morselOrNil) {
                                                             [item.morsel removeItemsObject:item];
                                                             [morselOrNil addItemsObject:item];
                                                             item.morsel = morselOrNil;
                                                         }
                                                         if (itemToUpdate) {
                                                             [itemToUpdate.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                             if (successOrNil) successOrNil(responseObject);
                                                         } else {
                                                             if (failureOrNil) failureOrNil(nil);
                                                         }
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)updateItemImage:(MRSLItem *)item
                success:(MRSLAPISuccessBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil {
    if (!item) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (item.itemPhotoFull) {
        [parameters addEntriesFromDictionary:@{@"item" : @{@"photo" : item.itemPhotoFull}}];
    }
    int itemID = item.itemIDValue;
    __block MRSLItem *itemToUpdate = item;
    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"items/%i", itemID]
                                                  withMethod:MRSLAPIMethodTypePUT
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         if (!itemToUpdate || !itemToUpdate.managedObjectContext) {
                                                             itemToUpdate = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                                                    withValue:@(itemID)];
                                                         }
                                                         if (itemToUpdate) {
                                                             itemToUpdate.isUploading = @NO;
                                                             itemToUpdate.itemID = responseObject[@"data"][@"id"];
                                                             [itemToUpdate MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                             [itemToUpdate.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                             if (successOrNil) successOrNil(responseObject);
                                                         } else {
                                                             if (failureOrNil) failureOrNil(nil);
                                                         }
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         if (!itemToUpdate || !itemToUpdate.managedObjectContext) {
                                                             itemToUpdate = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                                                    withValue:@(itemID)];
                                                         }
                                                         if (itemToUpdate.managedObjectContext) {
                                                             itemToUpdate.isUploading = @NO;
                                                             itemToUpdate.didFailUpload = @YES;
                                                         }
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)updatePhotoKey:(NSString *)photoKey
               forItem:(MRSLItem *)item
               success:(MRSLAPISuccessBlock)successOrNil
               failure:(MRSLFailureBlock)failureOrNil {
    if (!item) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    parameters[@"item"] = @{ @"photo_key": photoKey };

    int itemID = item.itemIDValue;
    __block MRSLItem *itemToUpdate = item;
    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"items/%i", itemID]
                                                  withMethod:MRSLAPIMethodTypePUT
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         if (!itemToUpdate || !itemToUpdate.managedObjectContext) {
                                                             itemToUpdate = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                                                                    withValue:@(itemID)];
                                                         }
                                                         [itemToUpdate MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         if (itemToUpdate) {
                                                             [itemToUpdate.managedObjectContext MR_saveToPersistentStoreAndWait];
                                                             if (successOrNil) successOrNil(responseObject);
                                                         } else {
                                                             if (failureOrNil) failureOrNil(nil);
                                                         }
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)deleteItem:(MRSLItem *)item
           success:(MRSLSuccessBlock)successOrNil
           failure:(MRSLFailureBlock)failureOrNil {
    if (!item) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    int itemID = item.itemIDValue;
    NSManagedObjectContext *itemContext = item.managedObjectContext;
    if (!itemContext) return;
    NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:@"itemID == %i", itemID];
    [MRSLItem MR_deleteAllMatchingPredicate:itemPredicate
                                  inContext:itemContext];
    [itemContext MR_saveToPersistentStoreAndWait];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"items/%i", itemID]
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
