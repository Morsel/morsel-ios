//
//  MRSLBaseTableViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 6/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@interface MRSLBaseTableViewCell ()

- (UIColor *)defaultBackgroundColor;
- (UIColor *)defaultHighlightedBackgroundColor;
- (UIColor *)defaultSelectedBackgroundColor;

@property (nonatomic) BOOL togglable;

@end

@implementation MRSLBaseTableViewCell

- (UITableViewCellSelectionStyle)selectionStyle {
    return UITableViewCellSelectionStyleNone;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    [self setBackgroundColor:(highlighted) ? [self defaultHighlightedBackgroundColor] : (self.togglable && self.selected ? [self defaultSelectedBackgroundColor] : [self defaultBackgroundColor])];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    [self setBackgroundColor:(selected) ? [self defaultSelectedBackgroundColor] : [self defaultBackgroundColor]];
}


#pragma mark - Private Methods

- (UIColor *)defaultBackgroundColor {
    return [UIColor morselBackground];
}

- (UIColor *)defaultHighlightedBackgroundColor {
    return [self defaultSelectedBackgroundColor];
}

- (UIColor *)defaultSelectedBackgroundColor {
    return [UIColor morselLight];
}

@end
