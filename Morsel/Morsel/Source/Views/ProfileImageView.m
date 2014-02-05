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

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation ProfileImageView

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
    if (_user != user) {
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
        } else {
            self.image = nil;
            self.delegate = nil;
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

#pragma mark - Private Methods

- (void)displayUserProfile {
    if ([self.delegate respondsToSelector:@selector(profileImageViewDidSelectUser:)] && _user) {
        [self.delegate profileImageViewDidSelectUser:_user];
    }
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
