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

#import "MRSLCaptureMediaViewController.h"
#import "MRSLImagePreviewViewController.h"
#import "MRSLMorselAddTitleViewController.h"
#import "MRSLMorselEditItemTableViewCell.h"
#import "MRSLMorselEditDescriptionViewController.h"
#import "MRSLMorselPublishViewController.h"

#import "MRSLMediaItem.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"

@interface MRSLMorselEditViewController ()
<NSFetchedResultsControllerDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
CaptureMediaViewControllerDelegate,
MRSLMorselEditItemTableViewCellDelegate>

@property (nonatomic) BOOL shouldShowAddCell;
@property (nonatomic) BOOL wasNewMorsel;

@property (weak, nonatomic) IBOutlet UIButton *morselTitleButton;
@property (weak, nonatomic) IBOutlet UIButton *editItemsButton;
@property (weak, nonatomic) IBOutlet UILabel *morselTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@property (weak, nonatomic) IBOutlet UITableView *morselMorselsTableView;

@property (strong, nonatomic) UIBarButtonItem *nextButton;
@property (strong, nonatomic) NSDateFormatter *statusDateFormatter;
@property (strong, nonatomic) NSFetchedResultsController *itemsFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *items;

@property (weak, nonatomic) MRSLMorsel *morsel;
@property (weak, nonatomic) MRSLItem *item;

@end

@implementation MRSLMorselEditViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldShowAddCell = YES;
    self.items = [NSMutableArray array];
    self.statusDateFormatter = [[NSDateFormatter alloc] init];
    [_statusDateFormatter setDateFormat:@"MMM dd, h:mm a"];

    [self displayMorsel];
    [self updateMorselStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayMorsel];

    if (_shouldPresentMediaCapture) {
        self.wasNewMorsel = YES;
        [self presentMediaCapture];
    }
}

- (void)displayMorsel {
    [self getOrLoadMorselIfExists];

    if (_morsel.draftValue) {
        self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(displayPublishMorsel)];
        [self.navigationItem setRightBarButtonItem:_nextButton];
    }

    self.morselTitleLabel.text = ([_morsel.title length] == 0) ? @"Tap to add title" : _morsel.title;
    [self displayMorselStatus];

    if (!_morselID || self.itemsFetchedResultsController) {
        [self.morselMorselsTableView reloadData];
        return;
    }

    [self setupMorselsFetchRequest];
    [self populateContent];
}

- (void)updateMorselStatus {
    if ([self getOrLoadMorselIfExists]) {
        [_appDelegate.apiService getMorsel:_morsel
                                       success:nil
                                       failure:nil];
    }
}

- (void)displayMorselStatus {
    NSDate *lastUpdated = [_morsel latestUpdatedDate];
    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last saved at %@", (lastUpdated) ? [_statusDateFormatter stringFromDate:lastUpdated] : [_statusDateFormatter stringFromDate:[NSDate date]]];
}

- (void)setupMorselsFetchRequest {
    NSPredicate *morselMorselsPredicate = [NSPredicate predicateWithFormat:@"(morsel.morselID == %i)", [_morselID intValue]];

    self.itemsFetchedResultsController = [MRSLItem MR_fetchAllSortedBy:@"sort_order"
                                                             ascending:YES
                                                         withPredicate:morselMorselsPredicate
                                                               groupBy:nil
                                                              delegate:self
                                                             inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;

    [_itemsFetchedResultsController performFetch:&fetchError];

    if (_itemsFetchedResultsController) {
        [self.items removeAllObjects];
        [self.items addObjectsFromArray:[_itemsFetchedResultsController fetchedObjects]];
    }

    [self.morselMorselsTableView reloadData];

    [self displayMorselStatus];
}

- (void)presentMediaCapture {
    MRSLCaptureMediaViewController *captureMediaVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLCaptureMediaViewController"];
    captureMediaVC.delegate = self;
    [self presentViewController:captureMediaVC
                       animated:YES
                     completion:nil];
}

#pragma mark - Getter Methods

- (MRSLMorsel *)getOrLoadMorselIfExists {
#warning Should test with mutliple item creation to ensure this doesn't cause data loss issues
    if (self.morsel) [self.morsel.managedObjectContext MR_saveOnlySelfAndWait];
    if (_morselID) self.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                           withValue:_morselID];
    return _morsel;
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (_morselMorselsTableView.isEditing) [_morselMorselsTableView setEditing:NO animated:YES];
    if ([segue.identifier isEqualToString:@"seg_EditItemText"]) {
        MRSLMorselEditDescriptionViewController *itemEditTextVC = [segue destinationViewController];
        if (_item.itemID) {
            itemEditTextVC.itemID = _item.itemID;
        } else {
            itemEditTextVC.itemLocalUUID = _item.localUUID;
        }
    } else if ([segue.identifier isEqualToString:@"seg_EditMorselTitle"]) {
        MRSLMorselAddTitleViewController *morselAddTitleVC = [segue destinationViewController];
        morselAddTitleVC.isUserEditingTitle = YES;
        morselAddTitleVC.morselID = _morsel.morselID;
    } else if ([segue.identifier isEqualToString:@"seg_PublishMorsel"]) {
        MRSLMorselPublishViewController *morselPublishVC = [segue destinationViewController];
        morselPublishVC.morsel = _morsel;
    }
}

