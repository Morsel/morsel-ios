//
//  MorselAPIService.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

#import "NSManagedObject+JSON.h"

#import "MRSLActivity.h"
#import "MRSLComment.h"
#import "MRSLItem.h"
#import "MRSLNotification.h"
#import "MRSLMorsel.h"
#import "MRSLKeyword.h"
#import "MRSLTag.h"
#import "MRSLUser.h"

@implementation MRSLAPIService

#pragma mark - Parameters

- (NSMutableDictionary *)parametersWithDictionary:(NSDictionary *)dictionaryOrNil
                             includingMRSLObjects:(NSArray *)objects
                           requiresAuthentication:(BOOL)requiresAuthentication {
    __block NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionary];
    // append initial dictionary
    if (dictionaryOrNil) [parametersDictionary addEntriesFromDictionary:dictionaryOrNil];
    // loop through objects and convert into JSON
    for (NSManagedObject *managedObject in objects) {
        if ([managedObject respondsToSelector:@selector(objectToJSON)]) {
            NSDictionary *objectDictionary = [managedObject objectToJSON];
            [parametersDictionary addEntriesFromDictionary:objectDictionary];
        }
    }
    // apply authentication
    if (requiresAuthentication) [parametersDictionary setObject:[MRSLUser apiTokenForCurrentUser]
                                                         forKey:@"api_key"];
    // apply device information
    [parametersDictionary setObject:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"ipad" : @"iphone"
                             forKey:@"client[device]"];

    NSString *releaseAppendedIdentifier = @"";
#if defined(MORSEL_BETA)
    releaseAppendedIdentifier = @"b";
#endif
    [parametersDictionary setObject:[NSString stringWithFormat:@"%@%@", [MRSLUtil appMajorMinorPatchString], releaseAppendedIdentifier]
                             forKey:@"client[version]"];
    return parametersDictionary;
}

#pragma mark - Importing Helpers

- (void)importTagsWithDictionary:(NSDictionary *)responseDictionary
                             success:(MRSLAPIArrayBlock)successOrNil {
    __block NSMutableArray *tagIDs = [NSMutableArray array];
    NSArray *tagArray = responseDictionary[@"data"];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [tagArray enumerateObjectsUsingBlock:^(NSDictionary *tagDictionary, NSUInteger idx, BOOL *stop) {
            MRSLTag *tag = [MRSLTag MR_findFirstByAttribute:MRSLTagAttributes.tagID
                                                              withValue:tagDictionary[@"id"]
                                                              inContext:localContext];
            if (!tag) tag = [MRSLTag MR_createInContext:localContext];
            [tag MR_importValuesForKeysWithObject:tagDictionary];
            [tagIDs addObject:tagDictionary[@"id"]];
        }];
    } completion:^(BOOL success, NSError *error) {
        if (successOrNil) successOrNil(tagIDs);
    }];
}

- (void)importKeywordsWithDictionary:(NSDictionary *)responseDictionary
                             success:(MRSLAPIArrayBlock)successOrNil {
    __block NSMutableArray *keywordIDs = [NSMutableArray array];
    NSArray *keywordArray = responseDictionary[@"data"];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [keywordArray enumerateObjectsUsingBlock:^(NSDictionary *keywordDictionary, NSUInteger idx, BOOL *stop) {
            MRSLKeyword *keyword = [MRSLKeyword MR_findFirstByAttribute:MRSLKeywordAttributes.keywordID
                                                              withValue:keywordDictionary[@"id"]
                                                              inContext:localContext];
            if (!keyword) keyword = [MRSLKeyword MR_createInContext:localContext];
            [keyword MR_importValuesForKeysWithObject:keywordDictionary];
            [keywordIDs addObject:keywordDictionary[@"id"]];
        }];
    } completion:^(BOOL success, NSError *error) {
        if (successOrNil) successOrNil(keywordIDs);
    }];
}

- (void)importUsersWithDictionary:(NSDictionary *)responseDictionary
                          success:(MRSLAPIArrayBlock)successOrNil {
    if ([responseDictionary[@"data"] isKindOfClass:[NSArray class]]) {
        __block NSMutableArray *userIDs = [NSMutableArray array];
        NSArray *userArray = responseDictionary[@"data"];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [userArray enumerateObjectsUsingBlock:^(NSDictionary *userDictionary, NSUInteger idx, BOOL *stop) {
                MRSLUser *user = [MRSLUser MR_findFirstByAttribute:MRSLUserAttributes.userID
                                                                                 withValue:userDictionary[@"id"]
                                                                                 inContext:localContext];
                if (!user) user = [MRSLUser MR_createInContext:localContext];
                NSString *authToken = user.auth_token;
                [user MR_importValuesForKeysWithObject:userDictionary];
                if ([user isCurrentUser] && authToken && !user.auth_token) user.auth_token = authToken;
                [userIDs addObject:userDictionary[@"id"]];
            }];
        } completion:^(BOOL success, NSError *error) {
            if (successOrNil) successOrNil(userIDs);
        }];
    }
}

#pragma mark - Errors

- (void)reportFailure:(MRSLFailureBlock)failureOrNil
            withError:(NSError *)error
             inMethod:(NSString *)methodName {
    MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

    if (!serviceErrorInfo) {
        DDLogError(@"Request error in method (%@) with userInfo: %@", methodName, error.userInfo);
    } else {
        DDLogError(@"Request error in method (%@) with serviceInfo: %@", methodName, [serviceErrorInfo errorInfo]);
    }
    
    if (failureOrNil) failureOrNil(error);
}

@end
