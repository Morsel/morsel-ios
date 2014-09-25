//
//  CaptureMediaViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/25/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MRSLCameraPreviewView.h"
#import "MRSLMediaItem.h"

@protocol CaptureMediaViewControllerDelegate <NSObject>

@optional
// Returns an array of MediaItem objects
- (void)captureMediaViewControllerDidFinishCapturingMediaItems:(NSArray *)capturedMedia;
- (void)captureMediaViewControllerDidCancel;

@end

@interface MRSLBaseCaptureMediaViewController : UIViewController

@property (weak, nonatomic) id<CaptureMediaViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *captureImageButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *importDropboxButton;
@property (weak, nonatomic) IBOutlet UIImageView *cameraRollImageView;
@property (weak, nonatomic) IBOutlet MRSLCameraPreviewView *previewView;

@property (strong, nonatomic) NSMutableArray *capturedMediaItems;

@property (strong, nonatomic) NSString *mp_action;

- (void)beginCameraSession;
- (void)endCameraSession;
- (void)updateFinishButtonAvailability;
- (void)handleProcessedMediaItem:(MRSLMediaItem *)mediaItem;

@end
