//
//  MRSLCollectionDetailViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLCollectionDetailViewController.h"

#import "MRSLAPIService+Collection.h"

#import "MRSLCollectionDescriptionReusableView.h"
#import "MRSLCollectionView.h"
#import "MRSLCollectionViewDataSource.h"
#import "MRSLCollectionCreateViewController.h"
#import "MRSLMorselDetailViewController.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLToolbar.h"

#import "MRSLCollection.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLCollectionDetailViewController ()
<UIActionSheetDelegate,
MRSLToolbarViewDelegate>

@property (nonatomic, getter=isEditing) BOOL editing;

@property (weak, nonatomic) IBOutlet MRSLToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;

@property (strong, nonatomic) NSMutableArray *checkedIndexPaths;

@end

@implementation MRSLCollectionDetailViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_eventView = @"collection_detail";
    self.emptyStateString = @"No morsels";

    self.checkedIndexPaths = [NSMutableArray array];

    __weak __typeof(self) weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [_appDelegate.apiService getMorselsForCollection:strongSelf.collection
                                                    page:page
                                                   count:nil
                                                 success:^(NSArray *responseArray) {
                                                     remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                 }
                                                 failure:^(NSError *error) {
                                                     remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                 }];
    };

    if (![self.collection.creator isCurrentUser]) {
        self.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.toolbarHeightConstraint.constant = 0.f;
        [self.view needsUpdateConstraints];
    } else {
        [self determineSelectStatus];
    }

    self.toolbar.leftButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.title = self.collection.title;
    self.view.accessibilityLabel = self.collection.title;
}

- (void)determineSelectStatus {
    if ([self.collection.morsels count] == 0) {
        self.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Action Methods

- (IBAction)displayCollectionSelectState:(id)sender {
    [self setEditing:!self.isEditing];
}

- (void)setEditing:(BOOL)editing {
    _editing = editing;
    self.toolbar.leftButton.hidden = ![self isEditing];
    [self.rightBarButtonItem setTitle:([self isEditing]) ? @"Cancel" : @"Select"];
    [self.collectionView reloadData];
    if (![self isEditing]) {
        [self.checkedIndexPaths removeAllObjects];
    }
    [self determineSelectStatus];
}

- (BOOL)containsCheckedIndexPath:(NSIndexPath *)indexPath {
    return [self.checkedIndexPaths containsObject:indexPath];
}

- (void)addCheckedIndexPath:(NSIndexPath *)indexPath {
    if ([self containsCheckedIndexPath:indexPath]) {
        [self.checkedIndexPaths removeObject:indexPath];
    } else {
        [self.checkedIndexPaths addObject:indexPath];
    }
    self.toolbar.leftButton.enabled = ([self.checkedIndexPaths count] > 0);
}

#pragma mark - MRSLBaseRemoteDataSourceViewController Methods

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"collection_%i_morselIDs", self.collection.collectionIDValue];
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLMorsel MR_fetchAllSortedBy:@"sort_order"
                                  ascending:NO
                              withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", self.objectIDs]
                                    groupBy:nil
                                   delegate:self
                                  inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLCollectionViewDataSource *superDataSource = (MRSLCollectionViewDataSource *)[super dataSource];
    if (superDataSource) return superDataSource;
    __weak __typeof(self)weakSelf = self;
    MRSLCollectionViewDataSource *newDataSource = [[MRSLCollectionViewDataSource alloc] initWithObjects:nil
                                                                                               sections:nil
                                                                                     configureCellBlock:^UICollectionViewCell *(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                         MRSLMorsel *morsel = item;
                                                                                         MRSLMorselPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDMorselPreviewCellKey
                                                                                                                                                                               forIndexPath:indexPath];
                                                                                         cell.editing = weakSelf.isEditing;
                                                                                         cell.checked = [self containsCheckedIndexPath:indexPath];
                                                                                         cell.morsel = morsel;
                                                                                         return cell;
                                                                                     }
                                                                                     supplementaryBlock:^UICollectionReusableView *(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath) {
                                                                                         UICollectionReusableView *reusableView = nil;
                                                                                         if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
                                                                                             reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                               withReuseIdentifier:MRSLStoryboardRUIDLoadingCellKey
                                                                                                                                                      forIndexPath:indexPath];
                                                                                         } else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
                                                                                             reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                               withReuseIdentifier:MRSLStoryboardRUIDCollectionDescriptionCellKey
                                                                                                                                                      forIndexPath:indexPath];
                                                                                             [[(MRSLCollectionDescriptionReusableView *)reusableView descriptionLabel] setText:weakSelf.collection.collectionDescription];
                                                                                         }
                                                                                         return reusableView;
                                                                                     }
                                                                                 sectionHeaderSizeBlock:^CGSize(UICollectionView *collectionView, NSInteger section) {
                                                                                     return ([weakSelf.collection.collectionDescription length] > 0) ? CGSizeMake([collectionView getWidth], [weakSelf.collection descriptionHeight]) : CGSizeZero;
                                                                                 }
                                                                                 sectionFooterSizeBlock:^CGSize(UICollectionView *collectionView, NSInteger section) {
                                                                                     return weakSelf.loadingMore ? CGSizeMake([collectionView getWidth], 50.f) : CGSizeZero;
                                                                                 }
                                                                                          cellSizeBlock:^CGSize(UICollectionView *collectionView, NSIndexPath *indexPath) {
                                                                                              return [MRSLMorselPreviewCollectionViewCell defaultCellSizeForCollectionView:collectionView
                                                                                                                                                               atIndexPath:indexPath];
                                                                                          }
                                                                                     sectionInsetConfig:nil];
    [self setDataSource:newDataSource];
    return newDataSource;
}

