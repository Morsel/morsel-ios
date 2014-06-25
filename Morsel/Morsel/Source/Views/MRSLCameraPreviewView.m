//
//  CameraPreviewView.m
//  Morsel
//
//  Created by Javier Otero on 1/25/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCameraPreviewView.h"

#import <AVFoundation/AVFoundation.h>

@implementation MRSLCameraPreviewView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)[self layer];
    [previewLayer setSession:session];
    previewLayer.videoGravity = AVLayerVideoGravityResize;
    previewLayer.bounds = self.bounds;
    previewLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

@end
