//
//  MRSLPROManageMorselViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import <DateTools/NSDate+DateTools.h>
#import <ELCImagePickerController/ELCAlbumPickerController.h>

#import "MRSLAPIService+Morsel.h"

#import "MRSLPROManageMorselViewController.h"

#import "MRSLBadgedBarButtonItem.h"
#import "MRSLPROItemTableViewCell.h"
#import "MRSLReorderTableView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"

static const CGFloat kDefaultItemCellHeight = 400.0f;
static const CGFloat kItemCellBottomPadding = 80.0f;

static NSString * const kPhotoLibrary = @"Photo Library";
static NSString * const kTakePhoto = @"Take Photo";
static NSString * const kImportFromWebsite = @"Import from Website";
static NSString * const kDelete = @"Delete";

NS_ENUM(NSUInteger, MRSLPROManagerMorselSections) {
    MRSLPROManagerMorselSectionTitle = 0,
    MRSLPROManagerMorselSectionItems,
    MRSLPROManagerMorselSectionAddItems,

    MRSLPROManagerMorselSectionsCount,
    MRSLPROManagerMorselSectionsStopArrowNavigationAtSection = MRSLPROManagerMorselSectionAddItems  //  Don't allow navigating to this section and all sections afterwards using the keyboard toolbar arrows
};

@interface BVReorderTableView ()

@property (nonatomic, strong) UIImageView *draggingView;

@end


@interface MRSLPROManageMorselViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) UITextView *activeTextView;
@property (nonatomic) CGFloat defaultKeyboardHeight;
@property (nonatomic) CGRect defaultViewFrame;
@property (nonatomic, strong) MRSLPROInputAccessoryToolbar *keyboardInputAccessoryToolbar;
@property (nonatomic, strong) MRSLMorsel *morsel;
@property (nonatomic, getter=isReordering) BOOL reordering;
@property (nonatomic) CGFloat titleCellHeight;
@property (nonatomic, getter=isUpdating) BOOL updating;
@property (nonatomic) int updatingCounter;
@property (nonatomic, strong) MRSLItem *draggingItem;

@property (strong, nonatomic) NSFetchedResultsController *itemsFetchedResultsController;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic) int previousSortOrder;
@property (strong, nonatomic) NSIndexPath *sourceIndexPath;

@property (nonatomic, strong) NSDictionary *socialSettingsDictionary;

@property (nonatomic, weak) IBOutlet UIToolbar *morselOptionsToolbar;
@property (nonatomic, weak) IBOutlet MRSLBadgedBarButtonItem *taggedUsersBarButton;
@property (nonatomic, weak) IBOutlet MRSLReorderTableView *tableView;

@end

@implementation MRSLPROManageMorselViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.taggedUsersBarButton setToolbar:self.morselOptionsToolbar];

//    self.morsel = [MRSLMorsel MR_findFirstByAttribute:@"morselID" withValue:@"1427"];
    self.morselID = @1427;
    self.titleCellHeight = MRSLPRODefaultTitleCellHeight;

    [self setupNotificationObservers];

    _updating = NO;
    _updatingCounter = 0;

    self.keyboardInputAccessoryToolbar = [MRSLPROInputAccessoryToolbar defaultInputAccessoryToolbarWithDelegate:self];

    self.objects = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.defaultViewFrame = self.view.frame;
    [self updateMorselStatus];
    [self displayMorsel];
}

- (void)configureCell:(UITableViewCell *)cell withObject:(id)object {
    if ([object isKindOfClass:[MRSLItem class]]) {
        MRSLItem *item = (MRSLItem *)object;
        [(id)cell setText:item.itemDescription];

        if (item == self.draggingItem) {
            [cell setBackgroundColor:[UIColor clearColor]];
        } else {
            [cell setBackgroundColor:[UIColor colorWithWhite:(item.sort_orderValue * 0.1f)
                                                       alpha:0.7f]];
        }
    }
}

- (void)displayMorsel {
    self.morsel = [self getOrLoadMorselIfExists];
    if (self.itemsFetchedResultsController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } else {
        self.updating = YES;
        [self setupFetchRequest];
        [self populateContent];
    }
}

