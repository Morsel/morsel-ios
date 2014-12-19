//
//  MRSLProfileMorselsViewController.h
//  Morsel
//
//  Created by Javier Otero on 4/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseRemoteDataSourceViewController.h"

@interface MRSLMorselDetailViewController : MRSLBaseRemoteDataSourceViewController

@property (nonatomic) BOOL isExplore;

@property (weak, nonatomic) MRSLUser *user;
@property (weak, nonatomic) MRSLMorsel *morsel;

@end
