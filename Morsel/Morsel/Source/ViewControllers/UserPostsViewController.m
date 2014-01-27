//
//  UserPostsViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UserPostsViewController.h"

#import "ModelController.h"
#import "PostCollectionViewCell.h"

#import "MRSLPost.h"
#import "MRSLUser.h"

@interface UserPostsViewController ()

<
UICollectionViewDataSource,
UICollectionViewDelegate,
NSFetchedResultsControllerDelegate,
UITextFieldDelegate
>

@property (nonatomic, weak) IBOutlet UICollectionView *postCollectionView;
@property (weak, nonatomic) IBOutlet UIView *titlePromptView;
@property (weak, nonatomic) IBOutlet UITextField *titlePromptTextField;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation UserPostsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"(author.userID == %i)", [[ModelController sharedController].currentUser.userID intValue]];
    
    self.fetchedResultsController = [MRSLPost MR_fetchAllSortedBy:@"creationDate"
                                                        ascending:NO
                                                    withPredicate:currentUserPredicate
                                                          groupBy:nil
                                                         delegate:self
                                                        inContext:[ModelController sharedController].defaultContext];
    
    [self.postCollectionView reloadData];
}

- (void)setPost:(MRSLPost *)post
{
    if (_post != post)
    {
        _post = post;
        [self.postCollectionView reloadData];
    }
}

#pragma mark - Action Methods

- (IBAction)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (PostCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                          cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MRSLPost *post = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    PostCollectionViewCell *postCell = [self.postCollectionView dequeueReusableCellWithReuseIdentifier:@"PostCell"
                                                                                            forIndexPath:indexPath];
    postCell.post = post;
    
    if ([_post isEqual:post])
    {
        [postCell setHighlighted:([post.postID intValue] == [_post.postID intValue])];
    }
    
    if (_postTitle &&
        !post.title)
    {
        postCell.postTitleLabel.text = _postTitle;
    }
    
    return postCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MRSLPost *post = [_fetchedResultsController objectAtIndexPath:indexPath];

    if (_post)
    {
        self.post = ([post.postID intValue] == [_post.postID intValue]) ? nil : post;
    }
    else
    {
        self.post = post;
    }
    
    if (!_post)
    {
        PostCollectionViewCell *postCell = (PostCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [postCell setHighlighted:NO];
    }
    
    if (!_post.title)
    {
        self.titlePromptView.hidden = NO;
        
        [self.titlePromptTextField becomeFirstResponder];
    }
    else
    {
        [self performSegueWithIdentifier:@"ReturnToCreateMorsel"
                                  sender:nil];
    }
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
    
    [self.postCollectionView reloadData];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        self.postTitle = textField.text;
        
        [self performSegueWithIdentifier:@"ReturnToCreateMorsel"
                                  sender:nil];
        
        return YES;
    }
    return NO;
}

@end
