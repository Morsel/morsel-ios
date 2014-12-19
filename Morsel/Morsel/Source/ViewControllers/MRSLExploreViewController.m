//
//  MRSLExploreViewController.m
//  Morsel
//
//  Created by Javier Otero on 9/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLExploreViewController.h"

#import "MRSLAPIService+Search.h"

#import "MRSLCollectionView.h"
#import "MRSLCollectionViewDataSource.h"
#import "MRSLExploreSearchViewController.h"
#import "MRSLMorselDetailViewController.h"
#import "MRSLMorselPreviewCollectionViewCell.h"
#import "MRSLSearchBarCollectionReusableView.h"

#import "MRSLMorsel.h"

@interface MRSLBaseRemoteDataSourceViewController (Private)

- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView
                               withOffset:(CGFloat)offset;

@end

@interface MRSLExploreViewController ()
<MRSLCollectionViewDataSourceDelegate,
UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *exploreSearchContainerView;

@property (weak, nonatomic) MRSLExploreSearchViewController *exploreSearchVC;

@end

@implementation MRSLExploreViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp_eventView = @"Explore";
    [self.collectionView setEmptyStateTitle:@"Nothing to explore"];

    [self.collectionView registerNib:[UINib nibWithNibName:@"MRSLSearchBarCollectionReusableView"
                                                    bundle:nil]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:MRSLStoryboardRUIDSearchCellKey];

    [self.childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MRSLExploreSearchViewController class]]) {
            self.exploreSearchVC = obj;
        }
    }];
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService searchMorselsWithQuery:nil
                                                   page:page
                                                  count:nil
                                                success:^(NSArray *responseArray) {
                                                    remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                                } failure:^(NSError *error) {
                                                    remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                                }];
    };
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Private Methods

- (NSString *)objectIDsKey {
    return @"explore_morselIDs";
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLMorsel MR_fetchAllSortedBy:@"morselID"
                                  ascending:NO
                              withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", self.objectIDs]
                                    groupBy:nil
                                   delegate:self
                                  inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    MRSLDataSource *newDataSource = [[MRSLCollectionViewDataSource alloc] initWithObjects:nil
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
                                                                           } else if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
                                                                               MRSLSearchBarCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                                                withReuseIdentifier:MRSLStoryboardRUIDSearchCellKey
                                                                                                                                                                       forIndexPath:indexPath];
                                                                               header.searchBar.delegate = self;
                                                                               return header;
                                                                           }
                                                                           return nil;
                                                                       }
                                                                   sectionHeaderSizeBlock:^CGSize(UICollectionView *collectionView, NSInteger section) {
                                                                       return CGSizeMake([collectionView getWidth], 44.f);
                                                                   }
                                                                   sectionFooterSizeBlock:^CGSize(UICollectionView *collectionView, NSInteger section) {
                                                                       return self.loadingMore ? CGSizeMake([collectionView getWidth], 50.f) : CGSizeZero;
                                                                   }
                                                                            cellSizeBlock:^CGSize(UICollectionView *collectionView, NSIndexPath *indexPath) {
                                                                                return [MRSLMorselPreviewCollectionViewCell defaultCellSizeForCollectionView:collectionView
                                                                                                                                                 atIndexPath:indexPath];
                                                                            }
                                                                       sectionInsetConfig:nil];
    [self setDataSource:newDataSource];
    return newDataSource;
}

#pragma mark - MRSLCollectionViewDataSource Delegate

- (void)collectionViewDataSource:(UICollectionView *)collectionView didSelectItem:(id)item {
    MRSLMorsel *morsel = item;
    MRSLMorselDetailViewController *userMorselsFeedVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselDetailViewControllerKey];
    userMorselsFeedVC.isExplore = YES;
    userMorselsFeedVC.morsel = morsel;
    userMorselsFeedVC.user = morsel.creator;
    [self.navigationController pushViewController:userMorselsFeedVC
                                         animated:YES];
}

- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView withOffset:(CGFloat)offset {
    [super collectionViewDataSourceDidScroll:collectionView
                                  withOffset:offset];
    [self.view endEditing:YES];
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.exploreSearchVC.searchQuery = searchText;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [searchBar setShowsCancelButton:NO animated:YES];
        [searchBar resignFirstResponder];
        [self.exploreSearchVC commenceSearch];
        return NO;
    } else {
        return YES;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.view endEditing:YES];
    self.exploreSearchContainerView.hidden = YES;
    self.exploreSearchContainerView.userInteractionEnabled = NO;
    self.collectionView.scrollEnabled = YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.exploreSearchContainerView.hidden = NO;
    self.exploreSearchContainerView.userInteractionEnabled = YES;
    self.collectionView.scrollEnabled = NO;
}

#pragma mark - Notification Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.searchBottomConstraint.constant = keyboardSize.height;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.35f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.searchBottomConstraint.constant = 0.f;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

@end
