//
//  DraftsViewController.m
//  Morsel
//
//  Created by Javier Otero on 2/1/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "DraftsViewController.h"

#import "CreateMorselViewController.h"
#import "PostMorselCollectionViewCell.h"

#import "MRSLMorsel.h"
#import "MRSLUser.h"

@interface DraftsViewController ()
<NSFetchedResultsControllerDelegate,
UIAlertViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UITextFieldDelegate>

@property (nonatomic) int postID;

@property (nonatomic, weak) IBOutlet UICollectionView *draftMorselsCollectionView;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation DraftsViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    MRSLUser *user = [MRSLUser currentUser];

    NSPredicate *userDraftsPredicate = [NSPredicate predicateWithFormat:@"(post.creator.userID == %i) AND (draft == YES)", user.userIDValue];

    self.fetchedResultsController = [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                          ascending:NO
                                                      withPredicate:userDraftsPredicate
                                                            groupBy:nil
                                                           delegate:self
                                                          inContext:[NSManagedObjectContext MR_defaultContext]];

    [self.draftMorselsCollectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_selectedIndexPath) [_draftMorselsCollectionView deselectItemAtIndexPath:_selectedIndexPath
                                                                        animated:YES];
}

#pragma mark - Action Methods

- (IBAction)displaySideBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLShouldDisplaySideBarNotification
                                                        object:@YES];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

- (PostMorselCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                          cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLMorsel *morsel = [_fetchedResultsController objectAtIndexPath:indexPath];

    PostMorselCollectionViewCell *postMorselCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostMorselCell"
                                                                                             forIndexPath:indexPath];
    postMorselCell.morsel = morsel;

    return postMorselCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLMorsel *morsel = [_fetchedResultsController objectAtIndexPath:indexPath];

    CreateMorselViewController *createMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:@"CreateMorselViewController"];
    createMorselVC.morsel = morsel;

    [self.navigationController pushViewController:createMorselVC
                                         animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];

    if (fetchError) {
        DDLogDebug(@"Refresh Fetch Failed! %@", fetchError.userInfo);
    }

    [self.draftMorselsCollectionView reloadData];
}

@end
