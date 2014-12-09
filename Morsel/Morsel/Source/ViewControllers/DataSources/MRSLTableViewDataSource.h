//
//  MRSLTableViewDataSource.h
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLDataSource.h"

typedef UITableViewCell *(^MRSLTVCellConfigureBlock)(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count);

@protocol MRSLTableViewDataSourceDelegate <NSObject>

@optional
- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item;
- (void)tableViewDataSource:(UITableView *)tableView
   didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewDataSource:(UITableView *)tableView
              didSelectItem:(id)item
                atIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewDataSource:(UITableView *)tableView
            didDeselectItem:(id)item
                atIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewDataSourceDidScroll:(UITableView *)tableView
                          withOffset:(CGFloat)offset;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableViewDataSourceNumberOfItemsInSection:(NSInteger)section;

- (CGFloat)tableViewDataSource:(UITableView *)tableView
      heightForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface MRSLTableViewDataSource : MRSLDataSource
<UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) id <MRSLTableViewDataSourceDelegate> delegate;

- (id)initWithObjects:(id)objects
   configureCellBlock:(MRSLTVCellConfigureBlock)configureCellBlock;

@end
