//
//  MRSLActivityItemShareURLProvider.m
//  Morsel
//
//  Created by Javier Otero on 11/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityItemShareURLProvider.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@implementation MRSLActivityItemShareURLProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType {
    NSURL *shareURL = [NSURL URLWithString:self.morsel.clipboard_mrsl ?: self.morsel.url];

    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        shareURL = [NSURL URLWithString:self.morsel.facebook_mrsl ?: self.morsel.url];
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        shareURL = [NSURL URLWithString:self.morsel.twitter_mrsl ?: self.morsel.url];
    }

    return shareURL;
}

@end
