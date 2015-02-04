//
//  MRSLPROManageMorselViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import <ELCImagePickerController/ELCAlbumPickerController.h>

#import "MRSLPROManageMorselViewController.h"

#import "MRSLPROItemTableViewCell.h"
#import "MRSLReorderTableView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"

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


@interface MRSLPROManageMorselViewController ()

@property (nonatomic, weak) UITextView *activeTextView;
@property (nonatomic) CGFloat defaultKeyboardHeight;
@property (nonatomic) CGRect defaultViewFrame;
@property (nonatomic, strong) MRSLPROInputAccessoryToolbar *keyboardInputAccessoryToolbar;
@property (nonatomic, strong) MRSLMorsel *morsel;
@property (nonatomic, getter=isReordering) BOOL reordering;
@property (nonatomic, weak) IBOutlet MRSLReorderTableView *tableView;
@property (nonatomic) CGFloat titleCellHeight;
@property (nonatomic, getter=isUpdating) BOOL updating;
@property (nonatomic) int updatingCounter;
@property (nonatomic, strong) MRSLItem *draggingItem;

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic) int previousSortOrder;
@property (strong, nonatomic) NSIndexPath *sourceIndexPath;

@end

@implementation MRSLPROManageMorselViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.morsel = [MRSLMorsel MR_findFirstByAttribute:@"morselID" withValue:@"1427"];
    self.titleCellHeight = MRSLPRODefaultTitleCellHeight;

    [self setupNotificationObservers];

    _updating = NO;
    _updatingCounter = 0;

    self.keyboardInputAccessoryToolbar = [MRSLPROInputAccessoryToolbar defaultInputAccessoryToolbarWithDelegate:self];

    self.objects = [[NSMutableArray alloc] initWithArray:self.morsel.itemsArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.defaultViewFrame = self.view.frame;
}

#pragma mark - Private Methods

- (UITableViewCell *)activeCell {
    return [self findCellForView:self.activeTextView];
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
                                                        otherButtonTitles:@"Photo Library", @"Take Photo", @"Import from Website", nil];
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
    [UIView beginAnimations:nil
                    context:nil];
    if (self.activeTextView != nil) {
        CGRect viewFrame = self.view.frame;
        CGRect activeTextViewFrame = self.activeTextView.frame;
        UIView *activeTextViewSuperview = self.activeTextView.superview;

        viewFrame.size.height -= self.defaultKeyboardHeight + 40.0f;
        CGRect activeTextViewConvertedRect = [self.view convertRect:activeTextViewFrame
                                                  fromView:activeTextViewSuperview];

        if (CGRectContainsRect(viewFrame, activeTextViewConvertedRect)) {
            CGRect butts = [self.tableView convertRect:activeTextViewFrame
                                              fromView:activeTextViewSuperview];
            [self.tableView scrollRectToVisible:CGRectOffset(butts, 0.0f, self.defaultKeyboardHeight + 40.0f)
                                       animated:YES];
        }
    }

    [UIView commitAnimations];
}

- (void)setUpdating:(BOOL)updating {
    _updating = updating;
    self.updatingCounter += updating ? 1 : -1;
    if (self.updatingCounter < 1) {
        if (![self isKeyboardActive]) { [self toggleInterface:YES]; }
        [self toggleInterface:YES];
        self.navigationItem.prompt = [NSString stringWithFormat:@"%@", self.morsel.lastUpdatedDate];
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


#pragma mark - ELCImagePickerControllerDelegate

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    [info enumerateObjectsUsingBlock:^(NSDictionary *imageDictionary, NSUInteger idx, BOOL *stop) {
        if (imageDictionary[UIImagePickerControllerMediaType] == ALAssetTypePhoto) {
            UIImage *image = imageDictionary[UIImagePickerControllerOriginalImage];
            //  TODO: create item w/ image
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
//    let lastSortOrder = morsel?.lastItemSortOrder()
//    apiCreateItem(originalImage!, nil, lastSortOrder! + 1, true)

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}



#pragma mark - MRSLPROExpandableTextTableViewCellDelegate

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
    } else if (indexPath.section == MRSLPROManagerMorselSectionItems) {
        MRSLItem *item = [self itemForIndexPath:indexPath];
        //  TODO: Add cellHeight to Item
//        item.cellHeight = updatedHeight;
    }
}

- (BOOL)tableView:(UITableView *)tableView textViewDidBeginEditing:(UITextView *)textView {
    self.activeTextView = textView;
    //  TODO: Update scroll position
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
    if ([buttonTitle isEqualToString:@"Photo Library"]) {
        //  TODO: mp event
        [self showPhotoLibrary];
    } else if ([buttonTitle isEqualToString:@"Take Photo"]) {
        //  TODO: mp event
        [self showCamera];
    } else if ([buttonTitle isEqualToString:@"Import from Website"]) {
        //  TODO: mp event
        [self showImportFromWebsite];
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

        if ([self isReordering]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"butts"];
            [[cell textLabel] setText:item.itemDescription];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ruid_ItemCell"];
            [cell setText:item.itemDescription];
        }

        if (item == self.draggingItem) {
            [cell setBackgroundColor:[UIColor clearColor]];
        } else {
            [cell setBackgroundColor:[UIColor colorWithWhite:(item.sort_orderValue * 0.1f)
                                                       alpha:0.7f]];
        }
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
        return [self isReordering] ? 250.0f : 500.0f; //  !!!: Change second value to 500 or w/e item cell height is
    } else if (indexPath.section == MRSLPROManagerMorselSectionAddItems) {
        return [self isReordering] ? 0.0f : 80.0f;
    } else {
        return 0.0f;
    }
}

@end
