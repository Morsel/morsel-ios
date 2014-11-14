//
//  MRSLPlacesAddViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLPlacesAddViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "MRSLAPIService+Place.h"

#import "MRSLFoursquarePlaceTableViewCell.h"

#import "MRSLFoursquarePlace.h"

#import "MRSLPlace.h"

@interface MRSLPlacesAddViewController ()
<CLLocationManagerDelegate,
UIAlertViewDelegate,
UISearchBarDelegate,
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate>

@property (nonatomic) BOOL shouldDisplayStatus;
@property (nonatomic) BOOL locationDisabled;
@property (nonatomic) BOOL searchQueued;

@property (nonatomic) MRSLStatusType statusType;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) MRSLFoursquarePlace *selectedFoursquarePlace;

@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *foursquarePlaces;
@property (strong, nonatomic) NSTimer *searchTimer;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation MRSLPlacesAddViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.foursquarePlaces = [NSArray array];
    self.shouldDisplayStatus = YES;
    self.statusType = MRSLStatusTypeNone;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [UIAlertView showAlertViewWithTitle:@"Location Permission"
                                        message:@"To improve your place search, we’d like to access your location. If you're ready to grant permission, press OK for the next prompt."
                                       delegate:self
                              cancelButtonTitle:@"Not now"
                              otherButtonTitles:@"OK", nil];
        } else {
            self.locationDisabled = YES;
            self.searchBar.userInteractionEnabled = NO;
            [self.tableView reloadData];
        }
    } else {
        [self updateLocationOfUser];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self suspendTimer];
}

#pragma mark - Private Methods

- (void)updateLocationOfUser {
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;

    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }

    [_locationManager startUpdatingLocation];
}

- (void)refreshContent {
    if ([_searchBar.text length] <= 2) return;
    if (_locationDisabled || !_userLocation) {
        self.searchQueued = YES;
        return;
    }
    self.shouldDisplayStatus = YES;
    self.statusType = MRSLStatusTypeLoading;
    [self.tableView reloadData];
    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService searchPlacesWithQuery:_searchBar.text
                                       andLocation:_userLocation
                                           success:^(NSArray *responseArray) {
                                               if ([weakSelf.searchBar.text length] > 2) {
                                                   weakSelf.foursquarePlaces = responseArray;
                                                   if ([responseArray count] == 0) {
                                                       weakSelf.statusType = MRSLStatusTypeNoResults;
                                                       weakSelf.shouldDisplayStatus = YES;
                                                   } else {
                                                       weakSelf.statusType = MRSLStatusTypeNone;
                                                       weakSelf.shouldDisplayStatus = NO;
                                                   }
                                                   [weakSelf.tableView reloadData];
                                               }
                                           } failure:nil];
}

- (void)cancelAdd {
    self.selectedFoursquarePlace = nil;
    [self.tableView deselectRowAtIndexPath:_selectedIndexPath
                                  animated:YES];
    [self resetBarButtonItems];
}

- (void)resetBarButtonItems {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(goBack)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationItem setRightBarButtonItem:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_locationDisabled || _shouldDisplayStatus) ? 1 : [_foursquarePlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_locationDisabled || _shouldDisplayStatus) {
        NSString *ruid = nil;
        switch (_statusType) {
            case MRSLStatusTypeNone:
                if (!_locationDisabled)
                    ruid = MRSLStoryboardRUIDInstructionCellKey;
                else
                    ruid = MRSLStoryboardRUIDLocationDisabledCellKey;
                break;
            case MRSLStatusTypeNoResults:
                ruid = MRSLStoryboardRUIDNoResultsCellKey;
                break;
            case MRSLStatusTypeLoading:
                ruid = MRSLStoryboardRUIDLoadingCellKey;
                break;
            case MRSLStatusTypeMoreCharactersRequired:
                ruid = MRSLStoryboardRUIDMoreCharactersCellKey;
                break;
            default:
                ruid = MRSLStoryboardRUIDLocationDisabledCellKey;
                break;
        }
        return [tableView dequeueReusableCellWithIdentifier:ruid];
    } else {
        MRSLFoursquarePlace *foursquarePlace = [_foursquarePlaces objectAtIndex:indexPath.row];
        MRSLFoursquarePlaceTableViewCell *foursquarePlaceCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDFoursquarePlaceCellKey];
        foursquarePlaceCell.foursquarePlace = foursquarePlace;
        return foursquarePlaceCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [_foursquarePlaces count]) return;
    self.selectedIndexPath = indexPath;
    self.selectedFoursquarePlace = [_foursquarePlaces objectAtIndex:indexPath.row];
    [self.view endEditing:YES];
    [UIAlertView showAlertViewWithTitle:@"Professional Title"
                                message:[NSString stringWithFormat:@"What's your title here, ex. Sous chef, Mixologist, ..."]
                               delegate:self style:UIAlertViewStylePlainTextInput
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"Done"];
}

