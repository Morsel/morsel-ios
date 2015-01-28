//
//  MRSLAPIService+Morsel.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Morsel.h"

#import "MRSLAPIClient.h"

#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Morsel)

#pragma mark - Morsel Services

- (void)createMorselWithSuccess:(MRSLAPISuccessBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"morsel": @{@"title" : NSNullIfNil(nil)}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:@"morsels"
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                                        withValue:responseObject[@"data"][@"id"]
                                                                                                        inContext:[NSManagedObjectContext MR_defaultContext]];
                                                         if (!morsel) morsel = [MRSLMorsel MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
                                                         [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         [MRSLUser incrementCurrentUserDraftCount];
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidCreateMorselNotification
                                                                                                                 object:morsel.morselID];
                                                         });
                                                         if (successOrNil) successOrNil(morsel);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil {
    if (!morsel) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];
    int morselID = morsel.morselIDValue;
    NSManagedObjectContext *morselContext = morsel.managedObjectContext;
    NSPredicate *morselPredicate = [NSPredicate predicateWithFormat:@"morselID == %i", morselID];
    [MRSLMorsel MR_deleteAllMatchingPredicate:morselPredicate
                                    inContext:morselContext];
    [morselContext MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidDeleteMorselNotification
                                                        object:@(morselID)];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"morsels/%i", morselID]
                                                  withMethod:MRSLAPIMethodTypeDELETE
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         [MRSLUser decrementCurrentUserDraftCount];
                                                         if (successOrNil) successOrNil(responseObject);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)updateMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil {
    if (!morsel) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"morsels/%i", morsel.morselIDValue]
                                                  withMethod:MRSLAPIMethodTypePUT
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                                         [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdateMorselNotification
                                                                                                                 object:morsel];
                                                         });

                                                         if (successOrNil) successOrNil(responseObject);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)publishMorsel:(MRSLMorsel *)morsel
              success:(MRSLAPISuccessBlock)successOrNil
              failure:(MRSLFailureBlock)failureOrNil
       sendToFacebook:(BOOL)sendToFacebook
        sendToTwitter:(BOOL)sendToTwitter
  willOpenInInstagram:(BOOL)willOpenInInstagram {
    if (!morsel) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    if (sendToFacebook) [parameters setObject:@"true"
                                       forKey:@"post_to_facebook"];
    if (sendToTwitter) [parameters setObject:@"true"
                                      forKey:@"post_to_twitter"];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"morsels/%i/publish", morsel.morselIDValue]
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                                         [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         if (successOrNil) successOrNil(responseObject);
                                                         if (!willOpenInInstagram) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [[NSUserDefaults standardUserDefaults] setInteger:[morsel.morselID integerValue]
                                                                                                            forKey:@"recentlyPublishedMorselID"];
                                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidPublishMorselNotification
                                                                                                                     object:morsel];
                                                             });
                                                         }
                                                         [MRSLUser decrementCurrentUserDraftCount];
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         if (morsel) morsel.draft = @(!morsel.draftValue);
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)getMorsel:(MRSLMorsel *)morsel
         orWithID:(NSNumber *)morselID
          success:(MRSLAPISuccessBlock)successOrNil
          failure:(MRSLFailureBlock)failureOrNil {
    if (!morsel) return;
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];

    int morselObjectID = (morsel) ? morsel.morselIDValue : [morselID intValue];
    if (!morsel && !morselID) {
        DDLogError(@"Unable to get Morsel because both MRSLMorsel and morselID are nil!");
        if (failureOrNil) failureOrNil(nil);
        return;
    }
    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"morsels/%i", morselObjectID]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             MRSLMorsel *localMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                                 withValue:@(morselObjectID)
                                                                                                 inContext:[NSManagedObjectContext MR_defaultContext]];
                                             if (!localMorsel) localMorsel = [MRSLMorsel MR_createInContext:[NSManagedObjectContext MR_defaultContext]];

                                             if (localMorsel.managedObjectContext) {
                                                 @try {
                                                     [localMorsel MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                 } @catch (NSException *exception) {
                                                     DDLogError(@"Unable to import morsel data due to exception: %@", exception.debugDescription);
                                                 }
                                                 if (successOrNil) successOrNil(localMorsel);
                                             }
                                         } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                             [self reportFailure:failureOrNil
                                                    forOperation:operation
                                                       withError:error
                                                        inMethod:NSStringFromSelector(_cmd)];
                                         }];
}

