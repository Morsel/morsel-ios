//
//  UITableView+Additions.m
//  Morsel
//
//  Created by Marty Trzpit on 7/14/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UITableView+Additions.h"

@implementation UITableView (Additions)

- (NSInteger)numberOfRowsInAllSections {
    NSUInteger rowCount = 0;
    for (NSInteger i = 0; i < [self numberOfSections]; i++)
        rowCount += [self numberOfRowsInSection:i];
    return rowCount;
}

@end
