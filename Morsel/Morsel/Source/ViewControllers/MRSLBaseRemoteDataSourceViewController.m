//
//  MRSLBaseNetworkDataSourceViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/12/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseRemoteDataSourceViewController.h"

#import "MRSLActivityIndicatorView.h"
#import "MRSLCollectionView.h"
#import "MRSLCollectionViewDataSource.h"
#import "MRSLTableView.h"
#import "MRSLTableViewDataSource.h"

@interface MRSLBaseRemoteDataSourceViewController ()
<MRSLCollectionViewDataSourceDelegate,
MRSLTableViewDataSourceDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL stopLoadingNextPage;

@property (strong, nonatomic) MRSLActivityIndicatorView *footerActivityIndicatorView;

@property (weak, nonatomic) IBOutlet MRSLTableView *tableView;
@property (weak, nonatomic) IBOutlet MRSLCollectionView *collectionView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLBaseRemoteDataSourceViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    if ((self.dataSource) && !self.disableFetchRefresh) {
        //  Pull to refresh
        self.refreshControl = [UIRefreshControl MRSL_refreshControl];
        [self.refreshControl addTarget:self
                                action:@selector(refreshContent)
                      forControlEvents:UIControlEventValueChanged];

        if (self.tableView) {
            [self.tableView addSubview:self.refreshControl];
            //  Bottom activity Indicator
            self.footerActivityIndicatorView = [MRSLActivityIndicatorView defaultActivityIndicatorView];
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, [self.tableView getWidth], 60.f)];
            [footerView addSubview:_footerActivityIndicatorView];
            [_footerActivityIndicatorView setX:([footerView getWidth] * .5f) - ([_footerActivityIndicatorView getWidth] * .5f)];
            [_footerActivityIndicatorView setY:([footerView getHeight] * .5f) - ([_footerActivityIndicatorView getHeight] * .5f)];
            [self.tableView setTableFooterView:footerView];
        } else if (self.collectionView) {
            [self.collectionView addSubview:self.refreshControl];
        }
    }
    if (self.objectIDsKey) self.objectIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:self.objectIDsKey] ?: @[];

    if (self.tableView) {
        self.tableView.alwaysBounceVertical = YES;
        [self.tableView setScrollsToTop:YES];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [self.tableView setEmptyStateTitle:self.emptyStateString ?: @"Nothing to display."];
    } else if (self.collectionView) {
        self.collectionView.alwaysBounceVertical = YES;
        [self.collectionView setScrollsToTop:YES];

        [self.collectionView setEmptyStateTitle:self.emptyStateString ?: @"Nothing to display."];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
        self.selectedIndexPath = nil;
    }

    if ((self.dataSource) && !_fetchedResultsController && !self.disableFetchRefresh) {
        [self populateContent];
        [self refreshContent];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resetFetchedResultsController];
    [super viewWillDisappear:animated];
}

#pragma mark - Getter Methods

- (NSString *)objectIDsKey {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - Setter Methods

- (void)setDataSource:(MRSLDataSource *)dataSource {
    _dataSource = dataSource;
    if ([dataSource isKindOfClass:[MRSLCollectionViewDataSource class]]) {
        [self.collectionView setDataSource:(MRSLCollectionViewDataSource *)_dataSource];
        [self.collectionView setDelegate:(MRSLCollectionViewDataSource *)dataSource];
        [(MRSLCollectionViewDataSource *)_dataSource setDelegate:self];
    } else if ([dataSource isKindOfClass:[MRSLTableViewDataSource class]]) {
        [self.tableView setDataSource:(MRSLTableViewDataSource *)_dataSource];
        [self.tableView setDelegate:(MRSLTableViewDataSource *)dataSource];
        [(MRSLTableViewDataSource *)_dataSource setDelegate:self];
    }
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    if (self.tableView) {
        [self.tableView toggleLoading:loading];
        if (loading && ([self.dataSource isEmpty])) {
            [_footerActivityIndicatorView MRSL_toggleAnimating:NO];
        } else {
            [_footerActivityIndicatorView MRSL_toggleAnimating:loading];
        }
    }
}

- (void)setObjectIDs:(NSArray *)objectIDs {
    _objectIDs = objectIDs;
    [[NSUserDefaults standardUserDefaults] setObject:[_objectIDs copy]
                                              forKey:[self objectIDsKey]];
}

- (void)registerCellsWithNames:(NSArray *)cellNames {
    [cellNames enumerateObjectsUsingBlock:^(NSString *cellName, NSUInteger idx, BOOL *stop) {
        [self.tableView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle mainBundle]]
             forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@", @"ruid", cellName]];
    }];
}

