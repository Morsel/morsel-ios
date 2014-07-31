//
//  CaptureMediaViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/25/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseCaptureMediaViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <DBChooser/DBChooser.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ALAssetsLibrary-CustomPhotoAlbum/ALAssetsLibrary+CustomPhotoAlbum.h>
#import <ELCImagePickerController/ELCImagePickerController.h>
#import <SDWebImage/SDWebImageDownloader.h>

#import "UIDevice+Additions.h"

static void *CapturingStillImageContext = &CapturingStillImageContext;
static void *SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface MRSLBaseCaptureMediaViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
ELCImagePickerControllerDelegate>

@property (nonatomic) int processingImageCount;

@property (weak, nonatomic) IBOutlet UIButton *cancelMorselButton;
@property (weak, nonatomic) IBOutlet UIView *topPanelView;

@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) id runtimeErrorHandlingObserver;

// Asset and Image Management
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

// Session and AV Management
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureFlashMode preferredFlashCaptureMode;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation MRSLBaseCaptureMediaViewController

#pragma mark - Class Methods

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized {
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode
           forDevice:(AVCaptureDevice *)device {
    if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
        NSError *error = nil;

        if ([device lockForConfiguration:&error]) {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        } else {
            DDLogError(@"Error setting Device Flash Mode: %@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];

    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            captureDevice = device;
            break;
        }
    }

    return captureDevice;
}

#pragma mark - Instance Methods

- (BOOL)isSessionRunningAndDeviceAuthorized {
    return ([self.session isRunning] &&
            [self isDeviceAuthorized]);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([UIDevice has35InchScreen]) self.topPanelView.hidden = YES;

    MRSLCameraPreviewView *previewView = [[MRSLCameraPreviewView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 568.f)];
    [self.view insertSubview:previewView atIndex:0];
    self.previewView = previewView;

    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.capturedMediaItems = [NSMutableArray array];
    self.preferredFlashCaptureMode = AVCaptureFlashModeOff;

    [self createSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
    [self beginCameraSession];

    if ([self isDeviceAuthorized]) {
        [self displayLatestCameraRollImage];
    }

    // Hide importDropboxButton if Dropbox is not installed or the installed version of Dropbox is not supported
    [self.importDropboxButton setHidden:![MRSLUtil dropboxAvailable]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self endCameraSession];
}

- (void)updateFinishButtonAvailability {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.finishButton.enabled = ([_capturedMediaItems count] > 0 && _processingImageCount == 0);
    });
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Action Methods

- (IBAction)importFromDropbox:(id)sender {
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect
                                    fromViewController:self completion:^(NSArray *results) {
         if ([results count]) {
             // Process results from Chooser
             [results enumerateObjectsUsingBlock:^(DBChooserResult *result, NSUInteger idx, BOOL *stop) {
                 [SDWebImageDownloader.sharedDownloader downloadImageWithURL:result.link
                                                                     options:0
                                                                    progress:nil
                                                                   completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                       if (image && finished) {
                                                                           MRSLMediaItem *mediaItem = [[MRSLMediaItem alloc] init];
                                                                           mediaItem.mediaFullImage = image;
                                                                           [self processMediaItem:mediaItem];
                                                                       } else if (error) {
                                                                           [UIAlertView showAlertViewWithTitle:@"Error"
                                                                                                       message:@"Unable to download photo from Dropbox! Please try again."
                                                                                                      delegate:nil
                                                                                             cancelButtonTitle:@"OK"
                                                                                             otherButtonTitles:nil];
                                                                       }
                                                                   }];
             }];
         } else {
             // User canceled the action
         }
     }];
}

