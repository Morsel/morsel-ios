//
//  UIStoryboard+Morsel.h
//  Morsel
//
//  Created by Javier Otero on 1/23/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (Morsel)

+ (UIStoryboard *)mainStoryboard;
+ (UIStoryboard *)feedStoryboard;
+ (UIStoryboard *)profileStoryboard;
+ (UIStoryboard *)loginStoryboard;
+ (UIStoryboard *)mediaManagementStoryboard;
+ (UIStoryboard *)storyManagementStoryboard;
+ (UIStoryboard *)activityStoryboard;
+ (UIStoryboard *)specsStoryboardInBundle:(NSBundle *)bundleOrNil;

@end
