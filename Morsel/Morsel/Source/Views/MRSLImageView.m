//
//  MRSLImageView.m
//  Morsel
//
//  Created by Javier Otero on 6/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLImageView.h"
#import "MRSLActivityIndicatorView.h"

#import <GPUImage/GPUImage.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "UIImage+Color.h"
#import "UIImage+Resize.h"

@interface MRSLImageView ()

@property (nonatomic) BOOL imageProcessed;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation MRSLImageView

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor morselDark];
    self.contentMode = UIViewContentModeScaleToFill;

    self.image = [self placeholderImage];

    self.activityIndicatorView = [MRSLActivityIndicatorView defaultActivityIndicatorView];

    [self addSubview:_activityIndicatorView];

    if (!_tapRecognizer && self.userInteractionEnabled) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(imageViewTapped:)];
        [self addGestureRecognizer:_tapRecognizer];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_activityIndicatorView setX:([self getWidth] / 2) - ([_activityIndicatorView getWidth] / 2)];
    [_activityIndicatorView setY:([self getHeight] / 2) - ([_activityIndicatorView getHeight] / 2)];
}

#pragma mark - Image Methods

- (void)setItemImage:(UIImage *)image {
    if (self.shouldBlur && image && !self.imageProcessed) {
        self.imageProcessed = YES;

        self.image = [self placeholderImage];

        GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
        saturationFilter.saturation = 2.f;

        GPUImageGaussianBlurPositionFilter *zoomBlurFilter = [[GPUImageGaussianBlurPositionFilter alloc] init];
        zoomBlurFilter.blurSize = (self.shouldBlurMore) ? 15.f : 5.f;
        zoomBlurFilter.blurRadius = (self.shouldBlurMore) ? 20.f : 2.f;

        GPUImageGaussianBlurFilter *gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        gaussianBlurFilter.blurRadiusInPixels = (self.shouldBlurMore) ? 20.f : 2.f;
        gaussianBlurFilter.blurPasses = (self.shouldBlurMore) ? 15.f : 5.f;

        GPUImageFilterGroup *filterGroup = [[GPUImageFilterGroup alloc] init];

        [filterGroup addFilter:saturationFilter];
        [filterGroup addFilter:zoomBlurFilter];
        [filterGroup addFilter:gaussianBlurFilter];

        [saturationFilter addTarget:zoomBlurFilter];
        [zoomBlurFilter addTarget:gaussianBlurFilter];

        [filterGroup setInitialFilters:@[saturationFilter, zoomBlurFilter]];
        [filterGroup setTerminalFilter:gaussianBlurFilter];

        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *processedImage = [filterGroup imageByFilteringImage:image];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.image = processedImage;
            });
        });
    } else {
        if (self.grayScale) {
            __weak __typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                UIImage *grayScaleImage = [image convertImageToGrayScale];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf) {
                        weakSelf.image = grayScaleImage;
                    }
                });
            });
        } else if (self.shouldBlur) {
            self.image = [self placeholderImage];
        } else {
            self.image = image;
        }
    }
}

