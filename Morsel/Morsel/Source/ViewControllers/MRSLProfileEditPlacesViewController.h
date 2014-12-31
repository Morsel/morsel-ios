//
//  MRSLProfileEditPlacesViewController.h
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseRemoteDataSourceViewController.h"

@protocol MRSLProfileEditPlacesViewControllerDelegate <NSObject>

@optional
- (void)profileEditPlacesDidSelectPlace:(MRSLPlace *)place;
- (void)profileEditPlacesDidSelectAddNew;

@end

@interface MRSLProfileEditPlacesViewController : MRSLBaseRemoteDataSourceViewController

@property (weak, nonatomic) id <MRSLProfileEditPlacesViewControllerDelegate> delegate;

@end
