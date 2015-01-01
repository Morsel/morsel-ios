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
@property (nonatomic) BOOL refreshedOnInitialLoad;

@property (nonatomic) NSNumber *currentPage;

@property (strong, nonatomic) MRSLActivityIndicatorView *footerActivityIndicatorView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLBaseRemoteDataSourceViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentPage = @(1);

    if (!self.paginationCount) self.paginationCount = @(MRSLPaginationCountDefault);

    if ((self.dataSource) && !self.disableAutomaticPagination && ![self isHorizontalLayout]) {
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
            [self.tableView setTableFooterView:footerView];
        } else if (self.collectionView) {
            [self.collectionView addSubview:self.refreshControl];
        }
    }
    if (self.objectIDsKey) self.objectIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:self.objectIDsKey] ?: @[];

    if ([self.objectIDs count] > [self.paginationCount intValue]) {
        self.objectIDs = [[self.objectIDs copy] subarrayWithRange:NSMakeRange(0, [self.paginationCount intValue])];
    }

    if (self.tableView) {
        [self.tableView setScrollsToTop:YES];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (!self.disableAutomaticPagination) self.tableView.alwaysBounceVertical = YES;

        [self.tableView setEmptyStateTitle:self.emptyStateString ?: @"Nothing to display."];
    } else if (self.collectionView) {
        [self.collectionView setScrollsToTop:YES];
        if (!self.disableAutomaticPagination && ![self isHorizontalLayout]) self.collectionView.alwaysBounceVertical = YES;

        [self.collectionView setEmptyStateTitle:self.emptyStateString ?: @"Nothing to display."];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
        self.selectedIndexPath = nil;
    }

    if ((self.dataSource) && !_fetchedResultsController && !self.refreshedOnInitialLoad) {
        [self populateContent];

        if (([self.currentPage intValue] == 1) &&
            [self.objectIDs count] > 0) {
            if (!self.disableAutomaticPagination) {
                [self.refreshControl beginRefreshing];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.collectionView) [self.collectionView setContentOffset:CGPointMake(0.f, MRSLDefaultRefreshControlPadding)
                                                                          animated:YES];
                    if (self.tableView) [self.tableView setContentOffset:CGPointMake(0.f, MRSLDefaultRefreshControlPadding)
                                                                animated:YES];
                });
            }
        }

        [self refreshContent];
    }
    self.refreshedOnInitialLoad = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resetFetchedResultsController];
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if ([_footerActivityIndicatorView getX] != [self.tableView getWidth] * .5f) {
        [_footerActivityIndicatorView setX:([self.tableView getWidth] * .5f) - ([_footerActivityIndicatorView getWidth] * .5f)];
        [_footerActivityIndicatorView setY:(60.f * .5f) - ([_footerActivityIndicatorView getHeight] * .5f)];
    }
}

#pragma mark - Getter Methods

- (BOOL)isHorizontalLayout {
    BOOL isHorizontal = NO;
    if (self.collectionView) {
        if ([self.collectionView.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
            isHorizontal = (UICollectionViewScrollDirectionHorizontal == [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout scrollDirection]);
        }
    }
    return isHorizontal;
}

- (NSString *)objectIDsKey {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - Setter Methods

- (void)setEmptyStateString:(NSString *)emptyStateString {
    _emptyStateString = emptyStateString;
    if (self.tableView) [self.tableView setEmptyStateTitle:emptyStateString ?: @"Nothing to display."];
    if (self.collectionView) [self.collectionView setEmptyStateTitle:emptyStateString ?: @"Nothing to display."];
}

- (void)setEmptyStateButtonString:(NSString *)emptyStateButtonString {
    _emptyStateButtonString = emptyStateButtonString;
    if (self.tableView) [self.tableView setEmptyStateButtonTitle:emptyStateButtonString];
    if (self.collectionView) [self.collectionView setEmptyStateButtonTitle:emptyStateButtonString];
}

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
    } else if (self.collectionView) {
        [self.collectionView toggleLoading:loading];
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

- (void)setPagedRemoteRequestBlock:(MRSLRemotePagedRequestBlock)pagedRemoteRequestBlock {
    _pagedRemoteRequestBlock = pagedRemoteRequestBlock;
    [self resetPaginationAndData];
}

- (void)setTimelineRemoteRequestBlock:(MRSLRemoteTimelineRequestBlock)timelineRemoteRequestBlock {
    _timelineRemoteRequestBlock = timelineRemoteRequestBlock;
    [self resetPaginationAndData];
}

- (void)resetPaginationAndData {
    self.stopLoadingNextPage = NO;
    if ([self.currentPage intValue] == 1) return;
    self.currentPage = @(1);
    _objectIDs = @[];
    [self.dataSource updateObjects:_objectIDs];
}

- (void)refreshLocalContent {
    [self resetFetchedResultsController];
    [self populateContent];
}

- (void)refreshRemoteContent {
    [self resetPaginationAndData];
    [self resetFetchedResultsController];
    [self populateContent];
    [self refreshContent];
}

- (void)refreshContent {
    [self fetchAPIWithNextPage:NO];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [self.fetchedResultsController performFetch:&fetchError];
    [self.dataSource updateObjects:[self.fetchedResultsController fetchedObjects]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.tableView) [self.tableView reloadData];
        if (self.collectionView) [self.collectionView reloadData];
        if ([self.dataSource count] > 0) self.loading = NO;
    });
}

