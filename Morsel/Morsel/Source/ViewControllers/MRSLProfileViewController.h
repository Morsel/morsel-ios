//
//  ProfileViewController.h
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLBaseRemoteDataSourceViewController.h"

@class MRSLUser;

@interface MRSLProfileViewController : MRSLBaseRemoteDataSourceViewController

@property (strong, nonatomic) MRSLUser *user;

@end
