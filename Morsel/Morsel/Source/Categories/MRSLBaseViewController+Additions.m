//
//  MRSLBaseViewController+Additions.m
//  Morsel
//
//  Created by Javier Otero on 9/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController+Additions.h"

#import <ALAssetsLibrary-CustomPhotoAlbum/ALAssetsLibrary+CustomPhotoAlbum.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <DBChooser/DBChooser.h>
#import <SDWebImage/SDWebImageDownloader.h>

#import "MRSLMediaItem.h"

@implementation MRSLBaseViewController (Additions)

#pragma mark - Instance Methods

- (void)displayMediaActionSheetWithTitle:(NSString *)title
               withPreferredDeviceCamera:(UIImagePickerControllerCameraDevice)cameraDevice {
    [self.view endEditing:YES];
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.preferredDeviceCamera = cameraDevice;
    UIActionSheet *profileActionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                    delegate:self
                                                           cancelButtonTitle:nil
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:@"Take Photo", @"Select from Library", nil];
    if ([MRSLUtil dropboxAvailable]) [profileActionSheet addButtonWithTitle:@"Dropbox"];
    [profileActionSheet setCancelButtonIndex:[profileActionSheet addButtonWithTitle:@"Cancel"]];
    [profileActionSheet showInView:self.view];
}

- (void)processMediaItem:(MRSLMediaItem *)mediaItem {
    // Override allowed
    __block UIImage *fullSizeImage = mediaItem.mediaFullImage;
    [self.view showActivityViewWithMode:RNActivityViewModeIndeterminate
                                  label:@"Processing image"
                            detailLabel:nil];
    __weak __typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("com.eatmorsel.capture-image-processing", NULL);
    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        mediaItem.mediaFullImage = [fullSizeImage thumbnailImage:MIN(MRSLImageFullDimensionSize, mediaItem.mediaFullImage.size.width)
                                            interpolationQuality:kCGInterpolationHigh];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(queue, ^{
                mediaItem.mediaLargeImage = [fullSizeImage thumbnailImage:MRSLItemImageLargeDimensionSize
                                                     interpolationQuality:kCGInterpolationHigh];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(queue, ^{
                        mediaItem.mediaThumbImage = [fullSizeImage thumbnailImage:MRSLItemImageThumbDimensionSize
                                                             interpolationQuality:kCGInterpolationHigh];
                        dispatch_async(main, ^{
                            if (weakSelf) {
                                [weakSelf.view hideActivityView];
                                [weakSelf userSelectedMediaItem:mediaItem];
                            }
                        });
                    });
                });
            });
        });
    });
}

- (void)userSelectedMediaItem:(MRSLMediaItem *)mediaItem {
    // Override necessary
}

- (void)importFromDropbox {
    __weak __typeof(self) weakSelf = self;
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect
                                    fromViewController:self completion:^(NSArray *results) {
                                        if (weakSelf) {
                                            if ([results count]) {
                                                // Process results from Chooser
                                                DBChooserResult *result = [results firstObject];
                                                if (result) {
                                                    [weakSelf.view showActivityViewWithMode:RNActivityViewModeIndeterminate
                                                                                      label:@"Downloading image"
                                                                                detailLabel:nil];
                                                    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:result.link
                                                                                                        options:0
                                                                                                       progress:nil
                                                                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                                                          if (weakSelf) {
                                                                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                  [weakSelf.view hideActivityView];
                                                                                                              });
                                                                                                              if (image && finished) {
                                                                                                                  [weakSelf showCropperForImage:image];
                                                                                                              } else if (error) {
                                                                                                                  [UIAlertView showAlertViewWithTitle:@"Error"
                                                                                                                                              message:@"Unable to download photo from Dropbox! Please try again."
                                                                                                                                             delegate:nil
                                                                                                                                    cancelButtonTitle:@"OK"
                                                                                                                                    otherButtonTitles:nil];
                                                                                                              }
                                                                                                          }
                                                                                                      }];
                                                }
                                            }
                                        }
                                    }];
}

- (void)showCropperForImage:(UIImage *)image {
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image
                                                                                       cropMode:RSKImageCropModeSquare
                                                                                       cropSize:CGSizeMake(MRSLItemImageLargeDimensionSize, MRSLItemImageLargeDimensionSize)];
    imageCropVC.delegate = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:imageCropVC
                           animated:NO
                         completion:nil];
    }];
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage {
    MRSLMediaItem *mediaItem = [[MRSLMediaItem alloc] init];
    mediaItem.mediaFullImage = croppedImage;
    [self processMediaItem:mediaItem];
    if (self.shouldSaveToDeviceLibrary) {
        [self.assetsLibrary saveImage:mediaItem.mediaFullImage
                              toAlbum:@"Morsel"
                           completion:nil
                              failure:nil];
    }
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.shouldSaveToDeviceLibrary = NO;
    NSString *actionSheetTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([actionSheetTitle isEqualToString:@"Cancel"]) return;

    if ([actionSheetTitle isEqualToString:@"Dropbox"]) {
        self.shouldSaveToDeviceLibrary = YES;
        [self importFromDropbox];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"]) {
            self.shouldSaveToDeviceLibrary = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.cameraDevice = self.preferredDeviceCamera;
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }

        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        imagePicker.delegate = self;

        if ([UIDevice currentDeviceIsIpad]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                    [popover presentPopoverFromRect:CGRectMake(self.view.center.x, self.view.center.y, 1.f, 1.f)
                                             inView:self.view
                           permittedArrowDirections:UIPopoverArrowDirectionAny
                                           animated:YES];
                    self.popOver = popover;
                } else {
                    [self presentViewController:imagePicker
                                       animated:YES
                                     completion:nil];
                }
            }];
        } else {
            [self presentViewController:imagePicker
                               animated:YES
                             completion:nil];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([UIDevice currentDeviceIsIpad] && !self.presentedViewController) {
        [self.popOver dismissPopoverAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:NO
                                 completion:nil];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
        [self showCropperForImage:selectedImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([UIDevice currentDeviceIsIpad] && !self.presentedViewController) {
        [self.popOver dismissPopoverAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:NO
                                 completion:nil];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
