//
//  MRSLCollectionAddViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/29/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLCollectionAddViewController.h"

#import "MRSLAPIService+Collection.h"

#import "MRSLCollectionCreateViewController.h"
#import "MRSLCollectionViewDataSource.h"
#import "MRSLCollectionPreviewCell.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLStateView.h"
#import "MRSLCollectionView.h"

#import "MRSLCollection.h"
#import "MRSLUser.h"

@interface MRSLCollectionAddViewController ()
<MRSLCollectionViewDataSourceDelegate,
MRSLStateViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;

@end

@implementation MRSLCollectionAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Add to collection";
    self.mp_eventView = @"collection-add";
    self.emptyStateString = @"No collections";
    self.emptyStateButtonString = @"Add a collection";

    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService getCollectionsForUser:[MRSLUser currentUser]
                                                  page:page
                                                 count:count
                                               success:^(NSArray *responseArray) {
                                                   remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                               }
                                               failure:^(NSError *error) {
                                                   remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                               }];
    };
}

#pragma mark - Actions

- (IBAction)addCollection:(id)sender {
#warning Create collection, add morsel immediately, then dismiss!
    MRSLCollectionCreateViewController *collectionCreateVC = [[UIStoryboard collectionsStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCollectionCreateViewControllerKey];
    [self.navigationController pushViewController:collectionCreateVC
                                         animated:YES];
}

#pragma mark - MRSLBaseRemoteDataSourceViewController

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"profile_user_%@_collectionIDs", [MRSLUser currentUser].userID];
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLCollection MR_fetchAllSortedBy:@"collectionID"
                                      ascending:NO
                                  withPredicate:[NSPredicate predicateWithFormat:@"collectionID IN %@", self.objectIDs]
                                        groupBy:nil
                                       delegate:self
                                      inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    __weak __typeof(self)weakSelf = self;
    MRSLDataSource *newDataSource = [[MRSLCollectionViewDataSource alloc] initWithObjects:nil
                                                                                 sections:nil
                                                                       configureCellBlock:^UICollectionViewCell *(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                           MRSLCollectionPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDCollectionCellKey
                                                                                                                                                       forIndexPath:indexPath];
                                                                           cell.collection = item;
                                                                           return cell;
                                                                       }
                                                                       supplementaryBlock:^UICollectionReusableView *(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath) {
                                                                           UICollectionReusableView *reusableView = nil;
                                                                           if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
                                                                               reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                 withReuseIdentifier:MRSLStoryboardRUIDLoadingCellKey
                                                                                                                                        forIndexPath:indexPath];
                                                                           }
                                                                           return reusableView;
                                                                       }
                                                                   sectionHeaderSizeBlock:nil
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
    [collectionView setUserInteractionEnabled:NO];
    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService addMorsel:self.morsel
                          toCollection:(MRSLCollection *)item
                              withNote:nil
                               success:^(id responseObject) {
                                   [weakSelf dismiss];
                               } failure:^(NSError *error) {
                                   [weakSelf.collectionView setUserInteractionEnabled:YES];
                               }];
}

#pragma mark - MRSLStateViewDelegate

- (void)stateView:(MRSLStateView *)stateView
  didSelectButton:(UIButton *)button {
    [self addCollection:button];
}

@end
