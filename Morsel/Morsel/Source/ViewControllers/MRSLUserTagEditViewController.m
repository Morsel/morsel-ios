//
//  MRSLUserKeywordEditViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserTagEditViewController.h"

#import "MRSLAPIService+Keyword.h"
#import "MRSLAPIService+Tag.h"

#import "MRSLToggleKeywordTableViewCell.h"

#import "MRSLKeyword.h"
#import "MRSLUser.h"

@interface MRSLUserTagEditViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSArray *keywords;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *keywordIDs;

@end

@implementation MRSLUserTagEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.keywordIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_keywordIDs", [_keywordType lowercaseString]]] ?: [NSMutableArray array];

    self.title = [_keywordType capitalizedString];

    self.keywords = [NSMutableArray array];

    self.refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor morselLightContent];
    [_refreshControl addTarget:self
                        action:@selector(refreshContent)
              forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:_refreshControl];
    self.tableView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupFetchRequest];
    [self populateContent];
    [self refreshContent];
}

- (void)viewWillDisappear:(BOOL)animated {
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
    [super viewWillDisappear:animated];
}


#pragma mark - Private Methods

- (void)setupFetchRequest {
    self.fetchedResultsController = [MRSLKeyword MR_fetchAllSortedBy:@"name"
                                                           ascending:YES
                                                       withPredicate:[NSPredicate predicateWithFormat:@"keywordID IN %@", _keywordIDs]
                                                             groupBy:nil
                                                            delegate:self
                                                           inContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)populateContent {
    NSError *fetchError = nil;
    [_fetchedResultsController performFetch:&fetchError];
    self.keywords = [_fetchedResultsController fetchedObjects];
    [self.tableView reloadData];
}

- (void)refreshContent {
    __weak __typeof(self)weakSelf = self;
    if ([_keywordType isEqualToString:@"Cuisine"]) {
        [_appDelegate.apiService getUserCuisines:[MRSLUser currentUser]
                                         success:^(NSArray *responseArray) {
                                             if ([weakSelf.keywordIDs count] == 0) {
                                                 [_appDelegate.apiService getCuisinesWithSuccess:^(NSArray *responseArray) {
                                                     [weakSelf.refreshControl endRefreshing];
                                                     weakSelf.keywordIDs = [responseArray mutableCopy];
                                                     [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                               forKey:[NSString stringWithFormat:@"%@_keywordIDs", [_keywordType lowercaseString]]];
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
    } else if ([_keywordType isEqualToString:@"Specialty"]) {
        [_appDelegate.apiService getUserSpecialties:[MRSLUser currentUser]
                                            success:^(NSArray *responseArray) {
                                                if ([weakSelf.keywordIDs count] == 0) {
                                                    [_appDelegate.apiService getSpecialtiesWithSuccess:^(NSArray *responseArray) {
                                                        [weakSelf.refreshControl endRefreshing];
                                                        weakSelf.keywordIDs = [responseArray mutableCopy];
                                                        [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                                  forKey:[NSString stringWithFormat:@"%@_keywordIDs", [_keywordType lowercaseString]]];
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

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_keywords count];
}

- (MRSLToggleKeywordTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLKeyword *keyword = [_keywords objectAtIndex:indexPath.row];
    MRSLToggleKeywordTableViewCell *keywordCell = [self.tableView dequeueReusableCellWithIdentifier:@"ruid_AddKeywordCell"];
    keywordCell.keyword = keyword;
    keywordCell.pipeView.hidden = (indexPath.row == [_keywords count] - 1);
    if ([keyword taggedByCurrentUser]) [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    return keywordCell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLKeyword *keyword = [_keywords objectAtIndex:indexPath.row];
    [_appDelegate.apiService createTagForKeyword:keyword
                                         success:nil
                                         failure:^(NSError *error) {
                                             [tableView deselectRowAtIndexPath:indexPath
                                                                      animated:NO];
                                         }];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLKeyword *keyword = [_keywords objectAtIndex:indexPath.row];
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

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [self.tableView removeFromSuperview];
    self.tableView = nil;
}

@end
