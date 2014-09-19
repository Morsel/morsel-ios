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
UICollectionViewDelegateFlowLayout,
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

    self.mp_eventView = @"storyboard_selection";
    self.templateIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"templateIDs"] ?: [NSMutableArray array];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) self.collectionView.contentInset = UIEdgeInsetsMake(20.f, 20.f, 20.f, 20.f);
    
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                withReuseIdentifier:@"ruid_TemplateHelperCell"
                                                                                       forIndexPath:indexPath];
    return reusableView;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(MAX(130.f, floorf(self.view.bounds.size.width * .4f)), MAX(120.f, floorf(self.view.bounds.size.height * .22f)));
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLTemplate *morselTemplate = [_templates objectAtIndex:indexPath.row];
    if ([morselTemplate isCreateMorselType]) {
        [[MRSLEventManager sharedManager] track:@"Tapped Quick Add"
                                     properties:@{@"_title": NSNullIfNil(morselTemplate.title),
                                                  @"_view": self.mp_eventView}];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        __weak __typeof(self) weakSelf = self;
        [_appDelegate.apiService createMorselWithTemplate:morselTemplate
                                                  success:^(id responseObject) {
                                                      if ([responseObject isKindOfClass:[MRSLMorsel class]]) {
                                                          MRSLMorselEditViewController *editMorselVC = [[UIStoryboard morselManagementStoryboard] instantiateViewControllerWithIdentifier:MRSLStoryboardMorselEditViewControllerKey];
                                                          editMorselVC.morselID = [(MRSLMorsel *)responseObject morselID];
                                                          editMorselVC.wasNewMorsel = YES;
                                                          [weakSelf.navigationController pushViewController:editMorselVC
                                                                                                   animated:YES];
                                                      }
                                                  } failure:^(NSError *error) {
                                                      [UIAlertView showAlertViewForErrorString:@"Unable to create morsel. Please try again."
                                                                                      delegate:nil];
                                                      weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                                                  }];
    } else {

        [[MRSLEventManager sharedManager] track:@"Tapped Storyboard"
                                     properties:@{@"_title": NSNullIfNil(morselTemplate.title),
                                                  @"_view": self.mp_eventView}];
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
