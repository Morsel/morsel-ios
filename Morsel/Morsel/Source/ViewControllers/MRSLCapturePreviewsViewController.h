//
//  MRSLCapturePreviewsViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLCapturePreviewsViewControllerDelegate <NSObject>

@optional
- (void)capturePreviewsDidDeleteMedia;

@end

@class MRSLMediaItem;

@interface MRSLCapturePreviewsViewController : UIViewController

@property (weak, nonatomic) id <MRSLCapturePreviewsViewControllerDelegate> delegate;

- (NSUInteger)thumbImageCount;

- (void)addPreviewMediaItemThumb:(UIImage *)thumbImage;

@end
