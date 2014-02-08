//
//  SideBarItemCell.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "SideBarItemCell.h"

#import "SideBarItem.h"

#import "MRSLUser.h"

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
        }
    }

    if (_draftCountLabel && _sideBarItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userModifiedMorsel)
                                                     name:MRSLUserDidCreateMorselNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userModifiedMorsel)
                                                     name:MRSLUserDidUpdateMorselNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userModifiedMorsel)
                                                     name:MRSLUserDidDeleteMorselNotification
                                                   object:nil];

        self.draftCountLabel.text = [NSString stringWithFormat:@"%i", _sideBarItem.badgeCount];
    }
}

- (void)userModifiedMorsel {
    MRSLUser *currentUser = [MRSLUser currentUser];
    dispatch_async(dispatch_get_main_queue(), ^{
         self.draftCountLabel.text = [NSString stringWithFormat:@"%i", currentUser.draft_countValue];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
