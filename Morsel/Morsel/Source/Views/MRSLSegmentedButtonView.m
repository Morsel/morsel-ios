//
//  MRSLSegmentedButtonView.m
//  Morsel
//
//  Created by Javier Otero on 5/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSegmentedButtonView.h"

@interface MRSLSegmentedButtonView ()

@property (nonatomic) BOOL constraintsSet;

@property (strong, nonatomic) NSIndexSet *buttonSet;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation MRSLSegmentedButtonView

#pragma mark - Instance Methods

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_constraintsSet) return;
    self.buttons =  [_buttons sortedArrayUsingComparator:^NSComparisonResult(UIButton *buttonA, UIButton *buttonB) {
        return [buttonA getX] > [buttonB getX];
    }];
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [button addTarget:self
                   action:@selector(selectedButton:)
         forControlEvents:UIControlEventTouchUpInside];

        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    }];

    [self addDefaultBorderForDirections:MRSLBorderSouth];
    [self setupConstraints];
}

- (void)setupConstraints {
    self.constraintsSet = YES;
    if ([self.delegate respondsToSelector:@selector(segmentedButtonViewIndexSetToDisplay)]) {
        self.buttonSet = [self.delegate segmentedButtonViewIndexSetToDisplay];
    }
    if (_buttonSet) self.buttons = [_buttons objectsAtIndexes:_buttonSet];
    NSDictionary *metrics = @{@"height": @50,
                              @"padding": @0};
    UIButton *firstButton = [_buttons firstObject];
    UIButton *previousButton = nil;
    NSInteger idx = 0;
    NSDictionary *views = NSDictionaryOfVariableBindings(firstButton);
    for (UIButton *button in _buttons) {
        NSArray *hConstraints = nil;
        NSArray *vConstraints = nil;

        if ([button isEqual:firstButton]) {
            hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(==padding)-[firstButton]"
                                                                   options:0
                                                                   metrics:metrics
                                                                     views:views];
            vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==padding)-[firstButton(==height)]-(==padding)-|"
                                                                   options:0
                                                                   metrics:metrics
                                                                     views:views];
        } else {
            previousButton = [_buttons objectAtIndex:idx - 1];
            NSDictionary *additionalViews = NSDictionaryOfVariableBindings(previousButton, button, firstButton);
            NSString *hConstraintsString = (idx == [_buttons count] - 1) ? @"[previousButton]-(==padding)-[button(firstButton)]-(==padding)-|" : @"[previousButton]-(==padding)-[button(firstButton)]";
            hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:hConstraintsString
                                                                   options:0
                                                                   metrics:metrics
                                                                     views:additionalViews];
            vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==padding)-[button(==height)]-(==padding)-|"
                                                                   options:0
                                                                   metrics:metrics
                                                                     views:additionalViews];
        }
        [self addConstraints:hConstraints];
        [self addConstraints:vConstraints];

        if (idx > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [button addDefaultBorderForDirections:MRSLBorderWest];
                [self selectedButton:[_buttons firstObject]];
            });
        }
        idx++;
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
