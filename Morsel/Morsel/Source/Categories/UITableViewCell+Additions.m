//
//  UITableViewCell+Additions.m
//  Morsel
//
//  Created by Javier Otero on 8/21/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "UITableViewCell+Additions.h"

@implementation UITableViewCell (Additions)

- (BOOL)shouldAllowReorder {
    // Should only be overridden in conjuction with BVReorderTableView usage.
    return NO;
}

@end
