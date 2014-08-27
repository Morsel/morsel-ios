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
#import "MRSLReorderTableView.h"
#import "MRSLToolbar.h"
#import "MRSLMorselAddTitleViewController.h"
#import "MRSLMorselEditItemTableViewCell.h"
#import "MRSLMorselInfoTableViewCell.h"
#import "MRSLMorselPublishShareViewController.h"
#import "MRSLMorselPublishPlaceViewController.h"
#import "MRSLUserMorselsFeedViewController.h"

#import "MRSLMediaItem.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLMorselEditViewController ()
<NSFetchedResultsControllerDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
CaptureMediaViewControllerDelegate,
MRSLToolbarViewDelegate,
MRSLMorselEditItemTableViewCellDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL isEditing;
@property (nonatomic, getter = isCapturing) BOOL capturing;

@property (nonatomic) NSInteger totalUserCells;
@property (nonatomic) NSInteger totalCells;

@property (weak, nonatomic) IBOutlet MRSLReorderTableView *morselItemsTableView;

@property (strong, nonatomic) UIBarButtonItem *rightBarButton;
@property (strong, nonatomic) NSFetchedResultsController *itemsFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSIndexPath *sourceIndexPath;

@property (weak, nonatomic) IBOutlet MRSLToolbar *toolbarView;

@property (weak, nonatomic) MRSLMorsel *morsel;
@property (weak, nonatomic) MRSLItem *item;

@end

@implementation MRSLMorselEditViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"your_morsel";

    self.isEditing = NO;

    self.objects = [NSMutableArray array];
    self.totalUserCells = [[MRSLUser currentUser] isProfessional] ? 2 : 1;
    self.totalCells = _totalUserCells + [_objects count];

    //  Reusing `capturing` here to prevent code in - displayMorsel from enabling the empty state before loading
    self.capturing = YES;
    [self displayMorsel];
    self.capturing = NO;
    [self updateMorselStatus];

    [self.morselItemsTableView setEmptyStateTitle:@"This morsel has no items."];

    [self.morsel downloadCoverPhotoIfNilWithCompletion:nil];
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
    if ([_objects count] == 0) {
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
    NSMutableArray *dataSourceObjects = [NSMutableArray array];
    for (int i = 0 ; i < _totalUserCells ; i++) {
        [dataSourceObjects addObject:[NSNull null]];
    }
    self.items = [_itemsFetchedResultsController fetchedObjects];
    [dataSourceObjects addObjectsFromArray:_items];
    self.objects = dataSourceObjects;
    self.totalCells = [_objects count];
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
    self.morsel = [self getOrLoadMorselIfExists];
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

- (void)determineControlState {
    [self showNextButton];
    // Disable next button if there are no items
    [self.rightBarButton setEnabled:([_objects count] > 0)];
    self.toolbarView.leftButton.enabled = YES;
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
    } else if ([segue.identifier isEqualToString:MRSLStoryboardSeguePublishShareMorselKey]) {
        MRSLMorselPublishShareViewController *morselPublishVC = [segue destinationViewController];
        morselPublishVC.morsel = _morsel;
    } else if ([segue.identifier isEqualToString:MRSLStoryboardSegueSelectPlaceKey]) {
        MRSLMorselPublishPlaceViewController *morselPlaceVC = [segue destinationViewController];
        morselPlaceVC.morsel = _morsel;
    }
}

#pragma mark - Action Methods

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
            [UIAlertView showOKAlertViewWithTitle:@"No photos"
                                          message:@"Please add at least one photo to this Morsel to continue."];
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
            } else if (!item.itemPhotoURL) {
                [UIAlertView showOKAlertViewWithTitle:@"Missing photos"
                                              message:([[_morsel items] count] == 1) ? @"Please add a photo to your item in order to continue." : @"All items must have photos in order to continue."];
                return;
            }
        }
        if ([_morsel hasPlaceholderTitle]) {
            [UIAlertView showOKAlertViewWithTitle:@"Missing title"
                                          message:@"Please give your morsel a title."];
            return;
        }
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Next",
                                                  @"_view": self.mp_eventView,
                                                  @"items_count": @([_objects count]),
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"morsel_draft":(_morsel.draftValue) ? @"true" : @"false"}];
        [self performSegueWithIdentifier:MRSLStoryboardSeguePublishShareMorselKey
                                  sender:nil];
    }
}

