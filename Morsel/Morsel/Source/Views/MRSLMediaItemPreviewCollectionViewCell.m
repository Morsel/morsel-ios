//
//  MRSLMediaItemPreviewCollectionViewCell.m
//  Morsel
//
//  Created by Javier Otero on 3/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMediaItemPreviewCollectionViewCell.h"

#import "MRSLMediaItem.h"

@interface MRSLMediaItemPreviewCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *mediaImage;

@end

@implementation MRSLMediaItemPreviewCollectionViewCell

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)setMediaItem:(MRSLMediaItem *)mediaItem {
    if (_mediaItem != mediaItem || !self.mediaImage.image) {
        [self reset];
        _mediaItem = mediaItem;
        if (_mediaItem) {
            self.mediaImage.image = _mediaItem.mediaThumbImage;
        }
    }
}

- (void)reset {
    self.mediaImage.image = nil;
}

@end
