//
//  MRSLItemImageView.m
//  Morsel
//
//  Created by Javier Otero on 3/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLItemImageView.h"

#import "MRSLMorsel.h"
#import "MRSLItem.h"

@implementation MRSLItemImageView

#pragma mark - Instance Methods

- (void)setItem:(MRSLItem *)item {
    _item = item;
    if ([_item isTemplatePlaceholderItem]) {
        [self reset];
        if (!_item.placeholder_description) {
            __weak __typeof(self)weakSelf = self;
            [_item.morsel reloadTemplateDataIfNecessaryWithSuccess:^(BOOL success) {
                if (weakSelf) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.image = [UIImage imageNamed:([self imageSizeType] == MRSLImageSizeTypeLarge) ? _item.placeholder_photo_large : _item.placeholder_photo_small];
                    });
                }
            } failure:^(NSError *error) {
                if (weakSelf) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.image = nil;
                    });                }
            }];
        } else {
            self.image = [UIImage imageNamed:([self imageSizeType] == MRSLImageSizeTypeLarge) ? _item.placeholder_photo_large : _item.placeholder_photo_small];
        }
    } else {
        [self setImageObject:_item];
    }
}

- (MRSLImageSizeType)imageSizeType {
    return ([self getWidth] >= MRSLImageLargeThreshold) ? MRSLImageSizeTypeLarge : MRSLImageSizeTypeSmall;
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
