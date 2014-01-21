//
//  UIStoryboard+Morsel.m
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIStoryboard+Morsel.h"

@implementation UIStoryboard (Morsel)

+ (UIStoryboard *)mainStoryboard
{
    return [UIStoryboard storyboardWithName:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Main_iPad" : @"Main_iPhone"
                                     bundle:nil];
}

@end
