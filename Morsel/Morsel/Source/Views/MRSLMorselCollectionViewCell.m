//
//  MorselCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselCollectionViewCell.h"

#import "MRSLItemImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"

@interface MRSLMorselCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLItemImageView *morselThumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *morselCountLabel;

@end

@implementation MRSLMorselCollectionViewCell

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) [self reset];

    _morsel = morsel;

    self.morselTitleLabel.text = _morsel.title ?: @"No title";

    if ([_morsel.items count] > 0) {
        _morselThumbnailView.item = [_morsel coverItem];
        self.morselCountLabel.text = [NSString stringWithFormat:@"%lu ITEM%@", (unsigned long)[_morsel.items count], ([_morsel.items count] > 1) ? @"S" : @""];
    } else {
        DDLogError(@"MorselCollectionViewCell assigned a Morsel with no items. Morsel ID: %i", _morsel.morselIDValue);
        _morselThumbnailView.item = nil;
        self.morselCountLabel.text = @"NO ITEMS";
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
    self.backgroundColor = selected ? [UIColor morselRed] : [UIColor whiteColor];
    self.morselTitleLabel.textColor = selected ? [UIColor whiteColor] : [UIColor morselDarkContent];
    self.morselCountLabel.textColor = selected ? [UIColor whiteColor] : [UIColor morselLightContent];

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
