//
//  MRSLAPIService+Morsel.h
//  Morsel
//
//  Created by Javier Otero on 5/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLAPIService.h"

@interface MRSLAPIService (Morsel)

#pragma mark - Morsel Services

- (void)createMorselWithTemplateID:(NSNumber *)templateID
                           success:(MRSLAPISuccessBlock)successOrNil
                           failure:(MRSLFailureBlock)failureOrNil;

- (void)deleteMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil;

- (void)updateMorsel:(MRSLMorsel *)morsel
             success:(MRSLAPISuccessBlock)successOrNil
             failure:(MRSLFailureBlock)failureOrNil;

- (void)publishMorsel:(MRSLMorsel *)morsel
              success:(MRSLAPISuccessBlock)successOrNil
              failure:(MRSLFailureBlock)failureOrNil
       sendToFacebook:(BOOL)sendToFacebook
        sendToTwitter:(BOOL)sendToTwitter
  willOpenInInstagram:(BOOL)willOpenInInstagram;

- (void)getMorsel:(MRSLMorsel *)morsel
         orWithID:(NSNumber *)morselID
          success:(MRSLAPISuccessBlock)successOrNil
          failure:(MRSLFailureBlock)failureOrNil;

- (void)getMorselsForUser:(MRSLUser *)userOrNil
                     page:(NSNumber *)pageOrNil
                    count:(NSNumber *)countOrNil
               onlyDrafts:(BOOL)shouldOnlyDisplayDrafts
                  success:(MRSLAPIArrayBlock)successOrNil
                  failure:(MRSLFailureBlock)failureOrNil;

- (void)getMorselsForPlace:(MRSLPlace *)placeOrNil
                      page:(NSNumber *)pageOrNil
                     count:(NSNumber *)countOrNil
                   success:(MRSLAPIArrayBlock)successOrNil
                   failure:(MRSLFailureBlock)failureOrNil;

- (void)tagUser:(MRSLUser *)user
       toMorsel:(MRSLMorsel *)morsel
      shouldTag:(BOOL)shouldTag
         didTag:(MRSLAPITagBlock)tagBlockOrNil
        failure:(MRSLFailureBlock)failureOrNil;

- (void)getTaggedUsersForMorsel:(MRSLMorsel *)morsel
                           page:(NSNumber *)pageOrNil
                          count:(NSNumber *)countOrNil
                        success:(MRSLAPIArrayBlock)successOrNil
                        failure:(MRSLFailureBlock)failureOrNil;

- (void)getEligibleTaggedUsersForMorsel:(MRSLMorsel *)morsel
                             usingQuery:(NSString *)queryOrNil
                                   page:(NSNumber *)pageOrNil
                                  count:(NSNumber *)countOrNil
                                success:(MRSLAPIArrayBlock)successOrNil
                                failure:(MRSLFailureBlock)failureOrNil;

@end
