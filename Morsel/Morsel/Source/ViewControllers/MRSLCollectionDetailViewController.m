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
#import "MRSLCollectionViewDataSource.h"
#import "MRSLMorselDetailViewController.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLToolbar.h"

#import "MRSLCollection.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLCollectionDetailViewController ()
<MRSLToolbarViewDelegate>

@property (weak, nonatomic) IBOutlet MRSLToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;

@end

@implementation MRSLCollectionDetailViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_eventView = @"collection_detail";
    self.emptyStateString = @"No morsels";

    self.title = self.collection.title;

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
    }
}

#pragma mark - Action Methods

- (IBAction)displayCollectionSelectState:(id)sender {

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
                   didSelectItem:(id)item {
    MRSLMorsel *morsel = item;
    MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
    userMorselsFeedVC.isExplore = YES;
    userMorselsFeedVC.morsel = morsel;
    userMorselsFeedVC.user = morsel.creator;
    [self.navigationController pushViewController:userMorselsFeedVC
                                         animated:YES];
}

#pragma mark - MRSLToolbarViewDelegate

- (void)toolbarDidSelectLeftButton:(UIButton *)leftButton {
#warning Remove selected items from collection
}

- (void)toolbarDidSelectRightButton:(UIButton *)rightButton {
#warning Display action sheet to Edit or Delete collection
}

@end
