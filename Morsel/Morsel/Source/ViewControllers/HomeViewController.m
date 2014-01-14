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

#import "MRSLPost.h"

@interface HomeViewController ()

<
UICollectionViewDataSource,
UICollectionViewDelegate
>

@property (nonatomic, weak) IBOutlet UICollectionView *feedCollectionView;

@property (nonatomic, strong) NSIndexPath *selectedMorselCellIndexPath;
@property (nonatomic, strong) NSArray *posts;

@end

@implementation HomeViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.posts = [MRSLPost MR_findAll];
}

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
    
    self.posts = [MRSLPost MR_findAll];
    
    [self.feedCollectionView reloadData];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowMorselDetail"])
    {
        MRSLPost *post = [_posts objectAtIndex:_selectedMorselCellIndexPath.row];
        
        MorselDetailViewController *morselDetailVC = [segue destinationViewController];
        morselDetailVC.post = post;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _posts.count;
}

- (MorselPostCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MRSLPost *post = [_posts objectAtIndex:indexPath.row];
    
    MorselPostCollectionViewCell *morselCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"MorselCell"
                                                                                                  forIndexPath:indexPath];
    morselCell.post = post;
    
    return morselCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMorselCellIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"ShowMorselDetail"
                              sender:nil];
}

@end
