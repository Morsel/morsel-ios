//
//  MRSLProfileMorselsViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/17/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMorselDetailViewController.h"

#import <SDWebImage/SDWebImageManager.h>

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Like.h"
#import "NSMutableArray+Additions.h"

#import "MRSLCollectionView.h"
#import "MRSLCollectionViewDataSource.h"
#import "MRSLFeedPanelViewController.h"
#import "MRSLFeedPanelCollectionViewCell.h"
#import "MRSLMediaManager.h"
#import "MRSLProfileViewController.h"
#import "MRSLMorselEditViewController.h"
#import "MRSLMorselTaggedUsersViewController.h"
#import "MRSLModalLikersViewController.h"
#import "MRSLModalCommentsViewController.h"

#import "MRSLItem.h"
#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface MRSLBaseRemoteDataSourceViewController (Private)

- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView
                               withOffset:(CGFloat)offset;

@end

@interface MRSLMorselDetailViewController ()
<MRSLCollectionViewDataSourceDelegate,
MRSLFeedPanelCollectionViewCellDelegate>

@property (nonatomic) BOOL isPreview;
@property (nonatomic) BOOL queuedToDisplayTaggedUsers;
@property (nonatomic) BOOL queuedToDisplayLikers;
@property (nonatomic) BOOL queuedToDisplayComments;

@property (nonatomic) NSNumber *queuedItemID;

@property (nonatomic) CGFloat previousContentOffset;

@property (nonatomic) MRSLScrollDirection scrollDirection;

@property (strong, nonatomic) UIBarButtonItem *likeBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *space;
@property (strong, nonatomic) UIBarButtonItem *shareBarButtonItem;

@property (strong, nonatomic) MRSLUser *currentUser;

@end

@implementation MRSLMorselDetailViewController

#pragma mark - Instance Methods

- (void)setupWithUserInfo:(NSDictionary *)userInfo {
    self.userInfo = userInfo;
}

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%@detail_morselIDs", _user.username ? [NSString stringWithFormat:@"%@_", _user.username] :@""];
}

