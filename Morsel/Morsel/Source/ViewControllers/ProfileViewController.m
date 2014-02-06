//
//  ProfileViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "ProfileViewController.h"

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
@property (nonatomic, weak) IBOutlet UICollectionView *feedCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *morselCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLabel;

@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) MRSLMorsel *selectedMorsel;

@end

@implementation ProfileViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

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

    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"(post.creator.userID == %i) AND (draft == NO)", [_user.userID intValue]];

    self.fetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                          ascending:NO
                                                      withPredicate:currentUserPredicate
                                                            groupBy:nil
                                                           delegate:self
                                                          inContext:[NSManagedObjectContext MR_defaultContext]];

    [self.feedCollectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_appDelegate.morselApiService getUserProfile:_user
                                         success:^(id responseObject)
     {
         self.likeCountLabel.text = [NSString stringWithFormat:@"%i", _user.like_countValue];
         self.morselCountLabel.text = [NSString stringWithFormat:@"%i", _user.morsel_countValue];
     } failure:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!_user)
        return;

    [_appDelegate.morselApiService getUserPosts:_user
                                       success:^(NSArray *responseArray)
     {
         if ([responseArray count] > 0) {
             DDLogDebug(@"%lu profile posts available.", (unsigned long)[responseArray count]);
         } else {
             DDLogDebug(@"No profile posts available");
         }
     } failure: ^(NSError * error) {
         DDLogError(@"Error loading profile posts: %@", error.userInfo);
     }];
}

#pragma mark - Private Methods

- (IBAction)displaySideBar:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLShouldDisplaySideBarNotification
                                                        object:@YES];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Section Methods

- (void)displayMorselDetail {
    MorselDetailViewController *morselDetailVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"MorselDetailViewController"];
    morselDetailVC.morsel = _selectedMorsel;

    [self.navigationController pushViewController:morselDetailVC
                                         animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

- (MorselFeedCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_fetchedResultsController objectAtIndexPath:indexPath];

    MorselFeedCollectionViewCell *morselCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"MorselCell"
                                                                                                  forIndexPath:indexPath];
    morselCell.delegate = self;
    morselCell.morsel = morsel;

    return morselCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedMorsel = morsel;

    [self displayMorselDetail];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Fetch controller detected change in content. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);

    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];

    if (fetchError) {
        DDLogDebug(@"Refresh Fetch Failed! %@", fetchError.userInfo);
    }

    [self.feedCollectionView reloadData];
}

#pragma mark - MorselFeedCollectionViewCellDelegate Methods

- (void)morselPostCollectionViewCellDidSelectMorsel:(MRSLMorsel *)morsel {
    self.selectedMorsel = morsel;

    [self displayMorselDetail];
}

- (void)morselPostCollectionViewCellDidDisplayProgression:(MorselFeedCollectionViewCell *)cell {
    NSIndexPath *cellIndexPath = [self.feedCollectionView indexPathForCell:cell];
    [self.feedCollectionView scrollToItemAtIndexPath:cellIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                            animated:YES];
}

- (void)morselPostCollectionViewCellDidSelectEditMorsel:(MRSLMorsel *)morsel {
    UINavigationController *editPostMorselsNC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"EditPostMorsels"];

    if ([editPostMorselsNC.viewControllers count] > 0) {
        PostMorselsViewController *postMorselsVC = [editPostMorselsNC.viewControllers firstObject];
        postMorselsVC.post = morsel.post;

        [self.navigationController presentViewController:editPostMorselsNC
                                                animated:YES
                                              completion:nil];
    }
}

@end
