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

#import "MRSLMediaItemPreviewViewController.h"
#import "MRSLReorderTableView.h"
#import "MRSLToolbar.h"
#import "MRSLMorselEditTitleViewController.h"
#import "MRSLMorselEditItemTableViewCell.h"
#import "MRSLMorselInfoTableViewCell.h"
#import "MRSLMorselTaggedUsersTableViewCell.h"
#import "MRSLMorselPublishShareViewController.h"
#import "MRSLMorselEditPlaceViewController.h"
#import "MRSLMorselEditEligibleUsersViewController.h"
#import "MRSLMorselDetailViewController.h"
#import "MRSLTemplateInfoViewController.h"

#import "MRSLMediaItem.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLPlace.h"
#import "MRSLUser.h"
#import "MRSLTemplate.h"

@interface MRSLMorselEditViewController ()
<NSFetchedResultsControllerDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
MRSLToolbarViewDelegate,
MRSLMorselEditItemTableViewCellDelegate>

@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic) BOOL isEditing;

@property (nonatomic) int previous_sort_order;

@property (nonatomic) NSInteger totalUserCells;
@property (nonatomic) NSInteger totalCells;

@property (weak, nonatomic) IBOutlet MRSLReorderTableView *morselItemsTableView;

@property (strong, nonatomic) UIBarButtonItem *rightBarButton;
@property (strong, nonatomic) NSFetchedResultsController *itemsFetchedResultsController;
@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSIndexPath *sourceIndexPath;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

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
    self.totalUserCells = [[MRSLUser currentUser] isProfessional] ? 3 : 2;
    self.totalCells = _totalUserCells + [_objects count];

    [self.morselItemsTableView setEmptyStateTitle:@"This morsel has no items."];

    [self.morsel downloadCoverPhotoIfNilWithCompletion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self displayMorsel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_selectedIndexPath) {
        [self.morselItemsTableView deselectRowAtIndexPath:_selectedIndexPath
                                                 animated:YES];
        self.selectedIndexPath = nil;
    }
    [self displayMorsel];
}

- (void)viewWillDisappear:(BOOL)animated {
    _itemsFetchedResultsController.delegate = nil;
    _itemsFetchedResultsController = nil;
    [super viewWillDisappear:animated];
}

#pragma mark - Private Methods

- (void)setLoading:(BOOL)loading {
    if (!loading) return;

    _loading = loading;

    [self.morselItemsTableView toggleLoading:loading];
}

- (void)displayMorsel {
    self.morsel = [self getOrLoadMorselIfExists];
    [self showNextButton];
    [self displayMorselStatus];
    if (self.itemsFetchedResultsController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.morselItemsTableView reloadData];
        });
        return;
    }
    self.loading = YES;
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
        MRSLMorselEditTitleViewController *morselEditTitleVC = [segue destinationViewController];
        morselEditTitleVC.morselID = _morsel.morselID;
    } else if ([segue.identifier isEqualToString:MRSLStoryboardSeguePublishShareMorselKey]) {
        MRSLMorselPublishShareViewController *morselPublishVC = [segue destinationViewController];
        morselPublishVC.morsel = _morsel;
    } else if ([segue.identifier isEqualToString:MRSLStoryboardSegueSelectPlaceKey]) {
        MRSLMorselEditPlaceViewController *morselPlaceVC = [segue destinationViewController];
        morselPlaceVC.morsel = _morsel;
    } else if ([segue.identifier isEqualToString:MRSLStoryboardSegueEligibleUsersKey]) {
        MRSLMorselEditEligibleUsersViewController *eligibleUsersVC = [segue destinationViewController];
        eligibleUsersVC.morsel = _morsel;
    }
}

#pragma mark - Action Methods

- (void)displayPublishMorsel {
    self.morsel = [self getOrLoadMorselIfExists];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getMorsel:_morsel
                              orWithID:nil
                               success:^(id responseObject) {
                                   if (weakSelf) {
                                       weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                                       if ([[weakSelf.morsel items] count] == 0) {
                                           [UIAlertView showOKAlertViewWithTitle:@"No photos"
                                                                         message:@"Please add at least one photo to this Morsel to continue."];
                                           return;
                                       }
                                       for (MRSLItem *item in weakSelf.morsel.itemsArray) {
                                           if (item.didFailUploadValue) {
                                               [UIAlertView showOKAlertViewWithTitle:@"Photo upload failed"
                                                                             message:@"A photo failed to upload. Please try again before continuing."];
                                               return;
                                           } else if (item.isUploadingValue || item.photo_processingValue) {
                                               [UIAlertView showOKAlertViewWithTitle:@"Uploading in progress"
                                                                             message:@"Images are still uploading. Please try again shortly."];
                                               return;
                                           } else if (!item.itemPhotoURL) {
                                               [UIAlertView showOKAlertViewWithTitle:@"Missing photos"
                                                                             message:([[weakSelf.morsel items] count] == 1) ? @"Please add a photo to your item in order to continue." : @"All items must have photos in order to continue. Please add photos or delete unused items."];
                                               return;
                                           }
                                       }
                                       if ([weakSelf.morsel hasPlaceholderTitle]) {
                                           [UIAlertView showAlertViewWithTitle:@"Missing title"
                                                                       message:@"You need to give your morsel a title to continue. Would you like to add a title to your morsel now?"
                                                                      delegate:weakSelf
                                                             cancelButtonTitle:@"No"
                                                             otherButtonTitles:@"Yes", nil];
                                           return;
                                       }
                                       [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                                                    properties:@{@"_title": @"Next",
                                                                                 @"_view": weakSelf.mp_eventView,
                                                                                 @"items_count": @([weakSelf.objects count]),
                                                                                 @"morsel_id": NSNullIfNil(weakSelf.morsel.morselID),
                                                                                 @"morsel_draft":(weakSelf.morsel.draftValue) ? @"true" : @"false"}];
                                       [weakSelf performSegueWithIdentifier:MRSLStoryboardSeguePublishShareMorselKey
                                                                     sender:nil];
                                   }
                               } failure:^(NSError *error) {
                                   if (weakSelf) {
                                       weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                                       [UIAlertView showOKAlertViewWithTitle:@"Error uploading"
                                                                     message:@"Please try again."];
                                   }
                               }];
}

