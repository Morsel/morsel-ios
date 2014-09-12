//
//  MorselAPIService.m
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

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
    if (requiresAuthentication && ![MRSLUser isCurrentUserGuest]) [parametersDictionary setObject:[MRSLUser apiTokenForCurrentUser]
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

/*
 Converts parameter keys into NSData.
 */
- (NSDictionary *)parametersToDataWithDictionary:(NSDictionary *)parameters {
    __block NSMutableDictionary *parameterDictionary = [NSMutableDictionary dictionary];
    __weak __typeof(self) weakSelf = self;
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            parameterDictionary[key] = [weakSelf parametersToDataWithDictionary:obj];
        } else {
            if ([obj isKindOfClass:[NSString class]]) {
                parameterDictionary[key] = [obj dataUsingEncoding:NSUTF8StringEncoding];
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                parameterDictionary[key] = [[obj stringValue] dataUsingEncoding:NSUTF8StringEncoding];
            } else if ([obj isKindOfClass:[NSData class]]) {
                parameterDictionary[key] = obj;
            } else if ([obj isKindOfClass:[NSNull class]]) {
                parameterDictionary[key] = [@"<null>" dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                DDLogDebug(@"Unsupported form parameter object will not be converted to NSData: %@", obj);
            }
        }
    }];
    return parameterDictionary;
}

#pragma mark - Importing Helpers

- (void)importManagedObjectClass:(Class)objectClass
                  withDictionary:(NSDictionary *)responseDictionary
                         success:(MRSLAPIArrayBlock)successOrNil
                         failure:(MRSLFailureBlock)failureOrNil {
    __block NSMutableArray *objectIDs = [NSMutableArray array];
    NSArray *objectArray = responseDictionary[@"data"];
    __block NSManagedObjectContext *workContext = nil;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        workContext = localContext;
        [objectArray enumerateObjectsUsingBlock:^(NSDictionary *objectDictionary, NSUInteger idx, BOOL *stop) {
            NSManagedObject *managedObject = [objectClass MR_findFirstByAttribute:[objectClass API_identifier]
                                                                        withValue:objectDictionary[@"id"]
                                                                        inContext:localContext];
            if (!managedObject) managedObject = [objectClass MR_createInContext:localContext];
            [managedObject MR_importValuesForKeysWithObject:objectDictionary];
            [objectIDs addObject:objectDictionary[@"id"]];
        }];
    } completion:^(BOOL success, NSError *error) {
        if (!error || [objectIDs count] > 0) {
            if (successOrNil) successOrNil(objectIDs);
        } else {
            if (failureOrNil) failureOrNil(error);
        }
        if (success) [workContext reset];
    }];
}

- (void)importFeedObjectsWithDictionary:(NSDictionary *)responseDictionary
                                success:(MRSLAPIArrayBlock)successOrNil {
    if ([responseDictionary[@"data"] isKindOfClass:[NSArray class]]) {
        __block NSMutableArray *feedItemIDs = [NSMutableArray array];
        NSArray *feedItemsArray = responseDictionary[@"data"];
        __weak __block NSManagedObjectContext *workContext = nil;
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            workContext = localContext;
            [feedItemsArray enumerateObjectsUsingBlock:^(NSDictionary *feedItemDictionary, NSUInteger idx, BOOL *stop) {
                if ([[feedItemDictionary[@"subject_type"] lowercaseString] isEqualToString:@"morsel"]) {
                    if (![feedItemDictionary[@"subject"] isEqual:[NSNull null]]) {
                        NSDictionary *morselDictionary = feedItemDictionary[@"subject"];
                        MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                       withValue:morselDictionary[@"id"]
                                                                       inContext:localContext];
                        if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                        [morsel MR_importValuesForKeysWithObject:morselDictionary];
                        morsel.feedItemID = feedItemDictionary[@"id"];
                        morsel.feedItemFeatured = @([feedItemDictionary[@"featured"] boolValue]);
                        if ([morsel.items count] > 0) [feedItemIDs addObject:morselDictionary[@"id"]];
                    }
                }
            }];
        } completion:^(BOOL success, NSError *error) {
            if (successOrNil) successOrNil(feedItemIDs);
            if (success) [workContext reset];
        }];
    }
}

- (void)importLikeablesWithDictionary:(NSDictionary *)responseDictionary
                              success:(MRSLAPIArrayBlock)successOrNil {
    if ([responseDictionary[@"data"] isKindOfClass:[NSArray class]]) {
        __block NSMutableArray *itemIDs = [NSMutableArray array];
        NSArray *likeablesArray = responseDictionary[@"data"];
        __block NSManagedObjectContext *workContext = nil;
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            workContext = localContext;
            [likeablesArray enumerateObjectsUsingBlock:^(NSDictionary *itemDictionary, NSUInteger idx, BOOL *stop) {
                MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                               withValue:itemDictionary[@"morsel"][@"id"]
                                                               inContext:localContext];
                if (!morsel) morsel = [MRSLMorsel MR_createInContext:localContext];
                [morsel MR_importValuesForKeysWithObject:itemDictionary[@"morsel"]];
                MRSLItem *item = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                         withValue:itemDictionary[@"id"]
                                                         inContext:localContext];
                if (!item) item = [MRSLItem MR_createInContext:localContext];
                [item MR_importValuesForKeysWithObject:itemDictionary];
                [itemIDs addObject:itemDictionary[@"id"]];
            }];
        } completion:^(BOOL success, NSError *error) {
            if (successOrNil) successOrNil(itemIDs);
            if (success) [workContext reset];
        }];
    }
}

#pragma mark - Errors

- (void)reportFailure:(MRSLFailureBlock)failureOrNil
         forOperation:(AFHTTPRequestOperation *)operation
            withError:(NSError *)error
             inMethod:(NSString *)methodName {
    if ([MRSLUser isCurrentUserGuest]) {
        if (failureOrNil) failureOrNil(nil);
        return;
    }
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
