//
//  MRSLPROManageMorselViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLPROManageMorselViewController.h"

#import "MRSLPROItemTableViewCell.h"
#import "MRSLReorderTableView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"

//  !!!: TESTING
#define MAX_ROWS 10

NS_ENUM(NSUInteger, MRSLPROManagerMorselSections) {
    MRSLPROManagerMorselSectionTitle = 0,
    MRSLPROManagerMorselSectionItems,
    MRSLPROManagerMorselSectionAddItems,

    MRSLPROManagerMorselSectionsCount
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

//    self.keyboardInputAccessoryToolbar = [MRSLPROInputAccessoryToolbar defaultInputAccessoryToolbarWithDelegate:self];

    self.objects = [[NSMutableArray alloc] initWithArray:self.morsel.itemsArray];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.defaultViewFrame = self.view.frame;
}

#pragma mark - Private Methods

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

- (void)toggleNavBarHidden:(BOOL)hidden {
    [[UIApplication sharedApplication] setStatusBarHidden:hidden
                                            withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:hidden
                                             animated:true];
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


#pragma mark - MRSLPROInputAccessoryToolbarDelegate

- (void)inputAccessoryToolbarTappedDismissKeyboardButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar {
    [self.view endEditing:YES];
}

- (void)inputAccessoryToolbarTappedDownButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar {
    //  TODO: Navigate to next Item
}

- (void)inputAccessoryToolbarTappedUpButtonForToolbar:(MRSLPROInputAccessoryToolbar *)toolbar {
    //  TODO: Navigate to previous Item
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
