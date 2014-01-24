//
//  ProfileViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/13/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "ProfileViewController.h"

#import "ModelController.h"
#import "MorselDetailViewController.h"
#import "MorselPostCollectionViewCell.h"
#import "ProfileImageView.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface ProfileViewController ()

<
MorselPostCollectionViewCellDelegate,
NSFetchedResultsControllerDelegate
>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_user) self.user = [ModelController sharedController].currentUser;
    
    self.userNameLabel.text = _user.fullName;
    self.userTitleLabel.text = _user.occupationTitle;
    self.profileImageView.user = _user;
    self.likeCountLabel.text = [NSString stringWithFormat:@"%i", [_user.likeCount intValue]];
    self.morselCountLabel.text = [NSString stringWithFormat:@"%i", [_user.morselCount intValue]];
    
    [_profileImageView addCornersWithRadius:36.f];
    _profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _profileImageView.layer.borderWidth = 2.f;
    
    if ([self.navigationController.viewControllers count] == 1)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.feedCollectionView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 50.f, 0.f);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:MorselHideBottomBarNotification
                                                            object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.fetchedResultsController) return;
    
    [[ModelController sharedController] getUserPosts:_user
                                             success:^(NSArray *responseArray)
     {
         if ([responseArray count] > 0)
         {
             DDLogDebug(@"%lu profile posts available. Initiating fetch request.", (unsigned long)[responseArray count]);
             
             NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"post.author.userID == %i", [_user.userID intValue]];
             
             self.fetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                                   ascending:NO
                                                               withPredicate:currentUserPredicate
                                                                     groupBy:nil
                                                                    delegate:self
                                                                   inContext:_user.isCurrentUser ? [ModelController sharedController].defaultContext : [ModelController sharedController].temporaryContext];
             
             [self.feedCollectionView reloadData];
         }
         else
         {
             DDLogDebug(@"No profile posts available");
         }
     }
                                                   failure:^(NSError *error)
     {
         DDLogError(@"Error loading profile posts: %@", error.userInfo);
     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.navigationController.viewControllers count] == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MorselShowBottomBarNotification
                                                            object:nil];
    }
}

#pragma mark - Private Methods

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowMorselDetail"])
    {
        MorselDetailViewController *morselDetailVC = [segue destinationViewController];
        morselDetailVC.morsel = _selectedMorsel;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (MorselPostCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MRSLMorsel *morsel = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    MorselPostCollectionViewCell *morselCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"MorselCell"
                                                                                                  forIndexPath:indexPath];
    morselCell.delegate = self;
    morselCell.morsel = morsel;
    
    return morselCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MRSLMorsel *morsel = [_fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedMorsel = morsel;
    
    [self performSegueWithIdentifier:@"ShowMorselDetail"
                              sender:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DDLogDebug(@"Fetch controller detected change in content. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    
    if (fetchError)
    {
        DDLogDebug(@"Refresh Fetch Failed! %@", fetchError.userInfo);
    }
    
    [self.feedCollectionView reloadData];
}

#pragma mark - MorselPostCollectionViewCellDelegate Methods

- (void)morselPostCollectionViewCellDidSelectMorsel:(MRSLMorsel *)morsel
{
    self.selectedMorsel = morsel;
    [self performSegueWithIdentifier:@"ShowMorselDetail"
                              sender:nil];
}

- (void)morselPostCollectionViewCellDidDisplayProgression:(MorselPostCollectionViewCell *)cell
{
    NSIndexPath *cellIndexPath = [self.feedCollectionView indexPathForCell:cell];
    [self.feedCollectionView scrollToItemAtIndexPath:cellIndexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                            animated:YES];
}

@end
