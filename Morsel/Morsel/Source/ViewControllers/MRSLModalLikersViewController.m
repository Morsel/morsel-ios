//
//  MRSLModalLikesViewController.m
//  Morsel
//
//  Created by Javier Otero on 3/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLModalLikersViewController.h"

#import "MRSLAPIService+Like.h"

#import "MRSLLikersTableViewCell.h"

@interface MRSLModalLikersViewController ()
<UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *likersTableView;

@property (strong, nonatomic) NSMutableArray *likers;

@end

@implementation MRSLModalLikersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.likers = [NSMutableArray array];

    __weak __typeof(self) weakSelf = self;
    [_appDelegate.apiService getItemLikes:_item
                                      success:^(NSArray *responseArray) {
                                          if (weakSelf) {
                                              [weakSelf.likers addObjectsFromArray:responseArray];
                                              [weakSelf.likersTableView reloadData];
                                          }
                                      } failure:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_likers count];
}

- (MRSLLikersTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRSLUser *user = [_likers objectAtIndex:indexPath.row];

    MRSLLikersTableViewCell *likerCell = [tableView dequeueReusableCellWithIdentifier:@"ruid_LikerCell"];
    likerCell.user = user;

    return likerCell;
}

@end
