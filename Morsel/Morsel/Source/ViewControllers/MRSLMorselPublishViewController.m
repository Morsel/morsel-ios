//
//  MRSLMorselSettingsViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/7/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselPublishViewController.h"

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Place.h"

#import "MRSLImagePreviewCollectionViewCell.h"
#import "MRSLItemImageView.h"
#import "MRSLMorselPublishShareViewController.h"
#import "MRSLPlaceCoverSelectTableViewCell.h"
#import "MRSLPlacesAddViewController.h"
#import "MRSLRobotoLightLabel.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLMorselPublishViewController ()
<NSFetchedResultsControllerDelegate,
UIActionSheetDelegate,
UICollectionViewDataSource,
UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *coverCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *placeTableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *places;
@property (strong, nonatomic) NSMutableArray *placeIDs;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLMorselPublishViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.placeIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_placeIDs", [MRSLUser currentUser].username]] ?: [NSMutableArray array];

    self.places = [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.placeTableView addSubview:_refreshControl];
    self.placeTableView.alwaysBounceVertical = YES;

    _morselTitleLabel.text = _morsel.title;
    [_morselTitleLabel addStandardShadow];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUInteger coverIndex = [[self.morsel itemsArray] indexOfObject:[self.morsel coverItem]];
        [self.coverCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:coverIndex inSection:0]
                                         atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                 animated:NO];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

#pragma mark - Action Methods

- (IBAction)next:(id)sender {
    [self updateMorsel];
    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService updateMorsel:_morsel
                                  success:^(id responseObject) {
                                      [weakSelf performSegueWithIdentifier:@"seg_PublishShareMorsel"
                                                                    sender:nil];
                                  } failure:^(NSError *error) {
                                      [UIAlertView showAlertViewForError:error
                                                                delegate:nil];
                                  }];
}

#pragma mark - Private Methods

- (void)updateMorsel {
    NSIndexPath *selectedCoverIndexPath = [self.coverCollectionView indexPathForCell:[[self.coverCollectionView visibleCells] firstObject]];
    MRSLItem *coverItem = [[self.morsel itemsArray] objectAtIndex:selectedCoverIndexPath.row];
    self.morsel.primary_item_id = coverItem.itemID;

    if ([_places count] > 0) {
        NSIndexPath *selectedIndexPath = [_placeTableView indexPathForSelectedRow];
        MRSLPlace *place = [_places objectAtIndex:selectedIndexPath.row];
        self.morsel.place = place;
    }
}

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLPlace MR_fetchAllSortedBy:@"name"
                                                         ascending:YES
                                                     withPredicate:[NSPredicate predicateWithFormat:@"placeID IN %@", _placeIDs]
                                                           groupBy:nil
                                                          delegate:self
                                                         inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    self.places = [_fetchedResultsController fetchedObjects];
    [self.placeTableView reloadData];
    if ([_places count] == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.placeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                             animated:NO
                                       scrollPosition:UITableViewScrollPositionNone];
        });
    }
}

- (void)refreshContent {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getPlacesForUser:[MRSLUser currentUser]
                                    withMaxID:nil
                                    orSinceID:nil
                                     andCount:nil
                                      success:^(NSArray *responseArray) {
                                          [weakSelf.refreshControl endRefreshing];
                                          weakSelf.placeIDs = [responseArray mutableCopy];
                                          [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                    forKey:[NSString stringWithFormat:@"%@_placeIDs", [MRSLUser currentUser].username]];
                                          [weakSelf setupFetchRequest];
                                          [weakSelf populateContent];
                                      } failure:^(NSError *error) {
                                          [weakSelf.refreshControl endRefreshing];
                                      }];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_PublishShareMorsel"]) {
        MRSLMorselPublishShareViewController *publishShareVC = [segue destinationViewController];
        publishShareVC.morsel = _morsel;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[_morsel items] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLItem *item = [[_morsel itemsArray] objectAtIndex:indexPath.row];
    MRSLImagePreviewCollectionViewCell *imagePreviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MediaPreviewCell"
                                                                                                     forIndexPath:indexPath];
    imagePreviewCell.mediaPreviewItem = item;
    return imagePreviewCell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([self.places count] == 0) ? 1 : [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([self.places count] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ruid_EmptyCell"];
    } else {
        MRSLPlace *place = [_places objectAtIndex:indexPath.row];
        MRSLPlaceCoverSelectTableViewCell *placeCell = [tableView dequeueReusableCellWithIdentifier:@"ruid_PlaceCell"];
        placeCell.place = place;
        cell = placeCell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.places count] == 0) {
        MRSLPlacesAddViewController *placesAddVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLPlacesAddViewController"];
        [self.navigationController pushViewController:placesAddVC
                                             animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    headerView.backgroundColor = [UIColor morselUserInterface];
    MRSLRobotoLightLabel *headerLabel = [[MRSLRobotoLightLabel alloc] initWithFrame:CGRectMake(20.f, 0.f, 280.f, 44.f)];
    headerLabel.text = @"Associate to Place";
    headerLabel.textColor = [UIColor morselDarkContent];
    [headerView addSubview:headerLabel];
    return headerView;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Activity detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

@end