- (IBAction)toggleFlashMode {
    switch (_preferredFlashCaptureMode) {
        case AVCaptureFlashModeAuto:
            self.preferredFlashCaptureMode = AVCaptureFlashModeOff;
            break;
        case AVCaptureFlashModeOff:
            self.preferredFlashCaptureMode = AVCaptureFlashModeOn;
            break;
        case AVCaptureFlashModeOn:
            self.preferredFlashCaptureMode = AVCaptureFlashModeAuto;
            break;
        default:
            break;
    }

    [self setFlashImageForMode:_preferredFlashCaptureMode];

    [MRSLBaseCaptureMediaViewController setFlashMode:_preferredFlashCaptureMode
                                       forDevice:[self.videoDeviceInput device]];
}

- (void)setFlashImageForMode:(AVCaptureFlashMode)mode {
    NSString *flashImageName = nil;

    switch (mode) {
        case AVCaptureFlashModeAuto:
            flashImageName = @"auto";
            break;
        case AVCaptureFlashModeOff:
            flashImageName = @"off";
            break;
        case AVCaptureFlashModeOn:
            flashImageName = @"on";
            break;
        default:
            break;
    }

    UIImage *flashImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon-capture-flash-%@", flashImageName]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_toggleFlashButton setImage:flashImage
                            forState:UIControlStateNormal];
    });
}

- (void)displayLatestCameraRollImage {
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                  usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stopSavedPhotoEnumeration) {
                                      if (assetsGroup) {
                                          [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                                          if (assetsGroup.numberOfAssets > 0) {
                                              [assetsGroup enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:assetsGroup.numberOfAssets - 1]
                                                                            options:NSEnumerationReverse
                                                                         usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                                                                             if (asset) {
                                                                                 ALAssetRepresentation *repr = [asset defaultRepresentation];
                                                                                 UIImage *thumbnailImage = [[UIImage imageWithCGImage:[repr fullResolutionImage]] thumbnailImage:MRSLUserProfileImageThumbDimensionSize interpolationQuality:kCGInterpolationHigh];
                                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                                     [self.cameraRollImageView setImage:thumbnailImage];
                                                                                 });
                                                                                 *stop = YES;
                                                                             }
                                                                         }];
                                          }
                                      }
                                  } failureBlock:^(NSError *error) {
                                      DDLogError(@"Unable to display latest Camera Roll image: %@", error);
                                  }];
}

- (IBAction)toggleTargetCamera {
    self.captureImageButton.enabled = NO;
    self.toggleCameraButton.enabled = NO;

    dispatch_async(self.sessionQueue, ^{
		AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
		AVCaptureDevicePosition currentPosition = [currentVideoDevice position];

		switch (currentPosition) {
			case AVCaptureDevicePositionUnspecified:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
			case AVCaptureDevicePositionBack:
				preferredPosition = AVCaptureDevicePositionFront;
				break;
			case AVCaptureDevicePositionFront:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
		}

		AVCaptureDevice *videoDevice = [MRSLBaseCaptureMediaViewController deviceWithMediaType:AVMediaTypeVideo
                                                                        preferringPosition:preferredPosition];

		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                                       error:nil];

		[self.session beginConfiguration];

		[self.session removeInput:[self videoDeviceInput]];

		if ([self.session canAddInput:videoDeviceInput]) {
			[[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                          object:currentVideoDevice];
			if (preferredPosition == AVCaptureDevicePositionFront) {
                self.toggleFlashButton.enabled = NO;
                [MRSLBaseCaptureMediaViewController setFlashMode:AVCaptureFlashModeOff
                                                   forDevice:videoDevice];

                [self setFlashImageForMode:AVCaptureFlashModeOff];
            } else {
                self.toggleFlashButton.enabled = YES;
                [MRSLBaseCaptureMediaViewController setFlashMode:_preferredFlashCaptureMode
                                                   forDevice:videoDevice];
                [self setFlashImageForMode:_preferredFlashCaptureMode];
            }

			[[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(subjectAreaDidChange:)
                                                         name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                       object:videoDevice];

			[self.session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		} else {
			[self.session addInput:[self videoDeviceInput]];
		}

		[self.session commitConfiguration];

		dispatch_async(dispatch_get_main_queue(), ^{
            self.captureImageButton.enabled = YES;
            self.toggleCameraButton.enabled = YES;
        });
    });
}

- (IBAction)cancelMediaCapture:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Cancel"
                                 properties:@{@"view": @"Media Capture",
                                              @"picture_count": @([_capturedMediaItems count])}];
    id captureDelegate = self.delegate;
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          if ([captureDelegate respondsToSelector:@selector(captureMediaViewControllerDidCancel)]) {
                                                              [captureDelegate captureMediaViewControllerDidCancel];
                                                          }
                                                      }];
}

