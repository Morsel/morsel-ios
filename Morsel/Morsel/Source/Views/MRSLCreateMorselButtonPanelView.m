//
//  CreateMorselButtonPanelView.m
//  Morsel
//
//  Created by Javier Otero on 1/29/14.
//  Copyright (c) 2014 Morsel. All rights reserved.
//

#import "MRSLCreateMorselButtonPanelView.h"

@interface MRSLCreateMorselButtonPanelView ()

@property (nonatomic, weak) IBOutlet UIButton *addTextButton;
@property (nonatomic, weak) IBOutlet UIButton *addProgressionButton;
@property (nonatomic, weak) IBOutlet UIButton *addTagButton;
@property (nonatomic, weak) IBOutlet UIButton *addRestaurantButton;
@property (nonatomic, weak) IBOutlet UIButton *addMenuItemButton;
@property (nonatomic, weak) IBOutlet UIView *selectedPipeView;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation MRSLCreateMorselButtonPanelView

- (IBAction)addButtonSelected:(UIButton *)sendingButton {
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop)
    {
        if ([sendingButton isEqual:button]) {
            [sendingButton setEnabled:NO];

            [UIView animateWithDuration:.2f
                             animations:^{
                [_selectedPipeView setX:[sendingButton getX]];
                             }];
        } else {
            [button setEnabled:YES];
        }
    }];

    if ([sendingButton isEqual:_addTextButton]) {
        if ([self.delegate respondsToSelector:@selector(createMorselButtonPanelDidSelectAddText)]) {
            [self.delegate createMorselButtonPanelDidSelectAddText];
        }
    }

    if ([sendingButton isEqual:_addProgressionButton]) {
        if ([self.delegate respondsToSelector:@selector(createMorselButtonPanelDidSelectAddProgression)]) {
            [self.delegate createMorselButtonPanelDidSelectAddProgression];
        }
    }
}

@end