- (MRSLMorsel *)getOrLoadMorselIfExists {
    MRSLMorsel *morsel = nil;
    if (_morselID) {
        morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                           withValue:_morselID];
        [morsel.managedObjectContext MR_saveOnlySelfAndWait];
    }
    return morsel;
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

    self.objects = [NSMutableArray arrayWithArray:[_itemsFetchedResultsController fetchedObjects]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        self.updating = NO;
    });
}

- (void)updateMorselStatus {
    self.morsel = [self getOrLoadMorselIfExists];
    if (_morsel) {
        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService getMorsel:_morsel
                                  orWithID:nil
                                   success:^(id responseObject) {
                                       [weakSelf updateTaggedUsersBadge:(weakSelf.morsel.tagged_users_countValue > 0 ? [NSString stringWithFormat:@"%d", weakSelf.morsel.tagged_users_countValue] : nil)];
                                   } failure:nil];
    }
}

- (void)setActiveTextView:(UITextView *)activeTextView {
    _activeTextView = activeTextView;
    [self toggleMorselOptionsToolbarHidden:activeTextView != nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destinationViewController = [segue destinationViewController];
    if ([destinationViewController isKindOfClass:[UINavigationController class]] && [[destinationViewController viewControllers] count] > 0) {
        id firstViewController = [[destinationViewController viewControllers] firstObject];
        if ([firstViewController respondsToSelector:@selector(setMorsel:)]) {
            [firstViewController setMorsel:_morsel];
        }
        if ([firstViewController isKindOfClass:[MRSLMorselPublishShareViewController class]]) {
            [(MRSLMorselPublishShareViewController *)firstViewController setDelegate:self];
        }
    }
}

#pragma mark - Private Methods

- (UITableViewCell *)activeCell {
    return [self findCellForView:self.activeTextView];
}

- (void)deleteMorsel {
    //  TODO: deleteMorsel
    NSLog(@"TODO: deleteMorsel");
}

- (UITableViewCell *)findCellForView:(UIView *)view {
    if (view == nil) {
        return nil;
    } else if ([view isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell *)view;
    } else {
        return [self findCellForView:view.superview];
    }
}

- (void)becomeFirstResponderAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView selectRowAtIndexPath:indexPath
                                animated:NO
                          scrollPosition:UITableViewScrollPositionTop];

    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell && [cell respondsToSelector:@selector(becomeFirstResponderForTextView)]) {
        [cell becomeFirstResponderForTextView];
    }
}

- (void)becomeFirstResponderAtPreviousCell {
    if ([self.tableView numberOfRowsInSection:MRSLPROManagerMorselSectionItems] > 0) {
        [self becomeFirstResponderAtIndexPath:[self indexPathForPreviousCell]];
    }
}

- (void)becomeFirstResponderAtNextCell {
    if ([self.tableView numberOfRowsInSection:MRSLPROManagerMorselSectionItems] > 0) {
        [self becomeFirstResponderAtIndexPath:[self indexPathForNextCell]];
    }
}

- (NSIndexPath *)indexPathForActiveCell {
    UITableViewCell *activeCell = [self activeCell];
    return [self.tableView indexPathForRowAtPoint:activeCell.center];
}

- (NSIndexPath *)indexPathForPreviousCell {
    NSIndexPath *activeCellIndexPath = [self indexPathForActiveCell];
    NSInteger previousCellIndexPathSection = activeCellIndexPath.section;
    NSInteger previousCellIndexPathRow = activeCellIndexPath.row - 1;

    //  previous row loops back
    if (previousCellIndexPathRow < 0) {
        //  jump back a section
        previousCellIndexPathSection--;
        //  check if the section is valid
        if (previousCellIndexPathSection < 0) {
            //  loop back to the last section
            previousCellIndexPathSection = MRSLPROManagerMorselSectionsStopArrowNavigationAtSection - 1;
        }

        //  previous row becomes the last row in the section
        previousCellIndexPathRow = [self.tableView numberOfRowsInSection:previousCellIndexPathSection] - 1;
    }

    return [NSIndexPath indexPathForRow:previousCellIndexPathRow
                              inSection:previousCellIndexPathSection];
}

