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

#import "MRSLMorsel.h"
#import "MRSLPost.h"

@interface HomeViewController ()

<
NSFetchedResultsControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate
>

@property (nonatomic, weak) IBOutlet UICollectionView *feedCollectionView;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *selectedMorselCellIndexPath;

@end

@implementation HomeViewController

#pragma mark - Instance Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![ModelController sharedController].currentUser || self.fetchedResultsController) return;
    
    [[ModelController sharedController] getFeedWithSuccess:^(NSArray *responseArray)
     {
         if ([responseArray count] > 0)
         {
             DDLogDebug(@"%lu feed items available. Initiating fetch request.", (unsigned long)[responseArray count]);
             
             self.fetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                                   ascending:YES
                                                               withPredicate:nil
                                                                     groupBy:nil
                                                                    delegate:self
                                                                   inContext:[ModelController sharedController].temporaryContext];
             
             [self.feedCollectionView reloadData];
         }
         else
         {
             DDLogDebug(@"No Feed items available");
         }
     }
                                                   failure:^(NSError *error)
     {
         DDLogError(@"Error loading feed items: %@", error.userInfo);
     }];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowMorselDetail"])
    {
        MRSLMorsel *morsel = [_fetchedResultsController objectAtIndexPath:_selectedMorselCellIndexPath];
        
        MorselDetailViewController *morselDetailVC = [segue destinationViewController];
        morselDetailVC.post = morsel.post;
    }
}

#pragma mark - UICollectionViewDataSource

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
    morselCell.morsel = morsel;
    
    return morselCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMorselCellIndexPath = indexPath;
    
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

@end
