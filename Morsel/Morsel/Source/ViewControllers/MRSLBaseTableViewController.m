//
//  MRSLBaseTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLActivityIndicatorView.h"
#import "MRSLBaseTableViewController.h"
#import "MRSLTableViewDataSource.h"
#import "MRSLIconStateView.h"

#import "UITableView+States.h"

@interface MRSLBaseTableViewController ()
<MRSLTableViewDataSourceDelegate,
NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MRSLTableViewDataSource *dataSource;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (copy, nonatomic) MRSLRemotePagedRequestBlock pagedRemoteRequestBlock;
@property (copy, nonatomic) MRSLRemoteTimelineRequestBlock timelineRemoteRequestBlock;

@property (strong, nonatomic) NSString *objectIDsKey;
@property (strong, nonatomic) NSArray *objectIDs;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL stopLoadingNextPage;
@property (nonatomic) BOOL refreshedOnInitialLoad;

@property (nonatomic) NSNumber *currentPage;

@property (strong, nonatomic) MRSLActivityIndicatorView *footerActivityIndicatorView;

- (void)refreshContent;
- (void)populateContent;

@end

@implementation MRSLBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentPage = @(1);

    if (self.dataSource && !self.disablePagination) {
        //  Pull to refresh
        self.refreshControl = [UIRefreshControl MRSL_refreshControl];
        [self.refreshControl addTarget:self
                                action:@selector(refreshContent)
                      forControlEvents:UIControlEventValueChanged];

        [self.tableView addSubview:self.refreshControl];

        //  Bottom activity Indicator
        self.footerActivityIndicatorView = [MRSLActivityIndicatorView defaultActivityIndicatorView];
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, [self.tableView getWidth], 60.f)];
        [footerView addSubview:_footerActivityIndicatorView];
        [_footerActivityIndicatorView setX:([footerView getWidth] * .5f) - ([_footerActivityIndicatorView getWidth] * .5f)];
        [_footerActivityIndicatorView setY:([footerView getHeight] * .5f) - ([_footerActivityIndicatorView getHeight] * .5f)];
        [self.tableView setTableFooterView:footerView];
    }
    if (self.objectIDsKey) _objectIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:self.objectIDsKey] ?: @[];

    if ([self.objectIDs count] > MRSLPaginationCountDefault) {
        self.objectIDs = [[self.objectIDs copy] subarrayWithRange:NSMakeRange(0, MRSLPaginationCountDefault)];
    }

    self.tableView.alwaysBounceVertical = YES;
    [self.tableView setScrollsToTop:YES];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupNavigationItems];
    [self.view setBackgroundColor:[UIColor morselDefaultBackgroundColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
        self.selectedIndexPath = nil;
    }

    if (self.dataSource && !_fetchedResultsController && !self.refreshedOnInitialLoad) {
        [self populateContent];
        if (([self.currentPage intValue] == 1) &&
            [self.objectIDs count] > 0) {
            if (!self.disablePagination) {
                [self.refreshControl beginRefreshing];
                if (self.tableView) [self.tableView setContentOffset:CGPointMake(0.f, -self.refreshControl.frame.size.height)
                                                            animated:YES];
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

- (void)setDataSource:(MRSLTableViewDataSource *)dataSource {
    _dataSource = dataSource;
    [self.tableView setDataSource:_dataSource];
    [self.tableView setDelegate:_dataSource];
    [_dataSource setDelegate:self];
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    [self.tableView toggleLoading:loading];
    if (loading && [self.dataSource isEmpty]) {
        [_footerActivityIndicatorView MRSL_toggleAnimating:NO];
    } else {
        [_footerActivityIndicatorView MRSL_toggleAnimating:loading];
    }
}

- (void)refreshLocalContent {
    [self resetFetchedResultsController];
    [self populateContent];
}

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
            [weakSelf completeRemoteRequestWithNextPage:nextPage
                                              objectIDs:objectIDs
                                                  error:error];
            if (!error) self.currentPage = @([self.currentPage intValue] + 1);
        });
    } else if (self.timelineRemoteRequestBlock) {
        // Timeline pagination
        self.timelineRemoteRequestBlock((nextPage ? [self maxID] : nil), (nextPage ? nil : [self sinceID]), nil, ^(NSArray *objectIDs, NSError *error) {
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
        //  If no data has been loaded or the first new objectID doesn't already exist
        if ([self.dataSource count] == 0 || ![[objectIDs firstObject] isEqualToNumber:[self.objectIDs firstObject]]) {
            if (nextPage)
                [self appendObjectIDs:[objectIDs copy]];
            else
                [self prependObjectIDs:[objectIDs copy]];
        }
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

- (void)setObjectIDs:(NSArray *)objectIDs {
    _objectIDs = objectIDs;
    [[NSUserDefaults standardUserDefaults] setObject:[_objectIDs copy]
                                              forKey:_objectIDsKey];
}

- (void)registerCellsWithNames:(NSArray *)cellNames {
    [cellNames enumerateObjectsUsingBlock:^(NSString *cellName, NSUInteger idx, BOOL *stop) {
        [self.tableView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle mainBundle]]
             forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@", @"ruid", cellName]];
    }];
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

#pragma mark - MRSLTableViewDataSourceDelegate

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.dataSource count] > 0) {
        CGFloat currentOffset = scrollView.contentOffset.y;
        CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        if (maximumOffset - currentOffset <= 10.f) {
            [self loadNextPage];
        }
    }
}


#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Activity detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}


#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
