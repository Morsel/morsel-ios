//
//  SideBarItemCell.m
//  Morsel
//
//  Created by Javier Otero on 1/31/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMoreItemCell.h"

#import "MRSLMoreItem.h"

#import "MRSLUser.h"

@interface MRSLMoreItemCell ()

@property (weak, nonatomic) IBOutlet UIImageView *itemIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *draftCountLabel;

@end

@implementation MRSLMoreItemCell

- (void)setSideBarItem:(MRSLMoreItem *)sideBarItem {
    if (_sideBarItem != sideBarItem) {
        _sideBarItem = sideBarItem;
        
        if (_sideBarItem) {
            self.itemIconImageView.image = _sideBarItem.iconImage;
            self.itemTitleLabel.text = _sideBarItem.title;
        }
    }

    if (_draftCountLabel && _sideBarItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userModifiedMorsel)
                                                     name:MRSLUserDidBeginCreateMorselNotification
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