- (void)getMorselsForUser:(MRSLUser *)userOrNil
                     page:(NSNumber *)pageOrNil
                    count:(NSNumber *)countOrNil
               onlyDrafts:(BOOL)shouldOnlyDisplayDrafts
                  success:(MRSLAPIArrayBlock)successOrNil
                  failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;

    NSString *endpoint = nil;

    if (shouldOnlyDisplayDrafts) {
        endpoint = @"morsels/drafts";
    } else {
        endpoint = (userOrNil) ? [NSString stringWithFormat:@"users/%i/morsels", userOrNil.userIDValue] : @"morsels";
    }

    [[MRSLAPIClient sharedClient] performRequest:endpoint
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             [self importManagedObjectClass:[MRSLMorsel class]
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

- (void)getMorselsForPlace:(MRSLPlace *)placeOrNil
                      page:(NSNumber *)pageOrNil
                     count:(NSNumber *)countOrNil
                   success:(MRSLAPIArrayBlock)successOrNil
                   failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;

    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"places/%i/morsels", placeOrNil.placeIDValue]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                             [self importManagedObjectClass:[MRSLMorsel class]
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

- (void)tagUser:(MRSLUser *)user
       toMorsel:(MRSLMorsel *)morsel
      shouldTag:(BOOL)shouldTag
         didTag:(MRSLAPITagBlock)tagBlockOrNil
        failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (shouldTag) {
        [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"morsels/%i/tagged_users/%i", morsel.morselIDValue, user.userIDValue]
                                                      withMethod:MRSLAPIMethodTypePOST
                                                  formParameters:[self parametersToDataWithDictionary:parameters]
                                                      parameters:nil
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             if (tagBlockOrNil) tagBlockOrNil(YES);
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                             if ([operation.response statusCode] == 200 || [[serviceErrorInfo.errorInfo lowercaseString] isEqualToString:@"user: already tagged"]) {
                                                                 if (tagBlockOrNil) tagBlockOrNil(YES);
                                                             } else {
                                                                 [self reportFailure:failureOrNil
                                                                        forOperation:operation
                                                                           withError:error
                                                                            inMethod:NSStringFromSelector(_cmd)];
                                                             }
                                                         }];
    } else {
        [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"morsels/%i/tagged_users/%i", morsel.morselIDValue, user.userIDValue]
                                                      withMethod:MRSLAPIMethodTypeDELETE
                                                  formParameters:[self parametersToDataWithDictionary:parameters]
                                                      parameters:nil
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             if (tagBlockOrNil) tagBlockOrNil(NO);
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];
                                                             if ([operation.response statusCode] == 200 || [[serviceErrorInfo.errorInfo lowercaseString] isEqualToString:@"user: not tagged"]) {
                                                                 if (tagBlockOrNil) tagBlockOrNil(NO);
                                                             } else {
                                                                 [self reportFailure:failureOrNil
                                                                        forOperation:operation
                                                                           withError:error
                                                                            inMethod:NSStringFromSelector(_cmd)];
                                                             }
                                                         }];
    }
}

- (void)getTaggedUsersForMorsel:(MRSLMorsel *)morsel
                           page:(NSNumber *)pageOrNil
                          count:(NSNumber *)countOrNil
                        success:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;
    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"morsels/%i/tagged_users", morsel.morselIDValue]
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

- (void)getEligibleTaggedUsersForMorsel:(MRSLMorsel *)morsel
                             usingQuery:(NSString *)queryOrNil
                                   page:(NSNumber *)pageOrNil
                                  count:(NSNumber *)countOrNil
                                success:(MRSLAPIArrayBlock)successOrNil
                                failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    if (pageOrNil) parameters[@"page"] = pageOrNil;
    if (countOrNil) parameters[@"count"] = countOrNil;

    if ([queryOrNil length] > 2) {
        parameters[@"query"] = queryOrNil;
    }

    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"morsels/%i/eligible_tagged_users", morsel.morselIDValue]
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

@end
