//
//  MRSLAPIService+Tag.m
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Tag.h"

#import "MRSLAPIClient.h"

#import "MRSLKeyword.h"
#import "MRSLTag.h"
#import "MRSLUser.h"

@implementation MRSLAPIService (Tag)

#pragma mark - Tag Services

- (void)getCuisineUsers:(MRSLKeyword *)cuisine
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil {
    [self getTagUsersForKeyword:cuisine
                         ofType:MRSLKeywordCuisinesType
                        success:successOrNil
                        failure:failureOrNil];
}

- (void)getSpecialtyUsers:(MRSLKeyword *)specialty
                  success:(MRSLAPIArrayBlock)successOrNil
                  failure:(MRSLFailureBlock)failureOrNil {
    [self getTagUsersForKeyword:specialty
                         ofType:MRSLKeywordSpecialtiesType
                        success:successOrNil
                        failure:failureOrNil];
}

- (void)getTagUsersForKeyword:(MRSLKeyword *)keyword
                       ofType:(NSString *)keywordType
                      success:(MRSLAPIArrayBlock)successOrNil
                      failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"%@/%i/users", keywordType, keyword.keywordIDValue]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             [self importManagedObjectClass:[MRSLUser class]
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

- (void)getUserCuisines:(MRSLUser *)user
                success:(MRSLAPIArrayBlock)successOrNil
                failure:(MRSLFailureBlock)failureOrNil {
    [self getUserTags:user
        ofKeywordType:MRSLKeywordCuisinesType
              success:successOrNil
              failure:failureOrNil];
}

- (void)getUserSpecialties:(MRSLUser *)user
                   success:(MRSLAPIArrayBlock)successOrNil
                   failure:(MRSLFailureBlock)failureOrNil {
    [self getUserTags:user
        ofKeywordType:MRSLKeywordSpecialtiesType
              success:successOrNil
              failure:failureOrNil];
}

- (void)getUserTags:(MRSLUser *)user
      ofKeywordType:(NSString *)keywordType
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:NO];
    [[MRSLAPIClient sharedClient] performRequest:[NSString stringWithFormat:@"users/%i/%@", user.userIDValue, keywordType]
                                      parameters:parameters
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             [self importManagedObjectClass:[MRSLTag class]
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

- (void)getUserTags:(MRSLUser *)user
            success:(MRSLAPIArrayBlock)successOrNil
            failure:(MRSLFailureBlock)failureOrNil {
    __block NSMutableArray *objectIDs = [NSMutableArray array];
    __weak __typeof(self) weakSelf = self;
    [self getUserCuisines:user
                  success:^(NSArray *cuisineResponse) {
                      [objectIDs addObjectsFromArray:cuisineResponse];
                      [weakSelf getUserSpecialties:user
                                           success:^(NSArray *specialtyResponse) {
                                               [objectIDs addObjectsFromArray:specialtyResponse];
                                               if (successOrNil) successOrNil(objectIDs);
                                           } failure:^(NSError *error) {
                                               if (failureOrNil) failureOrNil(error);
                                           }];
                  } failure:^(NSError *error) {
                      if (failureOrNil) failureOrNil(error);
                  }];
}

- (void)createTagForKeyword:(MRSLKeyword *)keyword
                    success:(MRSLAPISuccessBlock)successOrNil
                    failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:@{@"tag": @{@"keyword_id": keyword.keywordID}}
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"users/%i/tags", [MRSLUser currentUser].userIDValue]
                                                  withMethod:MRSLAPIMethodTypePOST
                                              formParameters:[self parametersToDataWithDictionary:parameters]
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                         DDLogVerbose(@"%@ Response: %@", NSStringFromSelector(_cmd), responseObject);
                                                         MRSLTag *tag = [MRSLTag MR_findFirstByAttribute:MRSLTagAttributes.tagID
                                                                                               withValue:responseObject[@"data"][@"id"]];
                                                         if (!tag) tag = [MRSLTag MR_createEntity];
                                                         [tag MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                         [tag.managedObjectContext MR_saveOnlySelfAndWait];
                                                         if (successOrNil) successOrNil(responseObject);
                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                         [self reportFailure:failureOrNil
                                                                forOperation:operation
                                                                   withError:error
                                                                    inMethod:NSStringFromSelector(_cmd)];
                                                     }];
}

- (void)deleteTag:(MRSLTag *)tag
          success:(MRSLSuccessBlock)successOrNil
          failure:(MRSLFailureBlock)failureOrNil {
    NSMutableDictionary *parameters = [self parametersWithDictionary:nil
                                                includingMRSLObjects:nil
                                              requiresAuthentication:YES];
    int tagID = tag.tagIDValue;
    [tag MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];

    [[MRSLAPIClient sharedClient] multipartFormRequestString:[NSString stringWithFormat:@"users/%i/tags/%i", [MRSLUser currentUser].userIDValue, tagID]
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
