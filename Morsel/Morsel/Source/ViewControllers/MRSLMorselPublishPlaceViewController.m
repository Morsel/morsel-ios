//
//  MRSLMorselPublishPlaceViewController.m
//  Morsel
//
//  Created by Javier Otero on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselPublishPlaceViewController.h"

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Place.h"

#import "MRSLMorselPublishShareViewController.h"
#import "MRSLPlaceCoverSelectTableViewCell.h"
#import "MRSLPlacesAddViewController.h"
#import "MRSLRobotoLightLabel.h"

#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLMorselPublishPlaceViewController ()
<NSFetchedResultsControllerDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *placeTableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *places;
@property (strong, nonatomic) NSMutableArray *placeIDs;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSInteger selectedPlaceRow;

@end

@implementation MRSLMorselPublishPlaceViewController

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
    self.selectedPlaceRow = -1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Action Methods

- (IBAction)next:(id)sender {
    [self updateMorsel];
    [_appDelegate.apiService updateMorsel:_morsel
                                  success:nil
                                  failure:nil];
    [self performSegueWithIdentifier:@"seg_PublishShareMorsel"
                              sender:nil];
}

#pragma mark - Private Methods

- (void)updateMorsel {
    if ([_places count] > 0 && _selectedPlaceRow >= 0) {
        MRSLPlace *place = [_places objectAtIndex:_selectedPlaceRow];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.placeTableView reloadData];
    });
    if ([_places count] == 1) {
        NSUInteger indexOfPlace = (_morsel.place) ? [_places indexOfObject:_morsel.place] : 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.placeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfPlace inSection:0]
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.places count] == 0) {
        MRSLPlacesAddViewController *placesAddVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLPlacesAddViewController"];
        [self.navigationController pushViewController:placesAddVC
                                             animated:YES];
    } else if(_selectedPlaceRow == indexPath.row) {
        _selectedPlaceRow = -1;
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:YES];
    } else {
        _selectedPlaceRow = indexPath.row;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Activity detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - Dealloc

- (void)dealloc {
    self.placeTableView.dataSource = nil;
    self.placeTableView.delegate = nil;
    [self.placeTableView removeFromSuperview];
    self.placeTableView = nil;
}

@end
