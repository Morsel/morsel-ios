//
//  CaptureMediaViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/25/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CaptureMediaViewControllerDelegate <NSObject>

@optional
// Returns an array of MediaItem objects
- (void)captureMediaViewControllerDidFinishCapturingMediaItems:(NSMutableArray *)capturedMedia;

@end

@interface MRSLCaptureMediaViewController : UIViewController

@property (weak, nonatomic) id<CaptureMediaViewControllerDelegate> delegate;

@end
