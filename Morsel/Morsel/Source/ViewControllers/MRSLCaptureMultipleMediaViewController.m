//
//  MRSLCaptureMultipleMediaViewController.m
//  Morsel
//
//  Created by Javier Otero on 7/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCaptureMultipleMediaViewController.h"

#import "MRSLMediaItemThumbnailViewController.h"

@interface MRSLCaptureMultipleMediaViewController ()
<MRSLMediaItemThumbnailViewControllerDelegate>

@property (weak, nonatomic) MRSLMediaItemThumbnailViewController *capturePreviewsViewController;

@end

@implementation MRSLCaptureMultipleMediaViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.childViewControllers count] > 0) {
        UIViewController *firstChildVC = [self.childViewControllers firstObject];
        if ([firstChildVC isKindOfClass:[MRSLMediaItemThumbnailViewController class]]) {
            self.capturePreviewsViewController = (MRSLMediaItemThumbnailViewController *)firstChildVC;
            _capturePreviewsViewController.delegate = self;
        }
    }
}

#pragma mark - Override Methods

- (void)handleProcessedMediaItem:(MRSLMediaItem *)mediaItem {
    [self.capturedMediaItems addObject:mediaItem];
    [self.capturePreviewsViewController addPreviewMediaItem:mediaItem];
}

#pragma mark - MRSLMediaItemThumbnailViewControllerDelegate

- (void)mediaItemThumbnailDidDeleteMediaItem:(MRSLMediaItem *)mediaItem {
    [self.capturedMediaItems removeObject:mediaItem];
    [self updateFinishButtonAvailability];
}

@end
