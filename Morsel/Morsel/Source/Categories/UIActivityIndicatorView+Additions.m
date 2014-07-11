//
//  UIActivityIndicatorView+Additions.m
//  Morsel
//
//  Created by Marty Trzpit on 7/10/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UIActivityIndicatorView+Additions.h"

@implementation UIActivityIndicatorView (Additions)

- (void)MRSL_toggleAnimating:(BOOL)shouldAnimate {
    if (shouldAnimate)
        [self startAnimating];
    else
        [self stopAnimating];
}

@end
