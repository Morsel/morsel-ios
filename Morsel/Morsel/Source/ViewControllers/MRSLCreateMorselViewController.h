//
//  CreateMorselViewController.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMorsel;

@interface MRSLCreateMorselViewController : UIViewController

@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong) MRSLMorsel *morsel;

@end
