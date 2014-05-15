//
//  SignUpViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLSocialUser;

@interface MRSLSignUpViewController : MRSLBaseViewController

@property (nonatomic) BOOL shouldOmitEmail;

@property (strong, nonatomic) MRSLSocialUser *socialUser;

@end
