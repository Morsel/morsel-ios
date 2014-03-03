//
//  ProfileViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "ProfileViewController.h"

#import "MorselAPIClient.h"
#import "MorselDetailViewController.h"
#import "MorselFeedCollectionViewCell.h"
#import "PostMorselsViewController.h"
#import "ProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface ProfileViewController ()
<MorselFeedCollectionViewCellDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *sideBarButton;
@property (weak, nonatomic) IBOutlet UICollectionView *profileCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@property (nonatomic, strong) NSMutableArray *morsels;
@property (nonatomic, strong) NSFetchedResultsController *userPostsFetchedResultsController;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) MRSLMorsel *selectedMorsel;

@end

@implementation ProfileViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.morsels = [NSMutableArray array];

    if (!_user) self.user = [MRSLUser currentUser];

    self.userNameLabel.text = _user.fullName;
    self.userTitleLabel.text = _user.title;
    self.profileImageView.user = _user;
    self.likeCountLabel.text = [NSString stringWithFormat:@"%i", _user.like_countValue];
    self.morselCountLabel.text = [NSString stringWithFormat:@"%i", _user.morsel_countValue];

    [_profileImageView addCornersWithRadius:36.f];
    _profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _profileImageView.layer.borderWidth = 2.f;

    if ([self.navigationController.viewControllers count] == 1) {
        self.backButton.hidden = YES;
    } else {
        self.sideBarButton.hidden = YES;
    }

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshUserPostsAndProfile)
              forControlEvents:UIControlEventValueChanged];

    [self.profileCollectionView addSubview:_refreshControl];
    self.profileCollectionView.alwaysBounceVertical = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(morselUploaded:)
                                                 name:MRSLMorselUploadDidCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localContentPurged)
                                                 name:MRSLServiceWillPurgeDataNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localContentRestored)
                                                 name:MRSLServiceWillRestoreDataNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.userPostsFetchedResultsController) {
        [self setupUserPostsFetchRequest];
        [self populateContent];
        [self refreshUserPostsAndProfile];
    }
}
#pragma mark - Notification Methods

- (void)morselUploaded:(NSNotification *)notification {
    MRSLMorsel *uploadedMorsel = notification.object;
    if (uploadedMorsel.draftValue && [_user isCurrentUser]) {
        [self refreshUserPostsAndProfile];
    }
}

- (void)localContentPurged {
    [NSFetchedResultsController deleteCacheWithName:@"Home"];

    self.userPostsFetchedResultsController.delegate = nil;

    self.userPostsFetchedResultsController = nil;
}

- (void)localContentRestored {
    [self.morsels removeAllObjects];

    [self setupUserPostsFetchRequest];
    [self populateContent];

    self.activityView.hidden = YES;
}

#pragma mark - Private Methods

- (void)setupUserPostsFetchRequest {
    if (_userPostsFetchedResultsController) return;

    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"(post.creator.userID == %i) AND (draft == NO)", [_user.userID intValue]];

    self.userPostsFetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                                   ascending:NO
                                                               withPredicate:currentUserPredicate
                                                                     groupBy:nil
                                                                    delegate:self
                                                                   inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_userPostsFetchedResultsController performFetch:&fetchError];

    if (_userPostsFetchedResultsController) {
        [self.morsels removeAllObjects];
        [self.morsels addObjectsFromArray:[_userPostsFetchedResultsController fetchedObjects]];
    }

    [self.profileCollectionView reloadData];
}

#pragma mark - Section Methods

- (IBAction)goBack:(id)sender {
    [[MorselAPIClient sharedClient].operationQueue cancelAllOperations];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshUserPostsAndProfile {
    self.activityView.hidden = NO;

    __weak __typeof(self)weakSelf = self;

    [_appDelegate.morselApiService getUserProfile:_user
                                          success:^(id responseObject)
     {
         if (weakSelf) {
             weakSelf.likeCountLabel.text = [NSString stringWithFormat:@"%i", _user.like_countValue];
             weakSelf.morselCountLabel.text = [NSString stringWithFormat:@"%i", _user.morsel_countValue];
         }
     } failure:nil];

    [_appDelegate.morselApiService getUserPosts:_user
                                  includeDrafts:NO
                                        success:^(NSArray *responseArray)
     {
         if ([responseArray count] > 0) {
             DDLogDebug(@"%lu profile posts available.", (unsigned long)[responseArray count]);
         } else {
             DDLogDebug(@"No profile posts available");
         }
         if (weakSelf) [weakSelf.refreshControl endRefreshing];
     } failure: ^(NSError * error) {
         DDLogError(@"Error profile draft posts: %@", error.userInfo);
         if (weakSelf) [weakSelf.refreshControl endRefreshing];
     }];
}

- (void)displayMorselDetail {
    MorselDetailViewController *morselDetailVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselDetailViewController"];
    morselDetailVC.morsel = _selectedMorsel;

    [self.navigationController pushViewController:morselDetailVC
                                         animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_morsels count];
}

- (MorselFeedCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];

    MorselFeedCollectionViewCell *morselCell = [self.profileCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MorselCell"
                                                                                                     forIndexPath:indexPath];
    morselCell.delegate = self;
    morselCell.morsel = morsel;

    return morselCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];
    self.selectedMorsel = morsel;

    [self displayMorselDetail];
}

#pragma mark - MorselFeedCollectionViewCellDelegate Methods

- (void)morselPostCollectionViewCellDidSelectMorsel:(MRSLMorsel *)morsel {
    self.selectedMorsel = morsel;

    [self displayMorselDetail];
}

- (void)morselPostCollectionViewCellDidDisplayProgression:(MorselFeedCollectionViewCell *)cell {
    NSIndexPath *cellIndexPath = [self.profileCollectionView indexPathForCell:cell];
    [self.profileCollectionView scrollToItemAtIndexPath:cellIndexPath
                                       atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                               animated:YES];
}

- (void)morselPostCollectionViewCellDidSelectEditMorsel:(MRSLMorsel *)morsel {
    UINavigationController *editPostMorselsNC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_EditPostMorsels"];

    if ([editPostMorselsNC.viewControllers count] > 0) {
        PostMorselsViewController *postMorselsVC = [editPostMorselsNC.viewControllers firstObject];
        postMorselsVC.post = morsel.post;

        [self.navigationController presentViewController:editPostMorselsNC
                                                animated:YES
                                              completion:nil];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - Destruction

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
