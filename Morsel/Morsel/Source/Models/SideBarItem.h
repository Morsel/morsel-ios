//
//  SideBarItem.h
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SideBarMenuItemType) {
    SideBarMenuItemTypeHome,
    SideBarMenuItemTypeProfile,
    SideBarMenuItemTypeDrafts,
    SideBarMenuItemTypeLogout,
    SideBarMenuItemTypeHide
};

@interface SideBarItem : NSObject

@property (nonatomic) int badgeCount;

@property (nonatomic) SideBarMenuItemType menuType;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) NSString *cellIdentifier;

+ (SideBarItem *)sideBarItemWithTitle:(NSString *)title
                        iconImageName:(NSString *)iconImageName
                       cellIdentifier:(NSString *)cellIdentifier
                                 type:(SideBarMenuItemType)menuType;

@end