- (IBAction)completeMediaCapture:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Done"
                                 properties:@{@"view": @"Media Capture",
                                              @"picture_count": @([_capturedMediaItems count])}];
    if ([self.capturedMediaItems count] > 0) {
        if ([self.delegate respondsToSelector:@selector(captureMediaViewControllerDidFinishCapturingMediaItems:)]) {
            [self.delegate captureMediaViewControllerDidFinishCapturingMediaItems:_capturedMediaItems];
            self.capturedMediaItems = nil;
        }
    }
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)displayCameraRoll:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Camera Roll Icon"
                                 properties:@{@"view": @"Media Capture"}];

    [self endCameraSession];

    // Create the image picker
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] init];
    imagePicker.maximumImagesCount = 10;
    imagePicker.imagePickerDelegate = self;

    //Present modally
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (IBAction)snapStillImage:(id)sender {
    [[MRSLEventManager sharedManager] track:@"Tapped Take a Picture"
                                 properties:@{@"view": @"Media Capture",
                                              @"picture_count": @([_capturedMediaItems count])}];
    dispatch_async(self.sessionQueue, ^{
		// Update the orientation on the still image output video connection before capturing.
		[[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer  *)self.previewView.layer connection] videoOrientation]];

		// Flash set to Auto for Still Capture
		[MRSLBaseCaptureMediaViewController setFlashMode:_preferredFlashCaptureMode
                                           forDevice:[self.videoDeviceInput device]];

		// Capture a still image.
		[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo]
                                                           completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                               if (imageDataSampleBuffer) {
                                                                   NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];

                                                                   UIImage *capturedImage = [[UIImage alloc] initWithData:imageData];

                                                                   [_assetsLibrary saveImage:capturedImage
                                                                                     toAlbum:@"Morsel"
                                                                                  completion:nil
                                                                                     failure:nil];

                                                                   MRSLMediaItem *mediaItem = [[MRSLMediaItem alloc] init];
                                                                   mediaItem.mediaFullImage = capturedImage;

                                                                   [self processMediaItem:mediaItem];
                                                               }
                                                           }];
    });
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)self.previewView.layer captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:gestureRecognizer.view]];

    [self focusWithMode:AVCaptureFocusModeAutoFocus
         exposeWithMode:AVCaptureExposureModeAutoExpose
          atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    CGPoint devicePoint = CGPointMake(.5f, .5f);

    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus
         exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
          atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark - Device Camera Methods

- (void)processMediaItem:(MRSLMediaItem *)mediaItem {
    self.processingImageCount++;
    self.captureImageButton.enabled = NO;
    __block UIImage *fullSizeImage = mediaItem.mediaFullImage;
    DDLogDebug(@"Source Process Image Dimensions: (w:%f, h:%f)", fullSizeImage.size.width, fullSizeImage.size.height);
    BOOL imageIsLandscape = [MRSLUtil imageIsLandscape:fullSizeImage];
    CGFloat cameraDimensionScale = [MRSLUtil cameraDimensionScaleFromImage:fullSizeImage];
    CGFloat cropStartingY = [UIDevice has35InchScreen] ? 0.f : yCameraImagePreviewOffset * cameraDimensionScale;
    CGFloat minimumImageDimension = (imageIsLandscape) ? fullSizeImage.size.height : fullSizeImage.size.width;
    CGFloat maximumImageDimension = (imageIsLandscape) ? fullSizeImage.size.width : fullSizeImage.size.height;
    CGFloat xCenterAdjustment = (maximumImageDimension - minimumImageDimension) / 2.f;

    [self updateFinishButtonAvailability];

    __weak __typeof(self) weakSelf = self;

    dispatch_queue_t queue = dispatch_queue_create("com.eatmorsel.capture-image-processing", NULL);
    dispatch_queue_t main = dispatch_get_main_queue();

    dispatch_async(queue, ^{
        if (weakSelf) {
            CGRect cropRect = CGRectMake((imageIsLandscape) ? xCenterAdjustment : 0.f, (imageIsLandscape) ? 0.f : cropStartingY, minimumImageDimension, minimumImageDimension);
            if (fullSizeImage.size.width == fullSizeImage.size.height) {
                // Since the image is square, don't adjust the crop rect to account for interface overlap
                cropRect = CGRectMake(0.f, 0.f, minimumImageDimension, minimumImageDimension);
            }
            dispatch_async(queue, ^{
                __block UIImage *croppedFullSizeImage = [fullSizeImage croppedImage:cropRect
                                                                 ignoresOrientation:NO];
                fullSizeImage = nil;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), main, ^{
                    dispatch_async(queue, ^{
                        croppedFullSizeImage = [croppedFullSizeImage resizedImage:CGSizeMake(MRSLItemImageFullDimensionSize, MRSLItemImageFullDimensionSize)
                                                             interpolationQuality:kCGInterpolationHigh];
                        dispatch_async(queue, ^{
                            mediaItem.mediaFullImage = croppedFullSizeImage;
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), main, ^{
                                dispatch_async(queue, ^{
                                    mediaItem.mediaThumbImage = [croppedFullSizeImage thumbnailImage:MRSLItemImageThumbDimensionSize
                                                                                interpolationQuality:kCGInterpolationHigh];
                                    dispatch_async(main, ^{
                                        if (weakSelf) {
                                            [weakSelf handleProcessedMediaItem:mediaItem];
                                            weakSelf.captureImageButton.enabled = YES;
                                            weakSelf.processingImageCount--;
                                            [weakSelf updateFinishButtonAvailability];
                                        }
                                    });
                                });
                            });
                        });
                    });
                });
            });
        }
    });
}

