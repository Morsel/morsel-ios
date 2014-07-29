//
//  MRSLImagePreviewCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLImagePreviewCollectionViewCell.h"

#import <GCPlaceholderTextView/GCPlaceholderTextView.h>

#import "MRSLItemImageView.h"

#import "MRSLMediaItem.h"
#import "MRSLItem.h"

@interface MRSLImagePreviewCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLItemImageView *previewImageView;
@property (weak, nonatomic) IBOutlet GCPlaceholderTextView *descriptionField;
@property (weak, nonatomic) IBOutlet UIButton *descriptionButton;

@end

@implementation MRSLImagePreviewCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.descriptionField.placeholder = @"Tap to add text";
    self.descriptionField.placeholderColor = [UIColor morselLightContent];
}

- (void)setMediaPreviewItem:(id)mediaPreviewItem {
    _mediaPreviewItem = mediaPreviewItem;
    if ([mediaPreviewItem isKindOfClass:[MRSLItem class]]) {
        self.descriptionButton.hidden = NO;
        self.descriptionField.hidden = NO;
        MRSLItem *item = (MRSLItem *)mediaPreviewItem;
        self.previewImageView.item = item;
        self.descriptionField.text = item.itemDescription;
    } else if ([mediaPreviewItem isKindOfClass:[MRSLMediaItem class]]) {
        self.descriptionButton.hidden = YES;
        self.descriptionField.hidden = YES;
        MRSLMediaItem *mediaItem = (MRSLMediaItem *)mediaPreviewItem;
        self.previewImageView.image = mediaItem.mediaFullImage;
    }
}

- (void)dealloc {
    self.descriptionField.delegate = nil;
    self.descriptionField.placeholder = nil;
    self.descriptionField.placeholderColor = nil;
}

@end
