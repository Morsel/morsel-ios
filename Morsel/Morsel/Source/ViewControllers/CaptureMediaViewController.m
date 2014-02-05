//
//  CaptureMediaViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/25/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "CaptureMediaViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "CameraPreviewView.h"
#import "CreateMorselViewController.h"

static void *CapturingStillImageContext = &CapturingStillImageContext;
static void *SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface CaptureMediaViewController ()
    <UIImagePickerControllerDelegate,
     UINavigationControllerDelegate>

@property (nonatomic) BOOL isSelectingImage;
@property (nonatomic) BOOL userIsEditing;

@property (nonatomic) AVCaptureFlashMode preferredFlashCaptureMode;

@property (nonatomic, weak) IBOutlet CameraPreviewView *previewView;

@property (weak, nonatomic) IBOutlet UIButton *acceptImageButton;
@property (nonatomic, weak) IBOutlet UIButton *captureImageButton;
@property (weak, nonatomic) IBOutlet UIButton *discardImageButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraRollButton;
@property (weak, nonatomic) IBOutlet UIButton *addTextMorselButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelMorselButton;
@property (weak, nonatomic) IBOutlet UIImageView *approvalImageView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraRollImageView;
@property (weak, nonatomic) IBOutlet UIButton *toggleFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleCameraButton;
@property (weak, nonatomic) IBOutlet UIView *togglePipeView;

// Image Data
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

// Session management
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter=isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter=isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation CaptureMediaViewController

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

    self.preferredFlashCaptureMode = AVCaptureFlashModeOff;

    [self createSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_morsel) self.userIsEditing = YES;

    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];

    if (![self.session isRunning] && !_isSelectingImage) {
        [self beginCameraSession];
    }
    
    if ([self isDeviceAuthorized]) {
        [self displayLatestCameraRollImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (self.approvalImageView.image) {
        self.approvalImageView.image = nil;

        [self enableMainControls:YES];
    }

    [self endCameraSession];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"DisplayCreateMorsel"]) {
        CreateMorselViewController *createMorselVC = [segue destinationViewController];
        createMorselVC.capturedImage = _capturedImage ?: nil;

        self.capturedImage = nil;
    }
}

#pragma mark - Action Methods

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

    [CaptureMediaViewController setFlashMode:_preferredFlashCaptureMode
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
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stopSavedPhotoEnumeration) {
                                     if (nil != group) {
                                         [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                                                                 options:0
                                                              usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                                  if (nil != result) {
                                                                      ALAssetRepresentation *repr = [result defaultRepresentation];
                                                                      UIImage *thumbnailImage = [[UIImage imageWithCGImage:[repr fullResolutionImage]] thumbnailImage:40.f interpolationQuality:kCGInterpolationHigh];
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          [self.cameraRollImageView setImage:thumbnailImage];
                                                                      });
                                                                      *stop = YES;
                                                                  }
                                                              }];
                                     }
                                 } failureBlock:^(NSError *error) {
                                     NSLog(@"error: %@", error);
                                 }];
}

- (IBAction)toggleTargetCamera {
    self.captureImageButton.enabled = NO;
    self.toggleCameraButton.enabled = NO;

    dispatch_async(self.sessionQueue, ^{
		AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
		AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
		
		switch (currentPosition)
		{
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
		
		AVCaptureDevice *videoDevice = [CaptureMediaViewController deviceWithMediaType:AVMediaTypeVideo
                                                                    preferringPosition:preferredPosition];
        
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                                       error:nil];
		
		[self.session beginConfiguration];
		
		[self.session removeInput:[self videoDeviceInput]];
        
		if ([self.session canAddInput:videoDeviceInput])
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                          object:currentVideoDevice];
			if (preferredPosition == AVCaptureDevicePositionFront)
            {
                self.toggleFlashButton.enabled = NO;
                [CaptureMediaViewController setFlashMode:AVCaptureFlashModeOff
                                               forDevice:videoDevice];
                
                [self setFlashImageForMode:AVCaptureFlashModeOff];
            }
            else
            {
                self.toggleFlashButton.enabled = YES;
                [CaptureMediaViewController setFlashMode:_preferredFlashCaptureMode
                                               forDevice:videoDevice];
                [self setFlashImageForMode:_preferredFlashCaptureMode];
            }
            
			[[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(subjectAreaDidChange:)
                                                         name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                       object:videoDevice];
			
			[self.session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		}
		else
		{
			[self.session addInput:[self videoDeviceInput]];
		}
		
		[self.session commitConfiguration];
		
		dispatch_async(dispatch_get_main_queue(), ^
        {
			self.captureImageButton.enabled = YES;
            self.toggleCameraButton.enabled = YES;
		});
    });
}

