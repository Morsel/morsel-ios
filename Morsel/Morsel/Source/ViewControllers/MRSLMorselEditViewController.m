//
//  MRSLMorselEditViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselEditViewController.h"

#import <NSDate+TimeAgo/NSDate+TimeAgo.h>

#import "MRSLAPIService+Item.h"
#import "MRSLAPIService+Morsel.h"

#import "MRSLCaptureMultipleMediaViewController.h"
#import "MRSLMediaItemPreviewViewController.h"
#import "MRSLTableView.h"
#import "MRSLToolbar.h"
#import "MRSLMorselAddTitleViewController.h"
#import "MRSLMorselEditItemTableViewCell.h"
#import "MRSLMorselPublishCoverViewController.h"

#import "MRSLMediaItem.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"

@interface MRSLMorselEditViewController ()
<NSFetchedResultsControllerDelegate,
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
CaptureMediaViewControllerDelegate,
MRSLToolbarViewDelegate,
MRSLMorselEditItemTableViewCellDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) BOOL wasNewMorsel;
@property (nonatomic, getter = isCapturing) BOOL capturing;

@property (weak, nonatomic) IBOutlet UIButton *morselTitleButton;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet MRSLTableView *morselItemsTableView;

@property (strong, nonatomic) UIBarButtonItem *rightBarButton;
@property (strong, nonatomic) NSDateFormatter *statusDateFormatter;
@property (strong, nonatomic) NSFetchedResultsController *itemsFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *items;

@property (weak, nonatomic) IBOutlet MRSLToolbar *toolbarView;

@property (weak, nonatomic) MRSLMorsel *morsel;
@property (weak, nonatomic) MRSLItem *item;

@end

@implementation MRSLMorselEditViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isEditing = NO;

    self.items = [NSMutableArray array];
    self.statusDateFormatter = [[NSDateFormatter alloc] init];
    [_statusDateFormatter setDateFormat:@"MMM dd, h:mm a"];

    //  Reusing `capturing` here to prevent code in - displayMorsel from enabling the empty state before loading
    self.capturing = YES;
    [self displayMorsel];
    self.capturing = NO;
    [self updateMorselStatus];

    [self.morselItemsTableView setEmptyStateTitle:@"This morsel has no items. Add one below."];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.loading = YES;
    [self displayMorsel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_shouldPresentMediaCapture && !_wasNewMorsel) {
        self.wasNewMorsel = YES;
        [self presentMediaCapture];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    _itemsFetchedResultsController.delegate = nil;
    _itemsFetchedResultsController = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Private Methods

- (void)setLoading:(BOOL)loading {
    if ([self isCapturing] && !loading) return;

    _loading = loading;

    [self.morselItemsTableView toggleLoading:loading];
}

- (void)displayMorsel {
    self.morsel = [self getOrLoadMorselIfExists];

    [self showNextButton];

    self.morselTitleLabel.text = ([_morsel.title length] == 0) ? @"Tap to add title" : _morsel.title;

    [self displayMorselStatus];
    [self setupFetchRequest];
    [self populateContent];
}

- (void)updateMorselStatus {
    self.morsel = [self getOrLoadMorselIfExists];
    if (_morsel) {
        [_appDelegate.apiService getMorsel:_morsel
                                  orWithID:nil
                                   success:nil
                                   failure:nil];
    }
}

- (void)displayMorselStatus {
    NSDate *lastUpdated = [_morsel latestUpdatedDate];
    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last saved at %@", (lastUpdated) ? [_statusDateFormatter stringFromDate:lastUpdated] : [_statusDateFormatter stringFromDate:[NSDate date]]];
    if ([_items count] == 0) {
        self.toolbarView.leftButton.enabled = YES;
        self.isEditing = NO;
        [self.morselItemsTableView setEditing:NO
                                     animated:NO];
    }
    [self determineControlState];
}

- (void)setupFetchRequest {
    self.itemsFetchedResultsController = [MRSLItem MR_fetchAllSortedBy:@"sort_order"
                                                             ascending:YES
                                                         withPredicate:[NSPredicate predicateWithFormat:@"(morsel.morselID == %i)", [_morselID intValue]]
                                                               groupBy:nil
                                                              delegate:self
                                                             inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_itemsFetchedResultsController performFetch:&fetchError];
    self.items = [[_itemsFetchedResultsController fetchedObjects] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.morselItemsTableView reloadData];
        self.loading = NO;
    });
    [self displayMorselStatus];
}

