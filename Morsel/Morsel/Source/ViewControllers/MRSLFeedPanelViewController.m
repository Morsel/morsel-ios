//
//  MRSLFeedPanelCollectionViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLFeedPanelViewController.h"

#import "MRSLAPIService+Morsel.h"

#import "MRSLFeedCoverCollectionViewCell.h"
#import "MRSLFeedPageCollectionViewCell.h"
#import "MRSLFeedShareCollectionViewCell.h"
#import "MRSLSocialService.h"
#import "MRSLModalCommentsViewController.h"
#import "MRSLModalLikersViewController.h"
#import "MRSLModalShareViewController.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLProfileImageView.h"
#import "MRSLTitleItemView.h"
#import "MRSLItemImageView.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLFeedPanelViewController ()
<UIActionSheetDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
MRSLFeedShareCollectionViewCellDelegate>

@property (nonatomic) BOOL isPresentingMorselLayout;
@property (nonatomic) BOOL isDraggingScrollViewUp;
@property (nonatomic) BOOL isViewingCover;
@property (nonatomic) BOOL isViewingItem;

@property (nonatomic) CGFloat previousContentOffset;

@property (nonatomic) MRSLScrollDirection scrollDirection;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet MRSLItemImageView *coverImageView;

@end

@implementation MRSLFeedPanelViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isViewingCover = YES;
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    self.coverImageView.shouldBlur = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContent:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
    [self.collectionView setScrollsToTop:YES];
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        [self displayContent];
    }
}

#pragma mark - Notification Methods

- (void)updateContent:(NSNotification *)notification {
    if (![self isViewLoaded]) return;
    NSDictionary *userInfoDictionary = [notification userInfo];
    NSSet *updatedObjects = [userInfoDictionary objectForKey:NSUpdatedObjectsKey];

    __weak __typeof(self) weakSelf = self;
    [updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject *managedObject, BOOL *stop) {
        if (weakSelf) {
            if ([managedObject isKindOfClass:[MRSLMorsel class]]) {
                MRSLMorsel *morsel = (MRSLMorsel *)managedObject;
                if (morsel.morselIDValue == weakSelf.morsel.morselIDValue &&
                    [weakSelf.morsel.items count] != [morsel.items count]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf displayContent];
                    });
                    *stop = YES;
                }
            }
        }
    }];
}

#pragma mark - Private Methods

- (void)displayContent {
    if (_collectionView && _morsel) {
        self.coverImageView.item = [_morsel coverItem];
        [self.collectionView reloadData];
        [self resetCollectionViewContentOffset:NO];
    }
}

- (void)resetCollectionViewContentOffset:(BOOL)animated {
    [self.collectionView setContentOffset:CGPointMake(0.f, 0.f)
                                 animated:animated];
}

- (MRSLItem *)visibleItem {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    MRSLItem *visibleItem = [_morsel coverItem];
    if (indexPath.row - 1 >= 0 && indexPath.row - 1 < [_morsel.items count]) {
        visibleItem = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
    }
    return visibleItem;
}

- (void)displayTitleForCurrentPage:(CGFloat)currentPage {
    if (![self.navigationController.navigationBar.topItem.titleView isKindOfClass:[MRSLTitleItemView class]]) return;
    if (currentPage > 0 && currentPage < [_morsel.items count] + 1 && _isViewingCover) {
        self.isViewingCover = NO;
        self.isViewingItem = YES;
        [(MRSLTitleItemView *)self.navigationController.navigationBar.topItem.titleView setTitle:_morsel.title];
    }
    if ((currentPage == 0 || currentPage == [_morsel.items count] + 1) && _isViewingItem) {
        self.isViewingItem = NO;
        self.isViewingCover = YES;
        [(MRSLTitleItemView *)self.navigationController.navigationBar.topItem.titleView setTitle:nil];
    }
}

#pragma mark - Action Methods

- (IBAction)displayComments {
    MRSLItem *visibleItem = [self visibleItem];
    [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                 properties:@{@"_title": @"Comments",
                                              @"_view": @"feed",
                                              @"morsel_id": NSNullIfNil(_morsel.morselID),
                                              @"item_id": NSNullIfNil(visibleItem.itemID),
                                              @"comment_count": NSNullIfNil(visibleItem.comment_count)}];
    UINavigationController *commentNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCommentsKey];
    MRSLModalCommentsViewController *modalCommentsVC = [[commentNC viewControllers] firstObject];
    modalCommentsVC.item = visibleItem;
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                        object:commentNC];
}

- (IBAction)displayLikers {
    __block BOOL alreadyDisplayed = NO;
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *childVC, NSUInteger idx, BOOL *stop) {
        if ([childVC isKindOfClass:[MRSLModalLikersViewController class]]) {
            alreadyDisplayed = YES;
            *stop = YES;
        }
    }];
    if (!alreadyDisplayed) {
        MRSLItem *visibleItem = [self visibleItem];
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Likes",
                                                  @"_view": @"feed",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(visibleItem.itemID),
                                                  @"like_count": NSNullIfNil(visibleItem.like_count)}];
        UINavigationController *likesNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardLikesKey];
        MRSLModalLikersViewController *modalLikersVC = [[likesNC viewControllers] firstObject];
        modalLikersVC.morsel = self.morsel;
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                            object:likesNC];
    }
}