- (NSIndexPath *)indexPathForNextCell {
    NSIndexPath *activeCellIndexPath = [self indexPathForActiveCell];
    NSInteger nextCellIndexPathSection = activeCellIndexPath.section;
    NSInteger nextCellIndexPathRow = activeCellIndexPath.row + 1;
    NSInteger lastRowInSection = [self.tableView numberOfRowsInSection:nextCellIndexPathSection] - 1;

    //  next row if in the next section
    if (nextCellIndexPathRow > lastRowInSection) {
        //  jump forward a section
        nextCellIndexPathSection++;
        //  check if the section is valid
        if (nextCellIndexPathSection >= MRSLPROManagerMorselSectionsStopArrowNavigationAtSection) {
            //  loop back to the first section
            nextCellIndexPathSection = 0;
        }

        //  next row becomes the first row in the section
        nextCellIndexPathRow = 0;
    }

    return [NSIndexPath indexPathForRow:nextCellIndexPathRow
                              inSection:nextCellIndexPathSection];
}

- (void)toggleInterface:(BOOL)enabled {
    [self.navigationItem.leftBarButtonItem setEnabled:enabled];
    [self.navigationItem.rightBarButtonItem setEnabled:enabled];
}

- (BOOL)isKeyboardActive {
    return self.activeTextView != nil;
}

- (MRSLItem *)itemForIndexPath:(NSIndexPath *)indexPath {
    return self.objects[indexPath.row];
}

- (IBAction)publishUpdate:(id)sender {
    //  TODO: publishUpdateCheck socialSettingsDictionary to handle Instagram and send_to_x flags
    NSLog(@"TODO: publishUpdate");
}

- (void)setupNotificationObservers {
    NSNotificationCenter *defaultNotificationCenter = [NSNotificationCenter defaultCenter];
    [defaultNotificationCenter addObserver:self
                                  selector:@selector(keyboardWillShow:)
                                      name:UIKeyboardWillShowNotification
                                    object:nil];
    [defaultNotificationCenter addObserver:self
                                  selector:@selector(keyboardDidShow:)
                                      name:UIKeyboardDidShowNotification
                                    object:nil];
    [defaultNotificationCenter addObserver:self
                                  selector:@selector(keyboardWillHide:)
                                      name:UIKeyboardWillHideNotification
                                    object:nil];
}

- (void)showAddItemPrompt {
    [self.view endEditing:YES];

    if (self.morsel != nil) {
        //  TODO: mp event
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add a photo"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:kPhotoLibrary, kTakePhoto, kImportFromWebsite, nil];
        [actionSheet showInView:self.view];
    } else {
        //  TODO: show alert about syncing data
    }
}

- (void)showCamera {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;

    [self presentViewController:imagePickerController
                       animated:YES
                     completion:nil];
}

- (void)showImportFromWebsite {
    //  TODO: showImportFromWebsite
    NSLog(@"TODO: showImportFromWebsite");
}

- (void)showPhotoLibrary {
    ELCAlbumPickerController *albumPickerController = [[ELCAlbumPickerController alloc] init];
    ELCImagePickerController *imagePickerController = [[ELCImagePickerController alloc] initWithRootViewController:albumPickerController];
    imagePickerController.maximumImagesCount = 20;
    imagePickerController.returnsOriginalImage = YES;
    imagePickerController.onOrder = YES;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePickerController.imagePickerDelegate = self;
    albumPickerController.parent = imagePickerController;

    [self presentViewController:imagePickerController
                       animated:YES
                     completion:nil];
}

- (void)toggleMorselOptionsToolbarHidden:(BOOL)hidden {
    [self.morselOptionsToolbar setHidden:hidden];
}

- (void)toggleNavBarHidden:(BOOL)hidden {
    [[UIApplication sharedApplication] setStatusBarHidden:hidden
                                            withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:hidden
                                             animated:YES];
}

