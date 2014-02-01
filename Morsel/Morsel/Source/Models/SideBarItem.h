//
//  SideBarItem.h
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SideBarItem : NSObject

@property (nonatomic) NSUInteger draftCount;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) NSString *preferredCellType;

@end