#pragma mark - BVReorderTableView Methods

- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_objects objectAtIndex:indexPath.row];
    [_objects replaceObjectAtIndex:indexPath.row
                        withObject:@"REORDER_PLACEHOLDER"];
    if ([object isKindOfClass:[MRSLItem class]]) {
        self.previous_sort_order = [(MRSLItem *)object sort_orderValue];
    }
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

    if (self.previous_sort_order != movedItem.sort_orderValue) {
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
            if (indexPath.row == 0) {
                tableViewCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDMorselInfoCell];
                [[(MRSLMorselInfoTableViewCell *)tableViewCell keyLabel] setText:@"Title"];
                [[(MRSLMorselInfoTableViewCell *)tableViewCell titleLabel] setText:(!_morsel || [_morsel hasPlaceholderTitle]) ? @"Name your morsel" : [_morsel title]];
                [[(MRSLMorselInfoTableViewCell *)tableViewCell titleLabel] setFont:(!_morsel || [_morsel hasPlaceholderTitle]) ? [UIFont robotoLightItalicFontOfSize:14.f] : [UIFont robotoLightFontOfSize:14.f]];
            } else if (indexPath.row == 1 && [[MRSLUser currentUser] isProfessional]) {
                tableViewCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDMorselInfoCell];
                [[(MRSLMorselInfoTableViewCell *)tableViewCell keyLabel] setText:@"Place"];
                [[(MRSLMorselInfoTableViewCell *)tableViewCell titleLabel] setText:[_morsel.place name] ?: @"None / Personal"];
                [[(MRSLMorselInfoTableViewCell *)tableViewCell titleLabel] setFont:(![_morsel.place name]) ? [UIFont robotoLightItalicFontOfSize:14.f] : [UIFont robotoLightFontOfSize:14.f]];
            } else {
                tableViewCell = [tableView dequeueReusableCellWithIdentifier:MRSLStoryboardRUIDMorselTaggedUsersCellKey];
                [(MRSLMorselTaggedUsersTableViewCell *)tableViewCell setMorsel:self.morsel];
            }
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
    self.selectedIndexPath = indexPath;
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
                                            [[MRSLEventManager sharedManager] track:@"Tapped Add Item"
                                                                         properties:@{@"_title": @"Add",
                                                                                      @"_view": NSNullIfNil(weakSelf.mp_eventView),
                                                                                      @"item_count": @([weakSelf.objects count]),
                                                                                      @"morsel_id": NSNullIfNil(weakSelf.morsel.morselID),
                                                                                      @"item_id": NSNullIfNil(item.itemID)}];
                                        }
                                    } failure:nil];
    } else if (indexPath.row < _totalUserCells) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:MRSLStoryboardSegueEditMorselTitleKey
                                      sender:nil];
        } else if (indexPath.row == 1 && [[MRSLUser currentUser] isProfessional]) {
            [self performSegueWithIdentifier:MRSLStoryboardSegueSelectPlaceKey
                                      sender:nil];
        } else {
            [self performSegueWithIdentifier:MRSLStoryboardSegueEligibleUsersKey
                                      sender:nil];
        }
    } else {
        self.item = [_objects objectAtIndex:indexPath.row];
        if (!self.item.itemID) return;
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Item Detail",
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

#pragma mark - MRSLToolbarViewDelegate

- (void)toolbarDidSelectLeftButton:(UIButton *)leftButton {
    self.morsel = [self getOrLoadMorselIfExists];
    MRSLTemplate *currentTemplate = [MRSLTemplate MR_findFirstByAttribute:MRSLTemplateAttributes.templateID
                                                                withValue:_morsel.template_id ?: @(1)];
    if (currentTemplate) {
        UINavigationController *templateInfoNC = [[UIStoryboard templatesStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardTemplateInfoKey];
        MRSLTemplateInfoViewController *templateInfoVC = [templateInfoNC.viewControllers firstObject];
        templateInfoVC.isDisplayingHelp = YES;
        templateInfoVC.morselTemplate = currentTemplate;
        [self presentViewController:templateInfoNC
                           animated:YES
                         completion:nil];
    } else {
        [UIAlertView showAlertViewForErrorString:@"Unable to display help. Please try again."
                                        delegate:nil];
    }
}

- (void)toolbarDidSelectRightButton:(UIButton *)rightButton {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Morsel options"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:nil];
    if ([_morsel.items count] > 0) {
        [actionSheet addButtonWithTitle:@"Preview"];
    }
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
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
        MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
        userMorselsFeedVC.morsel = _morsel;
        userMorselsFeedVC.user = _morsel.creator;
        [self.navigationController pushViewController:userMorselsFeedVC
                                             animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *alertButtonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([alertButtonTitle isEqualToString:@"OK"]) {
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
    } else if ([alertButtonTitle isEqualToString:@"Cancel"]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Delete: Cancel",
                                                  @"_view": self.mp_eventView,
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    } else if ([alertButtonTitle isEqualToString:@"No"]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Add Title: No",
                                                  @"_view": self.mp_eventView,
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID)}];
    } else if ([alertButtonTitle isEqualToString:@"Yes"]) {
        [self performSegueWithIdentifier:MRSLStoryboardSegueEditMorselTitleKey
                                  sender:nil];
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
