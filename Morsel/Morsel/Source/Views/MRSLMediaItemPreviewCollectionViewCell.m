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

- (void)setMediaItem:(MRSLMediaItem *)mediaItem {
    if (_mediaItem != mediaItem || !self.mediaImage.image) {
        [self reset];
        _mediaItem = mediaItem;
        if (_mediaItem) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                if (!_mediaItem.mediaThumbImage) {
                    _mediaItem.mediaThumbImage = [_mediaItem.mediaCroppedImage thumbnailImage:50.f
                                                                         interpolationQuality:kCGInterpolationHigh];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mediaImage.image = _mediaItem.mediaThumbImage;
                });
            });
        }
    }
}

- (void)reset {
    self.mediaImage.image = nil;
}

@end