- (void)presentMediaCapture {
    self.capturing = YES;
    MRSLCaptureMultipleMediaViewController *captureMediaVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCaptureMultipleMediaViewControllerKey];
    captureMediaVC.delegate = self;
    [self presentViewController:captureMediaVC
                       animated:YES
                     completion:nil];
}

- (void)showNextButton {
    if (_morsel.draftValue) {
        if (![self.rightBarButton.title isEqualToString:@"Next"]) {
            [self.navigationItem setRightBarButtonItem:nil];
            self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(displayPublishMorsel)];
            [self.navigationItem setRightBarButtonItem:_rightBarButton];
        }
    }
}

- (void)showDoneButton {
    if (![self.rightBarButton.title isEqualToString:@"Done"]) {
        [self.navigationItem setRightBarButtonItem:nil];
        self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(toggleEditing)];
        [self.navigationItem setRightBarButtonItem:_rightBarButton];
    }
}

- (void)determineControlState {
    [self.toolbarView.rightButton setTitle:(_isEditing) ? @"Delete morsel" : @"New item"
                                  forState:UIControlStateNormal];
    if (_isEditing) {
        [self showDoneButton];
        [self.rightBarButton setEnabled:YES];
    } else {
        [self showNextButton];
        // Disable next button if there are no items
        [self.rightBarButton setEnabled:([_items count] > 0)];
        self.toolbarView.leftButton.enabled = YES;
    }
}

#pragma mark - Getter Methods

- (MRSLMorsel *)getOrLoadMorselIfExists {
    MRSLMorsel *morsel = nil;
    if (_morselID) {
        morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                           withValue:_morselID];
        [morsel.managedObjectContext MR_saveOnlySelfAndWait];
    }
    return morsel;
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (_morselItemsTableView.isEditing) {
        [_morselItemsTableView setEditing:NO animated:NO];
        self.isEditing = NO;
    }
    if ([segue.identifier isEqualToString:MRSLStoryboardSegueEditMorselTitleKey]) {
        MRSLMorselAddTitleViewController *morselAddTitleVC = [segue destinationViewController];
        morselAddTitleVC.isUserEditingTitle = YES;
        morselAddTitleVC.morselID = _morsel.morselID;
    } else if ([segue.identifier isEqualToString:MRSLStoryboardSeguePublishMorselKey]) {
        MRSLMorselPublishCoverViewController *morselPublishVC = [segue destinationViewController];
        morselPublishVC.morsel = _morsel;
    }
}

#pragma mark - Action Methods

