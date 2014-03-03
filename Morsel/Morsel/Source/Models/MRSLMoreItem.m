//
//  SideBarItem.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMoreItem.h"

@implementation MRSLMoreItem

+ (MRSLMoreItem *)sideBarItemWithTitle:(NSString *)title
                        iconImageName:(NSString *)iconImageName
                             cellIdentifier:(NSString *)cellIdentifier
                             type:(SideBarMenuItemType)menuType {
    MRSLMoreItem *sideBarItem = [[MRSLMoreItem alloc] init];
    sideBarItem.title = title;
    sideBarItem.iconImage = [UIImage imageNamed:iconImageName];
    sideBarItem.cellIdentifier = cellIdentifier;
    sideBarItem.menuType = menuType;
    
    return sideBarItem;
}

@end
