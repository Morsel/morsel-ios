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
                             cellIdentifier:(NSString *)cellIdentifier
                             type:(SideBarMenuItemType)menuType {
    SideBarItem *sideBarItem = [[SideBarItem alloc] init];
    sideBarItem.title = title;
    sideBarItem.iconImage = [UIImage imageNamed:iconImageName];
    sideBarItem.cellIdentifier = cellIdentifier;
    sideBarItem.menuType = menuType;
    
    return sideBarItem;
}

@end