- (void)toggleReordering:(BOOL)isReordering {
    NSLog(@"\t\tReordering: %d", isReordering);
    self.reordering = isReordering;

    if (isReordering) {
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.7f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGFloat scale = 0.25f;
                             weakSelf.view.frame = CGRectMake(CGRectGetMinX(weakSelf.view.frame), CGRectGetMinY(weakSelf.view.frame), CGRectGetWidth(weakSelf.view.frame), CGRectGetWidth(weakSelf.view.frame) + CGRectGetHeight(weakSelf.view.frame) * 2.0f);

                             CGRect frame = weakSelf.view.frame;
                             CGPoint topCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame));

                             weakSelf.view.layer.anchorPoint = CGPointMake(0.5, 0);
                             weakSelf.view.transform = CGAffineTransformMakeScale(scale, scale);

                             weakSelf.view.layer.position = topCenter;
                             [weakSelf.tableView.draggingView setTransform:CGAffineTransformMakeScale(0.5f, 0.5f)];
                         } completion:^(BOOL finished) {
                             [weakSelf.navigationItem setPrompt:@"Drop to new position."];
                             [weakSelf.tableView setNeedsDisplay];
                         }];
    } else {
        self.view.transform = CGAffineTransformIdentity;
        self.view.frame = self.defaultViewFrame;
        if (self.tableView.draggingView) [self.tableView.draggingView setTransform:CGAffineTransformIdentity];
    }
}

- (void)updateScrollPosition {
    if (self.activeTextView != nil) {
        [UIView beginAnimations:nil
                        context:nil];

        CGRect viewFrame = self.view.frame;
        CGRect activeTextViewFrame = self.activeTextView.frame;
        UIView *activeTextViewSuperview = self.activeTextView.superview;

        CGFloat offset = 20.0f;
        viewFrame.size.height -= self.defaultKeyboardHeight + offset;
        CGRect activeTextViewConvertedRect = [self.view convertRect:activeTextViewFrame
                                                           fromView:activeTextViewSuperview];

        if (!CGRectContainsRect(viewFrame, activeTextViewConvertedRect)) {
            CGRect butts = [self.tableView convertRect:activeTextViewFrame
                                              fromView:activeTextViewSuperview];
            [self.tableView scrollRectToVisible:CGRectOffset(butts, 0.0f, self.defaultKeyboardHeight + offset)
                                       animated:YES];
        }

        [UIView commitAnimations];
    }
}

- (void)updateTaggedUsersBadge:(NSString *)badgeString {
    [self.taggedUsersBarButton setBadgeText:badgeString];
}

- (void)setUpdating:(BOOL)updating {
    _updating = updating;
    self.updatingCounter += updating ? 1 : -1;
    if (self.updatingCounter < 1) {
        if (![self isKeyboardActive]) { [self toggleInterface:YES]; }
        [self toggleInterface:YES];
        self.navigationItem.prompt = [NSString stringWithFormat:@"Updated %@", [[self.morsel.lastUpdatedDate timeAgoSinceNow] lowercaseString]];
    } else {
        self.navigationItem.prompt = @"Updating...";
    }
}


#pragma mark Keyboard Notification Observers

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrameEndRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.defaultKeyboardHeight = keyboardFrameEndRect.size.height;

    [self toggleNavBarHidden:YES];
    [self updateScrollPosition];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    [self updateScrollPosition];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self toggleNavBarHidden:NO];
}


#pragma mark - IBAction

- (IBAction)addItem:(id)sender {
    [self showAddItemPrompt];
}

- (IBAction)showDeleteMorselPrompt:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete this morsel and all \nphotos associated with it?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (IBAction)showSocialSettings:(id)sender {
    [self performSegueWithIdentifier:@"seg_SocialSettings"
                              sender:nil];
}

- (IBAction)showTaggedUsers:(id)sender {
    [self performSegueWithIdentifier:@"seg_TagUsers"
                              sender:nil];
}


#pragma mark - ELCImagePickerControllerDelegate

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    [info enumerateObjectsUsingBlock:^(NSDictionary *imageDictionary, NSUInteger idx, BOOL *stop) {
        if (imageDictionary[UIImagePickerControllerMediaType] == ALAssetTypePhoto) {
            UIImage *image = imageDictionary[UIImagePickerControllerOriginalImage];
            //  TODO: create item w/ image
            NSLog(@"TODO: create item w/ image");
        }
    }];
