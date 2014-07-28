//
//  ProfileImageView.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLProfileImageView.h"

#import "UIImage+Color.h"

#import "MRSLUser.h"

@implementation MRSLProfileImageView

- (void)awakeFromNib {
    [super awakeFromNib];

    if (!self.shouldBlur) {
        [self setRoundedCornerRadius:[self getWidth] / 2];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2.f;
    }
}

#pragma mark - Instance Methods

- (void)setUser:(MRSLUser *)user {
    _user = user;
    [self setImageObject:_user];
}

- (void)addAndRenderImage:(UIImage *)image
                 complete:(MRSLImageProcessingBlock)completeOrNil {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *scaledImage = [image thumbnailImage:[self getWidth] interpolationQuality:kCGInterpolationHigh];
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

- (UIImage *)placeholderImage {
    return ([self getWidth] <= MRSLProfileThumbDimensionThreshold) ? [UIImage imageNamed:@"graphic-placeholder-profile"] : [UIImage imageWithColor:[UIColor whiteColor]];
}

#pragma mark - Action Methods

- (void)imageViewTapped:(UITapGestureRecognizer *)tapRecognizer {
    if (_user) {
        NSDictionary *parameters = @{@"user_id": NSNullIfNil(_user.userID)};
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayUserProfileNotification
                                                            object:parameters];
    }
}

@end