#pragma mark - MRSLCollectionViewDataSourceDelegate

- (void)collectionViewDataSource:(UICollectionView *)collectionView
        didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isEditing) {
        MRSLMorselPreviewCollectionViewCell *morselPreviewCell = (MRSLMorselPreviewCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        morselPreviewCell.selected = !morselPreviewCell.selected;
        [self addCheckedIndexPath:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } else {
        MRSLMorsel *morsel = [self.dataSource objectAtIndexPath:indexPath];
        MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
        userMorselsFeedVC.isExplore = YES;
        userMorselsFeedVC.morsel = morsel;
        userMorselsFeedVC.user = morsel.creator;
        [self.navigationController pushViewController:userMorselsFeedVC
                                             animated:YES];
    }
}

#pragma mark - MRSLToolbarViewDelegate

- (void)toolbarDidSelectLeftButton:(UIButton *)leftButton {
    if ([self.checkedIndexPaths count] > 0) {
        [self.checkedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            MRSLMorsel *morsel = [self.dataSource objectAtIndexPath:indexPath];
            if (morsel) {
                [_appDelegate.apiService removeMorsel:morsel
                                       fromCollection:self.collection
                                              success:nil
                                              failure:nil];
            }
            if (idx == [self.checkedIndexPaths count] - 1) {
                *stop = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self setEditing:NO];
                    [self refreshRemoteContent];
                });
            }
        }];
    }
}

- (void)toolbarDidSelectRightButton:(UIButton *)rightButton {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Collection options"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:@"Edit"];
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit"]) {
        MRSLCollectionCreateViewController *collectionCreateVC = [[UIStoryboard collectionsStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCollectionCreateViewControllerKey];
        collectionCreateVC.collection = self.collection;
        [self.navigationController pushViewController:collectionCreateVC
                                             animated:YES];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        __weak __typeof(self) weakSelf = self;
        [self.toolbar.rightButton setEnabled:NO];
        [_appDelegate.apiService deleteCollection:self.collection
                                          success:^(BOOL success) {
                                              [weakSelf goBack];
                                          } failure:^(NSError *error) {
                                              [UIAlertView showAlertViewForErrorString:@"Unable to delete collection. Please try again."
                                                                              delegate:nil];
                                              [weakSelf.toolbar.rightButton setEnabled:YES];
                                          }];
    }
}

@end