- (void)handleProcessedMediaItem:(MRSLMediaItem *)mediaItem {
    NSAssert(NO, @"Must override method handleProcessedMediaItem: in subclass");
}

- (void)createSession {
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];

    // Setup the preview view
    [self.previewView setSession:session];

    // Check for device authorization
    [self checkDeviceAuthorizationStatus];

    // Dispatch the rest of session setup to the sessionQueue so that the main queue isn't blocked.
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];

    dispatch_async(sessionQueue, ^{
        NSError *error = nil;

        AVCaptureDevice *videoDevice = [MRSLBaseCaptureMediaViewController deviceWithMediaType:AVMediaTypeVideo
                                                                        preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                                       error:&error];
        if (error) {
            DDLogError(@"Error setting AVCaptureDeviceInput: %@", error);
        }

        if ([session canAddInput:videoDeviceInput]) {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }

        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];

        if ([session canAddOutput:stillImageOutput]) {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
    });
}

- (void)beginCameraSession {
    if (![self.session isRunning]) {
        dispatch_async(self.sessionQueue, ^{
            [self addObserver:self
                   forKeyPath:@"sessionRunningAndDeviceAuthorized"
                      options:(NSKeyValueObservingOptionOld |
                               NSKeyValueObservingOptionNew)
                      context:SessionRunningAndDeviceAuthorizedContext];

            [self addObserver:self
                   forKeyPath:@"stillImageOutput.capturingStillImage"
                      options:(NSKeyValueObservingOptionOld |
                               NSKeyValueObservingOptionNew)
                      context:CapturingStillImageContext];

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(subjectAreaDidChange:)
                                                         name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                       object:[self.videoDeviceInput device]];

            __weak __typeof(self)weakSelf = self;

            [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter]
                                                   addObserverForName:AVCaptureSessionRuntimeErrorNotification
                                                   object:self.session
                                                   queue:nil
                                                   usingBlock:^(NSNotification *note) {
                                                       MRSLBaseCaptureMediaViewController *strongSelf = weakSelf;

                                                       dispatch_async(strongSelf.sessionQueue, ^{
                                                           // Manually restarting the session since it must have been stopped due to an error.
                                                           [strongSelf.session startRunning];
                                                       });
                                                   }]];
            [self.session startRunning];
        });
    }
}

