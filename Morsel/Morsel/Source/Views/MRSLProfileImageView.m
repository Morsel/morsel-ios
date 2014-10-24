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

@interface MRSLProfileImageView ()

@property (nonatomic) BOOL viewPrepared;

@end

@implementation MRSLProfileImageView

#pragma mark - Instance Methods

- (void)setUser:(MRSLUser *)user {
    _user = user;
    [self setImageObject:_user];
    [self setUp];
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

#pragma mark - Private Methods

- (void)setUp {
    if (self.viewPrepared) return;
    self.viewPrepared = YES;
    if (!self.shouldBlur) {
        UIImageView *whiteCircleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([self getWidth] <= MRSLProfileThumbDimensionThreshold) ? @"effect-circle-white-large" : @"effect-circle-white-small"]];
        whiteCircleImageView.frame = CGRectMake(0.f, 0.f, [self getWidth], [self getHeight]);
        [self addSubview:whiteCircleImageView];
    }
}

- (void)setValue:(id)value
      forKeyPath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"addRoundedCorners"]) {
        if (!self.shouldBlur) {
            [self setRoundedCornerRadius:[self getWidth] / 2];
        }
    } else {
        [super setValue:value
             forKeyPath:keyPath];
    }
}

@end
