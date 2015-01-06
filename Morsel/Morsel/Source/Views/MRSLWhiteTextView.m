//
//  MRSLWhiteTextView.m
//  Morsel
//
//  Created by Javier Otero on 12/15/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLWhiteTextView.h"

@implementation MRSLWhiteTextView

- (void)setUp {
    self.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
}

@end
