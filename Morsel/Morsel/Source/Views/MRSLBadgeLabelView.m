//
//  MRSLBadgeLabelView.m
//  Morsel
//
//  Created by Javier Otero on 6/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBadgeLabelView.h"

@interface MRSLBadgeLabelView ()

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation MRSLBadgeLabelView

- (void)setCount:(int)count {
    _count = count;
    self.countLabel.text = [NSString stringWithFormat:@"%i", _count];
}

@end
