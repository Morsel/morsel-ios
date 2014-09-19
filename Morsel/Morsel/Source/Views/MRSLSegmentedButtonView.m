//
//  MRSLSegmentedButtonView.m
//  Morsel
//
//  Created by Javier Otero on 5/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSegmentedButtonView.h"

@interface MRSLSegmentedButtonView ()

@property (nonatomic) BOOL defaultSet;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation MRSLSegmentedButtonView

#pragma mark - Instance Methods

- (void)layoutSubviews {
    [super layoutSubviews];

    self.buttons =  [_buttons sortedArrayUsingComparator:^NSComparisonResult(UIButton *buttonA, UIButton *buttonB) {
        return [buttonA getX] > [buttonB getX];
    }];
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [button addTarget:self
                   action:@selector(selectedButton:)
         forControlEvents:UIControlEventTouchUpInside];

        if (idx > 0) {
            [button addDefaultBorderForDirections:MRSLBorderWest];
        }
    }];

    [self addDefaultBorderForDirections:MRSLBorderSouth];
}

//  TODO: Make a delegate for this: - (void)segmentButtonView:()segementButtonView hideButtonsInIndexSet:()
- (void)setShouldDisplayProfessionalTabs:(BOOL)shouldDisplayProfessionalTabs {
    if (!_defaultSet) {
        self.defaultSet = YES;
        _shouldDisplayProfessionalTabs = shouldDisplayProfessionalTabs;
        if (!_shouldDisplayProfessionalTabs) {
            CGFloat halfWidth = [self getWidth] * 0.5f;

            UIButton *morselsButton = [_buttons firstObject];
            [morselsButton setX:0.f];
            [morselsButton setWidth:halfWidth];
            [self bringSubviewToFront:morselsButton];

            UIButton *likesButton = [_buttons lastObject];
            [likesButton setX:halfWidth];
            [likesButton setWidth:halfWidth];
            [self bringSubviewToFront:likesButton];
        }
        [self selectedButton:[_buttons firstObject]];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [_buttons enumerateObjectsUsingBlock:^(UIButton *segmentButton, NSUInteger idx, BOOL *stop) {
        if (segmentButton.tag == selectedIndex) {
            [self selectedButton:segmentButton];
            _selectedIndex = selectedIndex;
            *stop = YES;
        }
    }];
}

#pragma mark - Action Methods

- (IBAction)selectedButton:(UIButton *)button {
    button.selected = YES;
    if ([self.delegate respondsToSelector:@selector(segmentedButtonViewDidSelectIndex:)]) {
        [self.delegate segmentedButtonViewDidSelectIndex:button.tag];
    }
    [_buttons enumerateObjectsUsingBlock:^(UIButton *segmentedButton, NSUInteger idx, BOOL *stop) {
        if (![segmentedButton isEqual:button]) {
            segmentedButton.selected = NO;
        }
    }];
}

@end
