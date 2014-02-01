//
//  MRSLSideBarViewController.h
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLSideBarViewControllerDelegate <NSObject>

@optional
- (void)sideBarDidSelectDisplayHome;
- (void)sideBarDidSelectDisplayProfile;
- (void)sideBarDidSelectLogout;
- (void)sideBarDidSelectHideSideBar;

@end

@interface MRSLSideBarViewController : UIViewController

@property (nonatomic, weak) IBOutlet id <MRSLSideBarViewControllerDelegate> delegate;

@end
