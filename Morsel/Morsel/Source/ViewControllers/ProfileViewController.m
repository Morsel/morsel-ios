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

#import "MRSLPost.h"
#import "MRSLUser.h"

@interface ProfileViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *feedCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet ProfileImageView *profileImageView;

@property (nonatomic, strong) NSIndexPath *selectedMorselCellIndexPath;

@end

@implementation ProfileViewController

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
    
    MRSLUser *currentUser = [[ModelController sharedController] currentUser];
    
    self.userNameLabel.text = currentUser.fullName;
    self.profileImageView.user = currentUser;
    
    [self.feedCollectionView reloadData];
}


#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowMorselDetail"])
    {
        MRSLPost *post = [[[ModelController sharedController] currentUser].posts objectAtIndex:_selectedMorselCellIndexPath.row];
        
        MorselDetailViewController *morselDetailVC = [segue destinationViewController];
        morselDetailVC.post = post;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[ModelController sharedController] currentUser].posts count];
}

- (MorselPostCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //MRSLPost *post = [[[ModelController sharedController] currentUser].posts objectAtIndex:indexPath.row];
    
    MorselPostCollectionViewCell *morselCell = [self.feedCollectionView dequeueReusableCellWithReuseIdentifier:@"MorselCell"
                                                                                                  forIndexPath:indexPath];
    //morselCell.post = post;
    
    return morselCell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowMorselDetail"
                              sender:nil];
}

@end
