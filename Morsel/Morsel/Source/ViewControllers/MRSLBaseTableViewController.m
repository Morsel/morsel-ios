//
//  MRSLBaseTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewController.h"
#import "MRSLTableViewDataSource.h"
#import "MRSLIconStateView.h"
#import "MRSLLoadingStateView.h"

@interface MRSLBaseTableViewController ()
<MRSLTableViewDataSourceDelegate,
NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) MRSLTableViewDataSource *dataSource;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (copy, nonatomic) MRSLRemoteRequestBlock remoteRequestBlock;

@property (strong, nonatomic) NSString *objectIDsKey;
@property (strong, nonatomic) NSArray *objectIDs;
@property (strong, nonatomic) MRSLLoadingStateView *loadingStateView;
@property (strong, nonatomic) MRSLIconStateView *emptyStateView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL stopLoadingNextPage;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

- (void)refreshContent;
- (void)populateContent;

@end

@implementation MRSLBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.dataSource) {
        //  Pull to refresh
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.tintColor = [UIColor morselLightContent];
        [self.refreshControl addTarget:self
                                action:@selector(refreshContent)
                      forControlEvents:UIControlEventValueChanged];

        [self.tableView addSubview:self.refreshControl];

        //  Bottom activity Indicator
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityIndicatorView setColor:[UIColor morselDarkContent]];
        [_activityIndicatorView setHidesWhenStopped:YES];
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, [self.tableView getWidth], 60.f)];
        [footerView addSubview:_activityIndicatorView];
        [_activityIndicatorView setX:([footerView getWidth] * .5f) - ([_activityIndicatorView getWidth] * .5f)];
        [_activityIndicatorView setY:([footerView getHeight] * .5f) - ([_activityIndicatorView getHeight] * .5f)];
        [self.tableView setTableFooterView:footerView];
    }
    if (self.objectIDsKey) _objectIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:self.objectIDsKey] ?: @[];

    self.tableView.alwaysBounceVertical = YES;
    [self.tableView setScrollsToTop:YES];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.loadingStateView = [MRSLLoadingStateView loadingStateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupNavigationItems];

    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
        self.selectedIndexPath = nil;
    }

    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    if (self.dataSource) {
        [self resetFetchedResultsController];
        [self populateContent];
        [self refreshContent];
    }
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

    [_activityIndicatorView MRSL_toggleAnimating:loading];

    if (loading && [self.dataSource isEmpty]) {
        [self toggleLoadingState:YES];
        [_activityIndicatorView MRSL_toggleAnimating:NO];
    } else {
        [self toggleLoadingState:NO];
    }
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
                [weakSelf resetFetchedResultsController];
                [weakSelf populateContent];
            }
        } else if (nextPage) {
            //  Reached the end, stop loading nextPage
            weakSelf.stopLoadingNextPage = YES;
        }
        [weakSelf.refreshControl endRefreshing];
        weakSelf.loading = NO;
    });
}

- (void)setObjectIDs:(NSArray *)objectIDs {
    _objectIDs = objectIDs;
    [[NSUserDefaults standardUserDefaults] setObject:_objectIDs
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


#pragma mark - States

- (void)toggleLoadingState:(BOOL)shouldEnable {
    if (shouldEnable) {
        [self toggleEmptyState:NO];
        [self.tableView addCenteredSubview:_loadingStateView withOffset:[_loadingStateView defaultOffset]];
    } else {
        [_loadingStateView removeFromSuperview];
        [self toggleEmptyState:[self.dataSource isEmpty]];
    }
}

- (void)toggleEmptyState:(BOOL)shouldEnable {
    if (shouldEnable)
        [self.tableView addCenteredSubview:self.emptyStateView withOffset:[_emptyStateView defaultOffset]];
    else
        [_emptyStateView removeFromSuperview];
}

- (MRSLIconStateView *)emptyStateView {
    if (_emptyStateView) return _emptyStateView;

    _emptyStateView = [MRSLIconStateView iconStateViewWithTitle:[self emptyStateTitle]
                                                     imageNamed:nil];

    return _emptyStateView;
}

- (NSString *)emptyStateTitle {
    return @"Empty";
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
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

@end
