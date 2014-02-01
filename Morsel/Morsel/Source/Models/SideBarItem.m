//
//  SideBarItem.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "SideBarItem.h"

@implementation SideBarItem

+ (SideBarItem *)sideBarItemWithTitle:(NSString *)title
                        iconImageName:(NSString *)iconImageName
                             cellType:(NSString *)cellType {
    SideBarItem *sideBarItem = [[SideBarItem alloc] init];
    sideBarItem.title = title;
    sideBarItem.iconImage = [UIImage imageNamed:iconImageName];
    sideBarItem.preferredCellType = cellType;
    
    return sideBarItem;
}

@end
