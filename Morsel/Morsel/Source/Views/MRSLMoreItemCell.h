//
//  SideBarItemCell.h
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSLMoreItem;

@interface MRSLMoreItemCell : UITableViewCell

@property (nonatomic, strong) MRSLMoreItem *sideBarItem;

@property (nonatomic, weak) IBOutlet UIView *pipeView;

@end
