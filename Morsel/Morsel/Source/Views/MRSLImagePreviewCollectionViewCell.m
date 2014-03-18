//
//  MRSLImagePreviewCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLImagePreviewCollectionViewCell.h"

#import <AFNetworking/AFNetworking.h>

#import "MRSLMorselImageView.h"

#import "MRSLMediaItem.h"
#import "MRSLMorsel.h"

@interface MRSLImagePreviewCollectionViewCell ()

@property (weak, nonatomic) IBOutlet MRSLMorselImageView *previewImageView;

@end

@implementation MRSLImagePreviewCollectionViewCell

- (void)setMediaPreviewItem:(id)mediaPreviewItem {
    if (_mediaPreviewItem != mediaPreviewItem) {
        _mediaPreviewItem = mediaPreviewItem;

        [self reset];

        if ([mediaPreviewItem isKindOfClass:[MRSLMorsel class]]) {
            MRSLMorsel *morsel = (MRSLMorsel *)mediaPreviewItem;
            _previewImageView.morsel = morsel;
        } else if ([mediaPreviewItem isKindOfClass:[MRSLMediaItem class]]) {
            MRSLMediaItem *mediaItem = (MRSLMediaItem *)mediaPreviewItem;
            self.previewImageView.image = mediaItem.mediaCroppedImage;
        }
    }
}

- (void)reset {
    self.previewImageView.morsel = nil;
}

@end
