//
//  MRSLExploreSearchViewController.h
//  Morsel
//
//  Created by Javier Otero on 12/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseRemoteDataSourceViewController.h"

@interface MRSLExploreSearchViewController : MRSLBaseRemoteDataSourceViewController

@property (strong, nonatomic) NSString *searchQuery;

- (void)commenceSearch;

@end
