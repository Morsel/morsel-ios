//
//  UITableView+States.m
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UITableView+States.h"

@interface UIView (States_Private)

- (BOOL)shouldShowTableViewEmptyState;

@end

@implementation UITableView (States)

#pragma mark - Private Methods

- (BOOL)shouldShowTableViewEmptyState {
    if ([self.dataSource respondsToSelector:@selector(isEmpty)])
        return [(id)self.dataSource isEmpty];
    else {
        return [self numberOfRowsInAllSections] == 0;
    }
}

@end