- (void)viewDidLoad {
    self.isPreview = (_morsel.publishedDate == nil);
    self.disablePagination = (self.isPreview || self.isExplore);

    [super viewDidLoad];

    self.mp_eventView = @"morsel_detail";
    if (_isPreview) self.navigationItem.rightBarButtonItem = nil;
    if (!_isPreview) [self setupFeedNavigationItems];

    if (self.userInfo[@"morsel_id"]) {
        self.morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                withValue:self.userInfo[@"morsel_id"]];
        if (!_morsel) {
            self.morsel = [MRSLMorsel MR_createEntity];
            self.morsel.morselID = @([self.userInfo[@"morsel_id"] intValue]);
        } else {
            self.user = self.morsel.creator;
        }
        __weak __typeof(self)weakSelf = self;
        [_appDelegate.apiService getMorsel:_morsel
                                  orWithID:nil
                                   success:^(id responseObject) {
                                       if (weakSelf) {
                                           [weakSelf setupRemoteRequestBlock];
                                           [weakSelf dataSource];
                                       }
                                   } failure:^(NSError *error) {
                                       [UIAlertView showAlertViewForErrorString:@"Unable to load morsel."
                                                                       delegate:nil];
                                   }];
        if ([self.userInfo[@"action"] isEqualToString:@"user_tags"]) {
            self.queuedToDisplayTaggedUsers = YES;
        } else if ([self.userInfo[@"action"] isEqualToString:@"likers"]) {
            self.queuedToDisplayLikers = YES;
        } else if ([self.userInfo[@"action"] isEqualToString:@"comments"]) {
            self.queuedItemID = self.userInfo[@"item_id"];
            self.queuedToDisplayComments = (self.queuedItemID != nil);
        }
    } else {
        [self setupRemoteRequestBlock];
    }
    if (self.disablePagination) [self.collectionView setAlwaysBounceHorizontal:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    MRSLMorsel *morsel = [MRSLMorsel MR_findFirstByAttribute:MRSLMorselAttributes.morselID
                                                   withValue:self.userInfo[@"morsel_id"]];
    if (self.queuedToDisplayTaggedUsers) {
        self.queuedToDisplayTaggedUsers = NO;
        if (morsel) {
            UINavigationController *taggedNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardTaggedUsersKey];
            MRSLMorselTaggedUsersViewController *taggedUsersVC = [[taggedNC viewControllers] firstObject];
            taggedUsersVC.morsel = morsel;
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                                object:taggedNC];
        }
    } else if (self.queuedToDisplayLikers) {
        self.queuedToDisplayLikers = NO;
        if (morsel) {
            UINavigationController *likesNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardLikesKey];
            MRSLModalLikersViewController *modalLikersVC = [[likesNC viewControllers] firstObject];
            modalLikersVC.morsel = morsel;
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                                object:likesNC];
        }
    } else if (self.queuedToDisplayComments) {
        self.queuedToDisplayComments = NO;
        MRSLItem *morselItem = [MRSLItem MR_findFirstByAttribute:MRSLItemAttributes.itemID
                                                       withValue:self.queuedItemID];
        if (morselItem) {
            UINavigationController *commentNC = [[UIStoryboard feedStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardCommentsKey];
            MRSLModalCommentsViewController *modalCommentsVC = [[commentNC viewControllers] firstObject];
            modalCommentsVC.item = morselItem;
            [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayBaseViewControllerNotification
                                                                object:commentNC];
            NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
            if (indexPath) {
                MRSLFeedPanelCollectionViewCell *visibleFeedPanel = (MRSLFeedPanelCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [visibleFeedPanel.feedPanelViewController scrollToMorselItem:morselItem];
            }
        }
    }
}


#pragma mark - Action Methods

- (void)displayMorselShare {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLFeedPanelCollectionViewCell *visibleFeedPanel = (MRSLFeedPanelCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [visibleFeedPanel.feedPanelViewController displayShare];
    }
}

- (IBAction)toggleLike {
    if ([MRSLUser isCurrentUserGuest]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayLandingNotification
                                                            object:nil];
        return;
    }
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath) {
        MRSLMorsel *morsel = [self.dataSource objectAtIndexPath:indexPath];

        self.likeBarButtonItem.enabled = NO;
        if (!morsel.managedObjectContext) return;
        [[MRSLEventManager sharedManager] track:@"Tapped Button"
                                     properties:@{@"_title": @"Like Icon",
                                                  @"_view": self.mp_eventView,
                                                  @"morsel_id": morsel.morselID}];

        [morsel setLikedValue:!morsel.likedValue];
        [self setLikeButtonImageForMorsel:morsel];

        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService likeMorsel:morsel
                                 shouldLike:morsel.likedValue
                                    didLike:^(BOOL doesLike) {
                                        if (morsel.likedValue) [MRSLEventManager sharedManager].likes_given++;
                                        weakSelf.likeBarButtonItem.enabled = YES;
                                    } failure: ^(NSError * error) {
                                        weakSelf.likeBarButtonItem.enabled = YES;
                                        [morsel setLikedValue:!morsel.likedValue];
                                        [morsel setLike_countValue:morsel.like_countValue - 1];
                                        [weakSelf setLikeButtonImageForMorsel:morsel];
                                    }];
    }
}

- (void)setLikeButtonImageForMorsel:(MRSLMorsel *)morsel {
    UIImage *likeImage = [UIImage imageNamed:morsel.likedValue ? @"icon-like-on" : @"icon-like-off"];
    [self.likeBarButtonItem setImage:likeImage];
    self.likeBarButtonItem.enabled = YES;
}

#pragma mark - Private Methods

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return [MRSLMorsel MR_fetchAllSortedBy:@"publishedDate"
                                 ascending:NO
                             withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", self.objectIDs]
                                   groupBy:nil
                                  delegate:self];
}

- (void)setupRemoteRequestBlock {
    __weak __typeof(self) weakSelf = self;
    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf.disablePagination) {
            [_appDelegate.apiService getMorsel:strongSelf.morsel
                                      orWithID:nil
                                       success:^(id responseObject) {
                                           if ([responseObject isKindOfClass:[MRSLMorsel class]]) {
                                               strongSelf.morsel = responseObject;
                                               NSArray *responseArray = @[[(MRSLMorsel *)responseObject morselID]];
                                               remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                           } else {
                                               remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, nil);
                                           }
                                       } failure:^(NSError *error) {
                                           remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                       }];
        } else {
            [_appDelegate.apiService getMorselsForUser:strongSelf.user
                                                  page:page
                                                 count:@(4)
                                            onlyDrafts:NO
                                               success:^(NSArray *responseArray) {
                                                   remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                               } failure:^(NSError *error) {
                                                   remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                               }];
        }
    };
    [self setupInterface];
}

