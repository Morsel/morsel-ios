//
//  MRSLBadgedBarButtonItem.m
//  Morsel
//
//  Created by Marty Trzpit on 2/5/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLBadgedBarButtonItem.h"
#import "BadgeLabel.h"

@interface MRSLBadgedBarButtonItem()

@property (nonatomic, strong) BadgeLabel *badgeLabel;

@end

@implementation MRSLBadgedBarButtonItem

- (BadgeLabel *)badgeLabel {
    if (!_badgeLabel) {
        _badgeLabel = [[BadgeLabel alloc] init];
        [_badgeLabel setBackgroundColor:[UIColor colorWithRed:1.0f green:0.227f blue:0.176f alpha:1.0f]];
        [self.toolbar addSubview:_badgeLabel];
    }

    return _badgeLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setBadgeText:(NSString *)badgeText {
    [self.badgeLabel setText:badgeText];
    [_badgeLabel setCenter:CGPointMake(CGRectGetWidth(self.toolbar.frame) - 4.0f - (CGRectGetWidth(self.badgeLabel.frame) * 0.5f), _badgeLabel.center.y)];
    [_badgeLabel setTransform:CGAffineTransformMakeScale(0.75f, 0.75f)];
}

@end