//    let lastSortOrder = morsel?.lastItemSortOrder()
//    for (index, dict: NSDictionary) in enumerate(info as [NSDictionary]) {
//        if dict[UIImagePickerControllerMediaType] as NSString == ALAssetTypePhoto {
//            let image: UIImage = dict[UIImagePickerControllerOriginalImage] as UIImage
//            apiCreateItem(image, nil, index + lastSortOrder! + 1, index == 0)
//        }
//    }
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    //  TODO: create item w/ image
    NSLog(@"TODO: create item w/ image");
//    let lastSortOrder = morsel?.lastItemSortOrder()
//    apiCreateItem(originalImage!, nil, lastSortOrder! + 1, true)

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}


#pragma mark - MRSLMorselPublishShareViewControllerDelegate

- (void)morselPublishShareViewController:(MRSLMorselPublishShareViewController *)morselPublishShareViewController viewWillDisappearWithSocialSettings:(NSDictionary *)socialSettings {
    self.socialSettingsDictionary = socialSettings;
}


#pragma mark - MRSLPROExpandableTextTableViewCellDelegate

- (void)tableView:(UITableView *)tableview makePrimaryItemAtIndexPath:(NSIndexPath *)indexPath {
    //  TODO: makePrimaryItemAtIndexPath
    NSLog(@"TODO: makePrimaryItemAtIndexPath");
}

- (void)tableView:(UITableView *)tableview updatedText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MRSLPROManagerMorselSectionTitle) {
        [self.morsel setTitle:text];
        // TODO: Save
    } else if (indexPath.section == MRSLPROManagerMorselSectionItems) {
        MRSLItem *item = [self itemForIndexPath:indexPath];
        [item setItemDescription:text];
        // TODO: Save
    }
}

- (void)tableView:(UITableView *)tableview updatedHeight:(CGFloat)updatedHeight atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MRSLPROManagerMorselSectionTitle) {
        self.titleCellHeight = MAX(updatedHeight, MRSLPRODefaultTitleCellHeight);
    }

    [self updateScrollPosition];
}

- (BOOL)tableView:(UITableView *)tableView textViewDidBeginEditing:(UITextView *)textView {
    self.activeTextView = textView;
    [self updateScrollPosition];
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView textViewDidEndEditing:(UITextView *)textView {
    self.activeTextView = nil;
    return YES;
}


#pragma mark - MRSLPROInputAccessoryToolbarDelegate

- (void)inputAccessoryToolbarTappedAddButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar {
    [self showAddItemPrompt];
}

- (void)inputAccessoryToolbarTappedDoneButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar {
    [self.view endEditing:YES];
}

- (void)inputAccessoryToolbarTappedDownButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar {
    [self becomeFirstResponderAtNextCell];
}

- (void)inputAccessoryToolbarTappedUpButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar {
    [self becomeFirstResponderAtPreviousCell];
}


#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell != nil) {
                [self configureCell:cell withObject:anObject];
            }
            } break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];

            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark - BVReorderTableView Methods

- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    [self toggleReordering:YES];
    self.draggingItem = [self.objects objectAtIndex:indexPath.row];
    self.previousSortOrder = [self.draggingItem sort_orderValue];
    return self.draggingItem;
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

//    [[MRSLEventManager sharedManager] track:@"Tapped Button"
//                                 properties:@{@"_title": @"Reordered Morsel",
//                                              @"_view": self.mp_eventView,
//                                              @"item_count": @([_objects count]),
//                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
//                                              @"item_id": NSNullIfNil(movedItem.itemID)}];

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
//
//    if (self.previous_sort_order != movedItem.sort_orderValue) {
//        __weak __typeof(self) weakSelf = self;
//        [_appDelegate.apiService updateItem:movedItem
//                                  andMorsel:nil
//                                    success:^(id responseObject) {
//                                        if (weakSelf) {
//                                            weakSelf.morsel = [weakSelf getOrLoadMorselIfExists];
//                                            weakSelf.morsel.lastUpdatedDate = [NSDate date];
//                                        }
//                                    } failure:nil];
//    }
    self.sourceIndexPath = nil;
    self.draggingItem = nil;

    [self toggleReordering:NO];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kPhotoLibrary]) {
        //  TODO: mp event
        [self showPhotoLibrary];
    } else if ([buttonTitle isEqualToString:kTakePhoto]) {
        //  TODO: mp event
        [self showCamera];
    } else if ([buttonTitle isEqualToString:kImportFromWebsite]) {
        //  TODO: mp event
        [self showImportFromWebsite];
    } else if ([buttonTitle isEqualToString:kDelete]) {
        //  TODO: mp event
        [self deleteMorsel];
    } else {
        //  TODO: mp event for cancel
    }
}


