//
//  CameraPreviewView.h
//  Morsel
//
//  Created by Javier Otero on 1/25/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface MRSLCameraPreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
