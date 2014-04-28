//
//  MRSLProfileLikesViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/22/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserActivityViewController.h"

#import "MRSLArrayDataSource.h"
#import "MRSLUserMorselsFeedViewController.h"
#import "MRSLUserLikedItemCollectionViewCell.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLUserActivityViewController ()
<UICollectionViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL loadingMore;
@property (nonatomic) BOOL loadedAll;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *nullStateView;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableArray *itemIDs;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) MRSLArrayDataSource *arrayDataSource;

@end

@implementation MRSLUserActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!_user) self.user = [MRSLUser currentUser];

    self.itemIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_activity_itemIDs", _user.username]] ?: [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.collectionView addSubview:_refreshControl];
    self.collectionView.alwaysBounceVertical = YES;

    self.arrayDataSource = [[MRSLArrayDataSource alloc] initWithObjects:nil
                                                         cellIdentifier:@"ruid_UserLikedItemCell"
                                                     configureCellBlock:^(id cell, id item, NSIndexPath *indexPath, NSUInteger count) {
                                                         [cell setItem:item andUser:_user];
                                                         if (indexPath.row != count) {
                                                             [cell setBorderWithDirections:MRSLBorderSouth
                                                                               borderWidth:1.0f
                                                                            andBorderColor:[UIColor morselLightOffColor]];
                                                         }
                                                     }];

    [self.collectionView setDataSource:_arrayDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillAppear:animated];
    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    if (_selectedIndexPath) {
        [self.collectionView deselectItemAtIndexPath:_selectedIndexPath
                                            animated:YES];
        self.selectedIndexPath = nil;
    }

    if (self.fetchedResultsController) return;

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}


#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLItem MR_fetchAllSortedBy:@"likedDate"
                                                            ascending:NO
                                                        withPredicate:[NSPredicate predicateWithFormat:@"itemID IN %@", _itemIDs]
                                                              groupBy:nil
                                                             delegate:self
                                                            inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    [self.arrayDataSource updateObjects:[_fetchedResultsController fetchedObjects]];
    [self.collectionView reloadData];
    self.nullStateView.hidden = ([self.arrayDataSource count] > 0);
    [_refreshControl endRefreshing];
}

- (void)refreshContent {
    self.loadedAll = NO;
    self.refreshing = YES;
    self.nullStateView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    [_appDelegate.apiService getLikedItemsForUser:_user
                                       maxID:nil
                                   orSinceID:nil
                                    andCount:nil
                                     success:^(NSArray *responseArray) {
                                         weakSelf.itemIDs = [responseArray mutableCopy];
                                         [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                   forKey:[NSString stringWithFormat:@"%@_activity_itemIDs", _user.username]];
                                         [weakSelf setupFetchRequest];
                                         [weakSelf populateContent];
                                     } failure:nil];
}

- (void)loadMore {
    if (_loadingMore || !_user || _loadedAll || _refreshing) return;
    self.loadingMore = YES;
    DDLogDebug(@"Loading more liked items");
    __weak __typeof (self) weakSelf = self;
    [_appDelegate.apiService getLikedItemsForUser:_user
                                       maxID:@([[_itemIDs lastObject] intValue] - 1)
                                   orSinceID:nil
                                    andCount:@(12)
                                     success:^(NSArray *responseArray) {
                                         if ([responseArray count] == 0) weakSelf.loadedAll = YES;
                                         DDLogDebug(@"%lu items added", (unsigned long)[responseArray count]);
                                         if (weakSelf) {
                                             if ([responseArray count] > 0) {
                                                 [weakSelf.itemIDs addObjectsFromArray:responseArray];
                                                 [[NSUserDefaults standardUserDefaults] setObject:weakSelf.itemIDs
                                                                                           forKey:[NSString stringWithFormat:@"%@_activity_itemIDs", _user.username]];
                                                 [weakSelf setupFetchRequest];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [weakSelf populateContent];
                                                 });
                                             }
                                             weakSelf.loadingMore = NO;
                                         }
                                     } failure:^(NSError *error) {
                                         if (weakSelf) weakSelf.loadingMore = NO;
                                     }];
}


#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLItem *item = [self.arrayDataSource objectAtIndexPath:indexPath];
    if (item.morsel) {
        MRSLUserMorselsFeedViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLUserMorselsFeedViewController"];
        userMorselsFeedVC.morsel = item.morsel;
        userMorselsFeedVC.user = item.morsel.creator;
        [self.navigationController pushViewController:userMorselsFeedVC
                                             animated:YES];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"User likes detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 10.f) {
        [self loadMore];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
