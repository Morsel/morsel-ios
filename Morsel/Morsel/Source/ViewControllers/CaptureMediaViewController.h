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
- (void)captureMediaViewControllerDidAcceptImage:(UIImage *)updatedImage;

@end

@class MRSLMorsel;

@interface CaptureMediaViewController : UIViewController

@property (nonatomic, weak) id<CaptureMediaViewControllerDelegate> delegate;

@property (nonatomic, strong) MRSLMorsel *morsel;

@end