- (IBAction)toggleEditing {
    [[MRSLEventManager sharedManager] track:@"Tapped Edit"
                                 properties:@{@"view": @"Your Morsel",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    self.isEditing = !_isEditing;
    [_morselItemsTableView setEditing:_isEditing
                             animated:YES];
    [self determineControlState];
}

- (void)goBack {
    if (_wasNewMorsel) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)displayPublishMorsel {
    self.morsel = [self getOrLoadMorselIfExists];
    if (_morsel) {
        if ([[_morsel items] count] == 0) {
            [UIAlertView showOKAlertViewWithTitle:@"No items"
                                          message:@"Please add at least one item to this Morsel to continue."];
            return;
        }
        for (MRSLItem *item in _morsel.itemsArray) {
            if (item.didFailUploadValue) {
                [UIAlertView showOKAlertViewWithTitle:@"Item Upload Failed"
                                              message:@"An item failed to upload. Please try again before continuing."];
                return;
            } else if (item.isUploadingValue) {
                [UIAlertView showOKAlertViewWithTitle:@"Currently Uploading"
                                              message:@"Please wait for all items to finish uploading before continuing."];
                return;
            }
        }
        [[MRSLEventManager sharedManager] track:@"Tapped Next"
                                     properties:@{@"view": @"Your Morsel",
                                                  @"item_count": @([_items count]),
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"morsel_draft":(_morsel.draftValue) ? @"true" : @"false"}];
        [self performSegueWithIdentifier:MRSLStoryboardSeguePublishMorselKey
                                  sender:nil];
    }
}

#pragma mark - UITableViewDataSource Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([_items count] > 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MRSLItem *deletedItem = [_items objectAtIndex:indexPath.row];
        [[MRSLEventManager sharedManager] track:@"Tapped Delete Item"
                                     properties:@{@"view": @"Your Morsel",
                                                  @"item_count": @([_items count]),
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(deletedItem.itemID)}];
        [_items removeObject:deletedItem];
        [_morselItemsTableView deleteRowsAtIndexPaths:@[indexPath]
                                     withRowAnimation:UITableViewRowAnimationFade];

        __weak __typeof(self) weakSelf = self;

        double delayInSeconds = .4f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_appDelegate.apiService deleteItem:deletedItem
                                        success:^(BOOL success) {
                                            if (weakSelf) {
                                                weakSelf.morsel = [weakSelf getOrLoadMorselIfExists];
                                                weakSelf.morsel.lastUpdatedDate = [NSDate date];
                                                [weakSelf displayMorselStatus];
                                            }
                                        } failure:nil];
        });
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    MRSLItem *movedItem = [_items objectAtIndex:sourceIndexPath.row];
    MRSLItem *replacedItem = [_items objectAtIndex:destinationIndexPath.row];
    if ([replacedItem isEqual:movedItem]) return;
    [_items removeObject:movedItem];
    [_items insertObject:movedItem
                 atIndex:destinationIndexPath.row];

    [[MRSLEventManager sharedManager] track:@"Tapped Reordered Morsel"
                                 properties:@{@"view": @"Your Morsel",
                                              @"item_count": @([_items count]),
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"item_id": NSNullIfNil(movedItem.itemID)}];

    DDLogDebug(@"Item Previous Sort Order: %@", movedItem.sort_order);
    DDLogDebug(@"Item Replacing Sort Order: %@", replacedItem.sort_order);
    BOOL shouldPlaceAfter = (sourceIndexPath.row < destinationIndexPath.row);
    movedItem.sort_order = @((shouldPlaceAfter) ? replacedItem.sort_orderValue + 1 : replacedItem.sort_orderValue);

    for (NSInteger i = destinationIndexPath.row + 1; i < [_items count]; i++) {
        MRSLItem *nextItem = [_items objectAtIndex:i];
        nextItem.sort_order = @(nextItem.sort_orderValue + 1);
        DDLogDebug(@"Item SORT CHANGED: %@", nextItem.sort_order);
    }
    DDLogDebug(@"Item New Sort Order: %@", movedItem.sort_order);

    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService updateItem:movedItem
                              andMorsel:nil
                                success:^(id responseObject) {
                                    if (weakSelf) {
                                        weakSelf.morsel = [weakSelf getOrLoadMorselIfExists];
                                        weakSelf.morsel.lastUpdatedDate = [NSDate date];
                                    }
                                } failure:nil];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.row + 1 > [_items count]) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLItem *item = [_items objectAtIndex:indexPath.row];

    MRSLMorselEditItemTableViewCell *morselMorselCell = [self.morselItemsTableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDMorselItemCellKey
                                                                                                        forIndexPath:indexPath];
    morselMorselCell.item = item;
    morselMorselCell.delegate = self;
    return morselMorselCell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.item = [_items objectAtIndex:indexPath.row];
    if (!self.item.itemID) return;
    [[MRSLEventManager sharedManager] track:@"Tapped Thumbnail"
                                 properties:@{@"view": @"Your Morsel",
                                              @"item_count": @([_items count]),
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"item_id": NSNullIfNil(_item.itemID)}];
    NSUInteger index = [_items indexOfObject:_item];
    MRSLMediaItemPreviewViewController *imagePreviewVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardImagePreviewViewControllerKey];
    [imagePreviewVC setPreviewMedia:_items andStartingIndex:index];

    [self.navigationController pushViewController:imagePreviewVC
                                         animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"NSFetchedResultsController detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - CaptureMediaViewControllerDelegate

- (void)captureMediaViewControllerDidFinishCapturingMediaItems:(NSArray *)capturedMedia {
    self.morsel = [self getOrLoadMorselIfExists];
    self.loading = [capturedMedia count] > 0;
    __weak __typeof(self) weakSelf = self;
    DDLogDebug(@"Received %lu Media Items. Should now create Morsels for each!", (unsigned long)[capturedMedia count]);
    int idx = 0;
    for (MRSLMediaItem *mediaItem in capturedMedia) {
        NSUInteger itemIndex = (idx + 1);
        if ([self.items count] > 0) {
            MRSLItem *lastMorsel = [self.items lastObject];
            itemIndex = (lastMorsel.sort_orderValue + (idx + 1));
        }
        DDLogDebug(@"Item INDEX: %lu", (unsigned long)itemIndex);

        [mediaItem processMediaToDataWithSuccess:^(NSData *fullImageData, NSData *thumbImageData) {
            weakSelf.capturing = NO;
            __block NSManagedObjectContext *workContext = nil;
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                workContext = localContext;
                MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                               withValue:weakSelf.morselID
                                                               inContext:localContext];
                if (morsel) {
                    MRSLItem *item = [MRSLItem localUniqueItemInContext:localContext];
                    item.sort_order = @(itemIndex);
                    item.itemPhotoFull = fullImageData;
                    item.itemPhotoThumb = thumbImageData;
                    item.isUploading = @YES;
                    item.morsel = morsel;
                    [morsel addItemsObject:item];
                    [_appDelegate.apiService createItem:item
                                                success:^(id responseObject) {
                                                    if ([responseObject isKindOfClass:[MRSLItem class]]) {
                                                        MRSLItem *itemToUploadWithImage = (MRSLItem *)responseObject;
                                                        [weakSelf getOrLoadMorselIfExists].lastUpdatedDate = [NSDate date];
                                                        [weakSelf displayMorselStatus];
                                                        [itemToUploadWithImage API_updateImage];
                                                    }
                                                } failure:nil];
                } else {
                    DDLogError(@"Morsel item add failure. Cannot add item to nil Morsel with ID: %@", weakSelf.morselID);
                    [UIAlertView showAlertViewForErrorString:[NSString stringWithFormat:@"There was a problem adding your item%@ to this Morsel. Please try again.", ([capturedMedia count] > 1) ? @"s" : @""]
                                                    delegate:nil];
                }
            } completion:^(BOOL success, NSError *error) {
                [workContext reset];
            }];
        }];

        idx++;
    }
    capturedMedia = nil;
}

