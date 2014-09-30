//
//  MRSLBaseViewController+Additions.h
//  Morsel
//
//  Created by Javier Otero on 9/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

#import <RSKImageCropper/RSKImageCropViewController.h>

#import "MRSLMediaItem.h"

@interface MRSLBaseViewController (Additions)
<UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
RSKImageCropViewControllerDelegate>

- (void)displayMediaActionSheetWithTitle:(NSString *)title
               withPreferredDeviceCamera:(UIImagePickerControllerCameraDevice)cameraDevice;
- (void)processMediaItem:(MRSLMediaItem *)mediaItem;
- (void)userSelectedMediaItem:(MRSLMediaItem *)mediaItem;

@end
