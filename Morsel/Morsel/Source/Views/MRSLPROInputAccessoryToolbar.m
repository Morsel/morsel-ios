//
//  MRSLPROInputAccessoryToolbar.m
//  Morsel
//
//  Created by Marty Trzpit on 1/29/15.
//  Copyright (c) 2015 Morsel. All rights reserved.
//

#import "MRSLPROInputAccessoryToolbar.h"

@interface MRSLPROInputAccessoryToolbar()

@property (nonatomic) MRSLPROPosition position;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *downButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *upButton;

@end

@implementation MRSLPROInputAccessoryToolbar

#pragma mark - Class Methods

+ (instancetype)defaultInputAccessoryToolbarWithDelegate:(id<MRSLPROInputAccessoryToolbarDelegate>)inputAccessoryToolbarDelegate {
    MRSLPROInputAccessoryToolbar *inputAccessoryToolbar = [[[NSBundle mainBundle] loadNibNamed:@"MRSLPROInputAccessoryToolbar"
                                                                       owner:nil
                                                                     options:nil] firstObject];

    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    [inputAccessoryToolbar.layer addSublayer:borderLayer];

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.5f)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(inputAccessoryToolbar.frame), 0.5f)];

    borderLayer.frame = inputAccessoryToolbar.bounds;
    borderLayer.path = path.CGPath;
    borderLayer.strokeColor = [[UIColor lightGrayColor] CGColor];
    borderLayer.lineWidth = 0.5f;

    inputAccessoryToolbar.inputAccessoryToolbarDelegate = inputAccessoryToolbarDelegate;

    return inputAccessoryToolbar;
}


#pragma mark - Instance Methods

- (void)updatePosition:(MRSLPROPosition)newPosition {
    _position = newPosition;

    switch (_position) {
        case MRSLPROPositionNone:
            self.downButton.enabled = NO;
            self.upButton.enabled = NO;
            break;
        case MRSLPROPositionTop:
            self.downButton.enabled = YES;
            self.upButton.enabled = NO;
            break;
        case MRSLPROPositionBottom:
            self.downButton.enabled = NO;
            self.upButton.enabled = YES;
            break;
        default:
            self.downButton.enabled = YES;
            self.upButton.enabled = YES;
            break;
    }
}


#pragma mark - IBAction

- (IBAction)dismissKeyboardTapped:(id)sender {
    if (self.inputAccessoryToolbarDelegate) {
        [self.inputAccessoryToolbarDelegate inputAccessoryToolbarTappedDismissKeyboardButtonForToolbar:self];
    }
}

- (IBAction)downButtonTapped:(id)sender {
    if (self.inputAccessoryToolbarDelegate) {
        [self.inputAccessoryToolbarDelegate inputAccessoryToolbarTappedDownButtonForToolbar:self];
    }
}

- (IBAction)upButtonTapped:(id)sender {
    if (self.inputAccessoryToolbarDelegate) {
        [self.inputAccessoryToolbarDelegate inputAccessoryToolbarTappedUpButtonForToolbar:self];
    }
}


#pragma mark - Private Methods

- (void)disableButtons {
    self.downButton.enabled = self.upButton.enabled = NO;
}

@end
