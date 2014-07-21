//
//  MRSLCollectionViewFetchResultsDataSource.m
//  Morsel
//
//  Created by Javier Otero on 5/26/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCollectionViewFetchResultsDataSource.h"

#import "MRSLPlace.h"

@interface MRSLCollectionViewDataSource ()

@property (weak, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *objects;

@property (copy, nonatomic) NSString *cellIdentifier;
@property (copy, nonatomic) MRSLCellConfigureBlock configureCellBlock;

@end

@interface MRSLCollectionViewFetchResultsDataSource ()

@property (nonatomic) Class managedObjectClass;

@property (strong, nonatomic) NSFetchedResultsController *fetchResultsController;
@property (strong, nonatomic) NSPredicate *fetchPredicate;

@end

@implementation MRSLCollectionViewFetchResultsDataSource

- (id)initWithManagedObjectClass:(Class)objectClass
                       predicate:(NSPredicate *)predicateOrNil
              configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock
                  collectionView:(UICollectionView *)collectionView {
    self = [super initWithCollectionView:collectionView];
    if (self) {

        if ([[MRSLPlace class] isSubclassOfClass:objectClass]) {
            self.sortType = MRSLDataSortTypeName;
            self.ascending = YES;
        }

        self.managedObjectClass = objectClass;
        self.fetchPredicate = predicateOrNil;
        self.configureCellBlock = configureCellBlock;
        self.collectionView = collectionView;

        [self setupFetchRequest];
        [self populateContent];
    }
    return self;
}

- (void)updateFetchRequestWithManagedObjectClass:(Class)objectClass
                                   withPredicate:(NSPredicate *)predicateOrNil {
    self.managedObjectClass = objectClass;
    self.fetchPredicate = predicateOrNil;
    [self setupFetchRequest];
    [self populateContent];
}

- (void)setupFetchRequest {
    if (![[NSNull null] isKindOfClass:_managedObjectClass]) {
        self.fetchResultsController = [_managedObjectClass MR_fetchAllSortedBy:[MRSLUtil stringForDataSortType:self.sortType]
                                                                     ascending:self.ascending
                                                                 withPredicate:self.fetchPredicate
                                                                       groupBy:nil
                                                                      delegate:self
                                                                     inContext:[NSManagedObjectContext MR_defaultContext]];
    } else {
        self.fetchResultsController = nil;
        DDLogError(@"Unable to setup fetch results controller due to NSNull class.");
    }
}

- (void)populateContent {
    NSError *fetchError = nil;
    [self.fetchResultsController performFetch:&fetchError];
    self.objects = [_fetchResultsController fetchedObjects];
    [self.collectionView reloadData];
}

- (void)setDataSortType:(MRSLDataSortType)sortType ascending:(BOOL)ascending {
    self.sortType = sortType;
    self.ascending = ascending;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"NSFetchedResultsController detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

@end
