//
//  MRSLMorselTableViewCell.m
//  Morsel
//
//  Created by Javier Otero on 7/8/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselTableViewCell.h"

#import "MRSLItemImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"

@interface MRSLMorselTableViewCell ()

@property (weak, nonatomic) IBOutlet MRSLItemImageView *morselThumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *morselCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

@implementation MRSLMorselTableViewCell

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) [self reset];

    _morsel = morsel;

    self.morselTitleLabel.text = ([_morsel hasPlaceholderTitle]) ? [_morsel placeholderTitle] : _morsel.title;

    if ([_morsel.items count] > 0) {
        _morselThumbnailView.item = [_morsel coverItem];
        self.morselCountLabel.text = [NSString stringWithFormat:@"%lu photo%@", (unsigned long)[_morsel.items count], ([_morsel.items count] > 1) ? @"s" : @""];
    } else {
        _morselThumbnailView.item = nil;
        self.morselCountLabel.text = @"No photos";
    }

    [_morselCountLabel sizeToFit];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    [self displaySelectedState:highlighted];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    [self displaySelectedState:selected];
}

- (void)displaySelectedState:(BOOL)selected {
    self.backgroundColor = selected ? [UIColor morselPrimary] : [UIColor whiteColor];
    self.morselTitleLabel.textColor = selected ? [UIColor whiteColor] : [UIColor morselDefaultTextColor];
    self.morselCountLabel.textColor = selected ? [UIColor whiteColor] : [UIColor morselDefaultTextColor];
    if (self.arrowImageView) {
        self.arrowImageView.image = [UIImage imageNamed:(selected) ? @"icon-arrow-accessory-white" : @"icon-arrow-accessory-red"];
    }
    if (_morselThumbnailView.image) {
        self.morselThumbnailView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.morselThumbnailView.layer.borderWidth = selected ? 2.f : 0.f;
    }
}

- (void)reset {
    self.morselTitleLabel.text = nil;
    self.morselCountLabel.text = nil;
    self.morselThumbnailView.item = nil;
}

@end
