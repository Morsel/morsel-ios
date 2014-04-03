//
//  ProfileImageView.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLProfileImageView.h"

#import <AFNetworking/AFNetworking.h>

#import "MRSLUser.h"

@interface MRSLProfileImageView ()

@property (strong, nonatomic) AFHTTPRequestOperation *imageRequestOperation;

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation MRSLProfileImageView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self addCornersWithRadius:[self getWidth] / 2];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.f;

    if (!self.image) [self setImageToPlaceholder];
}

#pragma mark - Instance Methods

- (void)setDelegate:(id<ProfileImageViewDelegate>)delegate {
    _delegate = delegate;

    if (!_tapRecognizer && _delegate) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayUserProfile)];

        [self addGestureRecognizer:_tapRecognizer];

        self.userInteractionEnabled = YES;
    }
}

- (void)setUser:(MRSLUser *)user {
    if (_user != user || !user) {
        _user = user;

        [self reset];

        if (user) {
            if (user.profilePhotoURL) {
                NSURLRequest *profileImageURLRequest = [user userProfilePictureURLRequestForImageSizeType:([self getWidth] > MRSLUserProfileImageThumbDimensionSize) ? ProfileImageSizeTypeMedium : ProfileImageSizeTypeSmall];
                if (!profileImageURLRequest)
                    return;

                __weak __typeof(self) weakSelf = self;

                self.imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:profileImageURLRequest];

                [_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *imageData) {
                    UIImage *downloadedProfileImage = [UIImage imageWithData:imageData];
                    weakSelf.image = downloadedProfileImage;
                } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                    if (weakSelf.user.profilePhotoLarge) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *localImage = [UIImage imageWithData:(weakSelf.frame.size.width > MRSLUserProfileImageThumbDimensionSize) ? weakSelf.user.profilePhotoLarge : weakSelf.user.profilePhotoThumb];
                            weakSelf.image = localImage;
                        });
                    } else {
                        DDLogError(@"ProfileImageView request operation failed and no local image exists: %@", error.userInfo);
                        [weakSelf setImageToPlaceholder];
                    }
                }];

                [_imageRequestOperation start];
            } else {
                if (self.user.profilePhotoLarge) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *localImage = [UIImage imageWithData:([self getWidth] > MRSLUserProfileImageThumbDimensionSize) ? self.user.profilePhotoLarge : self.user.profilePhotoThumb];
                        self.image = localImage;
                    });
                } else {
                    [self setImageToPlaceholder];
                }
            }
        } else {
            self.delegate = nil;
        }
    }
}

- (void)addAndRenderImage:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *scaledImage = [image thumbnailImage:[self getWidth]
                                interpolationQuality:kCGInterpolationHigh];

        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           self.image = scaledImage;
                       });
    });
}

#pragma mark - Private Methods

- (void)displayUserProfile {
    if ([self.delegate respondsToSelector:@selector(profileImageViewDidSelectUser:)] && _user) {
        [self.delegate profileImageViewDidSelectUser:_user];
    }
}

- (void)reset {
    if (self.imageRequestOperation) {
        [self.imageRequestOperation cancel];
        self.imageRequestOperation = nil;
    }
    self.image = nil;
}

- (void)setImageToPlaceholder {
    self.image = [UIImage imageNamed:@"placeholder_user_photo"];
}

#pragma mark - Destruction Methods

- (void)dealloc {
    if (self.imageRequestOperation) {
        [self.imageRequestOperation cancel];
        self.imageRequestOperation = nil;
    }
    
    if (self.tapRecognizer) {
        [self removeGestureRecognizer:_tapRecognizer];
        self.tapRecognizer = nil;
    }
}

@end