#pragma mark - UISearchBarDelegate

- (void)suspendTimer {
    if (_searchTimer) {
        [_searchTimer invalidate];
        self.searchTimer = nil;
    }
}

- (void)resumeTimer {
    [self suspendTimer];
    if (!_searchTimer) {
        self.searchTimer = [NSTimer timerWithTimeInterval:.1f
                                                   target:self
                                                 selector:@selector(refreshContent)
                                                 userInfo:nil
                                                  repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_searchTimer
                                     forMode:NSRunLoopCommonModes];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSUInteger textLength = searchText.length;
    if (textLength <= 2) {
        self.shouldDisplayStatus = YES;
        self.statusType = MRSLStatusTypeMoreCharactersRequired;
        if ([_foursquarePlaces count] > 0) self.foursquarePlaces = [NSArray array];
        [self.tableView reloadData];
    } else {
        [self resumeTimer];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.searchBar.isFirstResponder) [self.searchBar resignFirstResponder];
}

#pragma mark - UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"OK"]) {
        [self updateLocationOfUser];
    } else if ([buttonTitle isEqualToString:@"Done"]) {
        UITextField *alertTextField = [alertView textFieldAtIndex:0];
        if (alertTextField.text.length == 0) {
            [UIAlertView showAlertViewForErrorString:@"Sorry, your title cannot be empty!"
                                            delegate:nil];
            return;
        }
        __weak __typeof(self)weakSelf = self;
        [_appDelegate.apiService addUserToPlaceWithFoursquareID:_selectedFoursquarePlace
                                                      userTitle:alertTextField.text
                                                        success:^(id responseObject) {
                                                            weakSelf.selectedFoursquarePlace = nil;
                                                            __block NSManagedObjectContext *workContext = nil;
                                                            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                                                workContext = localContext;
                                                                MRSLPlace *place = [MRSLPlace MR_findFirstByAttribute:MRSLPlaceAttributes.placeID
                                                                                                            withValue:responseObject[@"data"][@"id"]
                                                                                                            inContext:localContext];
                                                                if (!place) place = [MRSLPlace MR_createInContext:localContext];
                                                                [place MR_importValuesForKeysWithObject:responseObject[@"data"]];
                                                            } completion:^(BOOL success, NSError *error) {
                                                                [weakSelf goBack];
                                                                if (success) [workContext reset];
                                                            }];
                                                        } failure:^(NSError *error) {
                                                            weakSelf.selectedFoursquarePlace = nil;
                                                            [UIAlertView showAlertViewForError:error
                                                                                      delegate:nil];
                                                        }];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized) {
        self.locationDisabled = NO;
        self.searchBar.userInteractionEnabled = YES;
        [self.tableView reloadData];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *possibleLocation = [locations lastObject];
    if (possibleLocation.horizontalAccuracy < 0) {
        return;
    }
    NSTimeInterval interval = [possibleLocation.timestamp timeIntervalSinceNow];
    if (abs(interval) < 30) {
        self.userLocation = possibleLocation;
        [manager stopUpdatingLocation];
        if (_searchQueued && self.searchBar.text.length > 0) {
            self.searchQueued = NO;
            [self refreshContent];
        }
    }
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

@end
