//
//  MRSLImageView.h
//  Morsel
//
//  Created by Javier Otero on 6/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

@class MRSLActivityIndicatorView;

#import "MRSLImageRequestable.h"

@interface MRSLImageView : UIImageView

@property (nonatomic) BOOL grayScale;
@property (nonatomic) BOOL shouldBlur;

@property (nonatomic, strong) MRSLActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) id <MRSLImageRequestable> imageObject;

- (UIImage *)placeholderImage;
- (MRSLImageSizeType)imageSizeType;

- (void)imageViewTapped:(UITapGestureRecognizer *)tapRecognizer;
- (void)reset;

@end
