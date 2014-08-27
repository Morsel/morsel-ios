//
//  MRSLMorselEditViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLMorselEditViewController : MRSLBaseViewController

@property (nonatomic) BOOL shouldPresentMediaCapture;
@property (nonatomic) BOOL wasNewMorsel;

@property (strong, nonatomic) NSNumber *morselID;

@end
