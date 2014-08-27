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
    MRSLMorsel *morsel = [MRSLMorsel MR_createEntity];
    morsel.draft = @YES;
    morsel.title = [NSString stringWithFormat:@"%@ morsel", morselTemplate.title];
    morsel.template_id = morselTemplate.templateID;

    [_appDelegate.apiService createMorsel:morsel
                                  success:^(id responseObject) {
                                      [MRSLEventManager sharedManager].new_morsels_created++;
                                      __block NSManagedObjectContext *workContext = nil;
                                      __block MRSLMorsel *morselInContext = nil;
                                      [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                          morselInContext = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                      withValue:morsel.morselID
                                                                                      inContext:localContext];
                                          for (MRSLTemplateItem *templateItem in morselTemplate.itemsArray) {
                                              MRSLItem *item = [MRSLItem localUniqueItemInContext:localContext];
                                              item.sort_order = @(templateItem.placeholder_sort_orderValue + 1);
                                              item.placeholder_description = templateItem.placeholder_description;
                                              item.template_order = templateItem.template_order;
                                              item.placeholder_photo_large = templateItem.placeholder_photo_large;
                                              item.placeholder_photo_small = templateItem.placeholder_photo_small;
                                              item.morsel = morselInContext;
                                              [morselInContext addItemsObject:item];
                                              [_appDelegate.apiService createItem:item
                                                                          success:nil
                                                                          failure:nil];
                                          }
                                      } completion:^(BOOL success, NSError *error) {
                                          if (success) [workContext reset];
                                          morselInContext = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                                                      withValue:morsel.morselID];
                                          if (successOrNil && morselInContext) successOrNil(morselInContext);
                                      }];
                                  } failure:^(NSError *error) {
                                      if (failureOrNil) failureOrNil(error);
                                      [morsel MR_deleteEntity];
                                  }];
}

@end
