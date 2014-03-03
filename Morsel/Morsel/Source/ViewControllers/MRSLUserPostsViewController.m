//
//  UserPostsViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/27/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserPostsViewController.h"

#import "MRSLPostCollectionViewCell.h"

#import "MRSLMorsel.h"
#import "MRSLPost.h"
#import "MRSLUser.h"

@interface MRSLUserPostsViewController ()
    <UICollectionViewDataSource,
     UICollectionViewDelegate,
     NSFetchedResultsControllerDelegate>

@property (nonatomic) int postCount;

@property (nonatomic, strong) NSArray *nonEmptyPostsArray;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MRSLUserPostsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.postCount = 0;
}

- (void)setMorsel:(MRSLMorsel *)morsel {
    if (_morsel != morsel) {
        _morsel = morsel;
        if (!morsel || self.fetchedResultsController) return;
        MRSLUser *currentUser = [MRSLUser currentUser];
        if (!currentUser) return;
        NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"creator.userID == %i", [MRSLUser currentUser].userIDValue];

        self.fetchedResultsController = [MRSLPost MR_fetchAllSortedBy:@"creationDate"
                                                            ascending:NO
                                                        withPredicate:currentUserPredicate
                                                              groupBy:nil
                                                             delegate:self
                                                            inContext:[NSManagedObjectContext MR_defaultContext]];

        [self.postCollectionView reloadData];
    }
}

- (void)setPost:(MRSLPost *)post {
    if (_post != post) {
        _post = post;

        [self.postCollectionView reloadData];
    }
}

- (void)setTemporaryPostTitle:(NSString *)temporaryPostTitle {
    if (_temporaryPostTitle != temporaryPostTitle) {
        _temporaryPostTitle = temporaryPostTitle;

        [self.postCollectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];

    NSPredicate *nonEmptyPredicate = [NSPredicate predicateWithFormat:@"morsels[SIZE] > 0"];
    self.nonEmptyPostsArray = [[sectionInfo objects] filteredArrayUsingPredicate:nonEmptyPredicate];

    self.postCount = [_nonEmptyPostsArray count];

    return _postCount;
}

- (MRSLPostCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLPost *post = [_nonEmptyPostsArray objectAtIndex:indexPath.row];

    MRSLPostCollectionViewCell *postCell = [self.postCollectionView dequeueReusableCellWithReuseIdentifier:@"ruid_PostCell"
                                                                                          forIndexPath:indexPath];
    postCell.post = post;

    [postCell setHighlighted:([post.postID intValue] == [_post.postID intValue])];

    // Last one hides pipe
    postCell.postPipeView.hidden = (indexPath.row == _postCount - 1);

    if (_temporaryPostTitle &&
        !post.title &&
        (post.postIDValue == _post.postIDValue)) {
        postCell.postTitleLabel.text = _temporaryPostTitle;
    }

    return postCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.temporaryPostTitle = nil;

    self.post = [_nonEmptyPostsArray objectAtIndex:indexPath.row];

    if ([self.post.morsels containsObject:_morsel]) {
        if ([self.delegate respondsToSelector:@selector(userPostsSelectedOriginalMorsel)]) {
            [self.delegate userPostsSelectedOriginalMorsel];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(userPostsSelectedPost:)]) {
            [self.delegate userPostsSelectedPost:_post];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Fetch controller detected change in content. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);

    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];

    if (fetchError) {
        DDLogDebug(@"Refresh Fetch Failed! %@", fetchError.userInfo);
    }

    [self.postCollectionView reloadData];
}

@end
