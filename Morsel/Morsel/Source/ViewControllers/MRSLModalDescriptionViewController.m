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
@property (weak, nonatomic) IBOutlet UIView *descriptionContainerView;

@end

@implementation MRSLModalDescriptionViewController

- (void)viewDidLoad {
    self.disableFade = YES;
    [super viewDidLoad];
    self.descriptionTextView.text = _item.itemDescription;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.descriptionContainerView setY:320.f];
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.descriptionContainerView setY:184.f];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.descriptionContainerView setY:320.f];
                     }];
}

@end
