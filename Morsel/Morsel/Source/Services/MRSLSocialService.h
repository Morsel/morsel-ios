//
//  SocialService.h
//  Morsel
//
//  Created by Marty Trzpit on 1/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@class ACAccount;
@class SLRequestHandler;

@interface MRSLSocialService : NSObject

+ (instancetype)sharedService;

- (void)activateFacebookWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                       failure:(MRSLSocialFailureBlock)failureOrNil;

- (void)activateTwitterWithSuccess:(MRSLSocialSuccessBlock)successOrNil
                      failure:(MRSLSocialFailureBlock)failureOrNil;

- (void)shareMorselToFacebook:(MRSLItem *)item
             inViewController:(UIViewController *)viewController
                      success:(MRSLSocialSuccessBlock)successOrNil
                       cancel:(MRSLSocialCancelBlock)cancelBlockOrNil;

- (void)shareMorselToTwitter:(MRSLItem *)item
            inViewController:(UIViewController *)viewController
                     success:(MRSLSocialSuccessBlock)successOrNil
                      cancel:(MRSLSocialCancelBlock)cancelBlockOrNil;

@end
