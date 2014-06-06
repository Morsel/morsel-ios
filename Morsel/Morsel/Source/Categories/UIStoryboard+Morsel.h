//
//  UIStoryboard+Morsel.h
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (Morsel)

#pragma mark - Main

+ (UIStoryboard *)activityStoryboard;
+ (UIStoryboard *)feedStoryboard;
+ (UIStoryboard *)loginStoryboard;
+ (UIStoryboard *)mainStoryboard;
+ (UIStoryboard *)mediaManagementStoryboard;
+ (UIStoryboard *)morselManagementStoryboard;
+ (UIStoryboard *)placesStoryboard;
+ (UIStoryboard *)profileStoryboard;
+ (UIStoryboard *)settingsStoryboard;
+ (UIStoryboard *)socialStoryboard;

#pragma mark - Specs

+ (UIStoryboard *)specsStoryboardInBundle:(NSBundle *)bundleOrNil;

@end
