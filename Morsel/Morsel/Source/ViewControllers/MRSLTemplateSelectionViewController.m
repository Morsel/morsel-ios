//
//  MRSLTemplateSelectionViewController.m
//  Morsel
//
//  Created by Javier Otero on 8/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTemplateSelectionViewController.h"

#import "MRSLAPIService+Morsel.h"
#import "MRSLAPIService+Templates.h"

#import "MRSLMorselEditViewController.h"
#import "MRSLTemplateSelectionCollectionViewCell.h"
#import "MRSLTemplateInfoViewController.h"

#import "MRSLMorsel.h"
#import "MRSLTemplate.h"

@interface MRSLTemplateSelectionViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *templates;
@property (strong, nonatomic) NSMutableArray *templateIDs;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation MRSLTemplateSelectionViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.templateIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"templateIDs"] ?: [NSMutableArray array];

    self.collectionView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.selectedIndexPath) [self.collectionView deselectItemAtIndexPath:_selectedIndexPath
                                                                    animated:YES];

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLTemplate MR_fetchAllSortedBy:@"templateID"
                                                            ascending:YES
                                                        withPredicate:[NSPredicate predicateWithFormat:@"templateID IN %@", _templateIDs]
                                                              groupBy:nil
                                                             delegate:self
                                                            inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    self.templates = [_fetchedResultsController fetchedObjects];
    [self.collectionView reloadData];
}

- (void)refreshContent {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getTemplatesWithSuccess:^(NSArray *responseArray) {
        weakSelf.templateIDs = [responseArray mutableCopy];
        [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                  forKey:[NSString stringWithFormat:@"templateIDs"]];
        [weakSelf setupFetchRequest];
        [weakSelf populateContent];
    } failure:nil];
}

#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([[segue identifier] isEqualToString:MRSLStoryboardSegueTemplateInfoKey]) {
        MRSLTemplateInfoViewController *templateInfoVC = [segue destinationViewController];
        templateInfoVC.morselTemplate = [_templates objectAtIndex:_selectedIndexPath.row];
    }
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_templates count];
}

- (MRSLTemplateSelectionCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                                     cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRSLTemplate *morselTemplate = [_templates objectAtIndex:indexPath.row];
    MRSLTemplateSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDTemplateCell
                                                                                              forIndexPath:indexPath];
    cell.morselTemplate = morselTemplate;
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLTemplate *morselTemplate = [_templates objectAtIndex:indexPath.row];
    if ([morselTemplate isCreateMorselType]) {
        MRSLMorsel *morsel = [MRSLMorsel MR_createEntity];
        morsel.draft = @YES;
        morsel.title = @"New morsel";

        self.collectionView.userInteractionEnabled = NO;
        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService createMorsel:morsel
                                      success:^(id responseObject) {
                                          [MRSLEventManager sharedManager].new_morsels_created++;
                                          MRSLMorselEditViewController *editMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselEditViewControllerKey];
                                          editMorselVC.shouldPresentMediaCapture = YES;
                                          editMorselVC.morselID = morsel.morselID;
                                          [weakSelf.navigationController pushViewController:editMorselVC
                                                                                   animated:YES];
                                      } failure:^(NSError *error) {
                                          [UIAlertView showAlertViewForErrorString:@"Unable to create Morsel! Please try again."
                                                                          delegate:nil];
                                          [morsel MR_deleteEntity];
                                          weakSelf.collectionView.userInteractionEnabled = YES;
                                      }];
    } else {
        [self performSegueWithIdentifier:MRSLStoryboardSegueTemplateInfoKey
                                  sender:nil];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"NSFetchedResultsController detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

@end