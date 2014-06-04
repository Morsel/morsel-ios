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
@property (weak, nonatomic) IBOutlet UIView *addTitleView;
@property (weak, nonatomic) IBOutlet UILabel *titleHeaderLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleField;

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

    [self.titleField setBorderWithColor:[UIColor morselLightContent]
                               andWidth:1.f];
    self.shouldDisplayStatus = YES;
    self.statusType = MRSLStatusTypeNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [UIAlertView showAlertViewWithTitle:@"Location Permission"
                                        message:@"Hey! We're going to need access to your location to make Place search more convenient. If you're ready to grant permission, press OK for the next prompt."
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

#pragma mark - Private Methods

- (void)updateLocationOfUser {
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
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

- (void)addPlace {
    if (_titleField.text.length == 0) {
        [UIAlertView showAlertViewForErrorString:@"Sorry, your title cannot be empty!"
                                        delegate:nil];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService addUserToPlaceWithFoursquareID:_selectedFoursquarePlace
                                                  userTitle:_titleField.text
                                                    success:^(id responseObject) {
                                                        weakSelf.selectedFoursquarePlace = nil;
                                                        [weakSelf goBack];
                                                    } failure:^(NSError *error) {
                                                        weakSelf.selectedFoursquarePlace = nil;
                                                        [UIAlertView showAlertViewForError:error
                                                                                  delegate:nil];
                                                    }];
}

- (void)cancelAdd {
    self.selectedFoursquarePlace = nil;
    [self.tableView deselectRowAtIndexPath:_selectedIndexPath
                                  animated:YES];
    [UIView animateWithDuration:.4f
                     animations:^{
                         self.addTitleView.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         self.titleField.text = nil;
                         self.titleHeaderLabel.text = nil;
                         self.addTitleView.hidden = YES;
                     }];
    [self resetBarButtonItems];
}

- (void)addBarButtonItemsAndDisplayAlert {
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(cancelAdd)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(addPlace)];
    [self.navigationItem setRightBarButtonItem:addButton];

    self.addTitleView.hidden = NO;
    self.titleHeaderLabel.text = [NSString stringWithFormat:@"Great! Before we can add %@ to your profile, we'll need your title:", self.selectedFoursquarePlace.name];

    [UIView animateWithDuration:.4f animations:^{
        self.addTitleView.alpha = 1.f;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.titleField becomeFirstResponder];
    });
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
        NSString *ruid = @"ruid_LocationDisabledCell";
        if (_statusType == MRSLStatusTypeNone) ruid = @"ruid_InstructionCell";
        if (_statusType == MRSLStatusTypeNoResults) ruid = @"ruid_NoResultsCell";
        if (_statusType == MRSLStatusTypeLoading) ruid = @"ruid_LoadingCell";
        if (_statusType == MRSLStatusTypeMoreCharactersRequired) ruid = @"ruid_MoreCharactersCell";
        return [tableView dequeueReusableCellWithIdentifier:ruid];
    } else {
        MRSLFoursquarePlace *foursquarePlace = [_foursquarePlaces objectAtIndex:indexPath.row];
        MRSLFoursquarePlaceTableViewCell *foursquarePlaceCell = [tableView dequeueReusableCellWithIdentifier:@"ruid_FoursquarePlaceCell"];
        foursquarePlaceCell.foursquarePlace = foursquarePlace;
        return foursquarePlaceCell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    self.selectedFoursquarePlace = [_foursquarePlaces objectAtIndex:indexPath.row];
    [self addBarButtonItemsAndDisplayAlert];
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
        [self addPlace];
        return NO;
    }
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        [self updateLocationOfUser];
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

- (void)dealloc {
    [self suspendTimer];
}

@end
