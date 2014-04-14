//
//  MRSLItemImageView.m
//  Morsel
//
//  Created by Javier Otero on 3/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLItemImageView.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "MRSLItem.h"

@interface MRSLItemImageView ()

@property (strong, nonatomic) SDWebImageManager *webImageManager;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) UIImageView *emptyMorselStateView;

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation MRSLItemImageView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor morselDarkContent];
    self.contentMode = UIViewContentModeScaleToFill;

    self.webImageManager = [[SDWebImageManager alloc] init];

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityIndicatorView setX:([self getWidth] / 2) - ([_activityIndicatorView getWidth] / 2)];
    [_activityIndicatorView setY:([self getHeight] / 2) - ([_activityIndicatorView getHeight] / 2)];
    [_activityIndicatorView setColor:[UIColor morselUserInterface]];
    [_activityIndicatorView setHidesWhenStopped:YES];

    [self addSubview:_activityIndicatorView];
}

- (void)displayEmptyMorselState {
    if (!_emptyMorselStateView) {
        [self setBorderWithColor:[UIColor morselDarkContent]
                        andWidth:1.f];
        self.emptyMorselStateView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic-thumb-morsel-null"]];
        [self addSubview:_emptyMorselStateView];
    }
}

#pragma mark - Instance Methods

- (void)setDelegate:(id<MRSLItemImageViewDelegate>)delegate {
    _delegate = delegate;

    if (!_tapRecognizer && _delegate) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayMorsel)];

        [self addGestureRecognizer:_tapRecognizer];

        self.userInteractionEnabled = YES;
    }
}

- (void)setItem:(MRSLItem *)item {
    if (_emptyMorselStateView) {
        [self removeBorder];
        [self.emptyMorselStateView removeFromSuperview];
        self.emptyMorselStateView = nil;
    }
    if (_item != item || item.isUploading || !item) {
        _item = item;

        [self reset];

        if (item) {
            ItemImageSizeType itemSizeType = ([self getWidth] >= MRSLItemImageLargeDimensionSize) ? ItemImageSizeTypeLarge : ItemImageSizeTypeThumbnail;
            if (_item.itemPhotoURL) {
                NSURLRequest *itemImageURLRequest = [_item itemPictureURLRequestForImageSizeType:itemSizeType];
                if (!itemImageURLRequest)
                    return;
                __weak __typeof(self)weakSelf = self;
                [weakSelf attemptToSetLocalMorselImageForSizeType:itemSizeType
                                                        withError:nil];
                if (itemSizeType == ItemImageSizeTypeLarge) {
                    __block BOOL fullSizeImageSet = NO;
                    [_webImageManager downloadWithURL:[_item itemPictureURLRequestForImageSizeType:ItemImageSizeTypeThumbnail].URL
                                              options:SDWebImageHighPriority
                                             progress:nil
                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                if (!fullSizeImageSet && image) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        weakSelf.image = image;
                                                    });
                                                }
                                            }];
                    [_activityIndicatorView startAnimating];
                    [_webImageManager downloadWithURL:itemImageURLRequest.URL
                                              options:SDWebImageHighPriority
                                             progress:nil
                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                [weakSelf.activityIndicatorView stopAnimating];
                                                if (error || !image) {
                                                    [weakSelf attemptToSetLocalMorselImageForSizeType:itemSizeType
                                                                                            withError:nil];
                                                } else {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        fullSizeImageSet = YES;
                                                        weakSelf.image = image;
                                                    });
                                                }
                                            }];
                } else {
                    [_webImageManager downloadWithURL:[_item itemPictureURLRequestForImageSizeType:ItemImageSizeTypeThumbnail].URL
                                              options:SDWebImageHighPriority
                                             progress:nil
                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                if (image) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        weakSelf.image = image;
                                                    });
                                                } else {
                                                    [weakSelf attemptToSetLocalMorselImageForSizeType:itemSizeType
                                                                                            withError:nil];
                                                }
                                            }];
                }
            } else {
                [self attemptToSetLocalMorselImageForSizeType:itemSizeType
                                                    withError:nil];
            }
        }
    }
}

- (void)attemptToSetLocalMorselImageForSizeType:(ItemImageSizeType)itemSizeType
                                      withError:(NSError *)errorOrNil {
    if (_item.itemPhotoThumb && _item.itemPhotoCropped) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *localImage = [UIImage imageWithData:(itemSizeType == ItemImageSizeTypeLarge) ? _item.itemPhotoCropped : _item.itemPhotoThumb];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = localImage;
                });
            });
        });
    } else {
        if (errorOrNil.code != -999) {
            DDLogError(@"Unable to set Morsel image and no local copy exists%@", (errorOrNil) ? [NSString stringWithFormat:@": %@", errorOrNil] : @".");
            self.image = [UIImage imageNamed:(itemSizeType == ItemImageSizeTypeThumbnail) ? @"graphic-thumb-morsel-null" : @"graphic-image-large-placeholder"];
        }
    }
}

#pragma mark - Private Methods

- (void)displayMorsel {
    if ([self.delegate respondsToSelector:@selector(itemImageViewDidSelectMorsel:)] && _item) {
        [self.delegate itemImageViewDidSelectMorsel:_item];
    }
}

- (void)reset {
    [_webImageManager cancelAll];
    self.image = nil;
}

#pragma mark - Dealloc Methods

- (void)dealloc {
    [self reset];
}

@end
