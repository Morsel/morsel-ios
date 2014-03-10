//
//  MRSLTabBarView.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTabBarView.h"

@interface MRSLTabBarView ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tabBarButtons;

@end

@implementation MRSLTabBarView

- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayFeed)
                                                 name:MRSLAppShouldDisplayFeedNotification
                                               object:nil];
    [self selectedButton:[self feedButton]];
}

- (void)displayFeed {
    [self selectedButton:[self feedButton]];
}

- (IBAction)selectedButton:(MRSLTabBarButton *)targetButton {
    [_tabBarButtons enumerateObjectsUsingBlock:^(MRSLTabBarButton *tabBarButton, NSUInteger idx, BOOL *stop) {
        BOOL targetEqualsButton = [tabBarButton isEqual:targetButton];
        tabBarButton.selected = targetEqualsButton;
        if (targetEqualsButton) {
            if ([self.delegate respondsToSelector:@selector(tabBarDidSelectButtonOfType:)]) {
                [self.delegate tabBarDidSelectButtonOfType:tabBarButton.tabBarButtonType];
            }
        }
    }];
}

- (MRSLTabBarButton *)feedButton {
    __block MRSLTabBarButton *feedButton = nil;
    [_tabBarButtons enumerateObjectsUsingBlock:^(MRSLTabBarButton *tabBarButton, NSUInteger idx, BOOL *stop) {
        if ([tabBarButton.titleLabel.text isEqualToString:@"Feed"]) {
            feedButton = tabBarButton;
            *stop = YES;
        }
    }];
    return feedButton;
}

- (void)reset {
    [_tabBarButtons enumerateObjectsUsingBlock:^(MRSLTabBarButton *tabBarButton, NSUInteger idx, BOOL *stop) {
        tabBarButton.selected = NO;
    }];
}

#pragma mark - Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
