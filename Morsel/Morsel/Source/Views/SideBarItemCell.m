//
//  SideBarItemCell.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "SideBarItemCell.h"

#import "SideBarItem.h"

@interface SideBarItemCell ()

@property (nonatomic, weak) IBOutlet UIImageView *itemIconImageView;
@property (nonatomic, weak) IBOutlet UILabel *itemTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *draftCountLabel;

@end

@implementation SideBarItemCell

- (void)setSideBarItem:(SideBarItem *)sideBarItem {
    if (_sideBarItem != sideBarItem) {
        _sideBarItem = sideBarItem;
        
        if (_sideBarItem) {
            self.itemIconImageView.image = _sideBarItem.iconImage;
            self.itemTitleLabel.text = _sideBarItem.title;
            
            if (_draftCountLabel) {
                self.draftCountLabel.text = [NSString stringWithFormat:@"%i", _sideBarItem.draftCount];
            }
        }
    }
}

@end
