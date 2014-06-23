//
//  MRSLProfileEditViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/22/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileEditViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "MRSLCollectionViewArraySectionsDataSource.h"
#import "MRSLKeywordUsersViewController.h"
#import "MRSLPlaceViewController.h"
#import "MRSLPlacesAddViewController.h"
#import "MRSLProfileCredentialsViewController.h"
#import "MRSLProfileEditFieldsViewController.h"
#import "MRSLProfileEditPlacesViewController.h"
#import "MRSLProfileUserTagsListViewController.h"
#import "MRSLSocialConnectionsTableViewController.h"
#import "MRSLUserTagEditViewController.h"

#import "MRSLContainerCollectionViewCell.h"
#import "MRSLSectionHeaderReusableView.h"

#import "MRSLTag.h"
#import "MRSLUser.h"

@interface MRSLProfileEditViewController ()
<MRSLProfileEditPlacesViewControllerDelegate,
MRSLProfileUserTagsListViewControllerDelegate>

@property (nonatomic) CGFloat scrollViewContentHeight;

@property (strong, nonatomic) NSArray *editSections;
@property (strong, nonatomic) NSString *keywordType;

@property (strong, nonatomic) MRSLCollectionViewArrayDataSource *collectionViewDataSource;

@property (strong, nonatomic) MRSLProfileEditFieldsViewController *profileEditFieldsVC;
@property (strong, nonatomic) MRSLProfileEditPlacesViewController *profileEditPlacesVC;
@property (strong, nonatomic) MRSLSocialConnectionsTableViewController *profileEditSocialVC;
@property (strong, nonatomic) MRSLProfileUserTagsListViewController *profileEditTagsVC;
@property (strong, nonatomic) MRSLProfileCredentialsViewController *profileEditSecurityVC;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MRSLProfileEditViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    if ([[MRSLUser currentUser] isProfessional]) {
        self.editSections = @[@"Basics", @"Places", @"Social", @"Tags", @"Security"];
    } else {
        self.editSections = @[@"Basics", @"Social", @"Security"];
    }
    __weak __typeof(self) weakSelf = self;
    self.collectionViewDataSource = [[MRSLCollectionViewArraySectionsDataSource alloc] initWithObjects:@[[NSNull null]]
                                                                                              sections:_editSections
                                                                                    configureCellBlock:^UICollectionViewCell *(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                        return [weakSelf configureCellForCollectionView:collectionView
                                                                                                                              indexPath:indexPath];
                                                                                    } supplementaryBlock:^UICollectionReusableView *(UICollectionView *collectionView, NSString *kind, NSIndexPath *indexPath) {
                                                                                        MRSLSectionHeaderReusableView *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                                                                                          withReuseIdentifier:@"ruid_SectionHeader"
                                                                                                                                                                                 forIndexPath:indexPath];
                                                                                        sectionHeader.titleLabel.text = [weakSelf.editSections objectAtIndex:[indexPath section]];
                                                                                        return sectionHeader;
                                                                                    } sectionSizeBlock:^CGSize(UICollectionView *collectionView, NSInteger section) {
                                                                                        return CGSizeMake(320.f, 44.f);
                                                                                    } cellSizeBlock:^CGSize(UICollectionView *collectionView, NSIndexPath *indexPath) {
                                                                                        return [weakSelf configureCellSizeForCollectionView:collectionView
                                                                                                                                  indexPath:indexPath];
                                                                                    }];
    [self.collectionView setDataSource:_collectionViewDataSource];
    [self.collectionView setDelegate:_collectionViewDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_profileEditPlacesVC) [self.profileEditPlacesVC refreshContent];
    if (_profileEditTagsVC) [self.profileEditTagsVC refreshContent];
}

#pragma mark - Private Methods