#pragma mark - Action Methods

- (IBAction)displayMorselSettings:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Morsel"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (IBAction)toggleEditing {
    [[MRSLEventManager sharedManager] track:@"Tapped Edit"
                                 properties:@{@"view": @"Your Morsel",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    [_morselMorselsTableView setEditing:!_morselMorselsTableView.editing
                               animated:YES];
    self.shouldShowAddCell = !_morselMorselsTableView.editing;
    NSIndexPath *addCellIndexPath = [NSIndexPath indexPathForItem:[_items count]
                                                        inSection:0];
    if (addCellIndexPath.row == [_items count]) {
        if (_shouldShowAddCell) [_morselMorselsTableView insertRowsAtIndexPaths:@[addCellIndexPath]
                                                               withRowAnimation:UITableViewRowAnimationFade];
        else [_morselMorselsTableView deleteRowsAtIndexPaths:@[addCellIndexPath]
                                            withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)goBack {
    if (_wasNewMorsel) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)displayPublishMorsel {
    [[MRSLEventManager sharedManager] track:@"Tapped Next"
                                 properties:@{@"view": @"Your Morsel",
                                              @"item_count": @([_items count]),
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"morsel_draft":(_morsel.draftValue) ? @"true" : @"false"}];
    [self performSegueWithIdentifier:@"seg_PublishMorsel"
                              sender:nil];
}

#pragma mark - UITableViewDataSource Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row + 1 != [_items count] + 1);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row + 1 != [_items count] + 1 && [_items count] > 1);
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row + 1 == [_items count] + 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([_items count] + ((_shouldShowAddCell) ? 1 : 0));
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MRSLItem *deletedItem = [_items objectAtIndex:indexPath.row];
        [[MRSLEventManager sharedManager] track:@"Tapped Delete Morsel"
                                     properties:@{@"view": @"Your Morsel",
                                                  @"item_count": @([_items count]),
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(deletedItem.itemID)}];
        [_items removeObject:deletedItem];
        [_morselMorselsTableView deleteRowsAtIndexPaths:@[indexPath]
                                       withRowAnimation:UITableViewRowAnimationFade];

        __weak __typeof(self) weakSelf = self;

        double delayInSeconds = .4f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_appDelegate.apiService deleteItem:deletedItem
                                            success:^(BOOL success) {
                                                if (weakSelf) {
                                                    [weakSelf getOrLoadMorselIfExists].lastUpdatedDate = [NSDate date];
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
                                            [weakSelf getOrLoadMorselIfExists].lastUpdatedDate = [NSDate date];
                                            [weakSelf displayMorselStatus];
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
    if (indexPath.row + 1 > [_items count]) {
        UITableViewCell *addCell = [self.morselMorselsTableView dequeueReusableCellWithIdentifier:@"ruid_ItemAddCell"
                                                                                     forIndexPath:indexPath];
        return addCell;
    }
    MRSLItem *item = [_items objectAtIndex:indexPath.row];

    MRSLMorselEditItemTableViewCell *morselMorselCell = [self.morselMorselsTableView dequeueReusableCellWithIdentifier:@"ruid_MorselItemCell"
                                                                                                          forIndexPath:indexPath];
    morselMorselCell.item = item;
    morselMorselCell.delegate = self;
    return morselMorselCell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (![selectedCell isKindOfClass:[MRSLMorselEditItemTableViewCell class]]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Add New"
                                     properties:@{@"view": @"Your Morsel",
                                                  @"item_count": @([_items count])}];
        [self presentMediaCapture];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - CaptureMediaViewControllerDelegate

- (void)captureMediaViewControllerDidFinishCapturingMediaItems:(NSMutableArray *)capturedMedia {
    self.shouldPresentMediaCapture = NO;
    self.morsel = [self getOrLoadMorselIfExists];
    NSArray *mediaToImport = [capturedMedia copy];
    __weak __typeof(self) weakSelf = self;
    DDLogDebug(@"Received %lu Media Items. Should now create Morsels for each!", (unsigned long)[capturedMedia count]);
    [mediaToImport enumerateObjectsUsingBlock:^(MRSLMediaItem *mediaItem, NSUInteger idx, BOOL *stop) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSUInteger itemIndex = (idx + 1);
            if ([strongSelf.items count] > 0) {
                MRSLItem *lastMorsel = [strongSelf.items lastObject];
                itemIndex = (lastMorsel.sort_orderValue + (idx + 1));
            }
            DDLogDebug(@"Item INDEX: %lu", (unsigned long)itemIndex);

            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                               withValue:strongSelf.morsel.morselID
                                                               inContext:localContext];
                MRSLItem *item = [MRSLItem localUniqueItemInContext:localContext];
                item.sort_order = @(itemIndex);
                item.itemPhotoFull = UIImageJPEGRepresentation(mediaItem.mediaFullImage, 1.f);
                item.itemPhotoCropped = UIImageJPEGRepresentation(mediaItem.mediaCroppedImage, .8f);
                item.itemPhotoThumb = UIImageJPEGRepresentation(mediaItem.mediaThumbImage, .8f);
                item.isUploading = @YES;
                item.morsel = morsel;
                [morsel addItemsObject:item];
                [_appDelegate.apiService createItem:item
                                                success:^(id responseObject) {
                                                    if ([responseObject isKindOfClass:[MRSLItem class]]) {
                                                        MRSLItem *itemToUploadWithImage = (MRSLItem *)responseObject;
                                                        [strongSelf getOrLoadMorselIfExists].lastUpdatedDate = [NSDate date];
                                                        [strongSelf displayMorselStatus];
                                                        [_appDelegate.apiService updateItemImage:itemToUploadWithImage
                                                                                             success:nil
                                                                                             failure:nil];
                                                    }
                                                } failure:nil];
            }];
        }
    }];
}

