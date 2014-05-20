//
//  UIStoryboard+Morsel.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIStoryboard+Morsel.h"

@implementation UIStoryboard (Morsel)

+ (UIStoryboard *)mainStoryboard {
    return [UIStoryboard storyboardWithName:[UIDevice currentDeviceIsIpad] ? @"Main_iPad" : @"Main_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)feedStoryboard {
    return [UIStoryboard storyboardWithName:[UIDevice currentDeviceIsIpad] ? @"Feed_iPad" : @"Feed_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)profileStoryboard {
    return [UIStoryboard storyboardWithName:[UIDevice currentDeviceIsIpad] ? @"Profile_iPad" : @"Profile_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)socialStoryboard {
    return [UIStoryboard storyboardWithName:[UIDevice currentDeviceIsIpad] ? @"Social_iPad" : @"Social_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)loginStoryboard {
    return [UIStoryboard storyboardWithName:[UIDevice currentDeviceIsIpad] ? @"Login_iPad" : @"Login_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)mediaManagementStoryboard {
    return [UIStoryboard storyboardWithName:[UIDevice currentDeviceIsIpad] ? @"MediaManagement_iPad" : @"MediaManagement_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)morselManagementStoryboard {
    return [UIStoryboard storyboardWithName:[UIDevice currentDeviceIsIpad] ? @"MorselManagement_iPad" : @"MorselManagement_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)activityStoryboard {
    return [UIStoryboard storyboardWithName:[UIDevice currentDeviceIsIpad] ? @"Activity_iPad" : @"Activity_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)specsStoryboardInBundle:(NSBundle *)bundleOrNil {
    return [UIStoryboard storyboardWithName:[UIDevice currentDeviceIsIpad] ? @"Specs_iPad" : @"Specs_iPhone"
                                     bundle:bundleOrNil];
}

@end
