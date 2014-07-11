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
#import "MRSLPlace.h"
#import "MRSLKeyword.h"
#import "MRSLTag.h"
#import "MRSLUser.h"

@interface MRSLAPIService ()
<UIAlertViewDelegate>

@property (nonatomic) BOOL loggingOut;

@end

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
        if ([managedObject respondsToSelector:@selector(jsonKeyName)]) {
            NSString *jsonKeyName = [managedObject jsonKeyName];
            if (parametersDictionary[jsonKeyName] != nil) {
                //  Since the key already exists, we need to merge the passed in parameters onto the existing managedObject values
                NSMutableDictionary *combinedDictionary = [NSMutableDictionary dictionaryWithDictionary:[managedObject objectToJSON]];
                [combinedDictionary addEntriesFromDictionary:parametersDictionary[jsonKeyName]];
                [parametersDictionary setObject:combinedDictionary
                                         forKey:jsonKeyName];
            } else {
                [parametersDictionary setObject:[managedObject objectToJSON]
                                         forKey:jsonKeyName];
            }
        }
    }
    // apply authentication
    if (requiresAuthentication) [parametersDictionary setObject:[MRSLUser apiTokenForCurrentUser]
                                                         forKey:@"api_key"];
    // apply device information
    NSString *releaseAppendedIdentifier = @"";
#if defined(MORSEL_BETA)
    releaseAppendedIdentifier = @"b";
#endif

    parametersDictionary[@"client"] = @{
                                        @"device": (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"ipad" : @"iphone",
                                        @"version": [NSString stringWithFormat:@"%@%@", [MRSLUtil appMajorMinorPatchString], releaseAppendedIdentifier],
                                        @"model": NSNullIfNil([MRSLUtil deviceModel]),
                                        @"os": NSNullIfNil([MRSLUtil deviceVersion]),
                                        @"build": NSNullIfNil(ROLLBAR_ENVIRONMENT)
                                        };

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
                [user MR_importValuesForKeysWithObject:userDictionary];
                [userIDs addObject:userDictionary[@"id"]];
            }];
        } completion:^(BOOL success, NSError *error) {
            if (successOrNil) successOrNil(userIDs);
        }];
    }
}

#pragma mark - Errors

- (void)reportFailure:(MRSLFailureBlock)failureOrNil
         forOperation:(AFHTTPRequestOperation *)operation
            withError:(NSError *)error
             inMethod:(NSString *)methodName {
    if (!self.loggingOut) {
        if (operation.response.statusCode == 401 && [[operation.responseObject[@"errors"][@"api"] firstObject] isEqualToString:@"unauthorized"]) {
            [UIAlertView showAlertViewWithTitle:@"Session Expired"
                                        message:@"Your session has expired. Please log in again to continue."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
            self.loggingOut = YES;
        } else {
            MRSLServiceErrorInfo *serviceErrorInfo = error.userInfo[JSONResponseSerializerWithServiceErrorInfoKey];

            if (!serviceErrorInfo) {
                DDLogError(@"Request error in method (%@) with userInfo: %@", methodName, error.userInfo);
            } else {
                DDLogError(@"Request error in method (%@) with serviceInfo: %@", methodName, [serviceErrorInfo errorInfo]);
            }
            
            if (failureOrNil) failureOrNil(error);
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        self.loggingOut = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLServiceShouldLogOutUserNotification
                                                            object:nil];
    }
}

@end
