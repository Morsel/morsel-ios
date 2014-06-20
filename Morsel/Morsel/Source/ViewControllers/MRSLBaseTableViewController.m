//
//  MRSLBaseTableViewController.m
//  Morsel
//
//  Created by Marty Trzpit on 6/5/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLBaseTableViewController.h"

@interface MRSLBaseTableViewController ()

@property (strong, nonatomic) NSString *objectIDsKey;
@property (strong, nonatomic) NSArray *objectIDs;

@end

@implementation MRSLBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.objectIDsKey) _objectIDs = [[NSUserDefaults standardUserDefaults] arrayForKey:self.objectIDsKey] ?: @[];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationItems];

    if (_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
        self.selectedIndexPath = nil;
    }
}

- (void)registerCellsWithNames:(NSArray *)cellNames {
    [cellNames enumerateObjectsUsingBlock:^(NSString *cellName, NSUInteger idx, BOOL *stop) {
        [self.tableView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle mainBundle]]
             forCellReuseIdentifier:[NSString stringWithFormat:@"%@_%@", @"ruid", cellName]];
    }];
}

- (void)setObjectIDs:(NSArray *)objectIDs {
    _objectIDs = objectIDs;
    [[NSUserDefaults standardUserDefaults] setObject:_objectIDs
                                              forKey:_objectIDsKey];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