- (MRSLCollectionViewDataSource *)dataSource {
    MRSLCollectionViewDataSource *superDataSource = (MRSLCollectionViewDataSource *)[super dataSource];
    if (superDataSource) return superDataSource;

    __weak __typeof(self) weakSelf = self;
    MRSLCollectionViewDataSource *newDataSource = [[MRSLCollectionViewDataSource alloc] initWithObjects:nil
                                                                                               sections:nil
                                                                                     configureCellBlock:^UICollectionViewCell *(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
                                                                                         MRSLMorsel *morsel = [weakSelf.dataSource objectAtIndexPath:indexPath];
                                                                                         NSString *identifier = [NSString stringWithFormat:@"%@_%d", MRSLStoryboardRUIDFeedPanelCellKey, (int)(indexPath.row % 4)];
                                                                                         MRSLFeedPanelCollectionViewCell *morselPanelCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                                                                                                                      forIndexPath:indexPath];
                                                                                         [morselPanelCell setOwningViewController:self
                                                                                                                       withMorsel:morsel
                                                                                                                    andNextMorsel:nil];
                                                                                         morselPanelCell.delegate = self;
                                                                                         return morselPanelCell;
                                                                                     }
                                                                                     supplementaryBlock:nil
                                                                                 sectionHeaderSizeBlock:nil
                                                                                 sectionFooterSizeBlock:nil
                                                                                          cellSizeBlock:^CGSize(UICollectionView *collectionView, NSIndexPath *indexPath) {
                                                                                              return CGSizeMake([collectionView getWidth], [collectionView getHeight]);
                                                                                          }
                                                                                     sectionInsetConfig:nil];
    [self setDataSource:newDataSource];
    return newDataSource;
}

- (void)setupInterface {
    if (_isPreview) {
        self.title = @"Preview";
    } else if (_isExplore) {
        if (!self.morsel) {
            NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
            if (indexPath) {
                MRSLMorsel *morsel = [self.dataSource objectAtIndexPath:indexPath];
                self.title = morsel.title;
            }
        } else {
            self.title = self.morsel.title;
        }
    } else {
        self.title = [NSString stringWithFormat:@"%@", _user.username];
    }
    if (self.morsel) [self setLikeButtonImageForMorsel:self.morsel];
    if ([self.dataSource count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.morsel && [self.dataSource containsObject:self.morsel]) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource indexOfObject:_morsel]
                                                                                inSection:0]
                                            atScrollPosition:UICollectionViewScrollPositionNone
                                                    animated:NO];
                self.morsel = nil;
            }
        });
    }
}

- (void)setupFeedNavigationItems {
    self.likeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-like-off"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(toggleLike)];
    self.likeBarButtonItem.width = 20.f;

    self.space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                               target:nil
                                                               action:nil];
    self.space.width = -12;

    self.shareBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-share"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(displayMorselShare)];

    NSArray *buttons = @[self.space, self.shareBarButtonItem, self.likeBarButtonItem];

    self.navigationItem.rightBarButtonItems = buttons;
}

#pragma mark - UIScrollViewDelegate

- (void)collectionViewDataSourceDidScroll:(UICollectionView *)collectionView
                               withOffset:(CGFloat)offset {
    [super collectionViewDataSourceDidScroll:collectionView
                                  withOffset:offset];
    if (_previousContentOffset > collectionView.contentOffset.x) {
        self.scrollDirection = MRSLScrollDirectionRight;
    } else if (_previousContentOffset < collectionView.contentOffset.x) {
        self.scrollDirection = MRSLScrollDirectionLeft;
    }
    self.previousContentOffset = collectionView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self handleScrollComplete];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self handleScrollComplete];
}

- (void)handleScrollComplete {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath && indexPath.row < [self.dataSource count]) {
        MRSLMorsel *visibleMorsel = [self.dataSource objectAtIndexPath:indexPath];
        [self setLikeButtonImageForMorsel:visibleMorsel];
    }
}

#pragma mark - MRSLFeedPanelCollectionViewCellDelegate

- (void)feedPanelCollectionViewCellDidSelectNextMorsel {
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    if (indexPath.row + 1 < [self.dataSource count]) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1
                                                        inSection:0];
        [self.collectionView scrollToItemAtIndexPath:nextIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:YES];
    }
}

@end
