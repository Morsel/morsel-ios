//
//  MRSLCollectionDetailViewController.m
//  Morsel
//
//  Created by Javier Otero on 1/27/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLCollectionDetailViewController.h"

#import "MRSLMorsel.h"

#import "MRSLCollectionViewDataSource.h"

@implementation MRSLCollectionDetailViewController

- (void)setCollection:(MRSLCollection *)collection {
    _collection = collection;
#warning Display collection morsels
}

#pragma mark - MRSLBaseRemoteDataSourceViewController Methods

- (NSString *)objectIDsKey {
#warning Will adjust per user
    return @"current_user_collections";
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLMorsel MR_fetchAllSortedBy:@"creationDate"
                                                          ascending:NO
                                                      withPredicate:[NSPredicate predicateWithFormat:@"morselID IN %@", self.objectIDs]
                                                            groupBy:nil
                                                           delegate:self
                                                          inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    MRSLDataSource *newDataSource = [[MRSLCollectionViewDataSource alloc] initWithObjects:nil];
    [self setDataSource:newDataSource];
    return newDataSource;
}

#pragma mark - CollectionView Methods



@end
