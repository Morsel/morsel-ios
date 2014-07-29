//
//  MRSLActivityIndicatorView.m
//  Morsel
//
//  Created by Marty Trzpit on 7/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityIndicatorView.h"

@implementation MRSLActivityIndicatorView

+ (instancetype)defaultActivityIndicatorView {
    return [[MRSLActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setColor:[UIColor morselDark]];
        [self setHidesWhenStopped:YES];
    }
    return self;
}

@end
