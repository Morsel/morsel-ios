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
    return [UIStoryboard storyboardWithName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Main_iPad" : @"Main_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)homeStoryboard {
    return [UIStoryboard storyboardWithName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Home_iPad" : @"Home_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)profileStoryboard {
    return [UIStoryboard storyboardWithName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Profile_iPad" : @"Profile_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)loginStoryboard {
    return [UIStoryboard storyboardWithName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Login_iPad" : @"Login_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)morselDetailStoryboard {
    return [UIStoryboard storyboardWithName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MorselDetail_iPad" : @"MorselDetail_iPhone"
                                     bundle:nil];
}

+ (UIStoryboard *)morselManagementStoryboard {
    return [UIStoryboard storyboardWithName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MorselManagement_iPad" : @"MorselManagement_iPhone"
                                     bundle:nil];
}

@end
