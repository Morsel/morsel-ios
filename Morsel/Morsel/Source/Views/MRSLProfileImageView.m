//
//  ProfileImageView.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLProfileImageView.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "MRSLUser.h"

@interface MRSLProfileImageView ()

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation MRSLProfileImageView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self addCornersWithRadius:[self getWidth] / 2];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.f;

    if (!self.image) [self setImageToPlaceholderOrLocal];

    if (!_tapRecognizer && self.userInteractionEnabled) {
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayUserProfile)];
        [self addGestureRecognizer:_tapRecognizer];
    }
}

#pragma mark - Instance Methods

- (void)setUser:(MRSLUser *)user {
    if (_user != user || !user) {
        _user = user;

        [self reset];

        if (user) {
            if (user.profilePhotoURL) {
                NSURLRequest *profileImageURLRequest = [user userProfilePictureURLRequestForImageSizeType:([self getWidth] > MRSLUserProfileImageThumbDimensionSize) ? MRSLProfileImageSizeTypeMedium : MRSLProfileImageSizeTypeSmall];
                if (!profileImageURLRequest)
                    return;

                __weak __typeof(self)weakSelf = self;
                [self setImageWithURL:profileImageURLRequest.URL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    if (error) {
                        [weakSelf setImageToPlaceholderOrLocal];
                    }
                }];
            } else {
                [self setImageToPlaceholderOrLocal];
            }
        }
    }
}

- (void)addAndRenderImage:(UIImage *)image
                 complete:(MRSLImageProcessingBlock)completeOrNil {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *scaledImage = [image thumbnailImage:[self getWidth]
                                interpolationQuality:kCGInterpolationHigh];
        if (scaledImage) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                self.image = scaledImage;
                if (completeOrNil) completeOrNil(YES);
            });
        } else {
            if (completeOrNil) completeOrNil(NO);
        }
    });
}

#pragma mark - Private Methods

- (void)displayUserProfile {
    if (_user) {
        NSDictionary *parameters = @{@"user_id": NSNullIfNil(_user.userID)};
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayUserProfileNotification
                                                            object:parameters];
    }
}

- (void)reset {
    self.image = nil;
}

- (void)setImageToPlaceholderOrLocal {
    if (self.user.profilePhotoLarge) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *localImage = [UIImage imageWithData:([self getWidth] > MRSLUserProfileImageThumbDimensionSize) ? self.user.profilePhotoLarge : self.user.profilePhotoThumb];
            self.image = localImage;
        });
    } else {
        self.image = [UIImage imageNamed:@"graphic-placeholder-profile"];
    }
}

#pragma mark - Dealloc Methods

- (void)dealloc {
    [self reset];
    if (self.tapRecognizer) {
        [self removeGestureRecognizer:_tapRecognizer];
        self.tapRecognizer = nil;
    }
}

@end
