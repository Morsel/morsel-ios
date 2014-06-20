//
//  MRSLCapturePreviewsViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMediaItem;

@protocol MRSLCapturePreviewsViewControllerDelegate <NSObject>

@optional
- (void)capturePreviewsDidDeleteMediaItem:(MRSLMediaItem *)mediaItem;

@end

@class MRSLMediaItem;

@interface MRSLCapturePreviewsViewController : UIViewController

@property (weak, nonatomic) id <MRSLCapturePreviewsViewControllerDelegate> delegate;

- (NSUInteger)thumbImageCount;

- (void)addPreviewMediaItem:(MRSLMediaItem *)mediaItem;

@end
