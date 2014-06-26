//
//  MRSLTableViewDataSource.h
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLDataSource.h"

typedef UITableViewCell *(^MRSLCellConfigureBlock)(id item, UITableView *tableView, NSIndexPath *indexPath, NSUInteger count);

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
- (NSInteger)tableViewDataSourceNumberOfItemsInSection:(NSInteger)section;

- (CGFloat)tableViewDataSource:(UITableView *)tableView
   heightForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewDataSourceScrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface MRSLTableViewDataSource : MRSLDataSource
<UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) id <MRSLTableViewDataSourceDelegate> delegate;

- (id)initWithObjects:(id)objects
   configureCellBlock:(MRSLCellConfigureBlock)configureCellBlock;

@end
