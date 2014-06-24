//
//  MRSLItemImageView.m
//  Morsel
//
//  Created by Javier Otero on 3/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLItemImageView.h"

#import "MRSLItem.h"

@implementation MRSLItemImageView

#pragma mark - Instance Methods

- (void)setItem:(MRSLItem *)item {
    _item = item;
    [self setImageObject:_item];
}

- (MRSLImageSizeType)imageSizeType {
    return ([self getWidth] >= MRSLItemImageLargeDimensionSize) ? MRSLImageSizeTypeLarge : MRSLImageSizeTypeSmall;
}

- (UIImage *)placeholderImage {
    return  [UIImage imageNamed:([self imageSizeType] == MRSLImageSizeTypeSmall) ? @"graphic-thumb-morsel-null" : @"graphic-image-large-placeholder"];
}

#pragma mark - Action Methods

- (void)imageViewTapped:(UITapGestureRecognizer *)tapRecognizer {
    if ([self.delegate respondsToSelector:@selector(itemImageViewDidSelectItem:)] && _item) {
        [self.delegate itemImageViewDidSelectItem:_item];
    }
}

@end
