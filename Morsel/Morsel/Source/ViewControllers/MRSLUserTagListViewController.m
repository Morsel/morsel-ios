//
//  MRSLTagUserListViewController.m
//  Morsel
//
//  Created by Javier Otero on 4/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLUserTagListViewController.h"

#import "MRSLKeywordUsersViewController.h"
#import "MRSLTagListTableViewCell.h"

#import "MRSLKeyword.h"
#import "MRSLUser.h"
#import "MRSLTag.h"

@interface MRSLUserTagListViewController ()
<UITableViewDataSource,
UITableViewDelegate,
NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSArray *userTags;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *tagIDs;

@end

@implementation MRSLUserTagListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tagIDs = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:[NSString stringWithFormat:@"%@_%@_tagIDs", _user.username, [_keywordType lowercaseString]]] ?: [NSMutableArray array];

    self.title = [_keywordType capitalizedString];

    self.userTags = [NSMutableArray array];

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

    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath
                                      animated:YES];
        self.selectedIndexPath = nil;
    }

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
    self.userTags = [_fetchedResultsController fetchedObjects];
    [self.tableView reloadData];
}

- (void)refreshContent {
    __weak __typeof(self)weakSelf = self;
    if ([_keywordType isEqualToString:MRSLKeywordSpecialtiesType]) {
        [_appDelegate.apiService getUserSpecialties:_user
                                            success:^(NSArray *responseArray) {
                                                [weakSelf.refreshControl endRefreshing];
                                                weakSelf.tagIDs = [responseArray mutableCopy];
                                                [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                          forKey:[NSString stringWithFormat:@"%@_%@_tagIDs", _user.username, [_keywordType lowercaseString]]];
                                                [weakSelf setupFetchRequest];
                                                [weakSelf populateContent];
                                            } failure:^(NSError *error) {
                                                [weakSelf.refreshControl endRefreshing];
                                            }];
    } else {
        [_appDelegate.apiService getUserCuisines:_user
                                         success:^(NSArray *responseArray) {
                                             [weakSelf.refreshControl endRefreshing];
                                             weakSelf.tagIDs = [responseArray mutableCopy];
                                             [[NSUserDefaults standardUserDefaults] setObject:responseArray
                                                                                       forKey:[NSString stringWithFormat:@"%@_%@_tagIDs", _user.username, [_keywordType lowercaseString]]];
                                             [weakSelf setupFetchRequest];
                                             [weakSelf populateContent];
                                         } failure:^(NSError *error) {
                                             [weakSelf.refreshControl endRefreshing];
                                         }];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_userTags count];
}

- (MRSLTagListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLTag *tag = [_userTags objectAtIndex:indexPath.row];
    MRSLTagListTableViewCell *tagCell = [self.tableView dequeueReusableCellWithIdentifier:@"ruid_TagListCell"];
    tagCell.nameLabel.text = tag.keyword.name;
    tagCell.pipeView.hidden = (indexPath.row == [_userTags count] - 1);
    return tagCell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    MRSLTag *tag = [_userTags objectAtIndex:indexPath.row];
    MRSLKeywordUsersViewController *keywordUsersVC = [[UIStoryboard profileStoryboard] instantiateViewControllerWithIdentifier:@"sb_MRSLKeywordUsersViewController"];
    keywordUsersVC.keyword = tag.keyword;
    [self.navigationController pushViewController:keywordUsersVC
                                         animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    DDLogDebug(@"Feed detected content change. Reloading with %lu items.", (unsigned long)[[controller fetchedObjects] count]);
    [self populateContent];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
