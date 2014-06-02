//
//  MRSLProfileEditPlacesViewController.h
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRSLProfileEditPlacesViewControllerDelegate <NSObject>

@optional
- (void)profileEditPlacesDidSelectPlace:(MRSLPlace *)place;
- (void)profileEditPlacesDidSelectAddNew;

@end

@interface MRSLProfileEditPlacesViewController : UIViewController

@property (weak, nonatomic) id <MRSLProfileEditPlacesViewControllerDelegate> delegate;

- (void)refreshContent;

@end
