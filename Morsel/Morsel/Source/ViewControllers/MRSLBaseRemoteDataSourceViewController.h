//
//  MRSLBaseNetworkDataSourceViewController.h
//  Morsel
//
//  Created by Javier Otero on 12/12/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseViewController.h"

@class MRSLDataSource;

@interface MRSLBaseRemoteDataSourceViewController : MRSLBaseViewController
<NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL disableFetchRefresh;

@property (copy, nonatomic) MRSLRemoteRequestBlock remoteRequestBlock;

@property (strong, nonatomic) MRSLDataSource *dataSource;

@property (strong, nonatomic) NSString *emptyStateString;
@property (strong, nonatomic) NSArray *objectIDs;

- (NSString *)objectIDsKey;
- (NSFetchedResultsController *)defaultFetchedResultsController;

- (void)populateContent;
- (void)refreshContent;
- (void)resetFetchedResultsController;

@end
