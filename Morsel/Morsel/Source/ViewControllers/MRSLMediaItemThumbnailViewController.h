//
//  MRSLCapturePreviewsViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMediaItem;

@protocol MRSLMediaItemThumbnailViewControllerDelegate <NSObject>

@optional
- (void)mediaItemThumbnailDidDeleteMediaItem:(MRSLMediaItem *)mediaItem;

@end

@class MRSLMediaItem;

@interface MRSLMediaItemThumbnailViewController : UIViewController

@property (weak, nonatomic) id <MRSLMediaItemThumbnailViewControllerDelegate> delegate;

- (NSUInteger)thumbImageCount;

- (void)addPreviewMediaItem:(MRSLMediaItem *)mediaItem;

@end
