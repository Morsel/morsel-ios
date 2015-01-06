//
//  MRSLUserFollowListViewController.h
//  Morsel
//
//  Created by Javier Otero on 4/30/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseRemoteDataSourceViewController.h"

@interface MRSLUserFollowListViewController : MRSLBaseRemoteDataSourceViewController

@property (weak, nonatomic) MRSLUser *user;

@property (nonatomic) BOOL shouldDisplayFollowers;

@end
