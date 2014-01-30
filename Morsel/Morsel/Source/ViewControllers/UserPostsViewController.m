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
    <UICollectionViewDataSource,
     UICollectionViewDelegate,
     NSFetchedResultsControllerDelegate>

@property (nonatomic) int postCount;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation UserPostsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.postCount = 0;

    NSPredicate *currentUserPredicate = [NSPredicate predicateWithFormat:@"(author.userID == %i)", [[ModelController sharedController].currentUser.userID intValue]];

    self.fetchedResultsController = [MRSLPost MR_fetchAllSortedBy:@"creationDate"
                                                        ascending:NO
                                                    withPredicate:currentUserPredicate
                                                          groupBy:nil
                                                         delegate:self
                                                        inContext:[ModelController sharedController].defaultContext];

    [self.postCollectionView reloadData];
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

    self.postCount = [sectionInfo numberOfObjects];

    return _postCount;
}

- (PostCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLPost *post = [_fetchedResultsController objectAtIndexPath:indexPath];

    PostCollectionViewCell *postCell = [self.postCollectionView dequeueReusableCellWithReuseIdentifier:@"PostCell"
                                                                                          forIndexPath:indexPath];
    postCell.post = post;

    [postCell setHighlighted:([post.postID intValue] == [_post.postID intValue])];

    // Last one hides pipe
    postCell.postPipeView.hidden = (indexPath.row == _postCount - 1);

    if (_temporaryPostTitle && !post.title && ([post.postID intValue] == [_post.postID intValue])) {
        postCell.postTitleLabel.text = _temporaryPostTitle;
    }

    return postCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.temporaryPostTitle = nil;

    MRSLPost *post = [_fetchedResultsController objectAtIndexPath:indexPath];

    if (_post) {
        self.post = ([post.postID intValue] == [_post.postID intValue]) ? nil : post;
    } else {
        self.post = post;
    }

    if (!_post) {
        PostCollectionViewCell *postCell = (PostCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [postCell setHighlighted:NO];
    }

    if ([self.delegate respondsToSelector:@selector(userPostsSelectedPost:)]) {
        [self.delegate userPostsSelectedPost:_post];
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
