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

+ (CGSize)defaultCellSizeForCollectionView:(UICollectionView *)collectionView
                               atIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = floorf(collectionView.frame.size.width / (([UIDevice currentDeviceIsIpad]) ? 3 : 2));
    CGFloat offset = 0.f;
    if ([UIDevice has35InchScreen] || [UIDevice has4InchScreen] || [UIDevice has55InchScreen] || [UIDevice currentDeviceIsIpad]) {
        cellWidth -= MRSLMinimumSpacingPadding;
        offset = ((indexPath.row % 2) ? 0.f : MRSLMinimumSpacingPadding);
    }
    return CGSizeMake(MAX(159.f, cellWidth + offset), MAX(159.f, cellWidth));
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor morselBackgroundDark];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!self.itemImageView.layer.mask) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:1.f
                                                                              green:1.f
                                                                               blue:1.f
                                                                              alpha:1.f] CGColor],
                                (id)[[UIColor colorWithRed:1.f
                                                     green:1.f
                                                      blue:1.f
                                                     alpha:0.f] CGColor], nil];

        gradientLayer.startPoint = CGPointMake(0.f, 0.5f);
        gradientLayer.endPoint = CGPointMake(0.f, 1.f);

        self.itemImageView.layer.mask = gradientLayer;
    } else {
        self.itemImageView.layer.mask.frame = self.bounds;
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _textView.attributedText = [_morsel thumbnailInformation];
        });
    }
}

@end
