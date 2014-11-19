//
//  MRSLAPIService+Templates.m
//  Morsel
//
//  Created by Javier Otero on 8/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService+Templates.h"

#import "MRSLAPIService+Item.h"
#import "MRSLAPIService+Morsel.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLTemplate.h"
#import "MRSLTemplateItem.h"

@implementation MRSLAPIService (Templates)

- (void)getTemplatesWithSuccess:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil {
    NSString *fileName = @"templates.json";
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension]
                                                         ofType:[fileName pathExtension]];
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:jsonPath]];
    NSError *jsonError = nil;
    NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:kNilOptions
                                                                     error:&jsonError];
    if (!jsonError) {
        [self importManagedObjectClass:[MRSLTemplate class]
                        withDictionary:responseObject
                               success:successOrNil
                               failure:failureOrNil];
    } else {
        if (failureOrNil) failureOrNil(jsonError);
    }
}

- (void)createMorselWithTemplate:(MRSLTemplate *)morselTemplate
                         success:(MRSLAPISuccessBlock)successOrNil
                         failure:(MRSLFailureBlock)failureOrNil {

    [_appDelegate.apiService createMorselWithTemplateID:morselTemplate.templateID
                                                success:^(id responseObject) {
                                                    MRSLMorsel *morsel = nil;
                                                    if ([responseObject isKindOfClass:[MRSLMorsel class]]) morsel = responseObject;
                                                    [MRSLEventManager sharedManager].new_morsels_created++;
                                                    for (MRSLTemplateItem *templateItem in morselTemplate.itemsArray) {
                                                        MRSLItem *item = [MRSLItem localUniqueItemInContext:morsel.managedObjectContext];
                                                        item.sort_order = @(templateItem.placeholder_sort_orderValue);
                                                        item.placeholder_description = templateItem.placeholder_description;
                                                        item.template_order = templateItem.template_order;
                                                        item.placeholder_photo_large = templateItem.placeholder_photo_large;
                                                        item.placeholder_photo_small = templateItem.placeholder_photo_small;
                                                        item.morsel = morsel;
                                                        [morsel addItemsObject:item];
                                                        [_appDelegate.apiService createItem:item
                                                                                    success:nil
                                                                                    failure:nil];
                                                    }
                                                    if (successOrNil && morsel) successOrNil(morsel);
                                                } failure:^(NSError *error) {
                                                    if (failureOrNil) failureOrNil(error);
                                                }];
}

@end
