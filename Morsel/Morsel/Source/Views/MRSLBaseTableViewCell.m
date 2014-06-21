//
//  MRSLBaseTableViewCell.m
//  Morsel
//
//  Created by Marty Trzpit on 6/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewCell.h"

@implementation MRSLBaseTableViewCell

- (UITableViewCellSelectionStyle)selectionStyle {
    return UITableViewCellSelectionStyleNone;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    [self setBackgroundColor:(highlighted) ? [UIColor morselUserInterface] : [UIColor whiteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    [self setBackgroundColor:(selected) ? [UIColor morselUserInterface] : [UIColor whiteColor]];
}

@end
