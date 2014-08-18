//
//  MRSLMenuBarButtonItem.m
//  Morsel
//
//  Created by Javier Otero on 8/12/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMenuBarButtonItem.h"

#import "UIBarButtonItem+Additions.h"

#import "MRSLAlignedButton.h"

@implementation MRSLMenuBarButtonItem

#pragma mark - Class Methods

+ (MRSLMenuBarButtonItem *)menuBarButtonItem {
    UIImage *image = [UIImage imageNamed:@"icon-burger-bar"];
    MRSLAlignedButton *button = [MRSLAlignedButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.f, 0.f, image.size.width, image.size.height)];
    [button setBackgroundImage:image
                      forState:UIControlStateNormal];
    MRSLMenuBarButtonItem *menuButton = [[MRSLMenuBarButtonItem alloc] initWithCustomView:button];
    menuButton.accessibilityLabel = @"Menu";

    NSNumber *unreadAmount = [[NSUserDefaults standardUserDefaults] objectForKey:@"MRSLUserUnreadCount"];
    if (unreadAmount) menuButton.badgeValue = [unreadAmount stringValue];
    return menuButton;
}

#pragma mark - Instance Methods

- (id)initWithCustomView:(UIView *)customView {
    self = [super initWithCustomView:customView];
    if (self) {
        self.style = UIBarButtonItemStyleBordered;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateMenuBadge:)
                                                     name:MRSLServiceDidUpdateUnreadAmountNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Notification Methods

- (void)updateMenuBadge:(NSNotification *)notification {
    self.badgeValue = [notification.object stringValue];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