- (IBAction)cancelMorselCreation:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)displayCameraRoll:(id)sender {
    [self endCameraSession];

    self.isSelectingImage = YES;

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.allowsEditing = NO;
    imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
    imagePicker.delegate = self;

    self.imagePicker = imagePicker;

    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (IBAction)addMorselText:(id)sender {
    [self performSegueWithIdentifier:@"DisplayCreateMorsel"
                              sender:nil];
}

- (IBAction)discardImage:(id)sender {
    self.isSelectingImage = NO;

    self.approvalImageView.image = nil;
    self.capturedImage = nil;

    [self beginCameraSession];

    [self enableMainControls:YES];
}

- (IBAction)acceptImage:(id)sender {
    if (_userIsEditing) {
        if ([self.delegate respondsToSelector:@selector(captureMediaViewControllerDidAcceptImage:)]) {
            [self.delegate captureMediaViewControllerDidAcceptImage:_capturedImage];
        }

        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    } else {
        [self performSegueWithIdentifier:@"DisplayCreateMorsel"
                                  sender:nil];
    }
}

- (IBAction)snapStillImage:(id)sender {
    dispatch_async(self.sessionQueue, ^{
		// Update the orientation on the still image output video connection before capturing.
		[[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer  *)self.previewView.layer connection] videoOrientation]];
		
		// Flash set to Auto for Still Capture
		[CaptureMediaViewController setFlashMode:_preferredFlashCaptureMode
                                       forDevice:[self.videoDeviceInput device]];
		
		// Capture a still image.
		[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo]
                                                           completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
        {
			if (imageDataSampleBuffer)
			{
				NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                self.capturedImage = [[UIImage alloc] initWithData:imageData];
                
                [self processImage:_capturedImage];
                
                // Hanging onto this as it might be useful for saving to device later
				//[[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
			}
		}];
    });
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)self.previewView.layer captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];

    [self focusWithMode:AVCaptureFocusModeAutoFocus
                  exposeWithMode:AVCaptureExposureModeAutoExpose
                   atDevicePoint:devicePoint
        monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    CGPoint devicePoint = CGPointMake(.5f, .5f);

    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus
                  exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
                   atDevicePoint:devicePoint
        monitorSubjectAreaChange:NO];
}

- (void)enableMainControls:(BOOL)shouldDisplay {
    self.cameraRollButton.hidden = !shouldDisplay;
    self.cameraRollImageView.hidden = !shouldDisplay;
    self.captureImageButton.hidden = !shouldDisplay;
    self.addTextMorselButton.hidden = !shouldDisplay;
    self.toggleCameraButton.hidden = !shouldDisplay;
    self.toggleFlashButton.hidden = !shouldDisplay;
    self.cancelMorselButton.hidden = !shouldDisplay;

    self.togglePipeView.hidden = shouldDisplay;
    self.acceptImageButton.hidden = shouldDisplay;
    self.discardImageButton.hidden = shouldDisplay;
    self.approvalImageView.hidden = shouldDisplay;
}

#pragma mark - Device Camera Methods

- (void)processImage:(UIImage *)image {
    DDLogDebug(@"Source Process Image Dimensions: (w:%f, h:%f)", image.size.width, image.size.height);

    BOOL imageIsLandscape = [Util imageIsLandscape:image];
    CGFloat cameraDimensionScale = [Util cameraDimensionScaleFromImage:image];
    CGFloat cropStartingY = yCameraImagePreviewOffset * cameraDimensionScale;
    CGFloat minimumImageDimension = (imageIsLandscape) ? image.size.height : image.size.width;
    CGFloat maximumImageDimension = (imageIsLandscape) ? image.size.width : image.size.height;
    CGFloat xCenterAdjustment = (maximumImageDimension - minimumImageDimension) / 2.f;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *processedImage = [image croppedImage:CGRectMake((imageIsLandscape) ? xCenterAdjustment : 0.f, (imageIsLandscape) ? 0.f : cropStartingY, minimumImageDimension, minimumImageDimension)
                                               scaled:CGSizeMake(320.f, 320.f)];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            self.approvalImageView.image = processedImage;
            [self enableMainControls:NO];
            
            if ([self.session isRunning])
            {
                [self endCameraSession];
            }
        });
    });
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
        
        AVCaptureDevice *videoDevice = [CaptureMediaViewController deviceWithMediaType:AVMediaTypeVideo
                                                                    preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                                       error:&error];
        
        if (error)
        {
            DDLogError(@"Error setting AVCaptureDeviceInput: %@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        
        if ([session canAddOutput:stillImageOutput])
        {
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
                                                   usingBlock:^(NSNotification *note)
                                                   {
                                                       CaptureMediaViewController *strongSelf = weakSelf;
                                                       
                                                       dispatch_async(strongSelf.sessionQueue, ^
                                                                      {
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
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                          object:[self.videoDeviceInput device]];
            
            [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
            
            [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized"
                         context:SessionRunningAndDeviceAuthorizedContext];
            
            [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage"
                         context:CapturingStillImageContext];
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
            if (isRunning)
            {
                [self.captureImageButton setEnabled:YES];
            }
            else
            {
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
        
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
            
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
            
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			DDLogError(@"%@", error);
		}
    });
}

#pragma mark - User Interface Methods

- (void)runStillImageCaptureAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
		[self.previewView.layer setOpacity:0.0];
        
		[UIView animateWithDuration:.25 animations:^
        {
			[self.previewView.layer setOpacity:1.0];
		}];
    });
}

- (void)checkDeviceAuthorizationStatus {
    NSString *mediaType = AVMediaTypeVideo;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted)
        {
            if (granted) {
                //Granted access to mediaType
                [self setDeviceAuthorized:YES];
                [self displayLatestCameraRollImage];
            } else {
                //Not granted access to mediaType
                dispatch_async(dispatch_get_main_queue(), ^{
                                    DDLogError(@"Camera access permission denied. Cannot create AV session!");
                                    
                                    [[[UIAlertView alloc] initWithTitle:@"Permission Denied"
                                                                message:@"Morsel doesn't have permission to use the Camera, please change your privacy settings!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil] show];
                                    
                                    [self setDeviceAuthorized:NO];
                });
            }
        }];
    } else {
        [self setDeviceAuthorized:YES];
        [self displayLatestCameraRollImage];
    }
}

#pragma mark - UIImagePickerController Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];

        self.capturedImage = image;

        [self processImage:image];
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.isSelectingImage = NO;

    [self beginCameraSession];

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
