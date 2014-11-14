//
//  MRSLActivityProvider.m
//  Morsel
//
//  Created by Javier Otero on 11/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityItemShareTextProvider.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@implementation MRSLActivityItemShareTextProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType {
    NSString *userFullName = self.morsel.creator.fullName;
    NSString *shareText = [NSString stringWithFormat:@"“%@” from %@ on Morsel", self.morsel.title, userFullName];

    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        NSString *twitterHandle =  [self.morsel.creator fullNameOrTwitterHandle];
        shareText = [NSString stringWithFormat:@"“%@” from %@ on @eatmorsel", self.morsel.title, twitterHandle];
    }
    return shareText;
}

@end