- (UICollectionViewCell *)configureCellForCollectionView:(UICollectionView *)collectionView
                                               indexPath:(NSIndexPath *)indexPath {
    MRSLContainerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ruid_ContainerCell"
                                                                                      forIndexPath:indexPath];
    UIViewController *viewController = nil;
    NSString *sectionName = [_editSections objectAtIndex:[indexPath section]];

    if ([sectionName isEqualToString:@"Basics"]) {
        if (!_profileEditFieldsVC) {
            self.profileEditFieldsVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileEditFieldsViewController"];
            _profileEditFieldsVC.containingView = self.view;
            [self addChildViewController:_profileEditFieldsVC];
        }
        viewController = _profileEditFieldsVC;
    } else if ([sectionName isEqualToString:@"Places"]) {
        if (!_profileEditPlacesVC) {
            self.profileEditPlacesVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileEditPlacesViewController"];
            self.profileEditPlacesVC.delegate = self;
            [self addChildViewController:_profileEditPlacesVC];
        }
        viewController = _profileEditPlacesVC;
    } else if ([sectionName isEqualToString:@"Social"]) {
        if (!_profileEditSocialVC) {
            self.profileEditSocialVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLSocialConnectionsTableViewController"];
            [self addChildViewController:_profileEditSocialVC];
        }
        viewController = _profileEditSocialVC;
    } else if ([sectionName isEqualToString:@"Tags"]) {
        if (!_profileEditTagsVC) {
            self.profileEditTagsVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileStatsTagsViewController"];
            _profileEditTagsVC.allowsEdit = YES;
            _profileEditTagsVC.user = [MRSLUser currentUser];
            _profileEditTagsVC.delegate = self;
            [self addChildViewController:_profileEditTagsVC];
        }
        [_profileEditTagsVC.view setHeight:500.f];
        viewController = _profileEditTagsVC;
    } else if ([sectionName isEqualToString:@"Security"]) {
        if (!_profileEditSecurityVC) {
            self.profileEditSecurityVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLProfileCredentialsViewController"];
            [self addChildViewController:_profileEditSecurityVC];
        }
        viewController = _profileEditSecurityVC;
    }

    [cell addViewController:viewController];

    return cell;
}

- (CGSize)configureCellSizeForCollectionView:(UICollectionView *)collectionView
                                   indexPath:(NSIndexPath *)indexPath {
    NSString *sectionName = [_editSections objectAtIndex:[indexPath section]];
    CGSize cellSize = CGSizeMake(320.f, 214.f);
    if ([sectionName isEqualToString:@"Basics"]) {
        cellSize.height = 360.f;
    } else if ([sectionName isEqualToString:@"Places"]) {
        cellSize.height = 200.f;
    } else if ([sectionName isEqualToString:@"Social"]) {
        cellSize.height = 200.f;
    } else if ([sectionName isEqualToString:@"Tags"]) {
        cellSize.height = 500.f;
    } else if ([sectionName isEqualToString:@"Security"]) {
        cellSize.height = 460.f;
    }
    return cellSize;
}

#pragma mark - Action Methods

- (IBAction)done {
    __weak __typeof(self) weakSelf = self;
    [self.profileEditFieldsVC updateProfileWithCompletion:^(BOOL success) {
        [weakSelf goBack];
    } failure:nil];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seg_EditKeywords"]) {
        MRSLUserTagEditViewController *userTagEditVC = [segue destinationViewController];
        userTagEditVC.keywordType = _keywordType;
    }
}

#pragma mark - Notification Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.collectionView setHeight:[self.view getHeight] - keyboardSize.height];
                     }];
}

- (void)keyboardWillHide {
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.collectionView setHeight:[self.view getHeight]];
                     }];
}

#pragma mark - MRSLProfileEditPlacesViewControllerDelegate

- (void)profileEditPlacesDidSelectPlace:(MRSLPlace *)place {
    MRSLPlaceViewController *placeVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLPlaceViewController"];
    placeVC.place = place;
    [self.navigationController pushViewController:placeVC
                                         animated:YES];
}

- (void)profileEditPlacesDidSelectAddNew {
    MRSLPlacesAddViewController *placesAddVC = [[UIStoryboard placesStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLPlacesAddViewController"];
    [self.navigationController pushViewController:placesAddVC
                                         animated:YES];
}

#pragma mark - MRSLProfileStatsKeywordsViewControllerDelegate

- (void)profileUserTagsListViewControllerDidSelectTag:(MRSLTag *)tag {
    MRSLKeywordUsersViewController *keywordUsersVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLKeywordUsersViewController"];
    keywordUsersVC.keyword = tag.keyword;
    [self.navigationController pushViewController:keywordUsersVC
                                         animated:YES];
}

- (void)profileUserTagsListViewControllerDidSelectType:(NSString *)type {
    self.keywordType = type;
    [self performSegueWithIdentifier:@"seg_EditKeywords"
                              sender:nil];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
}

@end
