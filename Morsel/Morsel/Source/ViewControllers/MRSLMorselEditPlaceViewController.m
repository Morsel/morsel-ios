//
//  MRSLMorselPublishPlaceViewController.m
//  Morsel
//
//  Created by Javier Otero on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselEditPlaceViewController.h"

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Place.h"

#import "MRSLMorselPublishShareViewController.h"
#import "MRSLPlaceCoverSelectTableViewCell.h"
#import "MRSLCheckmarkTextTableViewCell.h"
#import "MRSLPlacesAddViewController.h"
#import "MRSLPrimaryLightLabel.h"
#import "MRSLTableView.h"
#import "MRSLTableViewDataSource.h"

#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLBaseRemoteDataSourceViewController (Private)

- (void)populateContent;

@end

@interface MRSLMorselEditPlaceViewController ()
<MRSLTableViewDataSourceDelegate,
UIAlertViewDelegate>

@property (nonatomic) NSInteger selectedPlaceRow;
@property (nonatomic) NSInteger originalPlaceRow;

@end

@implementation MRSLMorselEditPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"associate_place";

    self.selectedPlaceRow = -1;
    self.originalPlaceRow = -1;

    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService getPlacesForUser:[MRSLUser currentUser]
                                             page:page
                                            count:nil
                                          success:^(NSArray *responseArray) {
                                              remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                          } failure:^(NSError *error) {
                                              remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                          }];
    };
}

#pragma mark - Action Methods

- (IBAction)addPlace {
    MRSLPlacesAddViewController *placesAddVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardPlacesAddViewControllerKey];
    [self.navigationController pushViewController:placesAddVC
                                         animated:YES];
}

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
                                                                                    @"place_count": NSNullIfNil(@([weakSelf.dataSource count])),
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

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%@_placeIDs", [MRSLUser currentUser].username];
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLPlace MR_fetchAllSortedBy:@"name"
                                 ascending:YES
                             withPredicate:[NSPredicate predicateWithFormat:@"placeID IN %@", self.objectIDs]
                                   groupBy:nil
                                  delegate:self
                                 inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    MRSLDataSource *newDataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil configureCellBlock:^UITableViewCell *(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
        UITableViewCell *cell = nil;
        if (indexPath.row > count - 1 || count == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDCheckmarkCellKey];
            [[(MRSLCheckmarkTextTableViewCell *)cell titleLabel] setText:@"None / Personal"];
        } else {
            MRSLPlace *place = item;
            cell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDPlaceCellKey];
            [(MRSLPlaceCoverSelectTableViewCell *)cell setPlace:place];
        }
        return cell;
    }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

- (BOOL)isDirty {
    return self.originalPlaceRow != self.selectedPlaceRow;
}

- (void)updateMorsel {
    if ([self.dataSource count] > 0 && _selectedPlaceRow >= 0 && _selectedPlaceRow < [self.dataSource count]) {
        MRSLPlace *place = [self.dataSource objectAtIndexPath:[NSIndexPath indexPathForRow:_selectedPlaceRow inSection:0]];
        self.morsel.place = place;
    } else {
        self.morsel.place = nil;
    }
}

- (void)populateContent {
    [super populateContent];
    if (self.morsel.place) {
        NSInteger placeIndex = [self.dataSource indexOfObject:self.morsel.place];
        self.selectedPlaceRow = placeIndex;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPlaceRow inSection:0]
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
        });
    } else {
        if ([self.dataSource count] > 0) {
            self.selectedPlaceRow = [self.dataSource count];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedPlaceRow inSection:0]
                                            animated:YES
                                      scrollPosition:UITableViewScrollPositionNone];
            });
        }
    }
    if (self.originalPlaceRow < 0) self.originalPlaceRow = _selectedPlaceRow;
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:MRSLStoryboardSeguePublishShareMorselKey]) {
        MRSLMorselPublishShareViewController *publishShareVC = [segue destinationViewController];
        publishShareVC.morsel = _morsel;
    }
}

#pragma mark - MRSLTableViewDataSource Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([self.dataSource count] == 0) ? 1 : [self.dataSource count] + 1;
}

- (void)tableViewDataSource:(UITableView *)tableView didSelectItem:(id)item atIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row > [self.dataSource count] - 1 && [self.dataSource count] > 0) || ([self.dataSource count] == 0)) {
        self.selectedPlaceRow = -1;
    } else {
        _selectedPlaceRow = indexPath.row;
    }
}

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Discard"]) {
        [super goBack];
    }
}

@end