#pragma mark - Network Methods

- (void)refreshContent {
    [self fetchAPIWithNextPage:NO];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [self.fetchedResultsController performFetch:&fetchError];
    [self.dataSource updateObjects:[self.fetchedResultsController fetchedObjects]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if ([self.dataSource count] > 0) self.loading = NO;
    });
    [self.refreshControl endRefreshing];
}

- (void)fetchAPIWithNextPage:(BOOL)nextPage {
    if ([self isLoading] || !self.remoteRequestBlock) return;

    self.loading = YES;
    __weak typeof(self) weakSelf = self;
    self.remoteRequestBlock((nextPage ? [self maxID] : nil), (nextPage ? nil : [self sinceID]), nil, ^(NSArray *objectIDs, NSError *error) {
        if ([objectIDs count] > 0) {
            //  If no data has been loaded or the first new objectID doesn't already exist
            if ([weakSelf.dataSource count] == 0 || ![[objectIDs firstObject] isEqualToNumber:[weakSelf.objectIDs firstObject]]) {
                if (nextPage)
                    [weakSelf appendObjectIDs:[objectIDs copy]];
                else
                    [weakSelf prependObjectIDs:[objectIDs copy]];
            }
            [weakSelf resetFetchedResultsController];
            [weakSelf populateContent];
        } else if (nextPage) {
            //  Reached the end, stop loading nextPage
            weakSelf.stopLoadingNextPage = YES;
        }

        [weakSelf.refreshControl endRefreshing];
        weakSelf.loading = NO;
    });
}

#pragma mark - FetchedResultsController

- (void)resetFetchedResultsController {
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) return _fetchedResultsController;
    _fetchedResultsController = [self defaultFetchedResultsController];

    return _fetchedResultsController;
}


#pragma mark - Pagination

- (void)appendObjectIDs:(NSArray *)newObjectIDs {
    self.objectIDs = [self.objectIDs arrayByAddingObjectsFromArray:newObjectIDs];
}

- (void)prependObjectIDs:(NSArray *)newObjectIDs {
    self.objectIDs = [newObjectIDs arrayByAddingObjectsFromArray:self.objectIDs];
}

- (void)loadNextPage {
    if (!self.stopLoadingNextPage) [self fetchAPIWithNextPage:YES];
}

- (NSNumber *)maxID {
    if ([self.objectIDs count] > 0) {
        return @([[self.objectIDs lastObject] integerValue] - 1);
    } else {
        return nil;
    }
}

- (NSNumber *)sinceID {
    if ([self.objectIDs count] > 0) {
        return [self.objectIDs firstObject];
    } else {
        return nil;
    }
}

#pragma mark - Data Source Delegate Methods

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView {
    [self dataSourceDidScroll:scrollView
                   withOffset:scrollView.contentOffset.y];
}

- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView withOffset:(CGFloat)offset {
    [self dataSourceDidScroll:collectionView
                   withOffset:offset];
}

- (void)dataSourceDidScroll:(UIScrollView *)scrollView
                 withOffset:(CGFloat)offset {
    if ([self.dataSource count] > 0) {
        CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        if (maximumOffset - offset <= 10.f) {
            [self loadNextPage];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Activity detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

@end