- (IBAction)displayShare {
    __block BOOL alreadyDisplayed = NO;
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *childVC, NSUInteger idx, BOOL *stop) {
        if ([childVC isKindOfClass:[MRSLModalShareViewController class]]) {
            alreadyDisplayed = YES;
            *stop = YES;
        }
    }];
    if (!alreadyDisplayed) {
        MRSLItem *visibleItem = [self visibleItem];
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Share Morsel",
                                                  @"_view": @"feed",
                                                  @"morsel_id": NSNullIfNil(_morsel.morselID),
                                                  @"item_id": NSNullIfNil(visibleItem.itemID)}];
        MRSLModalShareViewController *modalShareVC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardModalShareViewControllerKey];
        [modalShareVC.view setWidth:[self.view getWidth]];
        [modalShareVC.view setHeight:[self.view getHeight]];
        modalShareVC.item = visibleItem;
        [self addChildViewController:modalShareVC];
        [self.view addSubview:modalShareVC.view];
    }
}


- (IBAction)editMorsel {
    UINavigationController *morselEditNC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselEditKey];
    MRSLMorselEditViewController *morselEditVC = [[morselEditNC viewControllers] firstObject];
    morselEditVC.morselID = _morsel.morselID;
    [self presentViewController:morselEditNC
                       animated:YES
                     completion:nil];
}

- (IBAction)reportContent {
    if ([MRSLUser isCurrentUserGuest]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayLandingNotification
                                                            object:nil];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:@"Report inappropriate"
                                                    otherButtonTitles:nil];

    if (self.morsel.taggedValue) {
        [actionSheet addButtonWithTitle:@"Remove tag"];
    }

    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:@"Cancel"]];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return !_morsel ? 0 : ([_morsel.items count] + (_morsel.publishedDate ? 2 : 1));
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.row == 0) {
        MRSLFeedCoverCollectionViewCell *morselCoverCell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDFeedCoverCellKey
                                                                                                     forIndexPath:indexPath];
        morselCoverCell.morsel = _morsel;
        morselCoverCell.homeFeedItem = [[self parentViewController] isKindOfClass:NSClassFromString(@"MRSLFeedViewController")];
        cell = morselCoverCell;
    } else if (indexPath.row == [_morsel.items count] + 1) {
        MRSLFeedShareCollectionViewCell *shareCell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDFeedShareCellKey
                                                                                               forIndexPath:indexPath];
        shareCell.nextMorsel = _nextMorsel;
        shareCell.morsel = _morsel;
        shareCell.delegate = self;
        cell = shareCell;
    } else {
        MRSLFeedPageCollectionViewCell *morselPageCell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDFeedPageCellKey
                                                                                                   forIndexPath:indexPath];
        morselPageCell.item = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
        cell = morselPageCell;
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0.f;
    if (indexPath.row == 0) {
        // Estimate height for cover
        CGFloat coverElementsHeight = MAX(150.f, floorf([UIScreen mainScreen].bounds.size.height * .3)) + 30.f;
        cellHeight = coverElementsHeight + [self.morsel coverInformationHeight];
    } else if (indexPath.row == [_morsel.items count] + 1) {
        // Estimate height for share page
        CGFloat shareElementsHeight = 200.f;
        cellHeight = shareElementsHeight + [self.morsel.creator profileInformationHeight];
    } else {
        // Estimate height for item page
        MRSLItem *item = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
        CGFloat pageElementsHeight = [UIScreen mainScreen].bounds.size.width + 64.f;
        cellHeight = pageElementsHeight + [item descriptionHeight];
    }
    return CGSizeMake([collectionView getWidth], cellHeight);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentPage = scrollView.contentOffset.y / scrollView.frame.size.height;
    if (_previousContentOffset > scrollView.contentOffset.y) {
        self.scrollDirection = MRSLScrollDirectionDown;
    } else if (_previousContentOffset < scrollView.contentOffset.y) {
        self.scrollDirection = MRSLScrollDirectionUp;
    }
    [self displayTitleForCurrentPage:currentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [[_collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath && indexPath.row - 1 < [_morsel.items count]) {
        MRSLItem *visibleItem = nil;
        if (_isPresentingMorselLayout && indexPath.row != 0) {
            visibleItem = [_morsel.itemsArray objectAtIndex:indexPath.row - 1];
        } else {
            visibleItem = [_morsel coverItem];
        }
        [[MRSLEventManager sharedManager] registerItem:visibleItem];
    }
}

#pragma mark - MRSLFeedShareCollectionViewCellDelegate

- (void)feedShareCollectionViewCellDidSelectShareFacebook {
    [[MRSLSocialService sharedService] shareMorselToFacebook:_morsel
                                            inViewController:self
                                                     success:nil
                                                      cancel:nil];
}

- (void)feedShareCollectionViewCellDidSelectShareTwitter {
    [[MRSLSocialService sharedService] shareMorselToTwitter:_morsel
                                           inViewController:self
                                                    success:nil
                                                     cancel:nil];
}

- (void)feedShareCollectionViewCellDidSelectNextMorsel {
    if ([self.delegate respondsToSelector:@selector(feedPanelViewControllerDidSelectNextMorsel)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetCollectionViewContentOffset:YES];
        });
        [self.delegate feedPanelViewControllerDidSelectNextMorsel];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Report inappropriate"]) {
        [self.morsel API_reportWithSuccess:^(BOOL success) {
            [UIAlertView showOKAlertViewWithTitle:@"Report Successful"
                                          message:@"Thank you for the feedback!"];
        } failure:^(NSError *error) {
            [UIAlertView showOKAlertViewWithTitle:@"Report Failed"
                                          message:@"Please try again"];
        }];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Remove tag"]) {
        __weak __typeof(self)weakSelf = self;
        [_appDelegate.apiService tagUser:[MRSLUser currentUser]
                                toMorsel:self.morsel
                               shouldTag:NO
                                  didTag:^(BOOL didTag) {
                                      weakSelf.morsel.tagged = @(didTag);
        } failure:^(NSError *error) {
            [UIAlertView showOKAlertViewWithTitle:@"Unable to remove tag"
                                          message:@"Please try again"];
        }];
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
