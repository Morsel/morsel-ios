//
//  ProfileImageView.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "ProfileImageView.h"

#import "MRSLUser.h"

#import "UIImage+Resize.h"

@implementation ProfileImageView

- (void)setUser:(MRSLUser *)user
{
    _user = user;
    
    if (user)
    {
        self.image = [UIImage imageWithData:user.profileImage];
    }
    else
    {
        self.image = nil;
    }
}

- (void)addAndRenderImage:(UIImage *)image
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
    {
        UIImage *scaledImage = [image thumbnailImage:self.frame.size.width
                                interpolationQuality:kCGInterpolationHigh];
    
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.image = scaledImage;
        });
    });
}

@end