#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = nil;
    if (indexPath.section == MRSLPROManagerMorselSectionTitle) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ruid_TitleCell"];
        [cell setText:self.morsel.title];
    } else if (indexPath.section == MRSLPROManagerMorselSectionItems) {
        MRSLItem *item = self.objects[indexPath.row];

        cell = [tableView dequeueReusableCellWithIdentifier:@"ruid_ItemCell"];
        [self configureCell:cell
                 withObject:item];
    } else if (indexPath.section == MRSLPROManagerMorselSectionAddItems) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ruid_AddItemCell"];
    }

    if ([cell respondsToSelector:@selector(setInputAccessoryView:)]) {
        [cell setInputAccessoryView:self.keyboardInputAccessoryToolbar];
    }

    if ([cell respondsToSelector:@selector(setTableView:)]) {
        [cell setTableView: tableView];
    }

    if ([cell respondsToSelector:@selector(shouldHideEverythingButImage:)]) {
        [cell shouldHideEverythingButImage:[self isReordering]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //  TODO: commitEditingStyle
    NSLog(@"TODO: commitEditingStyle");
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        self.morsel = [self getOrLoadMorselIfExists];
//        MRSLItem *deletedItem = [_objects objectAtIndex:indexPath.row];
//        [[MRSLEventManager sharedManager] track:@"Tapped Button"
//                                     properties:@{@"_title": @"Delete Item",
//                                                  @"_view": self.mp_eventView,
//                                                  @"item_count": @([_objects count]),
//                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
//                                                  @"item_id": NSNullIfNil(deletedItem.itemID)}];
//        [_objects removeObject:deletedItem];
//        self.totalCells --;
//        [_morselItemsTableView deleteRowsAtIndexPaths:@[indexPath]
//                                     withRowAnimation:UITableViewRowAnimationFade];
//
//        __weak __typeof(self) weakSelf = self;
//
//        double delayInSeconds = .4f;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [_appDelegate.apiService deleteItem:deletedItem
//                                        success:^(BOOL success) {
//                                            if (weakSelf) {
//                                                weakSelf.morsel = [weakSelf getOrLoadMorselIfExists];
//                                                weakSelf.morsel.lastUpdatedDate = [NSDate date];
//                                                [weakSelf displayMorselStatus];
//                                            }
//                                        } failure:nil];
//        });
//    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == MRSLPROManagerMorselSectionItems) {
        return [self.objects count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == MRSLPROManagerMorselSectionItems && self.morsel != nil && [self.objects count] > 0) ? @"Items" : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MRSLPROManagerMorselSectionsCount;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MRSLPROManagerMorselSectionTitle) {
        return [self isReordering] ? 0.0f : MAX(self.titleCellHeight, MRSLPRODefaultTitleCellHeight);
    } else if (indexPath.section == MRSLPROManagerMorselSectionItems) {
        if ([self isReordering]) {
            return kDefaultItemCellHeight * 0.5f;
        } else {
            MRSLItem *item = [self itemForIndexPath:indexPath];
            if (item.itemDescription) {
                NSString *text = item.itemDescription;
                CGFloat imageDimension = CGRectGetWidth(tableView.frame);
                UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text
                                                                                       attributes:@{
                                                                                                    NSFontAttributeName: font
                                                                                                    }];
                CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(imageDimension, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                             context:nil];
                return MAX(ceilf(rect.size.height) + imageDimension + kItemCellBottomPadding, kDefaultItemCellHeight);
            } else {
                return kDefaultItemCellHeight;
            }
        }
    } else if (indexPath.section == MRSLPROManagerMorselSectionAddItems) {
        return [self isReordering] ? 0.0f : 140.0f;
    } else {
        return 0.0f;
    }
}

@end
