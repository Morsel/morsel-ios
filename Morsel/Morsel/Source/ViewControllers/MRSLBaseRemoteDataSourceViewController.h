//
//  MRSLBaseNetworkDataSourceViewController.h
//  Morsel
//
//  Created by Javier Otero on 12/12/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

@class MRSLDataSource, MRSLTableView, MRSLCollectionView;

@interface MRSLBaseRemoteDataSourceViewController : MRSLBaseViewController
<NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL disablePagination;
@property (nonatomic) BOOL loadingMore;

@property (weak, nonatomic) IBOutlet MRSLTableView *tableView;
@property (weak, nonatomic) IBOutlet MRSLCollectionView *collectionView;

@property (copy, nonatomic) MRSLRemotePagedRequestBlock pagedRemoteRequestBlock;
@property (copy, nonatomic) MRSLRemoteTimelineRequestBlock timelineRemoteRequestBlock;

@property (strong, nonatomic) MRSLDataSource *dataSource;

@property (strong, nonatomic) NSString *emptyStateString;
@property (strong, nonatomic) NSString *emptyStateButtonString;
@property (strong, nonatomic) NSArray *objectIDs;

- (NSString *)objectIDsKey;
- (NSFetchedResultsController *)defaultFetchedResultsController;

- (void)refreshLocalContent;
- (void)refreshRemoteContent;
- (void)loadNextPage;

@end
