//
//  ProfileViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "MRSLProfileViewController.h"

#import "MRSLAPIClient.h"
#import "MRSLMorselDetailViewController.h"
#import "MRSLFeedCollectionViewCell.h"
#import "MRSLProfileImageView.h"
#import "MRSLStoryEditViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLProfileViewController ()
<MorselFeedCollectionViewCellDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UICollectionView *profileCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *activityView;

@property (weak, nonatomic) IBOutlet MRSLProfileImageView *profileImageView;

@property (strong, nonatomic) NSMutableArray *morsels;
@property (strong, nonatomic) NSFetchedResultsController *userPostsFetchedResultsController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) MRSLMorsel *selectedMorsel;

@end

@implementation MRSLProfileViewController

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

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshUserPostsAndProfile)
              forControlEvents:UIControlEventValueChanged];

    [self.profileCollectionView addSubview:_refreshControl];
    self.profileCollectionView.alwaysBounceVertical = YES;

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-back"]
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(goBack:)];
    [self.navigationItem setLeftBarButtonItem:backButton];

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

- (void)localContentPurged {
    [NSFetchedResultsController deleteCacheWithName:@"Home"];

    self.userPostsFetchedResultsController.delegate = nil;

    self.userPostsFetchedResultsController = nil;
}

- (void)localContentRestored {
    if (_userPostsFetchedResultsController) return;

    [_refreshControl endRefreshing];

    [self.morsels removeAllObjects];

    [self setupUserPostsFetchRequest];
    [self populateContent];

    self.activityView.hidden = YES;
}

#pragma mark - Private Methods

- (void)setupUserPostsFetchRequest {
    if (_userPostsFetchedResultsController) return;

    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"(post.creator.userID == %i) AND (post.draft == NO)", [_user.userID intValue]];

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
    [[MRSLAPIClient sharedClient].operationQueue cancelAllOperations];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshUserPostsAndProfile {
    self.activityView.hidden = NO;

    __weak __typeof(self)weakSelf = self;

    [_appDelegate.morselApiService getUserProfile:_user
                                          success:^(id responseObject) {
         if (weakSelf) {
             weakSelf.likeCountLabel.text = [NSString stringWithFormat:@"%i", _user.like_countValue];
             weakSelf.morselCountLabel.text = [NSString stringWithFormat:@"%i", _user.morsel_countValue];
         }
     } failure:nil];

    [_appDelegate.morselApiService getUserPosts:_user
                                  includeDrafts:NO
                                        success:nil
                                        failure:nil];
}

- (void)displayMorselDetail {
    MRSLMorselDetailViewController *morselDetailVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"sb_MorselDetailViewController"];
    morselDetailVC.morsel = _selectedMorsel;

    [self.navigationController pushViewController:morselDetailVC
                                         animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_morsels count];
}

- (MRSLFeedCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_morsels objectAtIndex:indexPath.row];

    MRSLFeedCollectionViewCell *morselCell = [self.profileCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_MorselCell"
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

- (void)morselPostCollectionViewCellDidDisplayProgression:(MRSLFeedCollectionViewCell *)cell {
    NSIndexPath *cellIndexPath = [self.profileCollectionView indexPathForCell:cell];
    [self.profileCollectionView scrollToItemAtIndexPath:cellIndexPath
                                       atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                               animated:YES];
}

- (void)morselPostCollectionViewCellDidSelectEditMorsel:(MRSLMorsel *)morsel {
    MRSLStoryEditViewController *editStoryVC = [[UIStoryboard storyManagementStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLStoryEditViewController"];

    editStoryVC.postID = morsel.post.postID;

    [self.navigationController pushViewController:editStoryVC
                                         animated:YES];
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
