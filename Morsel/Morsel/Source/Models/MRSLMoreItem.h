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

@interface MRSLMoreItem : NSObject

@property (nonatomic) int badgeCount;

@property (nonatomic) SideBarMenuItemType menuType;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) NSString *cellIdentifier;

+ (MRSLMoreItem *)sideBarItemWithTitle:(NSString *)title
                        iconImageName:(NSString *)iconImageName
                       cellIdentifier:(NSString *)cellIdentifier
                                 type:(SideBarMenuItemType)menuType;

@end
