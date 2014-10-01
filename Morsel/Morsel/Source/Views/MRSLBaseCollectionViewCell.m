//
//  MRSLBaseCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 8/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseCollectionViewCell.h"

@implementation MRSLBaseCollectionViewCell

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setBackgroundColor:(highlighted) ? [self defaultHighlightedBackgroundColor] : (self.selected ? [self defaultSelectedBackgroundColor] : [self defaultBackgroundColor])];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setBackgroundColor:(selected) ? [self defaultSelectedBackgroundColor] : [self defaultBackgroundColor]];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

#pragma mark - Private Methods

- (UIColor *)defaultBackgroundColor {
    return [UIColor morselDefaultCellBackgroundColor];
}

- (UIColor *)defaultHighlightedBackgroundColor {
    return [self defaultSelectedBackgroundColor];
}

- (UIColor *)defaultSelectedBackgroundColor {
    return [UIColor morselLight];
}

@end