- (void)endCameraSession {
    if ([self.session isRunning]) {
        dispatch_async(self.sessionQueue, ^{
            [self.session stopRunning];
            @try {
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                              object:[self.videoDeviceInput device]];
                [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
                [[NSNotificationCenter defaultCenter] removeObserver:self.session];
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                [self removeObserver:self
                          forKeyPath:@"sessionRunningAndDeviceAuthorized"
                             context:SessionRunningAndDeviceAuthorizedContext];

                [self removeObserver:self
                          forKeyPath:@"stillImageOutput.capturingStillImage"
                             context:CapturingStillImageContext];
            } @catch (NSException *exception) {
                DDLogError(@"Unable to remove session observers because they do not exist.");
            }
        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == CapturingStillImageContext) {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];

        if (isCapturingStillImage) {
            [self runStillImageCaptureAnimation];
        }
    } else if (context == SessionRunningAndDeviceAuthorizedContext) {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning) {
                [self.captureImageButton setEnabled:YES];
            } else {
                [self.captureImageButton setEnabled:NO];
            }
        });
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode
       exposeWithMode:(AVCaptureExposureMode)exposureMode
        atDevicePoint:(CGPoint)point
monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    dispatch_async(self.sessionQueue, ^{
		AVCaptureDevice *device = [self.videoDeviceInput device];
		NSError *error = nil;

		if ([device lockForConfiguration:&error]) {
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]) {
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}

			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode]) {
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}

			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		} else {
			DDLogError(@"%@", error);
		}
    });
}

#pragma mark - User Interface Methods

- (void)runStillImageCaptureAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
		[self.previewView.layer setOpacity:0.f];

		[UIView animateWithDuration:.25f animations:^{
            [self.previewView.layer setOpacity:1.f];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus {
    NSString *mediaType = AVMediaTypeVideo;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if (granted) {
                //Granted access to mediaType
                [self setDeviceAuthorized:YES];
                [self displayLatestCameraRollImage];
            } else {
                //Not granted access to mediaType
                dispatch_async(dispatch_get_main_queue(), ^{
                    DDLogError(@"Camera access permission denied. Cannot create AV session!");

                    [UIAlertView showAlertViewWithTitle:@"Permission Denied"
                                                message:@"Morsel doesn't have permission to use the Camera, please change your privacy settings!"
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];

                    [self setDeviceAuthorized:NO];
                });
            }
        }];
    } else {
        [self setDeviceAuthorized:YES];
        [self displayLatestCameraRollImage];
    }
}

#pragma mark - ELCImagePickerControllerDelegate

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    [[MRSLEventManager sharedManager] track:@"Tapped Done"
                                 properties:@{@"view": @"Media Capture",
                                              @"picture_count": @([info count])}];
    [info enumerateObjectsUsingBlock:^(NSDictionary *mediaInfo, NSUInteger idx, BOOL *stop) {
        MRSLMediaItem *mediaItem = [[MRSLMediaItem alloc] init];
        mediaItem.mediaFullImage = mediaInfo[UIImagePickerControllerOriginalImage];
        [self processMediaItem:mediaItem];
    }];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.capturedMediaItems removeAllObjects];
    [self endCameraSession];

    [self.previewView reset];

    self.runtimeErrorHandlingObserver = nil;
    self.videoDeviceInput = nil;
    self.stillImageOutput = nil;
    self.session = nil;
    self.previewView = nil;
    self.assetsLibrary = nil;
    self.capturedMediaItems = nil;

    [self resetChildViewControllers];
}

@end
