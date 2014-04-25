//
//  MRSLMorselListViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLMorselListViewController : MRSLBaseViewController

@property (nonatomic) BOOL shouldPresentMediaCapture;

@property (nonatomic) MRSLMorselStatusType morselStatusType;

@property (weak, nonatomic) MRSLUser *user;

@end
