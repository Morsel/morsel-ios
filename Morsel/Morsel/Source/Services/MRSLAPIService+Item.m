//
//  MRSLAPIService+Item.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Item.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Item)

#pragma mark - Item Services

- (void)createItem:(MRSLItem *)item
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[item]
                                              requiresAuthentication:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidBeginCreateMorselNotification
                                                            object:nil];
    });

    NSString *itemLocalUUID = [item.localUUID copy];

    __block MRSLItem *localItem = item;

    [[MRSLAPIClient sharedClient] POST:@"items"
                            parameters:parameters
                               success: ^(AFHTTPRequestOperation * operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                   if (!localItem || !localItem.managedObjectContext) {
                                       localItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.localUUID
                                                                           withValue:itemLocalUUID];
                                   }
                                   if (localItem && localItem.managedObjectContext) {
                                       [localItem MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[NSNotificationCenter defaultCenter] postNotificationName:MRSLItemUploadDidCompleteNotification
                                                                                               object:localItem];
                                       });
                                       [localItem.managedObjectContext MR_saveOnlySelfAndWait];
                                       if (successOrNil) successOrNil(localItem);
                                   }
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
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
                                                 withError:error
                                                  inMethod:NSStringFromSelector(_cmd)];
                                   }
                               }];
}

- (void)getItem:(MRSLItem *)item
        success:(MRSLAPISuccessBlock)successOrNil
        failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    int itemID = item.itemIDValue;
    __block MRSLItem *itemToGet = item;

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"items/%i", itemID]
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
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)updateItem:(MRSLItem *)item
         andMorsel:(MRSLMorsel *)morselOrNil
           success:(MRSLAPISuccessBlock)successOrNil
           failure:(MRSLFailureBlock)failureOrNil {
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

    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"items/%i", item.itemIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                  if (morselOrNil) {
                                      [item.morsel removeItemsObject:item];
                                      [morselOrNil addItemsObject:item];
                                      item.morsel = morselOrNil;
                                  }

                                  [item MR_importValuesForKeysWithObject:responseObject[@"data"]];

                                  if (successOrNil) successOrNil(responseObject);
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)updateItemImage:(MRSLItem *)item
                success:(MRSLAPISuccessBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[item]
                                              requiresAuthentication:YES];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    NSString *urlString = [[NSURL URLWithString:[NSString stringWithFormat:@"items/%i", item.itemIDValue] relativeToURL:[[MRSLAPIClient sharedClient] baseURL]] absoluteString];
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"PUT"
                                                                           URLString:urlString
                                                                          parameters:parameters
                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                               if (item.itemPhotoFull) {
                                                                   [formData appendPartWithFileData:item.itemPhotoFull
                                                                                               name:@"item[photo]"
                                                                                           fileName:@"photo.jpg"
                                                                                           mimeType:@"image/jpeg"];
                                                               }
                                                           }];

    AFHTTPRequestOperation *operation = [[MRSLAPIClient sharedClient] HTTPRequestOperationWithRequest:request
                                                                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                                                                  if (item.managedObjectContext) {
                                                                                                      item.isUploading = @NO;
                                                                                                      item.itemID = responseObject[@"data"][@"id"];
                                                                                                      [item MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                                                                      [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                                                                                  }
                                                                                                  if (successOrNil) successOrNil(responseObject);
                                                                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                  if (item.managedObjectContext) {
                                                                                                      item.isUploading = @NO;
                                                                                                      item.didFailUpload = @YES;
                                                                                                  }
                                                                                                  [self reportFailure:failureOrNil
                                                                                                            withError:error
                                                                                                             inMethod:NSStringFromSelector(_cmd)];
                                                                                              }];
    [[MRSLAPIClient sharedClient].operationQueue addOperation:operation];
}

- (void)deleteItem:(MRSLItem *)item
           success:(MRSLSuccessBlock)successOrNil
           failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    int itemID = item.itemIDValue;

    [item MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"items/%i", itemID]
                              parameters:parameters
                                 success:nil
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     if ([operation.response statusCode] == 200) {
                                         if (successOrNil) successOrNil(YES);
                                     } else {
                                         [self reportFailure:failureOrNil
                                                   withError:error
                                                    inMethod:NSStringFromSelector(_cmd)];
                                     }
                                 }];
}

@end
