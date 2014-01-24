//
//  HomeViewController.m
//  Morsel
//
//  Created by Javier Otero on 12/6/13.
//  Copyright (c) 2013 Morsel. All rights reserved.
//

#import "HomeViewController.h"

#import "ModelController.h"
#import "MorselPostCollectionViewCell.h"
#import "MorselDetailViewController.h"
#import "ProfileViewController.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface HomeViewController ()

<
MorselPostCollectionViewCellDelegate,
NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, weak) IBOutlet UICollectionView *feedCollectionView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) MRSLMorsel *selectedMorsel;
@property (nonatomic, strong) MRSLUser *currentUser;

@end

@implementation HomeViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed: @"graphic-morsel-identity-small"];
    UIImageView *imageview = [[UIImageView alloc] initWithImage: image];
    
    self.navigationItem.titleView = imageview;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![ModelController sharedController].currentUser || self.fetchedResultsController) return;
    
    [[ModelController sharedController] getFeedWithSuccess:^(NSArray *responseArray)
     {
         if ([responseArray count] > 0)
         {
             DDLogDebug(@"%lu feed posts available. Initiating fetch request.", (unsigned long)[responseArray count]);
             
             self.fetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                                   ascending:NO
                                                               withPredicate:nil
                                                                     groupBy:nil
                                                                    delegate:self
                                                                   inContext:[ModelController sharedController].temporaryContext];
             
             [self.feedCollectionView reloadData];
         }
         else
         {
             DDLogDebug(@"No feed posts available");
         }
     }
                                                   failure:^(NSError *error)
     {
         DDLogError(@"Error loading feed posts: %@", error.userInfo);
     }];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowMorselDetail"])
    {
        MorselDetailViewController *morselDetailVC = [segue destinationViewController];
        morselDetailVC.morsel = _selectedMorsel;
    }
    
    if ([[segue identifier] isEqualToString:@"DisplayUserProfile"])
    {
        ProfileViewController *profileVC = [segue destinationViewController];
        profileVC.user = _currentUser;
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (MorselPostCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                          cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MRSLMorsel *morsel = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    MorselPostCollectionViewCell *morselCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"MorselCell"
                                                                                                  forIndexPath:indexPath];
    morselCell.delegate = self;
    morselCell.morsel = morsel;
    
    return morselCell;
}

#pragma mark - UICollectionViewDelegate Methods

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

- (void)morselPostCollectionViewCellDidSelectProfileForUser:(MRSLUser *)user
{
    self.currentUser = user;
    
    [self performSegueWithIdentifier:@"DisplayUserProfile"
                              sender:nil];
}

- (void)morselPostCollectionViewCellDidSelectMorsel:(MRSLMorsel *)morsel
{
    self.selectedMorsel = morsel;
    [self performSegueWithIdentifier:@"ShowMorselDetail"
                              sender:nil];
}

@end
