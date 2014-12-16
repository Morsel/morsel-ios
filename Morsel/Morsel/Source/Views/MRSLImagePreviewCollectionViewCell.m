//
//  MRSLImagePreviewCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLImagePreviewCollectionViewCell.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>
#import "MRSLPlaceholderTextView.h"

#import "MRSLItemImageView.h"

#import "MRSLMediaItem.h"
#import "MRSLItem.h"

@interface MRSLImagePreviewCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLItemImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIButton *descriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *retakePhotoButton;
@property (weak, nonatomic) IBOutlet UILabel *placeholderDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation MRSLImagePreviewCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.retakePhotoButton) [self.retakePhotoButton setRoundedCornerRadius:[self.retakePhotoButton getWidth] / 2];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.descriptionLabel setPreferredMaxLayoutWidth:[self.descriptionLabel getWidth]];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setMediaPreviewItem:(id)mediaPreviewItem {
    _mediaPreviewItem = mediaPreviewItem;

    MRSLItem *item = (MRSLItem *)mediaPreviewItem;
    self.previewImageView.item = item;

    if (!item.itemDescription || [item.description length] == 0) {
        self.descriptionLabel.text = @"Tap to add text";
        [self.descriptionLabel setFont:[UIFont primaryLightItalicFontOfSize:14.f]];
    } else {
        self.descriptionLabel.text = item.itemDescription;
        [self.descriptionLabel setFont:[UIFont primaryLightFontOfSize:14.f]];
    }
    self.placeholderDescriptionLabel.text = item.placeholder_description ?: @"Additional photo";
}

@end
