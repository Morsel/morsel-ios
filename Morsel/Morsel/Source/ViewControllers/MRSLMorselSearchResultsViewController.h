//
//  MRSLMorselSearchResultsViewController.h
//  Morsel
//
//  Created by Javier Otero on 12/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseRemoteDataSourceViewController.h"

@interface MRSLMorselSearchResultsViewController : MRSLBaseRemoteDataSourceViewController

@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSString *hashtagString;

@end
