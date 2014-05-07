//
//  MRSLValidationStatusView.m
//  Morsel
//
//  Created by Javier Otero on 5/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLValidationStatusView.h"

@implementation MRSLValidationStatusView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.statusLabel addShadowWithOpacity:.2f
                                 andRadius:3.f
                                 withColor:[UIColor whiteColor]];
    [self.activityIndicator setHidesWhenStopped:YES];
}

@end