#pragma mark - BVReorderTableView Methods

- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_objects objectAtIndex:indexPath.row];
    [_objects replaceObjectAtIndex:indexPath.row
                        withObject:@"REORDER_PLACEHOLDER"];
    return object;
}

- (void)moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
               toIndexPath:(NSIndexPath *)destinationIndexPath {
    id movedObject = [_objects objectAtIndex:sourceIndexPath.row];
    [_objects removeObjectAtIndex:sourceIndexPath.row];
    [_objects insertObject:movedObject
                   atIndex:destinationIndexPath.row];
    self.sourceIndexPath = sourceIndexPath;
}

- (void)finishReorderingWithObject:(id)object
                       atIndexPath:(NSIndexPath *)destinationIndexPath {
    [_objects replaceObjectAtIndex:destinationIndexPath.row
                        withObject:object];

    if (!self.sourceIndexPath) return;
    MRSLItem *movedItem = object;
    MRSLItem *replacedItem = [_objects objectAtIndex:_sourceIndexPath.row];
    if ([replacedItem isEqual:movedItem]) return;

    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Reordered Morsel",
                                              @"_view": self.mp_eventView,
                                              @"item_count": @([_objects count]),
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"item_id": NSNullIfNil(movedItem.itemID)}];

    DDLogDebug(@"Item Previous Sort Order: %@", movedItem.sort_order);
    DDLogDebug(@"Item Replacing Sort Order: %@", replacedItem.sort_order);
    BOOL shouldPlaceAfter = (_sourceIndexPath.row < destinationIndexPath.row);
    movedItem.sort_order = @((shouldPlaceAfter) ? replacedItem.sort_orderValue + 1 : replacedItem.sort_orderValue);

    for (NSInteger i = destinationIndexPath.row + 1; i < [_objects count]; i++) {
        MRSLItem *nextItem = [_objects objectAtIndex:i];
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
    self.sourceIndexPath = nil;
}

