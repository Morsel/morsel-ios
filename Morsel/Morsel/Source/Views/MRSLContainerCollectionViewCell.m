//
//  MRSLContainerCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 5/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLContainerCollectionViewCell.h"

@interface MRSLContainerCollectionViewCell ()

@property (strong, nonatomic) UIViewController *viewController;

@end

@implementation MRSLContainerCollectionViewCell

- (void)addViewController:(UIViewController *)viewController {
    [_viewController.view removeFromSuperview];
    self.viewController = viewController;
    [self.contentView addSubview:_viewController.view];
}

@end
