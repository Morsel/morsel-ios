//
//  MRSLProfileEditPlacesViewController.m
//  Morsel
//
//  Created by Javier Otero on 5/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLProfileEditPlacesViewController.h"
#import "MRSLPlacesAddViewController.h"

#import "MRSLAPIService+Place.h"

#import "MRSLCollectionView.h"
#import "MRSLCollectionViewDataSource.h"
#import "MRSLPlaceCollectionViewCell.h"

#import "MRSLPlace.h"
#import "MRSLUser.h"

@interface MRSLProfileEditPlacesViewController ()
<MRSLCollectionViewDataSourceDelegate>

@end

@implementation MRSLProfileEditPlacesViewController

#pragma mark - Instance Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mp_eventView = @"profile_places";
    self.emptyStateString = @"No places";

    self.pagedRemoteRequestBlock = ^(NSNumber *page, NSNumber *count, MRSLRemoteRequestWithObjectIDsOrErrorCompletionBlock remoteRequestWithObjectIDsOrErrorCompletionBlock) {
        [_appDelegate.apiService getPlacesForUser:[MRSLUser currentUser]
                                             page:page
                                            count:nil
                                          success:^(NSArray *responseArray) {
                                              remoteRequestWithObjectIDsOrErrorCompletionBlock(responseArray, nil);
                                          } failure:^(NSError *error) {
                                              remoteRequestWithObjectIDsOrErrorCompletionBlock(nil, error);
                                          }];
    };
}

- (IBAction)contactMorsel {
    [[NSNotificationCenter defaultCenter] postNotificationName:MRSLAppShouldDisplayEmailComposerNotification
                                                        object:@{
                                                                 @"title": @"Contact Morsel",
                                                                 @"subject": @"Morsel iOS App Remove Place Support",
                                                                 @"body": [NSString stringWithFormat:@"<br /><br />--<br />%@", [MRSLUtil supportDiagnostics]]}];
}

#pragma mark - Private Methods

- (NSString *)objectIDsKey {
    return [NSString stringWithFormat:@"%@_placeIDs", [MRSLUser currentUser].username];
}

- (NSFetchedResultsController *)defaultFetchedResultsController {
    return  [MRSLPlace MR_fetchAllSortedBy:@"name"
                                 ascending:YES
                             withPredicate:[NSPredicate predicateWithFormat:@"placeID IN %@", self.objectIDs]
                                   groupBy:nil
                                  delegate:self
                                 inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (MRSLDataSource *)dataSource {
    MRSLDataSource *superDataSource = [super dataSource];
    if (superDataSource) return superDataSource;
    MRSLDataSource *newDataSource = [[MRSLCollectionViewDataSource alloc] initWithObjects:nil configureCellBlock:^UICollectionViewCell *(id item, UICollectionView *collectionView, NSIndexPath *indexPath, NSUInteger count) {
        MRSLPlaceCollectionViewCell *placeCell = [collectionView dequeueReusableCellWithReuseIdentifier:MRSLStoryboardRUIDPlaceCellKey
                                                                                           forIndexPath:indexPath];
        placeCell.place = item;
        return placeCell;
        return nil;
    }];
    [self setDataSource:newDataSource];
    return newDataSource;
}

#pragma mark - MRSLCollectionViewDataSourceDelegate

- (void)collectionViewDataSource:(UICollectionView *)collectionView didSelectItem:(id)item {
    if ([self.delegate respondsToSelector:@selector(profileEditPlacesDidSelectPlace:)]) {
        [self.delegate profileEditPlacesDidSelectPlace:item];
    }
}

@end
