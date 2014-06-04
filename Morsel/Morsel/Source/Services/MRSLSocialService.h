//
//  SocialService.h
//  Morsel
//
//  Created by Marty Trzpit on 1/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLSocialService : NSObject

+ (instancetype)sharedService;

- (void)shareMorselToFacebook:(MRSLMorsel *)morsel
             inViewController:(UIViewController *)viewController
                      success:(MRSLSocialSuccessBlock)successOrNil
                       cancel:(MRSLSocialCancelBlock)cancelBlockOrNil;

- (void)shareMorselToTwitter:(MRSLMorsel *)morsel
            inViewController:(UIViewController *)viewController
                     success:(MRSLSocialSuccessBlock)successOrNil
                      cancel:(MRSLSocialCancelBlock)cancelBlockOrNil;

- (void)shareTextToTwitter:(NSString *)text
          inViewController:(UIViewController *)viewController
                   success:(MRSLSocialSuccessBlock)successOrNil
                    cancel:(MRSLSocialCancelBlock)cancelBlockOrNil;

@end
