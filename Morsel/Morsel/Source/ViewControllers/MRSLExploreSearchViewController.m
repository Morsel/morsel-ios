//
//  MRSLExploreSearchViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/9/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLExploreSearchViewController.h"

#import "MRSLAPIService+Search.h"

#import "MRSLUserFollowTableViewCell.h"
#import "MRSLHashtagKeywordTableViewCell.h"
#import "MRSLSegmentedButtonView.h"

@interface MRSLExploreSearchViewController ()
<UITableViewDataSource,
UITableViewDelegate,
MRSLSegmentedButtonViewDelegate>

@property (weak, nonatomic) IBOutlet MRSLSegmentedButtonView *segmentedButtonView;

@end

@implementation MRSLExploreSearchViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (void)setSearchQuery:(NSString *)searchQuery {
    _searchQuery = searchQuery;

}

#pragma mark - Action Methods

#pragma mark - Private Methods

#pragma mark - MRSLSegmentedButtonViewDelegate

- (void)segmentedButtonViewDidSelectIndex:(NSInteger)index {
    
}

#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDelegate

@end
