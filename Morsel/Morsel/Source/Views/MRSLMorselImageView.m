//
//  MRSLMorselImageView.m
//  Morsel
//
//  Created by Javier Otero on 3/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselImageView.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "MRSLMorsel.h"

@interface MRSLMorselImageView ()

@property (strong, nonatomic) SDWebImageManager *webImageManager;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) UIImageView *emptyStoryStateView;

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation MRSLMorselImageView

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

- (void)displayEmptyStoryState {
    if (!_emptyStoryStateView) {
        [self setBorderWithColor:[UIColor morselDarkContent]
                        andWidth:1.f];
        self.emptyStoryStateView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphic-thumb-story-null"]];
        [self addSubview:_emptyStoryStateView];
    }
}

#pragma mark - Instance Methods

- (void)setDelegate:(id<MRSLMorselImageViewDelegate>)delegate {
    _delegate = delegate;

    if (!_tapRecognizer && _delegate) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayMorsel)];

        [self addGestureRecognizer:_tapRecognizer];

        self.userInteractionEnabled = YES;
    }
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_emptyStoryStateView) {
        [self removeBorder];
        [self.emptyStoryStateView removeFromSuperview];
        self.emptyStoryStateView = nil;
    }
    if (_morsel != morsel || morsel.isUploading || !morsel) {
        _morsel = morsel;

        [self reset];

        if (morsel) {
            MorselImageSizeType morselSizeType = ([self getWidth] >= MRSLMorselImageLargeDimensionSize) ? MorselImageSizeTypeLarge : MorselImageSizeTypeThumbnail;
            if (_morsel.morselPhotoURL) {
                NSURLRequest *morselImageURLRequest = [_morsel morselPictureURLRequestForImageSizeType:morselSizeType];
                if (!morselImageURLRequest)
                    return;
                __weak __typeof(self)weakSelf = self;
                if (morselSizeType == MorselImageSizeTypeLarge) {
                    __block BOOL fullSizeImageSet = NO;
                    self.image = [UIImage imageNamed:@"graphic-image-large-placeholder.png"];

                    [_webImageManager downloadWithURL:[_morsel morselPictureURLRequestForImageSizeType:MorselImageSizeTypeThumbnail].URL
                                                               options:SDWebImageHighPriority
                                                              progress:nil
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                 if (!fullSizeImageSet) {
                                                                     self.image = image;
                                                                 }
                                                             }];
                    [_activityIndicatorView startAnimating];
                    [_webImageManager downloadWithURL:morselImageURLRequest.URL
                                                               options:SDWebImageHighPriority
                                                              progress:nil
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                 fullSizeImageSet = YES;
                                                                 [weakSelf.activityIndicatorView stopAnimating];
                                                                 weakSelf.image = image;
                                                                 if (error) {
                                                                     [weakSelf attemptToSetLocalMorselImageForSizeType:morselSizeType
                                                                                                             withError:nil];
                                                                 } else {
                                                                     if (weakSelf.morsel.morselPhotoFull) {
                                                                         weakSelf.morsel.morselPhotoFull = nil;
                                                                         weakSelf.morsel.morselPhotoCropped = nil;
                                                                         weakSelf.morsel.morselPhotoThumb = nil;
                                                                     }
                                                                 }
                                                             }];
                } else {
                    [self setImageWithURL:morselImageURLRequest.URL
                         placeholderImage:[UIImage imageNamed:@"graphic-thumb-story-null"]
                                  options:SDWebImageHighPriority
                                completed:nil];
                }
            } else {
                [self attemptToSetLocalMorselImageForSizeType:morselSizeType
                                                    withError:nil];
            }
        }
    }
}

- (void)attemptToSetLocalMorselImageForSizeType:(MorselImageSizeType)morselSizeType
                                      withError:(NSError *)errorOrNil {
    if (_morsel.morselPhotoThumb && _morsel.morselPhotoCropped) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *localImage = [UIImage imageWithData:(morselSizeType == MorselImageSizeTypeLarge) ? _morsel.morselPhotoCropped : _morsel.morselPhotoThumb];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = localImage;
                });
            });
            
        });
    } else {
        if (errorOrNil.code != -999) {
            DDLogError(@"Unable to set Morsel image and no local copy exists%@", (errorOrNil) ? [NSString stringWithFormat:@": %@", errorOrNil] : @".");
            self.image = nil;
        }
    }
}

#pragma mark - Private Methods

- (void)displayMorsel {
    if ([self.delegate respondsToSelector:@selector(morselImageViewDidSelectMorsel:)] && _morsel) {
        [self.delegate morselImageViewDidSelectMorsel:_morsel];
    }
}

- (void)reset {
    [_webImageManager cancelAll];
    self.image = nil;
}

#pragma mark - Destruction Methods

- (void)dealloc {
    [self reset];
}

@end
