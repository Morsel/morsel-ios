//
//  MRSLMorselPreviewCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 4/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselPreviewCollectionViewCell.h"

#import "MRSLItemImageView.h"

#import "MRSLStandardTextView.h"

#import "MRSLMorsel.h"

@interface MRSLMorselPreviewCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLStandardTextView *textView;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *itemImageView;

@end

@implementation MRSLMorselPreviewCollectionViewCell

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor morselBackgroundDark];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!self.itemImageView.layer.mask) {
        CAGradientLayer *l = [CAGradientLayer layer];
        l.frame = self.bounds;
        l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:1.f
                                                                  green:1.f
                                                                   blue:1.f
                                                                  alpha:1.f] CGColor],
                    (id)[[UIColor colorWithRed:1.f
                                         green:1.f
                                          blue:1.f
                                         alpha:0.f] CGColor], nil];

        l.startPoint = CGPointMake(0.f, 0.5f);
        l.endPoint = CGPointMake(0.f, 1.f);

        self.itemImageView.layer.mask = l;
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_itemImageView reset];
            _itemImageView.item = [morsel coverItem];
        });
        _textView.attributedText = [_morsel thumbnailInformation];
    }
}

@end
