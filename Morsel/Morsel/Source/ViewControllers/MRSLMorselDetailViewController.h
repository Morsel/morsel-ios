//
//  MRSLProfileMorselsViewController.h
//  Morsel
//
//  Created by Javier Otero on 4/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLMorselDetailViewController : MRSLBaseViewController

@property (nonatomic) BOOL isExplore;

@property (weak, nonatomic) MRSLUser *user;
@property (weak, nonatomic) MRSLMorsel *morsel;

@end
