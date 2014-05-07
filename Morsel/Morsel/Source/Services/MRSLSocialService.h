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

- (void)shareMorselToFacebook:(MRSLItem *)item
             inViewController:(UIViewController *)viewController
                      success:(MRSLSocialSuccessBlock)successOrNil
                       cancel:(MRSLSocialCancelBlock)cancelBlockOrNil;

- (void)shareMorselToTwitter:(MRSLItem *)item
            inViewController:(UIViewController *)viewController
                     success:(MRSLSocialSuccessBlock)successOrNil
                      cancel:(MRSLSocialCancelBlock)cancelBlockOrNil;

@end
