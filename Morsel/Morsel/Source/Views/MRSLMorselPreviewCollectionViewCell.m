//
//  MRSLMorselPreviewCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselPreviewCollectionViewCell.h"

#import "MRSLItemImageView.h"

#import "MRSLMorsel.h"

@interface MRSLMorselPreviewCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;

@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;

@end

@implementation MRSLMorselPreviewCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [_morselTitleLabel addStandardShadow];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;

        _itemImageView.item = [morsel coverItem];
        _morselTitleLabel.text = morsel.title;
    }
}

@end
