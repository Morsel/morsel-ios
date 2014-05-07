//
//  LoginViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLSocialUser;

@interface MRSLLoginViewController : MRSLBaseViewController

@property (strong, nonatomic) MRSLSocialUser *socialUser;

@end
