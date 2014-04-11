//
//  MRSLMediaItem.h
//  Morsel
//
//  Created by Javier Otero on 3/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSLMediaItem : NSObject

@property (strong, nonatomic) NSData *mediaFullImageData;
@property (strong, nonatomic) UIImage *mediaCroppedImage;
@property (strong, nonatomic) UIImage *mediaFullImage;
@property (strong, nonatomic) UIImage *mediaThumbImage;

@end
