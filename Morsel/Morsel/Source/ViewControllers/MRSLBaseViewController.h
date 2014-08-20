//
//  MRSLBaseViewController.h
//  Morsel
//
//  Created by Javier Otero on 3/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSLBaseViewController : UIViewController

@property (strong, nonatomic) NSString *mp_eventView;

- (void)setupNavigationItems;

- (IBAction)dismiss;
- (IBAction)displayMenuBar;
- (IBAction)displayMorselAdd;
- (IBAction)displayAddPlace:(id)sender;
- (IBAction)displayMorselShare;
- (IBAction)displayProfessionalSettings;
- (IBAction)goBack;
- (IBAction)report;

- (void)setupWithUserInfo:(NSDictionary *)userInfo;

- (void)reset;

@end
