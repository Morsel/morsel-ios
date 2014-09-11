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
#import "MRSLCheckmarkTextTableViewCell.h"
#import "MRSLPlacesAddViewController.h"
#import "MRSLRobotoLightLabel.h"

#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLMorselPublishPlaceViewController ()
<NSFetchedResultsControllerDelegate,
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (nonatomic) NSInteger selectedPlaceRow;
@property (nonatomic) NSInteger originalPlaceRow;

@property (weak, nonatomic) IBOutlet UITableView *placeTableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *places;
@property (strong, nonatomic) NSMutableArray *placeIDs;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation MRSLMorselPublishPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"associate_place";
    self.placeIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_placeIDs", [MRSLUser currentUser].username]] ?: [NSMutableArray array];

    self.places = [NSMutableArray array];

    self.refreshControl = [UIRefreshControl MRSL_refreshControl];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.placeTableView addSubview:_refreshControl];
    self.placeTableView.alwaysBounceVertical = YES;
    self.selectedPlaceRow = -1;
    self.originalPlaceRow = -1;
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

- (void)goBack {
    if ([self isDirty]) {
        [UIAlertView showAlertViewWithTitle:@"Warning"
                                    message:@"You have unsaved changes, are you sure you want to discard them?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Discard", nil];
    } else {
        [super goBack];
    }
}

- (IBAction)save {
    [self updateMorsel];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService updateMorsel:_morsel
                                  success:^(id responseObject) {
                                      if (weakSelf) {
                                          [weakSelf.navigationController popViewControllerAnimated:YES];
                                          [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                                                       properties:@{@"_title": @"Save",
                                                                                    @"_view": self.mp_eventView,
                                                                                    @"place_selected": NSNullIfNil(_morsel.place.placeID),
                                                                                    @"place_count": NSNullIfNil(@([_places count])),
                                                                                    @"morsel_id": NSNullIfNil(_morsel.morselID)}];
                                      }
                                  } failure:^(NSError *error) {
                                      if (weakSelf) {
                                          weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                                          [UIAlertView showAlertViewForErrorString:@"Unable to associate place. Please try again."
                                                                          delegate:nil];
                                      }
                                  }];
}

#pragma mark - Private Methods

- (BOOL)isDirty {
    return self.originalPlaceRow != self.selectedPlaceRow;
}

- (void)updateMorsel {
    if ([_places count] > 0 && _selectedPlaceRow >= 0 && _selectedPlaceRow < [_places count]) {
        MRSLPlace *place = [_places objectAtIndex:_selectedPlaceRow];
        self.morsel.place = place;
    } else {
        self.morsel.place = nil;
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
    if (self.morsel.place) {
        NSInteger placeIndex = [self.places indexOfObject:self.morsel.place];
        self.selectedPlaceRow = placeIndex;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.placeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPlaceRow inSection:0]
                                             animated:YES
                                       scrollPosition:UITableViewScrollPositionMiddle];
        });
    } else {
        if ([self.places count] > 0) {
            self.selectedPlaceRow = [_places count];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.placeTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPlaceRow inSection:0]
                                                 animated:YES
                                           scrollPosition:UITableViewScrollPositionNone];
            });
        }
    }
    if (self.originalPlaceRow < 0) self.originalPlaceRow = _selectedPlaceRow;
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
    if ([segue.identifier isEqualToString:MRSLStoryboardSeguePublishShareMorselKey]) {
        MRSLMorselPublishShareViewController *publishShareVC = [segue destinationViewController];
        publishShareVC.morsel = _morsel;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([self.places count] == 0) ? 1 : [self.places count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ([self.places count] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDEmptyCellKey];
    } else if (indexPath.row > [_places count] - 1 && [_places count] > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ruid_CheckmarkCell"];
        [[(MRSLCheckmarkTextTableViewCell *)cell titleLabel] setText:@"None / Personal"];
    } else {
        MRSLPlace *place = [_places objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDPlaceCellKey];
        [(MRSLPlaceCoverSelectTableViewCell *)cell setPlace:place];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.places count] == 0) {
        MRSLPlacesAddViewController *placesAddVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlacesAddViewControllerKey];
        [self.navigationController pushViewController:placesAddVC
                                             animated:YES];
    } else if (_selectedPlaceRow == indexPath.row) {
        _selectedPlaceRow = -1;
        [tableView deselectRowAtIndexPath:indexPath
                                 animated:YES];
    } else if (indexPath.row > [_places count] - 1 && [_places count] > 0) {
        self.selectedPlaceRow = -1;
    } else {
        _selectedPlaceRow = indexPath.row;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Activity detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Discard"]) {
        [super goBack];
    }
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    self.placeTableView.dataSource = nil;
    self.placeTableView.delegate = nil;
    [self.placeTableView removeFromSuperview];
    self.placeTableView = nil;
}

@end
