//
//  MRSLToggleKeywordsTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/24/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLToggleKeywordsTableViewController.h"

#import "MRSLAPIService+Keyword.h"
#import "MRSLAPIService+Tag.h"

#import "MRSLKeyword.h"
#import "MRSLToggleKeywordTableViewCell.h"
#import "MRSLTableViewDataSource.h"
#import "MRSLUser.h"

@interface MRSLBaseTableViewController ()

@property (strong, nonatomic) MRSLTableViewDataSource *dataSource;
@property (strong, nonatomic) NSString *objectIDsKey;
@property (strong, nonatomic) NSArray *objectIDs;

@end

@interface MRSLToggleKeywordsTableViewController ()
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (void)refreshContent;
- (void)setupFetchRequest;
- (void)populateContent;

@end

@implementation MRSLToggleKeywordsTableViewController

- (void)viewDidLoad {
    self.objectIDsKey = [NSString stringWithFormat:@"%@_%@", [MRSLUser currentUser].username, _keywordType];

    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor morselLightContent];
    [self.refreshControl addTarget:self
                            action:@selector(refreshContent)
                  forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:self.refreshControl];
    self.tableView.alwaysBounceVertical = YES;

    self.dataSource = [[MRSLTableViewDataSource alloc] initWithObjects:nil
                                                    configureCellBlock:^UITableViewCell *(MRSLKeyword *keyword, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count) {
                                                        MRSLToggleKeywordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ruid_MRSLToggleKeywordTableViewCell"];
                                                        [cell setKeyword:keyword];
                                                        cell.pipeView.hidden = (indexPath.row == count - 1);
                                                        if ([keyword taggedByCurrentUser]) [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                                                        return cell;
                                                    }];

    [self setTitle:_keywordType];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
    [super viewWillAppear:animated];
    if ([UIDevice currentDeviceSystemVersionIsAtLeastIOS7]) [self changeStatusBarStyle:UIStatusBarStyleDefault];

    if (self.fetchedResultsController) return;

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLKeyword MR_fetchAllSortedBy:@"name"
                                                           ascending:YES
                                                       withPredicate:[NSPredicate predicateWithFormat:@"keywordID IN %@", self.objectIDs]
                                                             groupBy:nil
                                                            delegate:self
                                                           inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)refreshContent {
    __weak __typeof(self)weakSelf = self;
    if ([_keywordType isEqualToString:@"Cuisines"]) {
        [_appDelegate.apiService getUserCuisines:[MRSLUser currentUser]
                                         success:^(NSArray *responseArray) {
                                             if ([weakSelf.objectIDs count] == 0) {
                                                 [_appDelegate.apiService getCuisinesWithSuccess:^(NSArray *objectIDs) {
                                                     if ([objectIDs count] > 0) {
                                                         //  If no data has been loaded or the first new objectID doesn't already exist
                                                         if ([weakSelf.dataSource count] == 0 || ![[objectIDs firstObject] isEqualToNumber:[weakSelf.objectIDs firstObject]]) {
                                                             [weakSelf prependObjectIDs:[objectIDs copy]];
                                                             [weakSelf setupFetchRequest];
                                                             [weakSelf populateContent];
                                                         }
                                                     }
                                                     [weakSelf.refreshControl endRefreshing];

                                                     [weakSelf setupFetchRequest];
                                                     [weakSelf populateContent];
                                                 } failure:^(NSError *error) {
                                                     [weakSelf.refreshControl endRefreshing];
                                                 }];
                                             } else {
                                                 [weakSelf.refreshControl endRefreshing];
                                             }
                                         } failure:^(NSError *error) {
                                             [weakSelf.refreshControl endRefreshing];
                                         }];
    } else if ([_keywordType isEqualToString:@"Specialties"]) {
        [_appDelegate.apiService getUserSpecialties:[MRSLUser currentUser]
                                            success:^(NSArray *responseArray) {
                                                if ([weakSelf.objectIDs count] == 0) {
                                                    [_appDelegate.apiService getSpecialtiesWithSuccess:^(NSArray *objectIDs) {
                                                        if ([objectIDs count] > 0) {
                                                            //  If no data has been loaded or the first new objectID doesn't already exist
                                                            if ([weakSelf.dataSource count] == 0 || ![[objectIDs firstObject] isEqualToNumber:[weakSelf.objectIDs firstObject]]) {
                                                                [weakSelf prependObjectIDs:[objectIDs copy]];
                                                                [weakSelf setupFetchRequest];
                                                                [weakSelf populateContent];
                                                            }
                                                        }
                                                        [weakSelf.refreshControl endRefreshing];

                                                        [weakSelf setupFetchRequest];
                                                        [weakSelf populateContent];
                                                    } failure:^(NSError *error) {
                                                        [weakSelf.refreshControl endRefreshing];
                                                    }];
                                                } else {
                                                    [weakSelf.refreshControl endRefreshing];
                                                }
                                            } failure:^(NSError *error) {
                                                [weakSelf.refreshControl endRefreshing];
                                            }];
    } else {
        DDLogError(@"Unsupported keyword type: %@", _keywordType);
    }
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    [self.dataSource updateObjects:[_fetchedResultsController fetchedObjects]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [self.refreshControl endRefreshing];
}

- (void)appendObjectIDs:(NSArray *)newObjectIDs {
    self.objectIDs = [self.objectIDs arrayByAddingObjectsFromArray:newObjectIDs];
}

- (void)prependObjectIDs:(NSArray *)newObjectIDs {
    self.objectIDs = [newObjectIDs arrayByAddingObjectsFromArray:self.objectIDs];
}

#pragma mark - MRSLTableViewDataSourceDelegate

- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item
                atIndexPath:(NSIndexPath *)indexPath {
    MRSLKeyword *keyword = item;
    [_appDelegate.apiService createTagForKeyword:keyword
                                         success:nil
                                         failure:^(NSError *error) {
                                             [tableView deselectRowAtIndexPath:indexPath
                                                                      animated:NO];
                                         }];
}

- (void)tableViewDataSource:(UITableView *)tableView
              didDeselectItem:(id)item
                atIndexPath:(NSIndexPath *)indexPath {
    MRSLKeyword *keyword = item;

    if (keyword.tag) {
        [_appDelegate.apiService deleteTag:keyword.tag
                                   success:nil
                                   failure:^(NSError *error) {
                                       [tableView selectRowAtIndexPath:indexPath
                                                              animated:NO
                                                        scrollPosition:UITableViewScrollPositionNone];
                                   }];
    }
}

- (CGFloat)tableViewDataSource:(UITableView *)tableView heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Activity detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

@end
