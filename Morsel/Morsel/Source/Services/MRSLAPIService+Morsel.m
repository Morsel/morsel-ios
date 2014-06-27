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

- (void)createMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] POST:@"morsels"
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                   [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];

                                   if (successOrNil) successOrNil(responseObject);
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                   [self reportFailure:failureOrNil
                                          forOperation:operation
                                             withError:error
                                              inMethod:NSStringFromSelector(_cmd)];
                               }];
}

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];
    int morselID = morsel.morselIDValue;
    [[MRSLAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"morsels/%i", morselID]
                              parameters:parameters
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                     if (morsel) {
                                         [morsel MR_deleteEntity];
                                         [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                     }
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidDeleteMorselNotification
                                                                                             object:@(morselID)];
                                     });

                                     if (successOrNil) successOrNil(responseObject);
                                 } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                     [self reportFailure:failureOrNil
                                            forOperation:operation
                                               withError:error
                                                inMethod:NSStringFromSelector(_cmd)];
                                 }];
}

- (void)updateMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    [[MRSLAPIClient sharedClient] PUT:[NSString stringWithFormat:@"morsels/%i", morsel.morselIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                  [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidUpdateMorselNotification
                                                                                          object:morsel];
                                  });

                                  if (successOrNil) successOrNil(responseObject);
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:@[morsel]
                                              requiresAuthentication:YES];

    if (sendToFacebook) [parameters setObject:@"true"
                                       forKey:@"post_to_facebook"];
    if (sendToTwitter) [parameters setObject:@"true"
                                      forKey:@"post_to_twitter"];

    [[MRSLAPIClient sharedClient] POST:[NSString stringWithFormat:@"morsels/%i/publish", morsel.morselIDValue]
                            parameters:parameters
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);

                                   [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                   if (successOrNil) successOrNil(responseObject);
                                   if (!willOpenInInstagram) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[NSNotificationCenter defaultCenter] postNotificationName:MRSLUserDidPublishMorselNotification
                                                                                               object:morsel];
                                       });
                                   }
                               } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
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
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];

    int morselObjectID = (morsel) ? morsel.morselIDValue : [morselID intValue];
    if (!morsel && !morselID) {
        DDLogError(@"Unable to get Morsel because both MRSLMorsel and morselID are nil!");
        if (failureOrNil) failureOrNil(nil);
        return;
    }
    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"morsels/%i", morselObjectID]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                      MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                              withValue:@(morselObjectID)];
                                  if (!morsel) morsel = [MRSLMorsel MR_createEntity];

                                  if (morsel.managedObjectContext) {
                                      @try {
                                          [morsel MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                      } @catch (NSException *exception) {
                                          DDLogError(@"Unable to import morsel data due to exception: %@", exception.debugDescription);
                                      }
                                      if (successOrNil) successOrNil(morsel);
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getMorselsForUser:(MRSLUser *)userOrNil
                withMaxID:(NSNumber *)maxOrNil
                orSinceID:(NSNumber *)sinceOrNil
                 andCount:(NSNumber *)countOrNil
               onlyDrafts:(BOOL)shouldOnlyDisplayDrafts
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

    NSString *endpoint = nil;

    if (shouldOnlyDisplayDrafts) {
        endpoint = @"morsels/drafts";
    } else {
        endpoint = (userOrNil) ? [NSString stringWithFormat:@"users/%i/morsels", userOrNil.userIDValue] : @"morsels";
    }

    [[MRSLAPIClient sharedClient] GET:endpoint
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *morselIDs = [NSMutableArray array];
                                      NSArray *userMorselsArray = responseObject[@"data"];

                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [userMorselsArray enumerateObjectsUsingBlock:^(NSDictionary *morselDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                             withValue:morselDictionary[@"id"]
                                                                                             inContext:localContext];
                                              if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                                              [morsel MR_importValuesForKeysWithObject:morselDictionary];
                                              [morselIDs addObject:morselDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(morselIDs);
                                      }];
                                  }
                              } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                                  [self reportFailure:failureOrNil
                                         forOperation:operation
                                            withError:error
                                             inMethod:NSStringFromSelector(_cmd)];
                              }];
}

- (void)getMorselsForPlace:(MRSLPlace *)placeOrNil
                 withMaxID:(NSNumber *)maxOrNil
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

    [[MRSLAPIClient sharedClient] GET:[NSString stringWithFormat:@"places/%i/morsels", placeOrNil.placeIDValue]
                           parameters:parameters
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                  if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                                      __block NSMutableArray *morselIDs = [NSMutableArray array];
                                      NSArray *userMorselsArray = responseObject[@"data"];

                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          [userMorselsArray enumerateObjectsUsingBlock:^(NSDictionary *morselDictionary, NSUInteger idx, BOOL *stop) {
                                              MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                             withValue:morselDictionary[@"id"]
                                                                                             inContext:localContext];
                                              if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                                              [morsel MR_importValuesForKeysWithObject:morselDictionary];
                                              [morselIDs addObject:morselDictionary[@"id"]];
                                          }];
                                      } completion:^(BOOL success, NSError *error) {
                                          if (successOrNil) successOrNil(morselIDs);
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
