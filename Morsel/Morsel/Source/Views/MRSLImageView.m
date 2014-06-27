//
//  MRSLImageView.m
//  Morsel
//
//  Created by Javier Otero on 6/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLImageView.h"

#import <GPUImage/GPUImageGaussianBlurFilter.h>
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

    self.backgroundColor = [UIColor morselDarkContent];
    self.contentMode = UIViewContentModeScaleToFill;

    self.image = [self placeholderImage];

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityIndicatorView setX:([self getWidth] / 2) - ([_activityIndicatorView getWidth] / 2)];
    [_activityIndicatorView setY:([self getHeight] / 2) - ([_activityIndicatorView getHeight] / 2)];
    [_activityIndicatorView setHidesWhenStopped:YES];

    [self addSubview:_activityIndicatorView];

    if (!_tapRecognizer && self.userInteractionEnabled) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(imageViewTapped:)];
        [self addGestureRecognizer:_tapRecognizer];
    }
}

#pragma mark - Image Methods

- (void)setItemImage:(UIImage *)image {
    if (self.imageProcessed) return;
    if (self.shouldBlur && image) {
        GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        blurFilter.blurPasses = 5.f;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = [blurFilter imageByFilteringImage:image];
            self.imageProcessed = YES;
        });
    } else {
        self.image = (self.grayScale) ? [image convertImageToGrayScale] : image;
    }
}

- (void)setImageObject:(id<MRSLImageRequestable>)imageObject {
    if (_imageObject != imageObject) self.imageProcessed = NO;
    _imageObject = imageObject;
    [self reset];
    if (imageObject) {
        MRSLImageSizeType imageSizeType = [self imageSizeType];
        if ([imageObject imageURL]) {
            NSURLRequest *largeImageURLRequest = [imageObject imageURLRequestForImageSizeType:MRSLImageSizeTypeLarge];
            NSURLRequest *smallImageURLRequest = [imageObject imageURLRequestForImageSizeType:MRSLImageSizeTypeSmall];
            if (imageSizeType == MRSLImageSizeTypeLarge && !_shouldBlur) {
                UIImage *smallImage = [self imageForCacheKey:[smallImageURLRequest.URL absoluteString]];
                UIImage *largeImage = [self imageForCacheKey:[largeImageURLRequest.URL absoluteString]];
                if (largeImage) {
                    [self setItemImage:largeImage];
                } else if (!largeImage && smallImage) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self setImageWithURL:largeImageURLRequest.URL
                             placeholderImage:smallImage ?: [self placeholderImage]
                                    completed:nil
                        showActivityIndicator:YES];
                    });
                } else {
                    [_activityIndicatorView startAnimating];
                    __weak __typeof(self)weakSelf = self;
                    [self setImageWithURL:smallImageURLRequest.URL
                         placeholderImage:[self placeholderImage]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [weakSelf setImageWithURL:largeImageURLRequest.URL
                                                 placeholderImage:image
                                                        completed:nil
                                            showActivityIndicator:YES];
                                    });
                                } showActivityIndicator:YES];
                }
            } else {
                UIImage *thumbImage = [self imageForCacheKey:[smallImageURLRequest.URL absoluteString]];
                [self setItemImage:thumbImage];
                if (!thumbImage) {
                    [self setImageWithURL:[imageObject imageURLRequestForImageSizeType:MRSLImageSizeTypeSmall].URL
                         placeholderImage:[self placeholderImage]
                                completed:nil
                    showActivityIndicator:YES];
                }
            }
        } else {
            [self attemptToSetLocalMorselImageForSizeType:imageSizeType
                                                withError:nil];
        }
    } else {
        self.image = [self placeholderImage];
    }
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholder
              completed:(SDWebImageCompletedBlock)completedBlockOrNil
  showActivityIndicator:(BOOL)showActivityIndicator {
    if (showActivityIndicator) [self.activityIndicatorView startAnimating];
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setImageWithURL:url
             placeholderImage:placeholder ?: [self placeholderImage]
                      options:([self window] ? SDWebImageHighPriority : 0)
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                        if (completedBlockOrNil) completedBlockOrNil(image, error, cacheType);
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
    return ([self getWidth] > MRSLItemImageThumbDimensionSize) ? MRSLImageSizeTypeLarge : MRSLImageSizeTypeSmall;
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
    [self cancelCurrentImageLoad];
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView setColor:([self imageSizeType] == MRSLImageSizeTypeSmall) ? [UIColor darkGrayColor] : [UIColor morselUserInterface]];
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