- (void)captureMediaViewControllerDidCancel {
    if (_shouldPresentMediaCapture) [self goBack];
}

#pragma mark - MRSLMorselEditMorselCollectionViewCellDelegate

- (void)morselEditItemCellDidSelectEditText:(MRSLItem *)item {
    self.item = item;
    [[MRSLEventManager sharedManager] track:@"Tapped Add Description"
                                 properties:@{@"view": @"Your Morsel",
                                              @"item_count": @([_items count]),
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"item_id": NSNullIfNil(item.itemID)}];
    [self performSegueWithIdentifier:@"seg_EditItemText"
                              sender:nil];
}

- (void)morselEditItemCellDidSelectImagePreview:(MRSLItem *)item {
    [[MRSLEventManager sharedManager] track:@"Tapped Thumbnail"
                                 properties:@{@"view": @"Your Morsel",
                                              @"item_count": @([_items count]),
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"item_id": NSNullIfNil(item.itemID)}];
    NSUInteger index = [_items indexOfObject:item];

    MRSLImagePreviewViewController *imagePreviewVC = [[UIStoryboard mediaManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLImagePreviewViewController"];
    [imagePreviewVC setPreviewMedia:_items andStartingIndex:index];

    [self presentViewController:imagePreviewVC
                       animated:YES
                     completion:nil];
}

- (void)morselEditItemCellDidTransitionToDeleteState:(BOOL)deleteStateActive {
    _editItemsButton.hidden = deleteStateActive;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Morsel"]) {
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
}

@end
