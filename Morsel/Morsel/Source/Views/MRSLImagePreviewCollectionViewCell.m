//
//  MRSLImagePreviewCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLImagePreviewCollectionViewCell.h"

#import "MRSLItemImageView.h"

#import "MRSLMediaItem.h"
#import "MRSLItem.h"

@interface MRSLImagePreviewCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLItemImageView *previewImageView;

@end

@implementation MRSLImagePreviewCollectionViewCell

- (void)setMediaPreviewItem:(id)mediaPreviewItem {
    if (_mediaPreviewItem != mediaPreviewItem) {
        _mediaPreviewItem = mediaPreviewItem;

        [self reset];

        if ([mediaPreviewItem isKindOfClass:[MRSLItem class]]) {
            MRSLItem *item = (MRSLItem *)mediaPreviewItem;
            _previewImageView.item = item;
        } else if ([mediaPreviewItem isKindOfClass:[MRSLMediaItem class]]) {
            MRSLMediaItem *mediaItem = (MRSLMediaItem *)mediaPreviewItem;
            self.previewImageView.image = mediaItem.mediaCroppedImage;
        }
    }
}

- (void)reset {
    self.previewImageView.item = nil;
}

@end
