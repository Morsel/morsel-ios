//
//  ProfileImageView.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "ProfileImageView.h"

#import <AFNetworking/AFNetworking.h>

#import "ModelController.h"

#import "MRSLUser.h"

@interface ProfileImageView ()

@property (nonatomic, strong) AFHTTPRequestOperation *imageRequestOperation;

@end

@implementation ProfileImageView

- (void)setUser:(MRSLUser *)user {
    _user = user;

    if (self.imageRequestOperation) {
        [self.imageRequestOperation cancel];
        self.imageRequestOperation = nil;
    }

    if (user) {
        if (user.profileImageURL) {
            NSURLRequest *profileImageURLRequest = [user userProfilePictureURLRequestForImageSizeType:(self.frame.size.width > 40.f) ? ProfileImageSizeTypeMedium : ProfileImageSizeTypeSmall];
            if (!profileImageURLRequest)
                return;

            __weak __typeof(self) weakSelf = self;

            self.imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:profileImageURLRequest];

            [_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData *imageData)
            {
                user.profileImage = imageData;

                UIImage *downloadedProfileImage = [UIImage imageWithData:imageData];
                weakSelf.image = downloadedProfileImage;

                weakSelf.imageRequestOperation = nil;
            } failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
                DDLogError(@"Profile Image View Request Operation Failed: %@", error.userInfo);

                weakSelf.imageRequestOperation = nil;
            }];

            [_imageRequestOperation start];
        } else {
            self.image = nil;
        }
    }
}

- (void)addAndRenderImage:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *scaledImage = [image thumbnailImage:self.frame.size.width
                                interpolationQuality:kCGInterpolationHigh];
    
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.image = scaledImage;
        });
    });
}

#pragma mark - Destruction Methods

- (void)dealloc {
    if (self.imageRequestOperation) {
        [self.imageRequestOperation cancel];
        self.imageRequestOperation = nil;
    }
}

@end
