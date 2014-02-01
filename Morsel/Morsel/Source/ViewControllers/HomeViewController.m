//
//  HomeViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "HomeViewController.h"

#import "CreateMorselViewController.h"
#import "PostMorselsViewController.h"
#import "ModelController.h"
#import "MorselFeedCollectionViewCell.h"
#import "MorselDetailViewController.h"
#import "PostMorselsViewController.h"
#import "ProfileViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface HomeViewController ()
    <MorselFeedCollectionViewCellDelegate,
     NSFetchedResultsControllerDelegate,
     UICollectionViewDataSource,
     UICollectionViewDelegate,
     UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *feedCollectionView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) MRSLMorsel *selectedMorsel;
@property (nonatomic, strong) MRSLUser *currentUser;

@end

@implementation HomeViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    NSPredicate *publishedMorselPredicate = [NSPredicate predicateWithFormat:@"draft == NO"];

    self.fetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                          ascending:NO
                                                      withPredicate:publishedMorselPredicate
                                                            groupBy:nil
                                                           delegate:self
                                                          inContext:[ModelController sharedController].defaultContext];

    [self.feedCollectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![ModelController sharedController].currentUser)
        return;

    [[ModelController sharedController] getFeedWithSuccess:^(NSArray *responseArray)
    {
        if ([responseArray count] > 0) {
            DDLogDebug(@"%lu feed posts available.", (unsigned long)[responseArray count]);
        } else {
            DDLogDebug(@"No feed posts available");
        }
    } failure: ^(NSError * error) {
        DDLogError(@"Error loading feed posts: %@", error.userInfo);
    }];
}

#pragma mark - Section Methods

- (IBAction)displaySideBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLShouldDisplaySideBarNotification
                                                        object:@YES];
}

- (IBAction)addMorsel {
    UINavigationController *createMorselNC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"CreateMorsel"];

    [self presentViewController:createMorselNC
                       animated:YES
                     completion:nil];
}

- (void)displayUserProfile {
    ProfileViewController *profileVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileVC.user = _currentUser;

    [self.navigationController pushViewController:profileVC
                                         animated:YES];
}

- (void)displayMorselDetail {
    MorselDetailViewController *morselDetailVC = [[UIStoryboard morselDetailStoryboard] instantiateViewControllerWithIdentifier:@"MorselDetailViewController"];
    morselDetailVC.morsel = _selectedMorsel;

    [self.navigationController pushViewController:morselDetailVC
                                         animated:YES];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

- (MorselFeedCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                         cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_fetchedResultsController objectAtIndexPath:indexPath];

    MorselFeedCollectionViewCell *morselCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"MorselCell"
                                                                                                  forIndexPath:indexPath];
    morselCell.delegate = self;
    morselCell.morsel = morsel;

    return morselCell;
}

#pragma mark - UICollectionViewDelegate Methods

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

- (void)morselPostCollectionViewCellDidSelectProfileForUser:(MRSLUser *)user {
    self.currentUser = user;

    [self displayUserProfile];
}

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
