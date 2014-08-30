//
//  MRSLCaptureSingleMediaViewController.m
//  Morsel
//
//  Created by Javier Otero on 7/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCaptureSingleMediaViewController.h"

@interface MRSLCaptureSingleMediaViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *approvalImageView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;

@property (strong, nonatomic) MRSLMediaItem *capturedMediaItem;

@end

@implementation MRSLCaptureSingleMediaViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_action = @"edit";
    self.finishButton.hidden = YES;
    if ([UIDevice has35InchScreen]) [self.approvalImageView setY:0.f];
}

#pragma mark - Override Methods

- (void)handleProcessedMediaItem:(MRSLMediaItem *)mediaItem {
    self.capturedMediaItem = mediaItem;
    self.approvalImageView.image = _capturedMediaItem.mediaFullImage;
    [self endCameraSession];
    [self shouldHideControls:YES];
}

#pragma mark - Action Methods

- (IBAction)acceptPhoto {
    if ([self.delegate respondsToSelector:@selector(captureMediaViewControllerDidFinishCapturingMediaItems:)]) {
        [self.delegate captureMediaViewControllerDidFinishCapturingMediaItems:@[_capturedMediaItem]];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)retakePhoto {
    self.capturedMediaItem = nil;
    self.approvalImageView.image = nil;
    [self beginCameraSession];
    [self shouldHideControls:NO];
}

#pragma mark - Private Methods

- (void)shouldHideControls:(BOOL)shouldHide {
    self.acceptButton.hidden = !shouldHide;
    self.retakeButton.hidden = !shouldHide;
    self.approvalImageView.hidden = !shouldHide;
    self.captureImageButton.enabled = !shouldHide;
    self.cameraRollButton.enabled = !shouldHide;
    self.previewView.hidden = shouldHide;
    self.cameraRollImageView.hidden = shouldHide;
    if ([MRSLUtil dropboxAvailable]) self.importDropboxButton.hidden = shouldHide;
    self.toggleCameraButton.hidden = shouldHide;
    self.toggleFlashButton.hidden = shouldHide;
}

@end
