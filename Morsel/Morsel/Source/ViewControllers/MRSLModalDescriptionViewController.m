//
//  MRSLItemDescriptionViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLModalDescriptionViewController.h"

#import "MRSLItem.h"
#import "MRSLRobotoLightTextView.h"

@interface MRSLModalDescriptionViewController ()

@property (weak, nonatomic) IBOutlet MRSLRobotoLightTextView *descriptionTextView;

@end

@implementation MRSLModalDescriptionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.descriptionTextView.text = _item.itemDescription;
}

@end
