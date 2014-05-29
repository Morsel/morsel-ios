//
//  MRSLTabBarView.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLMenuBarView.h"

#import "MRSLUser.h"

@interface MRSLMenuBarView ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *menuBarButtons;

@end

@implementation MRSLMenuBarView

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(highlightFeed)
                                                 name:MRSLUserDidPublishMorselNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedIn)
                                                 name:MRSLServiceDidLogInUserNotification
                                               object:nil];
}

#pragma mark - Notification Methods

- (void)userLoggedIn {
    MRSLMenuBarButton *myStuffButton = [self buttonWithName:@"My Stuff"];
    [myStuffButton setHidden:(![[MRSLUser currentUser] isChef])];
}

- (void)highlightFeed {
    MRSLMenuBarButton *feedButton = [self buttonWithName:@"Feed"];
    if (feedButton) [self selectedButton:feedButton];
}

#pragma mark - Private Methods

- (IBAction)selectedButton:(MRSLMenuBarButton *)targetButton {
    [_menuBarButtons enumerateObjectsUsingBlock:^(MRSLMenuBarButton *menuBarButton, NSUInteger idx, BOOL *stop) {
        BOOL targetEqualsButton = [menuBarButton isEqual:targetButton];
        menuBarButton.selected = targetEqualsButton;
        if (targetEqualsButton) {
            if ([self.delegate respondsToSelector:@selector(menuBarDidSelectButtonOfType:)]) {
                [self.delegate menuBarDidSelectButtonOfType:menuBarButton.menuBarButtonType];
            }
        }
    }];
}

- (MRSLMenuBarButton *)buttonWithName:(NSString *)buttonName {
    __block MRSLMenuBarButton *feedButton = nil;
    [_menuBarButtons enumerateObjectsUsingBlock:^(MRSLMenuBarButton *menuBarButton, NSUInteger idx, BOOL *stop) {
        if ([menuBarButton.titleLabel.text isEqualToString:buttonName]) {
            feedButton = menuBarButton;
            *stop = YES;
        }
    }];
    return feedButton;
}

- (void)reset {
    [_menuBarButtons enumerateObjectsUsingBlock:^(MRSLMenuBarButton *menuBarButton, NSUInteger idx, BOOL *stop) {
        menuBarButton.selected = NO;
    }];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
