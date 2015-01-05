//
//  MRSLMorselSearchResultsViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/4/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselSearchResultsViewController.h"

#import "MRSLAPIService+Search.h"

#import "MRSLCollectionView.h"
#import "MRSLMorselDetailViewController.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLCollectionViewDataSource.h"

#import "MRSLMorsel.h"

@interface MRSLMorselSearchResultsViewController ()
<MRSLCollectionViewDataSourceDelegate>

@end

@implementation MRSLMorselSearchResultsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_eventView = @"Search results";
    self.emptyStateString = @"No results";

    __weak __typeof(self) weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.hashtagString) {
            [_appDelegate.apiService searchMorselsWithHashtagQuery:strongSelf.hashtagString
                                                              page:page
                                                             count:nil
                                                           success:^(NSArray *responseArray) {
                                                               remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                           } failure:^(NSError *error) {
                                                               remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                           }];
        } else if (strongSelf.searchString) {
            [_appDelegate.apiService searchMorselsWithQuery:strongSelf.searchString
                                                       page:page
                                                      count:nil
                                                    success:^(NSArray *responseArray) {
                                                        remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                    } failure:^(NSError *error) {
                                                        remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                    }];
        }
    };

    self.title = (_searchString) ? _searchString : (_hashtagString ? [NSString stringWithFormat:@"#%@", _hashtagString] : @"Results");
}

- (NSString *)objectIDsKey {
    NSString *nonWhitespaceSearchString = (self.searchString) ? [self.searchString stringByReplacingOccurrencesOfString:@" " withString:@"_"] : [self.hashtagString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    return [NSString stringWithFormat:@"morsel_%@_IDs_forQuery_%@", (self.searchString) ? @"search" : @"hashtag_search", nonWhitespaceSearchString];
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return [MRSLMorsel MR_fetchAllSortedBy:@"publishedDate"
                                 ascending:NO
                             withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", self.objectIDs]
                                   groupBy:nil
                                  delegate:self];
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
                                                                                         if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
                                                                                             return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                       withReuseIdentifier:MRSLStoryboardRUIDLoadingCellKey
                                                                                                                                              forIndexPath:indexPath];
                                                                                         }
                                                                                         return nil;
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
    MRSLMorsel *morsel = item;
    MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
    userMorselsFeedVC.isExplore = YES;
    userMorselsFeedVC.morsel = morsel;
    userMorselsFeedVC.user = morsel.creator;
    [self.navigationController pushViewController:userMorselsFeedVC
                                         animated:YES];
}

@end
