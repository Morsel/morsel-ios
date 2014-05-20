//
//  MRSLSegmentedButtonView.m
//  Morsel
//
//  Created by Javier Otero on 5/20/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLSegmentedButtonView.h"

@interface MRSLSegmentedButtonView ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation MRSLSegmentedButtonView

#pragma mark - Instance Methods

- (void)awakeFromNib {
    [super awakeFromNib];

    [self addCornersWithRadius:4.f];
    self.buttons =  [_buttons sortedArrayUsingComparator:^NSComparisonResult(UIButton *buttonA, UIButton *buttonB) {
        return [buttonA getX] > [buttonB getX];
    }];
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [button addTarget:self
                   action:@selector(selectedButton:)
         forControlEvents:UIControlEventTouchUpInside];
    }];
    [self selectedButton:[_buttons firstObject]];
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
