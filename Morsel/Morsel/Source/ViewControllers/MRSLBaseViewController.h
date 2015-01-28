//
//  MRSLBaseViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsLibrary;

@interface MRSLBaseViewController : UIViewController
<UIGestureRecognizerDelegate,
UITextFieldDelegate>

@property (nonatomic) UIImagePickerControllerCameraDevice preferredDeviceCamera;

@property (nonatomic) BOOL allowObserversToRemain;

// Asset and Image Management
@property (nonatomic) BOOL shouldSaveToDeviceLibrary;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) UIPopoverController *popOver;

@property (strong, nonatomic) NSString *mp_eventView;
@property (strong, nonatomic) NSDictionary *userInfo;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)setupNavigationItems;

- (IBAction)dismiss;
- (IBAction)displayMenuBar;
- (IBAction)displayMorselAdd;
- (IBAction)displayAddPlace:(id)sender;
- (IBAction)displayAddToCollection:(MRSLMorsel *)morselOrNil;
- (IBAction)displayMorselShare;
- (IBAction)displayProfessionalSettings;
- (IBAction)goBack;
- (IBAction)report;

- (void)setupWithUserInfo:(NSDictionary *)userInfo;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide;

- (void)reset;

@end