#pragma mark - UITableViewDataSource Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row > _totalUserCells - 1) && (indexPath.row < _totalCells);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _totalCells + 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.morsel = [self getOrLoadMorselIfExists];
        MRSLItem *deletedItem = [_objects objectAtIndex:indexPath.row];
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Delete Item",
                                                  @"_view": self.mp_eventView,
                                                  @"item_count": @([_objects count]),
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(deletedItem.itemID)}];
        [_objects removeObject:deletedItem];
        self.totalCells --;
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

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.row < _totalUserCells || proposedDestinationIndexPath.row + 1 > _totalCells) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;
    if (indexPath.row > _totalCells - 1) {
        tableViewCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDMorselAddCell];
    } else if (indexPath.row < _totalUserCells) {
        if ([[_objects objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
            tableViewCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDEmptyCellKey];
        } else {
            tableViewCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDMorselInfoCell];

            NSString *cellTitle = @"";
            if (indexPath.row == 0) {
                cellTitle = [NSString stringWithFormat:@"Title: %@", ([_morsel hasPlaceholderTitle]) ? @"Name your morsel" : [_morsel title]];
            } else if (indexPath.row == 1) {
                cellTitle = [NSString stringWithFormat:@"Where: %@", [_morsel.place name] ?: @"None"];
            }
            [[(MRSLMorselInfoTableViewCell *)tableViewCell titleLabel] setText:cellTitle];
        }
    } else {
        if ([[_objects objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
            tableViewCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDEmptyCellKey];
        } else {
            MRSLItem *item = [_objects objectAtIndex:indexPath.row];

            tableViewCell = [self.morselItemsTableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDMorselItemCellKey
                                                                            forIndexPath:indexPath];
            [(MRSLMorselEditItemTableViewCell *)tableViewCell setItem:item];
            [(MRSLMorselEditItemTableViewCell *)tableViewCell setDelegate:self];
        }
    }
    return tableViewCell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > _totalCells - 1) {
        NSUInteger itemIndex = 1;
        if ([self.objects count] > 0) {
            MRSLItem *lastItem = [self.objects lastObject];
            itemIndex = (lastItem.sort_orderValue + 1);
        }
        self.morsel = [self getOrLoadMorselIfExists];
        MRSLItem *item = [MRSLItem localUniqueItemInContext:[NSManagedObjectContext MR_defaultContext]];
        item.sort_order = @(itemIndex);
        item.morsel = _morsel;
        [_morsel addItemsObject:item];
        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService createItem:item
                                    success:^(id responseObject) {
                                        if (weakSelf) {
                                            [weakSelf displayMorselStatus];
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [weakSelf.morselItemsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.items count] - 1 inSection:0]
                                                                                     atScrollPosition:UITableViewScrollPositionTop
                                                                                             animated:YES];
                                            });
                                        }
                                    } failure:nil];
    } else if (indexPath.row < _totalUserCells) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:MRSLStoryboardSegueEditMorselTitleKey
                                      sender:nil];
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:MRSLStoryboardSegueSelectPlaceKey
                                      sender:nil];
        }
    } else {
        self.item = [_objects objectAtIndex:indexPath.row];
        if (!self.item.itemID) return;
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Thumbnail",
                                                  @"_view": self.mp_eventView,
                                                  @"item_count": @([_objects count]),
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(_item.itemID)}];
        NSUInteger index = [_objects indexOfObject:_item];
        UINavigationController *imagePreviewNC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMediaPreviewKey];
        MRSLMediaItemPreviewViewController *imagePreviewVC = [[imagePreviewNC viewControllers] firstObject];
        [imagePreviewVC setPreviewMedia:[_items mutableCopy]
                       andStartingIndex:index - _totalUserCells];
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                            object:imagePreviewNC];
    }
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
        if ([self.objects count] > 0) {
            MRSLItem *lastItem = [self.objects lastObject];
            itemIndex = (lastItem.sort_orderValue + (idx + 1));
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
                    [UIAlertView showAlertViewForErrorString:[NSString stringWithFormat:@"There was a problem adding your photo%@ to this Morsel. Please try again.", ([capturedMedia count] > 1) ? @"s" : @""]
                                                    delegate:nil];
                }
            } completion:^(BOOL success, NSError *error) {
                if (success) [workContext reset];
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

#pragma mark - MRSLToolbarViewDelegate

- (void)toolbarDidSelectLeftButton:(UIButton *)leftButton {
#warning Display Help
}

- (void)toolbarDidSelectRightButton:(UIButton *)rightButton {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Morsel options"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:@"Preview", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        [UIAlertView showAlertViewWithTitle:@"Delete morsel"
                                    message:@"This will delete your entire morsel and all photos associated with it. Are you sure you want to do this?"
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Preview"]) {
        MRSLUserMorselsFeedViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardUserMorselsFeedViewControllerKey];
        userMorselsFeedVC.morsel = _morsel;
        userMorselsFeedVC.user = _morsel.creator;
        [self.navigationController pushViewController:userMorselsFeedVC
                                             animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        self.morsel = [self getOrLoadMorselIfExists];
        if (_morsel) {
            [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                         properties:@{@"_title": @"Delete morsel",
                                                      @"_view": self.mp_eventView,
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
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Cancel Delete Morsel",
                                                  @"_view": self.mp_eventView,
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
