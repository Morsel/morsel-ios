//
//  ProfileImageView.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLUser;

@interface MRSLProfileImageView : UIImageView

@property (nonatomic) BOOL shouldBlur;

@property (weak, nonatomic) MRSLUser *user;

- (void)addAndRenderImage:(UIImage *)image
                 complete:(MRSLImageProcessingBlock)completeOrNil;

@end
