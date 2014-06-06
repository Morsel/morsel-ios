//
//  MRSLProfileStatsKeywordsViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/28/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileUserTagsListViewController.h"

#import "MRSLAPIService+Tag.h"

#import "MRSLCollectionViewArrayDataSource.h"
#import "MRSLTagBaseCell.h"

#import "MRSLKeyword.h"
#import "MRSLTag.h"
#import "MRSLUser.h"

@interface MRSLProfileUserTagsListViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableArray *tagIDs;
@property (strong, nonatomic) NSMutableDictionary *tagsDictionary;
@property (strong, nonatomic) NSMutableArray *specialtyTags;
@property (strong, nonatomic) NSMutableArray *cuisineTags;

@end

@implementation MRSLProfileUserTagsListViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.specialtyTags = [NSMutableArray array];
    self.cuisineTags = [NSMutableArray array];
    self.tagsDictionary = [NSMutableDictionary dictionary];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_user) self.tagIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_specialty_cuisine_tagIDs", _user.username]] ?: [NSMutableArray array];

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLTag MR_fetchAllSortedBy:@"keyword.name"
                                                       ascending:YES
                                                   withPredicate:[NSPredicate predicateWithFormat:@"tagID IN %@", _tagIDs]
                                                         groupBy:nil
                                                        delegate:self
                                                       inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];

    NSPredicate *specialtyPredicate = [NSPredicate predicateWithBlock:^BOOL(MRSLTag *evaluatedTag, NSDictionary *bindings) {
        return [evaluatedTag.keyword isSpecialtyType];
    }];
    NSPredicate *cuisinePredicate = [NSPredicate predicateWithBlock:^BOOL(MRSLTag *evaluatedTag, NSDictionary *bindings) {
        return [evaluatedTag.keyword isCuisineType];
    }];

    [self.specialtyTags removeAllObjects];
    [self.cuisineTags removeAllObjects];
    [self.tagsDictionary removeAllObjects];

    [self.specialtyTags addObjectsFromArray:[[_fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:specialtyPredicate]];
    [self.cuisineTags addObjectsFromArray:[[_fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:cuisinePredicate]];

    if ([_specialtyTags count] > 4) [_specialtyTags removeObjectsInRange:NSMakeRange(3, [_specialtyTags count] - 4)];
    if ([_cuisineTags count] > 4) [_cuisineTags removeObjectsInRange:NSMakeRange(3, [_cuisineTags count] - 4)];

    [self.tagsDictionary setObject:([_specialtyTags count] > 0) ? _specialtyTags : [NSArray array]
                            forKey:[MRSLKeywordSpecialtiesType capitalizedString]];
    [self.tagsDictionary setObject:([_cuisineTags count] > 0) ? _cuisineTags : [NSArray array]
                            forKey:[MRSLKeywordCuisinesType capitalizedString]];

    [self.collectionView reloadData];
}

- (NSMutableArray *)arrayForIndexPath:(NSIndexPath *)indexPath {
    if ([_tagsDictionary count] == 0) return [NSMutableArray array];
    NSString *keyForIndex = [[_tagsDictionary allKeys] objectAtIndex:indexPath.section];
    NSMutableArray *tagsArray = ([keyForIndex isEqualToString:[MRSLKeywordSpecialtiesType capitalizedString]] ? _specialtyTags : _cuisineTags);
    return tagsArray;
}

- (void)refreshContent {
    __weak __typeof(self)weakSelf = self;
    [_appDelegate.apiService getUserCuisines:_user
                                     success:^(NSArray *responseArray) {
                                         [weakSelf populateTagIDsWithArray:responseArray];
                                     } failure:nil];
    [_appDelegate.apiService getUserSpecialties:_user
                                        success:^(NSArray *responseArray) {
                                            [weakSelf populateTagIDsWithArray:responseArray];
                                        } failure:nil];
}

- (void)populateTagIDsWithArray:(NSArray *)responseArray {
    if (_tagIDs) {
        [self.tagIDs addObjectsFromArray:responseArray];
        if ([_tagIDs count] > 0) {
            NSSet *uniqueTagIDs = [NSSet setWithArray:self.tagIDs];
            self.tagIDs = [[uniqueTagIDs allObjects] mutableCopy];
            [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                      forKey:[NSString stringWithFormat:@"%@_specialty_cuisine_tagIDs", _user.username]];
        }
    }

    [self setupFetchRequest];
    [self populateContent];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([_tagsDictionary count] == 0) {
        return 2;
    }
    NSString *keyForIndex = [[_tagsDictionary allKeys] objectAtIndex:section];
    NSUInteger tagsCount = [[_tagsDictionary objectForKey:keyForIndex] count];
    return ((tagsCount > 4) ? 4 : tagsCount) + 2;
}

- (MRSLTagBaseCell *)collectionView:(UICollectionView *)collectionView
             cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = nil;
    NSString *cellName = nil;

    if (indexPath.row == 0) {
        reuseIdentifier = @"ruid_KeywordTypeCell";
        cellName = [NSString stringWithFormat:@"%@:", [[_tagsDictionary allKeys] objectAtIndex:indexPath.section]];
    } else if (indexPath.row == [[self arrayForIndexPath:indexPath] count] + 1) {
        reuseIdentifier = @"ruid_SupplementaryCell";
        if (_allowsEdit) {
            cellName = @"Edit";
        } else {
            cellName = ([[self arrayForIndexPath:indexPath] count] == 0 ) ? @"None" : @"View All";
        }
    } else {
        MRSLTag *tag = [[self arrayForIndexPath:indexPath] objectAtIndex:indexPath.row - 1];
        reuseIdentifier = @"ruid_KeywordCell";
        cellName = tag.keyword.name;
    }
    MRSLTagBaseCell *baseCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                               forIndexPath:indexPath];
    baseCell.nameLabel.text = cellName;

    if (indexPath.row != [[self arrayForIndexPath:indexPath] count]) {
        [baseCell setBorderWithDirections:MRSLBorderSouth
                          borderWidth:1.0f
                       andBorderColor:[UIColor morselLightOffColor]];
    }

    return baseCell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row == [[self arrayForIndexPath:indexPath] count] + 1) {
        if (!_allowsEdit) return;
        if ([self.delegate respondsToSelector:@selector(profileUserTagsListViewControllerDidSelectType:)]) {
            [self.delegate profileUserTagsListViewControllerDidSelectType:[[[_tagsDictionary allKeys] objectAtIndex:indexPath.section] lowercaseString]];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(profileUserTagsListViewControllerDidSelectTag:)]) {
            MRSLTag *tag = [[self arrayForIndexPath:indexPath] objectAtIndex:indexPath.row - 1];
            [self.delegate profileUserTagsListViewControllerDidSelectTag:tag];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

@end
