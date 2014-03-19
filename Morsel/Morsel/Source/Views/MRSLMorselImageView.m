//
//  MRSLMorselImageView.m
//  Morsel
//
//  Created by Javier Otero on 3/13/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselImageView.h"

#import <AFNetworking/AFNetworking.h>

#import "MRSLMorsel.h"

@interface MRSLMorselImageView ()

@property (strong, nonatomic) AFHTTPRequestOperation *imageRequestOperation;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) UIImageView *emptyStoryStateView;

@end

@implementation MRSLMorselImageView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor morselDarkContent];

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:([self getWidth] > MRSLMorselImageThumbDimensionSize) ? UIActivityIndicatorViewStyleWhiteLarge : UIActivityIndicatorViewStyleGray];
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
            MorselImageSizeType morselSizeType = ([self getWidth] > MRSLMorselImageThumbDimensionSize) ? MorselImageSizeTypeCropped : MorselImageSizeTypeThumbnail;
            if (_morsel.morselPhotoURL) {
                NSURLRequest *morselImageURLRequest = [_morsel morselPictureURLRequestForImageSizeType:morselSizeType];
                if (!morselImageURLRequest)
                    return;
                __weak __typeof(self) weakSelf = self;
                self.imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:morselImageURLRequest];
                [_activityIndicatorView startAnimating];
                [_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *imageData) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        UIImage *downloadedMorselImage = [UIImage imageWithData:imageData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.image = downloadedMorselImage;
                        });
                    });
                    [weakSelf.activityIndicatorView stopAnimating];
                } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                    if ([operation.response statusCode] == 403 && !weakSelf.morsel.morselPhotoCropped) {
                        [_appDelegate.morselApiService getMorsel:weakSelf.morsel
                                                         success:nil
                                                         failure:^(NSError *error) {
                                                             DDLogError(@"Morsel appears to no longer exist. Removing from store!");
                                                             [weakSelf.morsel MR_deleteEntity];
                                                             [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
                                                         }];
                    } else {
                        [weakSelf attemptToSetLocalMorselImageForSizeType:morselSizeType
                                                                withError:error];
                        [weakSelf.activityIndicatorView stopAnimating];
                    }

                }];
                [_imageRequestOperation start];
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
                UIImage *localImage = [UIImage imageWithData:(morselSizeType == MorselImageSizeTypeCropped) ? _morsel.morselPhotoCropped : _morsel.morselPhotoThumb];
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

- (void)reset {
    if (self.imageRequestOperation) {
        [self.imageRequestOperation cancel];
        self.imageRequestOperation = nil;
    }
    self.image = nil;
}

#pragma mark - Destruction Methods

- (void)dealloc {
    if (self.imageRequestOperation) {
        [self.imageRequestOperation cancel];
        self.imageRequestOperation = nil;
    }
}

@end
