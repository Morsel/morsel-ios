//
//  MRSLTableViewDataSource.m
//  Morsel
//
//  Created by Marty Trzpit on 6/19/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTableViewDataSource.h"

@interface MRSLDataSource ()

@property (strong, nonatomic) id objects;

@end

@interface MRSLTableViewDataSource ()

@property (copy, nonatomic) MRSLTVCellConfigureBlock configureCellBlock;

@end

@implementation MRSLTableViewDataSource

- (id)initWithObjects:(id)objects
   configureCellBlock:(MRSLTVCellConfigureBlock)configureCellBlock {
    self = [super initWithObjects:objects];
    if (self) {
        self.configureCellBlock = [configureCellBlock copy];
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        return [self.delegate numberOfSectionsInTableView:tableView];
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableViewDataSource:didSelectItem:)]) {
        [self.delegate tableViewDataSource:tableView didSelectItem:[self objectAtIndexPath:indexPath]];
    }
    if ([self.delegate respondsToSelector:@selector(tableViewDataSource:didSelectItemAtIndexPath:)]) {
        [self.delegate tableViewDataSource:tableView didSelectItemAtIndexPath:indexPath];
    }
    if ([self.delegate respondsToSelector:@selector(tableViewDataSource:didSelectItem:atIndexPath:)]) {
        [self.delegate tableViewDataSource:tableView didSelectItem:[self objectAtIndexPath:indexPath] atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableViewDataSource:didDeselectItem:atIndexPath:)]) {
        [self.delegate tableViewDataSource:tableView didDeselectItem:[self objectAtIndexPath:indexPath] atIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableViewDataSource:heightForItemAtIndexPath:)]) {
        return [self.delegate tableViewDataSource:tableView heightForItemAtIndexPath:indexPath];
    }
    return 40.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [self.delegate tableView:tableView
                titleForHeaderInSection:section];
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.delegate tableView:tableView
                 viewForHeaderInSection:section];
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.delegate tableView:tableView heightForHeaderInSection:section];
    } else {
        return 0.f;
    }
}

#pragma mark - Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableViewDataSourceNumberOfItemsInSection:)]) {
        return [self.delegate tableViewDataSourceNumberOfItemsInSection:section];
    } else {
        return [self count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = self.configureCellBlock([self objectAtIndexPath:indexPath], tableView, indexPath, [self count]);
    return tableViewCell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(tableViewDataSourceScrollViewDidScroll:)]) {
        return [self.delegate tableViewDataSourceScrollViewDidScroll:scrollView];
    }
}

@end
