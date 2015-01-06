//
//  MRSLExploreSearchViewController.h
//  Morsel
//
//  Created by Javier Otero on 12/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseRemoteDataSourceViewController.h"

@protocol MRSLExploreSearchViewControllerDelegate <NSObject>

@optional
- (void)exploreSearchViewControllerDidChangeSegmentWithIndex:(NSInteger)index;

@end

@interface MRSLExploreSearchViewController : MRSLBaseRemoteDataSourceViewController

@property (strong, nonatomic) NSString *searchQuery;

@property (weak, nonatomic) id <MRSLExploreSearchViewControllerDelegate> delegate;

- (void)commenceSearch;

@end
