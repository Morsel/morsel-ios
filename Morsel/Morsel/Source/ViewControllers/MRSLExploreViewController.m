//
//  MRSLExploreViewController.m
//  Morsel
//
//  Created by Javier Otero on 9/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLExploreViewController.h"

#import "MRSLAPIService+Explore.h"

#import "MRSLCollectionView.h"
#import "MRSLExploreSearchViewController.h"
#import "MRSLMorselDetailViewController.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLSearchBarCollectionReusableView.h"

#import "MRSLMorsel.h"

@interface MRSLExploreViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UISearchBarDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet MRSLCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *exploreSearchContainerView;

@property (weak, nonatomic) MRSLExploreSearchViewController *exploreSearchVC;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *morsels;
@property (strong, nonatomic) NSMutableArray *morselIDs;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLExploreViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_eventView = @"Explore";
    [self.collectionView setEmptyStateTitle:@"Nothing to explore"];

    self.morsels = [NSMutableArray array];
    self.morselIDs = [NSMutableArray array];

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];

    [self.collectionView registerNib:[UINib nibWithNibName:@"MRSLSearchBarCollectionReusableView"
                                                    bundle:nil]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:MRSLStoryboardRUIDSearchCellKey];

    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MRSLExploreSearchViewController class]]) {
            self.exploreSearchVC = obj;
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_fetchedResultsController) return;
    [self.collectionView toggleLoading:YES];
    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

#pragma mark - Private Methods

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    [self.collectionView toggleLoading:loading];
    if (!loading) [self.refreshControl endRefreshing];
}

- (void)setLoadingMore:(BOOL)loadingMore {
    _loadingMore = loadingMore;

    [self.collectionView.collectionViewLayout invalidateLayout];
    if (!loadingMore) [self.refreshControl endRefreshing];
}

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"feedItemID"
                                                          ascending:NO
                                                      withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", _morselIDs]
                                                            groupBy:nil
                                                           delegate:self];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    self.morsels = [_fetchedResultsController fetchedObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        if ([_morsels count] > 0) self.loading = NO;
    });
}

- (void)refreshContent {
    if (_loadingMore || _loadedAll || [self isLoading]) return;
    self.loading = YES;
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getExploreWithMaxID:nil
                                       orSinceID:nil
                                        andCount:nil
                                         success:^(NSArray *responseArray) {
                                             if (weakSelf) {
                                                 if ([responseArray count] > 0) {
                                                     weakSelf.morselIDs = [responseArray mutableCopy];
                                                     [weakSelf setupFetchRequest];
                                                     [weakSelf populateContent];
                                                 }
                                                 weakSelf.loading = NO;
                                             }
                                         } failure:^(NSError *error) {
                                             if (weakSelf) {
                                                 [[MRSLEventManager sharedManager] track:@"Error Loading Explore"
                                                                              properties:@{@"_view": self.mp_eventView,
                                                                                           @"message" : NSNullIfNil(error.description),
                                                                                           @"action" : @"refresh"}];
                                                 weakSelf.loading = NO;
                                             }
                                         }];
}

- (void)loadMore {
    if (_loadingMore || _loadedAll || [self isLoading]) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more");
    MRSLMorsel *lastMorsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                       withValue:[_morselIDs lastObject]];
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getExploreWithMaxID:@([lastMorsel feedItemIDValue] - 1)
                                       orSinceID:nil
                                        andCount:nil
                                         success:^(NSArray *responseArray) {
                                             if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                             DDLogDebug(@"%lu feed items added", (unsigned long)[responseArray count]);
                                             if (weakSelf) {
                                                 weakSelf.loadingMore = NO;
                                                 if ([responseArray count] > 0) {
                                                     [weakSelf.morselIDs addObjectsFromArray:responseArray];
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [weakSelf setupFetchRequest];
                                                         [weakSelf populateContent];
                                                         weakSelf.loading = NO;
                                                     });
                                                 }
                                             }
                                         } failure:^(NSError *error) {
                                             if (weakSelf) weakSelf.loadingMore = NO;
                                             [[MRSLEventManager sharedManager] track:@"Error Loading Explore"
                                                                          properties:@{@"_view": self.mp_eventView,
                                                                                       @"message" : NSNullIfNil(error.description),
                                                                                       @"action" : @"load_more"}];
                                         }];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_morsels count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [self.morsels objectAtIndex:indexPath.row];
    MRSLMorselPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDMorselPreviewCellKey
                                                                                          forIndexPath:indexPath];
    cell.morsel = morsel;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:MRSLStoryboardRUIDLoadingCellKey
                                                         forIndexPath:indexPath];
    } else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        MRSLSearchBarCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                         withReuseIdentifier:MRSLStoryboardRUIDSearchCellKey
                                                                                                forIndexPath:indexPath];
        header.searchBar.delegate = self;
        return header;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [self.morsels objectAtIndex:indexPath.row];
    MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
    userMorselsFeedVC.isExplore = YES;
    userMorselsFeedVC.morsel = morsel;
    userMorselsFeedVC.user = morsel.creator;
    [self.navigationController pushViewController:userMorselsFeedVC
                                         animated:YES];
}

#pragma mark - UICollectionViewFlowLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(MAX(160.f, floorf(collectionView.frame.size.width / 2)), MAX(160.f, floorf(collectionView.frame.size.width / 2)));
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake([collectionView getWidth], 44.f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return _loadingMore ? CGSizeMake([collectionView getWidth], 50.f) : CGSizeZero;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"NSFetchedResultsController detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    CGFloat contentOffset = maximumOffset - currentOffset;
    if (contentOffset <= 10.f) [self loadMore];
    [self.view endEditing:YES];
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.exploreSearchVC.searchQuery = searchText;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [searchBar setShowsCancelButton:NO animated:YES];
        [searchBar resignFirstResponder];
        [self.exploreSearchVC commenceSearch];
        return NO;
    } else {
        return YES;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.view endEditing:YES];
    self.exploreSearchContainerView.hidden = YES;
    self.exploreSearchContainerView.userInteractionEnabled = NO;
    self.collectionView.scrollEnabled = YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.exploreSearchContainerView.hidden = NO;
    self.exploreSearchContainerView.userInteractionEnabled = YES;
    self.collectionView.scrollEnabled = NO;
}

#pragma mark - Notification Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.searchBottomConstraint.constant = keyboardSize.height;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.35f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.searchBottomConstraint.constant = 0.f;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

@end