- (void)fetchAPIWithNextPage:(BOOL)nextPage {
    if ([self isLoading] || (!self.pagedRemoteRequestBlock && !self.timelineRemoteRequestBlock)) return;

    self.loading = YES;
    self.loadingMore = nextPage;
    __weak typeof(self) weakSelf = self;
    if (self.pagedRemoteRequestBlock) {
        // Paged pagination
        if (!nextPage) self.currentPage = @(1);
        self.pagedRemoteRequestBlock(self.currentPage, nil, ^(NSArray *objectIDs, NSError *error) {
            weakSelf.loadingMore = NO;
            [weakSelf completeRemoteRequestWithNextPage:nextPage
                                              objectIDs:objectIDs
                                                  error:error];
            if (!error) self.currentPage = @([self.currentPage intValue] + 1);
        });
    } else if (self.timelineRemoteRequestBlock) {
        // Timeline pagination
        self.timelineRemoteRequestBlock((nextPage ? [self maxID] : nil), (nextPage ? nil : [self sinceID]), nil, ^(NSArray *objectIDs, NSError *error) {
            weakSelf.loadingMore = NO;
            [weakSelf completeRemoteRequestWithNextPage:nextPage
                                              objectIDs:objectIDs
                                                  error:error];
        });
    }
}

- (void)completeRemoteRequestWithNextPage:(BOOL)nextPage
                                objectIDs:(NSArray *)objectIDs
                                    error:(NSError *)error {
    if ([objectIDs count] > 0) {
        //  If no data has been loaded or the first new objectID doesn't already exist, aka identical response
        if ([self.dataSource count] == 0 || ![[objectIDs firstObject] isEqualToNumber:[self.objectIDs firstObject]]) {
            if (nextPage)
                [self appendObjectIDs:[objectIDs copy]];
            else
                [self prependObjectIDs:[objectIDs copy]];
        }
        // Reached final page since amount of objects returned was less than default of 20
        if ([objectIDs count] < [self.paginationCount intValue]) self.stopLoadingNextPage = YES;
    } else if (nextPage && [objectIDs count] == 0) {
        //  Reached the end, stop loading nextPage
        self.stopLoadingNextPage = YES;
    } else if (!nextPage && [objectIDs count] == 0) {
        self.objectIDs = objectIDs;
    }
    [self refreshLocalContent];
    [self.refreshControl endRefreshing];
    self.loading = NO;
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

- (void)loadNextPage {
    if (!self.stopLoadingNextPage) [self fetchAPIWithNextPage:YES];
}

#pragma mark - Data Source Delegate Methods

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
    [self dataSourceDidScroll:scrollView
                   withOffset:scrollView.contentOffset.y];
}

- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView withOffset:(CGFloat)offset {
    [self dataSourceDidScroll:collectionView
                   withOffset:offset];
}

- (void)dataSourceDidScroll:(UIScrollView *)scrollView
                 withOffset:(CGFloat)offset {
    if ([self.dataSource count] > 0 && ![self isLoading] && !self.disableAutomaticPagination) {
        BOOL isHorizontal = [self isHorizontalLayout];
        BOOL shouldLoadMore = NO;
        if (isHorizontal) {
            CGFloat currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
            shouldLoadMore = (currentPage >= [self.dataSource count] - 2);
        } else {
            CGFloat currentOffset = scrollView.contentOffset.y;
            CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
            CGFloat contentOffset = maximumOffset - currentOffset;
            shouldLoadMore = (contentOffset <= 10.f);
        }
        if (shouldLoadMore) [self loadNextPage];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self populateContent];
}

@end
