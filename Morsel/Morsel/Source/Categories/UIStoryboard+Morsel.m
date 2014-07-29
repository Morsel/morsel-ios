//
//  UIStoryboard+Morsel.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIStoryboard+Morsel.h"

@implementation UIStoryboard (Morsel)

#pragma mark - Main

+ (UIStoryboard *)activityStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneActivityKey
                                     bundle:nil];
}

+ (UIStoryboard *)feedStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneFeedKey
                                     bundle:nil];
}

+ (UIStoryboard *)loginStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneLoginKey
                                     bundle:nil];
}

+ (UIStoryboard *)mainStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneMainKey
                                     bundle:nil];
}

+ (UIStoryboard *)mediaManagementStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneMediaManagementKey
                                     bundle:nil];
}

+ (UIStoryboard *)morselManagementStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneMorselManagementKey
                                     bundle:nil];
}

+ (UIStoryboard *)placesStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhonePlacesKey
                                     bundle:nil];
}

+ (UIStoryboard *)profileStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneProfileKey
                                     bundle:nil];
}

+ (UIStoryboard *)settingsStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneSettingsKey
                                     bundle:nil];
}

+ (UIStoryboard *)socialStoryboard {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneSocialKey
                                     bundle:nil];
}

#pragma mark - Specs

+ (UIStoryboard *)specsStoryboardInBundle:(NSBundle *)bundleOrNil {
    return [UIStoryboard storyboardWithName:MRSLStoryboardiPhoneSpecsKey
                                     bundle:bundleOrNil];
}

@end