- (void)captureMediaViewControllerDidCancel {
    self.capturing = NO;
    self.loading = NO;
}

#pragma mark - MRSLMorselEditMorselCollectionViewCellDelegate

- (void)morselEditItemCellDidTransitionToDeleteState:(BOOL)deleteStateActive {
    self.toolbarView.leftButton.enabled = !deleteStateActive;
}

#pragma mark - MRSLToolbarViewDelegate

- (void)toolbarDidSelectLeftButton:(UIButton *)leftButton {
    [self toggleEditing];
}

- (void)toolbarDidSelectRightButton:(UIButton *)rightButton {
    if (_isEditing) {
        [UIAlertView showAlertViewWithTitle:@"Delete Morsel"
                                    message:@"This will delete your entire Morsel and all items associated with it. Are you sure you want to do this?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    } else {
        [self presentMediaCapture];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        self.morsel = [self getOrLoadMorselIfExists];
        if (_morsel) {
            [[MRSLEventManager sharedManager] track:@"Tapped Delete Morsel"
                                         properties:@{@"view": @"Your Morsel",
                                                      @"morsel_id": NSNullIfNil(_morsel.morselID)}];
            [_appDelegate.apiService deleteMorsel:_morsel
                                          success:nil
                                          failure:nil];
            [_morsel MR_deleteEntity];
            [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
            if (self.presentingViewController) {
                [self.presentingViewController dismissViewControllerAnimated:YES
                                                                  completion:nil];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    } else {
        [[MRSLEventManager sharedManager] track:@"Tapped Cancel Delete Morsel"
                                     properties:@{@"view": @"Your Morsel",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    }
}

#pragma mark - Dealloc

- (void)reset {
    [super reset];
    self.morselItemsTableView.dataSource = nil;
    self.morselItemsTableView.delegate = nil;
    [self.morselItemsTableView removeFromSuperview];
    self.morselItemsTableView = nil;
}

@end
