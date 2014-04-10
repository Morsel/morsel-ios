//
//  MRSLItemDescriptionViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLModalDescriptionViewController.h"

#import "MRSLItem.h"

@interface MRSLModalDescriptionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation MRSLModalDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.descriptionTextView.text = _item.itemDescription;
}

@end