- (void)setImageObject:(id<MRSLImageRequestable>)imageObject {
    self.imageProcessed = NO;
    _imageObject = imageObject;
    if (imageObject) {
        MRSLImageSizeType imageSizeType = [self imageSizeType];
        if ([imageObject imageURL]) {
            NSURLRequest *largeImageURLRequest = [imageObject imageURLRequestForImageSizeType:MRSLImageSizeTypeLarge];
            NSURLRequest *smallImageURLRequest = [imageObject imageURLRequestForImageSizeType:MRSLImageSizeTypeSmall];
            UIImage *smallImage = [self imageForCacheKey:[smallImageURLRequest.URL absoluteString]];
            if (imageSizeType == MRSLImageSizeTypeLarge && !_shouldBlur) {
                [self reset];
                UIImage *largeImage = [self imageForCacheKey:[largeImageURLRequest.URL absoluteString]];
                if (largeImage) {
                    [self setItemImage:largeImage];
                } else if (!largeImage && smallImage) {
                    [self setImageWithURL:largeImageURLRequest.URL
                         placeholderImage:smallImage ?: [self placeholderImage]
                                completed:nil
                    showActivityIndicator:YES];
                } else {
                    __weak __typeof(self)weakSelf = self;
                    [self setImageWithURL:smallImageURLRequest.URL
                         placeholderImage:[self placeholderImage]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    [weakSelf setImageWithURL:largeImageURLRequest.URL
                                             placeholderImage:image
                                                    completed:nil
                                        showActivityIndicator:YES];
                                } showActivityIndicator:YES];
                }
            } else {
                if (!smallImage) {
                    [self setImageWithURL:smallImageURLRequest.URL
                         placeholderImage:[self placeholderImage]
                                completed:nil
                    showActivityIndicator:YES];
                } else {
                    [self reset];
                    [self setItemImage:smallImage];
                }
            }
        } else {
            [self reset];
            [self attemptToSetLocalMorselImageForSizeType:imageSizeType
                                                withError:nil];
        }
    } else {
        [self reset];
        self.image = [self placeholderImage];
    }
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholder
              completed:(SDWebImageCompletionBlock)completedBlockOrNil
  showActivityIndicator:(BOOL)showActivityIndicator {
    if (showActivityIndicator) [self.activityIndicatorView startAnimating];
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sd_setImageWithURL:url
                placeholderImage:placeholder ?: [self placeholderImage]
                         options:([self window] ? SDWebImageHighPriority : 0)
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                           if (completedBlockOrNil) completedBlockOrNil(image, error, cacheType, imageURL);
                           if (!image || error) {
                               [weakSelf attemptToSetLocalMorselImageForSizeType:[weakSelf imageSizeType]
                                                                       withError:error];
                           } else {
                               [weakSelf setItemImage:image];
                           }
                           [weakSelf.activityIndicatorView stopAnimating];
                       }];
    });
}

- (void)imageViewTapped:(UITapGestureRecognizer *)tapRecognizer {
    NSAssert(NO, @"Should be overridden to either call delegate methods or other handling");
}

- (UIImage *)imageForCacheKey:(NSString *)cacheKey {
    return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheKey];
}

- (UIImage *)placeholderImage {
    NSAssert(NO, @"Should be overriden. Default is f0f because it's noticeable.");
    return [UIImage imageWithColor:[UIColor magentaColor]];
}

- (MRSLImageSizeType)imageSizeType {
    return ([self getWidth] > MRSLImageLargeThreshold) ? MRSLImageSizeTypeLarge : MRSLImageSizeTypeSmall;
}

#pragma mark - Private Methods

- (void)attemptToSetLocalMorselImageForSizeType:(MRSLImageSizeType)itemSizeType
                                      withError:(NSError *)errorOrNil {
    [self.activityIndicatorView stopAnimating];
    if ([self.imageObject localImageLarge] && [self.imageObject localImageSmall]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *localImage = [UIImage imageWithData:(itemSizeType == MRSLImageSizeTypeLarge) ? [self.imageObject localImageLarge] : [self.imageObject localImageSmall]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setItemImage:localImage];
                });
            });
        });
    } else {
        if (errorOrNil.code != -999) {
            self.image = [self placeholderImage];
        }
    }
}

- (void)reset {
    [self sd_cancelCurrentImageLoad];
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView setColor:([self imageSizeType] == MRSLImageSizeTypeSmall) ? [UIColor darkGrayColor] : [UIColor morselOffWhite]];
}

#pragma mark - Dealloc Methods

- (void)dealloc {
    [self reset];
    self.image = nil;
    if (self.tapRecognizer) {
        [self removeGestureRecognizer:_tapRecognizer];
        self.tapRecognizer = nil;
    }
}

@end
