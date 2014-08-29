//
//  MRSLTemplateInfoViewController.h
//  Morsel
//
//  Created by Javier Otero on 8/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

@class MRSLTemplate;

@interface MRSLTemplateInfoViewController : MRSLBaseViewController

@property (nonatomic) BOOL isDisplayingHelp;

@property (weak, nonatomic) MRSLTemplate *morselTemplate;

@end
