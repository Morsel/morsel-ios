//
//  MorselDetailViewController.h
//  Morsel
//
//  Created by Javier Otero on 12/16/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MRSLDetailHorizontalSwipePanelsViewController.h"

@class MRSLMorsel;

@interface MorselDetailViewController : MRSLDetailHorizontalSwipePanelsViewController

@property (nonatomic, strong) MRSLMorsel *morsel;

@end
