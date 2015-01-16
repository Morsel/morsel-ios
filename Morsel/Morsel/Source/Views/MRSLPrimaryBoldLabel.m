//
//  MRSLRobotoBoldLabel.m
//  Morsel
//
//  Created by Javier Otero on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPrimaryBoldLabel.h"

@implementation MRSLPrimaryBoldLabel

- (void)setUp {
    [self setFont:[UIFont primaryBoldFontOfSize:self.font.pointSize]];
}

- (UIFont *)obliqueFont {
    return [UIFont primaryItalicsFontOfSize:self.font.pointSize];
}

@end
