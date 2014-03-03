//
//  MRSLTabBarView.m
//  Morsel
//
//  Created by Javier Otero on 3/3/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLTabBarView.h"

@interface MRSLTabBarView ()

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *tabBarButtons;

@end

@implementation MRSLTabBarView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self selectedButton:[self feedButton]];
}

- (IBAction)selectedButton:(MRSLTabBarButton *)targetButton {
    [_tabBarButtons enumerateObjectsUsingBlock:^(MRSLTabBarButton *tabBarButton, NSUInteger idx, BOOL *stop) {
        BOOL targetEqualsButton = [tabBarButton isEqual:targetButton];
        tabBarButton.enabled = !targetEqualsButton;
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
        tabBarButton.enabled = YES;
    }];
}

@end
